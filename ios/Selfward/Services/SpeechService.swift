import AVFoundation
import SwiftUI

@MainActor
final class SpeechService: NSObject, ObservableObject {
    // Explicit @MainActor on shared ensures the singleton is created on the main actor.
    @MainActor static let shared = SpeechService()

    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    /// Called once when the current utterance finishes naturally. Cleared when a
    /// new utterance starts or when speech is cancelled, so it never fires for an
    /// interrupted utterance.
    private var onFinish: (() -> Void)?

    override private init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    /// Speak `text` with the given rate, pitch, and optional voice identifier.
    /// If `voiceID` is empty the device's default en-US voice is used.
    func speak(_ text: String,
               rate: Float = 0.5,
               pitch: Float = 1.0,
               voiceID: String = "",
               onFinish: (() -> Void)? = nil) {
        guard !text.isEmpty else { onFinish?(); return }

        // Clear any pending callback BEFORE interrupting, so the resulting
        // didCancel doesn't fire a stale completion.
        self.onFinish = nil
        synthesizer.stopSpeaking(at: .immediate)

        // Activate the audio session each time in case it was deactivated.
        configureAudioSession()

        let cleaned = stripMarkdown(text)
        let utterance = AVSpeechUtterance(string: cleaned)
        utterance.rate            = rate
        utterance.pitchMultiplier = pitch
        utterance.preUtteranceDelay = 0.05

        if voiceID.isEmpty {
            // No explicit choice: use the best-quality English voice installed.
            utterance.voice = Self.bestAvailableVoice()
        } else {
            utterance.voice = AVSpeechSynthesisVoice(identifier: voiceID)
                           ?? Self.bestAvailableVoice()
        }

        self.onFinish = onFinish
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// The display name of the currently stored voice. Falls back to the best
    /// installed voice's name when nothing is explicitly selected.
    static func voiceName(for identifier: String) -> String {
        if !identifier.isEmpty,
           let voice = AVSpeechSynthesisVoice(identifier: identifier) {
            return voice.name
        }
        return bestAvailableVoice()?.name ?? "Default"
    }

    /// Highest-quality English voice installed: Premium → Enhanced → Default.
    static func bestAvailableVoice() -> AVSpeechSynthesisVoice? {
        let english = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
        let best = english.max { a, b in a.quality.rawValue < b.quality.rawValue }
        return best ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    /// True when the device only has low-quality (compact/default) voices,
    /// i.e. the user has not downloaded any Enhanced or Premium voices.
    static func hasOnlyCompactVoices() -> Bool {
        let english = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
        return !english.contains { $0.quality == .enhanced || $0.quality == .premium }
    }

    func stop() {
        // A manual stop is an interruption, not a natural finish — drop the callback.
        onFinish = nil
        synthesizer.stopSpeaking(at: .word)
        isSpeaking = false
    }

    // MARK: - Audio session

    /// Configure for spoken audio: plays through the speaker, bypasses silent switch,
    /// and ducks any background music.
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // Non-fatal: synthesizer may still work in default session
            print("[SpeechService] audio session error: \(error)")
        }
    }

    // MARK: - Markdown stripping

    /// Strip common markdown tokens so the synthesizer reads clean prose.
    private func stripMarkdown(_ text: String) -> String {
        var s = text
        // Bold / italic
        s = s.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "$1", options: .regularExpression)
        s = s.replacingOccurrences(of: #"\*(.+?)\*"#,     with: "$1", options: .regularExpression)
        s = s.replacingOccurrences(of: #"_(.+?)_"#,       with: "$1", options: .regularExpression)
        // Headers
        s = s.replacingOccurrences(of: #"(?m)^#+\s+"#, with: "", options: .regularExpression)
        // Bullet lists → natural pause
        s = s.replacingOccurrences(of: #"(?m)^\s*[-•*]\s+"#, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: "\n",  with: ". ")
        // Collapse repeated punctuation
        s = s.replacingOccurrences(of: #"\.\s*\."#, with: ".", options: .regularExpression)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Delegate

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            let cb = self.onFinish
            self.onFinish = nil
            cb?()
        }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
