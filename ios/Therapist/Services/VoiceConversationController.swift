import Foundation
import Speech
import AVFoundation
import SwiftUI

/// Drives a hands-free, back-and-forth voice conversation:
///
///   listening → (natural pause) → thinking → speaking → listening → …
///
/// The mic is captured with `AVAudioEngine` and transcribed by
/// `SFSpeechRecognizer` (on-device when the device supports it). A turn ends
/// when the transcript stops changing for `silenceInterval` seconds — that is
/// the "natural pause" endpointing. The finalized utterance is handed to
/// `onUtterance`, whose returned text is spoken aloud; when speech finishes the
/// loop resumes listening automatically.
///
/// While the therapist is speaking, the mic is fully torn down so the app never
/// transcribes its own voice.
@MainActor
final class VoiceConversationController: NSObject, ObservableObject {

    enum Phase: Equatable {
        case idle
        case listening
        case thinking
        case speaking
    }

    @Published private(set) var phase: Phase = .idle
    @Published var partialText = ""
    @Published var errorMessage: String?

    /// Returns the assistant's response text to speak (or nil to just resume).
    var onUtterance: ((String) async -> String?)?

    /// Whether the conversation loop is engaged. Driven by `running` so the UI
    /// reflects "on" immediately, even during the brief thinking/speaking phases.
    @Published private(set) var isActive = false

    /// Seconds of silence that ends a turn. Configurable via Settings; defaults
    /// to 3s per user preference.
    private var silenceInterval: TimeInterval {
        let stored = UserDefaults.standard.double(forKey: "voice_silence_seconds")
        return stored > 0 ? stored : 3.0
    }
    private let minCharacters = 2   // ignore stray blips

    /// True from the moment the user enables voice mode until they disable it.
    /// Guards the loop so async callbacks don't restart a stopped session.
    private var running = false

    /// Prevents overlapping/re-entrant calls into beginListening().
    private var isConfiguring = false

    /// Consecutive immediate recognition failures. Capped so a recognizer that
    /// keeps erroring (e.g. no network, on-device model unavailable) can never
    /// spin the main thread into a freeze.
    private var consecutiveFailures = 0
    private let maxConsecutiveFailures = 3

    /// Set true once the recognizer has produced at least one usable transcript,
    /// so we know on-device recognition actually works on this device.
    private var allowOnDevice = true

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?
    private var lastTranscript = ""

    private let speech = SpeechService.shared

    // MARK: - Public control

    /// Requests permissions and starts the conversation loop.
    func start() {
        guard !running else { return }
        errorMessage = nil

        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition isn't available on this device right now."
            return
        }

