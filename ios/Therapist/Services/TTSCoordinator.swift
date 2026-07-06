import Foundation
import Combine
import VoiceLoopKit

/// Non-LLM cloud service(s) that also need a Keychain-stored API key.
enum TTSKeyProvider: String, APIKeyProvider {
    case elevenlabs

    var keychainKey: String { "tts_key_\(rawValue)" }   // distinct prefix from "llm_key_..."
    var displayName: String { "ElevenLabs" }
    var keyHint: String { "elevenlabs.io/app/settings/api-keys" }
}

/// Routes text-to-speech to on-device `SpeechService` or one of VoiceLoopKit's
/// cloud engines (ElevenLabs, OpenAI), based on the user's `tts_provider`
/// setting. Call sites (ChatView, VoiceConversationController) call `speak(...)`
/// without knowing which engine is active.
///
/// v1 scope: one global provider + one global cloud voice/model for all
/// personas. On-device per-persona voices are untouched, resolved exactly as
/// before by PersonaService/VoicePickerView.
@MainActor
final class TTSCoordinator: ObservableObject {
    static let shared = TTSCoordinator()

    private let onDevice = SpeechService.shared
    private let elevenLabs = ElevenLabsTTSEngine()
    private let openAI = OpenAITTSEngine()
    private var cancellable: AnyCancellable?

    @Published private(set) var isSpeakingCloud = false
    /// Combines on-device + cloud speaking state for a single UI source of truth.
    var isSpeaking: Bool { onDevice.isSpeaking || isSpeakingCloud }

    private var provider: String { UserDefaults.standard.string(forKey: "tts_provider") ?? "ondevice" }

    private init() {
        // SpeechService.isSpeaking is @Published, but callers observe
        // TTSCoordinator instead now — mirror its changes so the mute-button
        // icon still updates for the on-device path.
        cancellable = onDevice.$isSpeaking.sink { [weak self] _ in self?.objectWillChange.send() }
    }

    func speak(_ text: String,
               rate: Float = 0.5,
               pitch: Float = 1.0,
               voiceID: String = "",
               onFinish: (() -> Void)? = nil,
               onError: ((String) -> Void)? = nil) {
        switch provider {
        case "openai":
            speakOpenAI(text, rate: rate, onFinish: onFinish, onError: onError)
        case "elevenlabs":
            speakElevenLabs(text, onFinish: onFinish, onError: onError)
        default:
            onDevice.speak(text, rate: rate, pitch: pitch, voiceID: voiceID, onFinish: onFinish)
        }
    }

    func stop() {
        onDevice.stop()
        elevenLabs.stop()
        openAI.stop()
        isSpeakingCloud = false
    }

    private func speakOpenAI(_ text: String, rate: Float, onFinish: (() -> Void)?, onError: ((String) -> Void)?) {
        guard let apiKey = KeychainService.shared.get(for: LLMProvider.openai), !apiKey.isEmpty else {
            onError?("No OpenAI API key configured. Add one in Settings → Keys & Providers.")
            onFinish?()
            return
        }
        let defaults = UserDefaults.standard
        let voice = defaults.string(forKey: "tts_openai_voice") ?? OpenAITTSEngine.defaultVoice
        let model = defaults.string(forKey: "tts_openai_model") ?? OpenAITTSEngine.defaultModel
        // Rough mapping: therAIpist's on-device rate (0.2...0.7) onto OpenAI's
        // server-side speed (0.25...4.0) — not exact parity, revisit later.
        let speed = Double(rate > 0 ? rate * 2 : 1.0)
        isSpeakingCloud = true
        openAI.speak(text, voice: voice, model: model, apiKey: apiKey, speed: speed,
                     onStart: { _, _ in }, onProgress: { _ in },
                     completion: { [weak self] in self?.isSpeakingCloud = false; onFinish?() },
                     onError: { [weak self] error in
                         self?.isSpeakingCloud = false
                         onError?(error.localizedDescription)
                         onFinish?()
                     })
    }

    private func speakElevenLabs(_ text: String, onFinish: (() -> Void)?, onError: ((String) -> Void)?) {
        guard let apiKey = KeychainService.shared.get(for: TTSKeyProvider.elevenlabs), !apiKey.isEmpty else {
            onError?("No ElevenLabs API key configured. Add one in Settings → Voice & Speech.")
            onFinish?()
            return
        }
        let voiceId = UserDefaults.standard.string(forKey: "tts_elevenlabs_voice_id") ?? ElevenLabsTTSEngine.defaultVoiceId
        isSpeakingCloud = true
        elevenLabs.speak(text, voiceId: voiceId, modelId: ElevenLabsTTSEngine.defaultModelId, apiKey: apiKey,
                         onStart: { _, _ in }, onProgress: { _ in },
                         completion: { [weak self] in self?.isSpeakingCloud = false; onFinish?() },
                         onError: { [weak self] error in
                             self?.isSpeakingCloud = false
                             onError?(error.localizedDescription)
                             onFinish?()
                         })
    }
}
