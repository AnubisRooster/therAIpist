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
    @Published private(set) var partialText = ""
    @Published var errorMessage: String?

    /// Returns the assistant's response text to speak (or nil to just resume).
    var onUtterance: ((String) async -> String?)?

    var isActive: Bool { phase != .idle }

    // Tuning
    private let silenceInterval: TimeInterval = 1.6   // pause that ends a turn
    private let minCharacters = 2                     // ignore stray blips

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
        guard phase == .idle else { return }
        errorMessage = nil

        requestAuthorization { [weak self] granted in
            guard let self else { return }
            guard granted else {
                self.errorMessage = "Microphone and speech permissions are required for voice mode. Enable them in Settings."
                self.phase = .idle
                return
            }
            self.beginListening()
        }
    }

    /// Stops everything and returns to idle.
    func stop() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        teardownAudio()
        speech.stop()
        partialText = ""
        lastTranscript = ""
        phase = .idle
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
        guard isActiveOrStarting else { return }

        // Reset per-turn state.
        partialText = ""
        lastTranscript = ""

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default,
                                    options: [.duckOthers, .defaultToSpeaker, .allowBluetooth])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            if recognizer?.supportsOnDeviceRecognition == true {
                request.requiresOnDeviceRecognition = true
            }
            self.request = request

            let input = audioEngine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.request?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            phase = .listening

            task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }
                Task { @MainActor in
                    if let result {
                        self.handleTranscript(result.bestTranscription.formattedString)
                    }
                    if error != nil {
                        // Common when we end audio ourselves; only surface if unexpected.
                        if self.phase == .listening && self.lastTranscript.isEmpty {
                            self.handleRecognitionFailure()
                        }
                    }
                }
            }
        } catch {
            errorMessage = "Could not start listening: \(error.localizedDescription)"
            phase = .idle
        }
    }

    /// True while we intend to keep the loop running (active, or transitioning
    /// back into listening from speaking).
    private var isActiveOrStarting: Bool { phase != .idle }

    private func handleTranscript(_ text: String) {
        guard phase == .listening else { return }
        guard text != lastTranscript else { return }
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

    private func handleRecognitionFailure() {
        teardownAudio()
        // Soft retry: resume listening once if still active.
        if phase != .idle {
            beginListening()
        }
    }

    // MARK: - Endpointing → send → speak → resume

    private func endpoint() {
        guard phase == .listening else { return }
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
                guard self.phase == .thinking else { return }   // stopped meanwhile
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
                    guard let self, self.phase == .speaking else { return }
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
}
