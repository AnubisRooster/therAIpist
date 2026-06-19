import AVFoundation
import SwiftUI

@MainActor
final class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()

    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    override private init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, rate: Float = 0.5, pitch: Float = 1.0) {
        guard !text.isEmpty else { return }
        synthesizer.stopSpeaking(at: .immediate)

        let cleaned = stripMarkdown(text)
        let utterance = AVSpeechUtterance(string: cleaned)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.preUtteranceDelay = 0.1

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .word)
        isSpeaking = false
    }

    // Strip common markdown so the synthesizer doesn't read "asterisk asterisk"
    private func stripMarkdown(_ text: String) -> String {
        var s = text
        s = s.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "$1", options: .regularExpression)
        s = s.replacingOccurrences(of: #"\*(.+?)\*"#, with: "$1", options: .regularExpression)
        s = s.replacingOccurrences(of: #"#+\s"#, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: #"^\s*[-•]\s"#, with: "", options: [.regularExpression, .anchored])
        s = s.replacingOccurrences(of: "\n- ", with: ". ")
        s = s.replacingOccurrences(of: "\n• ", with: ". ")
        return s
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