        requestAuthorization { [weak self] granted in
            guard let self else { return }
            guard granted else {
                self.errorMessage = "Microphone and speech permissions are required for voice mode. Enable them in Settings."
                return
            }
            self.running = true
            self.isActive = true
            self.consecutiveFailures = 0
            self.beginListening()
        }
    }

    /// Stops everything and returns to idle.
    func stop() {
        running = false
        isActive = false
        isConfiguring = false
        consecutiveFailures = 0
        silenceTimer?.invalidate()
        silenceTimer = nil
        teardownAudio()
        speech.stop()
        partialText = ""
        lastTranscript = ""
        phase = .idle
        deactivateSession()
    }

    // MARK: - Authorization

    private func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { speechStatus in
            let speechOK = (speechStatus == .authorized)
            AVAudioApplication.requestRecordPermission { micOK in
                Task { @MainActor in completion(speechOK && micOK) }
            }
        }
    }

    // MARK: - Listening

    private func beginListening() {
        guard running else { return }
        guard !isConfiguring else { return }   // never overlap setup
        isConfiguring = true
        defer { isConfiguring = false }

        // Reset per-turn state.
        partialText = ""
        lastTranscript = ""
        teardownAudio()   // ensure any prior engine/task is gone

        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition isn't available right now."
            stop()
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            // Fully reset the session so switching back from TTS playback is reliable.
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            try session.setCategory(.playAndRecord, mode: .default,
                                    options: [.duckOthers, .defaultToSpeaker, .allowBluetooth])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            // Only force on-device when supported AND it hasn't been proven flaky.
            if allowOnDevice && recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            }
            self.request = request

            let input = audioEngine.inputNode
            let format = input.outputFormat(forBus: 0)
            // A zero sample-rate format means the input hardware isn't ready;
            // bail out gracefully instead of crashing in installTap.
            guard format.sampleRate > 0 else {
                errorMessage = "Microphone isn't ready. Please try again."
                stop()
                return
            }
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.request?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            phase = .listening

            task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }
                Task { @MainActor in
                    if let result {
                        self.handleTranscript(result.bestTranscription.formattedString)
                    }
                    if error != nil {
                        // Only treat as a failure worth retrying if we were
                        // actively listening and captured nothing.
                        if self.running && self.phase == .listening && self.lastTranscript.isEmpty {
                            self.handleRecognitionFailure()
                        }
                    }
                }
            }
        } catch {
            errorMessage = "Could not start listening: \(error.localizedDescription)"
            stop()
        }
    }

    private func handleTranscript(_ text: String) {
        guard running, phase == .listening else { return }
        guard text != lastTranscript else { return }
        consecutiveFailures = 0           // recognizer is working
        lastTranscript = text
        partialText = text
        resetSilenceTimer()
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceInterval,
                                            repeats: false) { [weak self] _ in
            Task { @MainActor in self?.endpoint() }
        }
    }

    /// Handles an immediate recognizer error WITHOUT spinning the main thread.
    /// Retries are delayed and capped; after the cap we stop with a message.
    private func handleRecognitionFailure() {
        teardownAudio()
        guard running else { return }

        consecutiveFailures += 1

        // If on-device recognition keeps failing instantly, drop the on-device
        // requirement and let the system fall back to server recognition.
        if consecutiveFailures == 2 { allowOnDevice = false }

        guard consecutiveFailures <= maxConsecutiveFailures else {
            errorMessage = "Voice recognition isn't responding. Tap the mic to try again, or type your message."
            stop()
            return
        }

        // Delayed retry breaks any tight error loop.
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 600_000_000)
            guard let self, self.running, self.phase != .speaking, self.phase != .thinking else { return }
            self.beginListening()
        }
    }

    // MARK: - Endpointing → send → speak → resume

    private func endpoint() {
        guard running, phase == .listening else { return }
        let utterance = lastTranscript.trimmingCharacters(in: .whitespacesAndNewlines)

        // Too short to be a real turn — keep listening.
        guard utterance.count >= minCharacters else {
            resetSilenceTimer()
            return
        }

        silenceTimer?.invalidate()
        silenceTimer = nil
        teardownAudio()

        phase = .thinking
        let captured = utterance

        Task { [weak self] in
            guard let self else { return }
            let response = await self.onUtterance?(captured)
            await MainActor.run {
                guard self.running, self.phase == .thinking else { return }
                if let response, !response.isEmpty {
                    self.speakThenResume(response)
                } else {
                    self.beginListening()
                }
            }
        }
    }

    private func speakThenResume(_ text: String) {
        phase = .speaking

        let rate    = Float(UserDefaults.standard.double(forKey: "tts_rate"))
        let pitch   = Float(UserDefaults.standard.double(forKey: "tts_pitch"))
        let voiceID = UserDefaults.standard.string(forKey: "tts_voice_id") ?? ""

        speech.speak(
            text,
            rate:  rate  > 0 ? rate  : 0.5,
            pitch: pitch > 0 ? pitch : 1.0,
            voiceID: voiceID,
            onFinish: { [weak self] in
                Task { @MainActor in
                    guard let self, self.running, self.phase == .speaking else { return }
                    // Brief pause so the audio session can flip from playback
                    // back to record cleanly before the mic re-engages.
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    guard self.running else { return }
                    self.beginListening()
                }
            }
        )
    }

    // MARK: - Teardown

    private func teardownAudio() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
