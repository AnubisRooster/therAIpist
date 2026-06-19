import AVFoundation
import SwiftUI

@MainActor
final class SpeechService: NSObject, ObservableObject {
    // Explicit @MainActor on shared ensures the singleton is created on the main actor.
    @MainActor static let shared = SpeechService()

    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    override private init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    func speak(_ text: String, rate: Float = 0.5, pitch: Float = 1.0) {
        guard !text.isEmpty else { return }
        synthesizer.stopSpeaking(at: .immediate)

        // Activate the audio session each time in case it was deactivated.
        configureAudioSession()

        let cleaned = stripMarkdown(text)
        let utterance = AVSpeechUtterance(string: cleaned)
        utterance.rate        = rate
        utterance.pitchMultiplier = pitch
        utterance.voice       = AVSpeechSynthesisVoice(language: "en-US")
        utterance.preUtteranceDelay = 0.05

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
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
        Task { @MainActor in self.isSpeaking = false }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
