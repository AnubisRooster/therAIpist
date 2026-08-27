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

    /// Bumped by `stop()` and by `speakPrefetched`'s own start, so a stale
    /// queue-playback loop (or a stale in-flight continuation from
    /// `playOne`) can tell it's been superseded and stop advancing instead of
    /// playing a sentence nobody asked for anymore.
    private var speechGeneration = 0
    /// The continuation `playOne` is currently waiting on, so `stop()` can
    /// resume it directly — the engines' own `stop()` clears their playback
    /// callbacks without invoking them, which would otherwise leave this
    /// continuation (and the queue loop awaiting it) suspended forever.
    private var activeSentenceContinuation: CheckedContinuation<Void, Never>?

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
        interruptPendingQueue()
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
        interruptPendingQueue()
        onDevice.stop()
        elevenLabs.stop()
        openAI.stop()
        isSpeakingCloud = false
    }

    /// Resumes (without playing anything) any `playOne` continuation left
    /// over from a `speakPrefetched` queue, and bumps `speechGeneration` so
    /// that queue's driving loop stops advancing. Called before starting any
    /// new utterance so an old queue can never keep running underneath it.
    private func interruptPendingQueue() {
        speechGeneration += 1
        activeSentenceContinuation?.resume()
        activeSentenceContinuation = nil
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
        // Rough mapping: Selfward's on-device rate (0.2...0.7) onto OpenAI's
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

    // MARK: - Sentence-level playback queue

    /// One sentence of a reply queued for ordered playback.
    ///
    /// The public OnDeviceKit 0.1.0 `VoiceLoopKit` ships no sentence-prefetch
    /// API, so we no longer synthesize ahead of generation — each sentence
    /// carries its raw text and is spoken (on-device, or via the active cloud
    /// engine) when its turn in the queue arrives.
    enum PrefetchedSentence: Sendable {
        case text(String)
    }

    /// Captures one completed streamed sentence for later ordered playback by
    /// `speakPrefetched`. No network work happens here; synthesis is deferred
    /// to playback so the call stays cheap and main-thread friendly.
    func prefetchSentence(_ text: String, voiceID: String) -> Task<PrefetchedSentence, Never> {
        Task { PrefetchedSentence.text(text) }
    }

    /// Plays a full reply's sentences in order, using whichever clips
    /// `prefetchSentence` already finished synthesizing and simply waiting on
    /// whichever haven't. Call this only once the caller has confirmed the
    /// reply cleared any safety check — nothing plays until this is called,
    /// no matter how early prefetching started.
    func speakPrefetched(_ tasks: [Task<PrefetchedSentence, Never>],
                        rate: Float = 0.5,
                        pitch: Float = 1.0,
                        voiceID: String = "",
                        onFinish: (() -> Void)? = nil,
                        onError: ((String) -> Void)? = nil) {
        guard !tasks.isEmpty else { onFinish?(); return }
        interruptPendingQueue()
        let generation = speechGeneration
        isSpeakingCloud = (provider != "ondevice")

        Task { [weak self] in
            guard let self else { return }
            for task in tasks {
                guard self.speechGeneration == generation else { return }
                let sentence = await task.value
                guard self.speechGeneration == generation else { return }
                await self.playOne(sentence, rate: rate, pitch: pitch, voiceID: voiceID, onError: onError)
            }
            guard self.speechGeneration == generation else { return }
            self.isSpeakingCloud = false
            onFinish?()
        }
    }

    /// Speaks a single queued sentence's text through the active engine and
    /// suspends until it finishes (or errors, or is interrupted by `stop()`),
    /// so `speakPrefetched`'s loop naturally plays the queue back-to-back.
    private func playOne(_ sentence: PrefetchedSentence, rate: Float, pitch: Float, voiceID: String,
                         onError: ((String) -> Void)?) async {
        let text: String
        switch sentence {
        case .text(let t): text = t
        }

        await withCheckedContinuation { continuation in
            activeSentenceContinuation = continuation
            let finish: () -> Void = { [weak self] in
                guard let self, self.activeSentenceContinuation != nil else { return }
                self.activeSentenceContinuation = nil
                continuation.resume()
            }
            switch provider {
            case "openai":
                speakOpenAI(text, rate: rate, onFinish: finish, onError: { onError?($0) })
            case "elevenlabs":
                speakElevenLabs(text, onFinish: finish, onError: { onError?($0) })
            default:
                onDevice.speak(text, rate: rate, pitch: pitch, voiceID: voiceID, onFinish: finish)
            }
        }
    }
}
