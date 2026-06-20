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

    /// A finalized spoken turn. The unique `id` guarantees `onChange` fires even
    /// when two consecutive utterances have identical text.
    struct VoiceUtterance: Equatable {
        let id = UUID()
        let text: String
    }

    @Published private(set) var phase: Phase = .idle
    @Published var partialText = ""
    @Published var errorMessage: String?

    /// A captured turn waiting to be processed by the view layer. The view
    /// observes this, runs the chat pipeline on its live ModelContext (so the
    /// message bubbles render exactly like typed messages), then calls
    /// `deliverResponse(_:)` with the reply to speak.
    @Published private(set) var pendingUtterance: VoiceUtterance?

    /// Whether the conversation loop is engaged. Driven by `running` so the UI
    /// reflects "on" immediately, even during the brief thinking/speaking phases.
    @Published private(set) var isActive = false

    /// Seconds of trailing silence that ends a turn. Configurable via Settings
    /// (2–12s). Defaults to 5s — long enough to think between sentences without
    /// the turn being cut off mid-thought.
    private var silenceInterval: TimeInterval {
        let stored = UserDefaults.standard.double(forKey: "voice_silence_seconds")
        guard stored > 0 else { return 5.0 }
        return min(max(stored, 2.0), 12.0)
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

    /// Right after the mic permission is granted the input node can report a
    /// zero sample-rate for a moment. Retry a few times before giving up.
    private var micNotReadyRetries = 0
    private let maxMicNotReadyRetries = 5

    /// Set true once the recognizer has produced at least one usable transcript,
    /// so we know on-device recognition actually works on this device.
    private var allowOnDevice = true

    /// Voice the spoken replies should use. Set by the view to the active
    /// persona's voice; falls back to the global TTS voice when nil/empty.
    var preferredVoiceID: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    /// Recreated on every listen so its input node materializes against the
    /// already-active recording session. Reusing one engine caches a 0 Hz input
    /// format (AURemoteIO -10851) when the node is first touched before the
    /// session is configured.
    private var audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?
    private var lastTranscript = ""

    /// Bumped every time a new recognition task is created. A cancelled
    /// SFSpeechRecognitionTask can still deliver one trailing callback after
    /// `cancel()`; callbacks carrying a stale generation are ignored so a
    /// superseded task can't trigger a redundant restart.
    private var recognitionGeneration = 0

    /// Finalized text from earlier recognition segments in the CURRENT turn.
    /// SFSpeechRecognizer terminates a recognition request after ~1 minute, so a
    /// long monologue is captured as several segments stitched together here.
    private var committedText = ""

    private let speech = SpeechService.shared

    /// Joins committed text from prior segments with the live segment. Pure and
    /// static so it can be unit-tested without audio hardware.
    static func combinedTranscript(committed: String, segment: String) -> String {
        if committed.isEmpty { return segment }
        if segment.isEmpty { return committed }
        return committed + " " + segment
    }

    /// Spoken phrases that mean "send what I've said so far".
    private static let sendCommands = [
        "send message", "send the message", "send it now", "send it",
        "send now", "send",
    ]

    /// Detects a trailing "send" voice command.
    /// - Returns: `nil` if no command; `""` if the command was the only thing
    ///   said (nothing to send); otherwise the message with the command stripped.
    /// Pure and static for unit testing.
    static func detectSendCommand(in text: String) -> String? {
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = trimmed.last, last.isPunctuation { trimmed.removeLast() }
        let lower = trimmed.lowercased()

        for cmd in sendCommands {
            if lower == cmd { return "" }
            let suffix = " " + cmd
            if lower.hasSuffix(suffix) {
                let end = trimmed.index(trimmed.endIndex, offsetBy: -suffix.count)
                var msg = String(trimmed[..<end])
                while let last = msg.last, last.isWhitespace || last.isPunctuation { msg.removeLast() }
                return msg
            }
        }
        return nil
    }

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
        micNotReadyRetries = 0
        pendingUtterance = nil
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

    /// - Parameter continuing: when `true` this is a segment restart mid-turn
    ///   (SFSpeechRecognizer's ~1-minute cap was hit while the user was still
    ///   speaking).  The audio engine and its tap stay running — only the
    ///   recognition request is replaced — so there is no audio gap and no
    ///   zero-byte tap callbacks.  When `false` the full engine is (re)created.
    private func beginListening(continuing: Bool = false) {
        guard running else { return }
        guard !isConfiguring else { return }
        isConfiguring = true
        defer { isConfiguring = false }

        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition isn't available right now."
            stop()
            return
        }

        if continuing {
            // ── Segment restart ──────────────────────────────────────────────
            // Keep the engine and its tap alive; just swap the recognition
            // request.  This avoids any audio gap and prevents the
            // mBuffers[0].mDataByteSize == 0 warnings caused by tearing down
            // and recreating the engine while the mic is hot.
            task?.cancel()
            task = nil
            request?.endAudio()
            request = nil
        } else {
            // ── Fresh start ──────────────────────────────────────────────────
            partialText = ""
            lastTranscript = ""
            committedText = ""
            teardownAudio()   // stop any prior engine / task

            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord, mode: .default,
                                        options: [.defaultToSpeaker, .allowBluetooth])
                // Hint a hardware rate so the input route settles on the first
                // activation (reduces transient AURemoteIO -10851 log).
                try? session.setPreferredSampleRate(48_000)
                try session.setActive(true, options: .notifyOthersOnDeactivation)

                // Create a fresh engine AFTER the session is active so its input
                // node reads the real hardware format instead of a cached 0 Hz value.
                audioEngine = AVAudioEngine()
                let input = audioEngine.inputNode
                let format = input.inputFormat(forBus: 0)

                guard format.sampleRate > 0, format.channelCount > 0 else {
                    if micNotReadyRetries < maxMicNotReadyRetries {
                        micNotReadyRetries += 1
                        Task { @MainActor [weak self] in
                            try? await Task.sleep(nanoseconds: 250_000_000)
                            guard let self, self.running else { return }
                            self.beginListening(continuing: false)
                        }
                    } else {
                        micNotReadyRetries = 0
                        errorMessage = "Microphone couldn't start. Make sure no other app is using it, then tap the mic again."
                        stop()
                    }
                    return
                }
                micNotReadyRetries = 0
                errorMessage = nil

                input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                    // Skip empty buffers that arrive as the audio pipeline warms
                    // up — appending them causes AVAudioBuffer mDataByteSize == 0
                    // warnings and can confuse the recognizer.
                    guard let pcm = buffer as? AVAudioPCMBuffer,
                          pcm.frameLength > 0 else { return }
                    self?.request?.append(pcm)
                }

                audioEngine.prepare()
                try audioEngine.start()
            } catch {
                errorMessage = "Could not start listening: \(error.localizedDescription)"
                stop()
                return
            }
        }

        // ── Start a new recognition request (shared by both paths) ───────────
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if allowOnDevice && recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        self.request = request
        phase = .listening

        recognitionGeneration += 1
        let generation = recognitionGeneration
        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                // Ignore trailing callbacks from a task we've already replaced.
                guard generation == self.recognitionGeneration else { return }
                var wasFinal = false
                if let result {
                    wasFinal = result.isFinal
                    self.handleTranscript(result.bestTranscription.formattedString,
                                          isFinal: result.isFinal)
                }
                // If isFinal was true, handleTranscript already scheduled a
                // restart — don't also call handleSegmentEnd or we get a
                // double-restart that creates an audio gap mid-monologue.
                if error != nil, !wasFinal {
                    self.handleSegmentEnd(hadResult: result != nil)
                }
            }
        }
    }

    private func handleTranscript(_ segment: String, isFinal: Bool) {
        guard running, phase == .listening else { return }
        let full = Self.combinedTranscript(committed: committedText, segment: segment)

        // "…send" voice command → finalize and send immediately.
        if let stripped = Self.detectSendCommand(in: full) {
            consecutiveFailures = 0
            guard !stripped.isEmpty else {
                // Only the word "send" was heard — nothing to send; keep listening.
                lastTranscript = ""
                committedText = ""
                partialText = ""
                resetSilenceTimer()
                return
            }
            lastTranscript = stripped
            committedText = stripped
            partialText = stripped
            endpoint()
            return
        }

        if !full.isEmpty, full != lastTranscript {
            consecutiveFailures = 0       // recognizer is working
            lastTranscript = full
            partialText = full
            resetSilenceTimer()
        }

        // A final result means the recognizer reached its OWN endpoint — either a
        // natural pause or its ~1-minute cap. That is NOT the end of the user's
        // turn: only `silenceInterval` of true trailing silence ends a turn.
        if isFinal {
            if !segment.isEmpty {
                committedText = full
                // The user just finished speaking a sentence; re-arm the silence
                // timer so the pause-driven finalize + restart cycle never eats
                // into the silence budget and cuts the turn off early.
                resetSilenceTimer()
            }
            // ALWAYS restart so we keep listening for the rest of the turn (the
            // recognizer won't accept more audio after a final result). The
            // silence timer remains the sole arbiter of when the turn ends.
            restartSegment()
        }
    }

    /// A recognition segment ended (final or error). If we already have text for
    /// this turn, keep the turn alive by restarting; otherwise treat it as a
    /// genuine start failure with capped, delayed retries.
    private func handleSegmentEnd(hadResult: Bool) {
        guard running, phase == .listening else { return }
        if lastTranscript.isEmpty && committedText.isEmpty {
            handleRecognitionFailure()
        } else {
            committedText = lastTranscript
            restartSegment()
        }
    }

    /// Starts a new recognition segment for the current turn, preserving all
    /// committed text.  The audio engine stays running — no gap, no empty
    /// tap buffers — only the recognition request is replaced.
    private func restartSegment() {
        guard running, phase == .listening else { return }
        beginListening(continuing: true)
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
        committedText = ""
        partialText = utterance

        // Hand the turn to the view layer; it will call deliverResponse(_:).
        pendingUtterance = VoiceUtterance(text: utterance)
    }

    /// Called by the view after it has processed the utterance and produced a
    /// reply. Speaks the reply (then resumes listening), or resumes immediately
    /// when there's nothing to say.
    func deliverResponse(_ text: String?) {
        guard running, phase == .thinking else { return }
        if let text, !text.isEmpty {
            speakThenResume(text)
        } else {
            beginListening()
        }
    }

    private func speakThenResume(_ text: String) {
        phase = .speaking

        let rate    = Float(UserDefaults.standard.double(forKey: "tts_rate"))
        let pitch   = Float(UserDefaults.standard.double(forKey: "tts_pitch"))
        let personaVoice = preferredVoiceID ?? ""
        let voiceID = personaVoice.isEmpty
            ? (UserDefaults.standard.string(forKey: "tts_voice_id") ?? "")
            : personaVoice

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

    /// Stops the current spoken reply and returns to listening. Used when the
    /// user taps the speaker control mid-reply so the voice loop doesn't stall
    /// in the `.speaking` phase (the dropped TTS `onFinish` never fires).
    func skipSpeaking() {
        guard running, phase == .speaking else { return }
        speech.stop()
        beginListening()
    }

    // MARK: - Teardown

    private func teardownAudio() {
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        if audioEngine.isRunning { audioEngine.stop() }
        // removeTap is idempotent; safe to call even if no tap is installed.
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
