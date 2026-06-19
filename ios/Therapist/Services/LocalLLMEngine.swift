import Foundation
import LLM

// MARK: - LocalLLMEngine

/// Manages a single loaded GGUF model and serves inference requests via LLM.swift.
///
/// The engine keeps exactly one model in memory at a time.  Loading is done in a
/// background task so the main thread stays responsive.  Inference is async and
/// runs inside LLM.swift's `LLMCore` actor (non-main thread), so the engine is
/// safe to call from @MainActor contexts without blocking the UI.
@MainActor
final class LocalLLMEngine: ObservableObject {
    static let shared = LocalLLMEngine()

    @Published private(set) var loadedModelID: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isGenerating = false
    @Published private(set) var loadError: String?

    private var llm: LLM?

    private init() {}

    // MARK: - Lifecycle

    /// Loads the GGUF at `url` for `id`.  No-ops if `id` is already loaded.
    func loadModel(id: String, url: URL) async {
        guard loadedModelID != id else { return }
        isLoading = true
        loadError = nil
        unload()

        // Use the model-specific stop sequence but NO template at init time.
        // LLM.swift registers the stop sequence via an async Task inside init,
        // and we need it to complete before the first getCompletion() call.
        // We handle the stop sequence registration explicitly below.
        let stopSeq = Self.stopSequence(for: id)

        // llama_model_load_from_file is synchronous and CPU-bound — run off main.
        let loaded: LLM? = await Task.detached(priority: .userInitiated) {
            LLM(from: url, stopSequence: stopSeq, maxTokenCount: 4096)
        }.value

        if let loaded {
            loaded.postprocess = { _ in }  // suppress default stdout print
            llm = loaded
            loadedModelID = id

            // LLM.swift registers the stop sequence via an unstructured `Task` inside
            // its init.  Wait long enough for that task to complete before the first
            // inference call; without this delay the model runs to maxTokenCount
            // (4096 tokens) because no stop sequence is installed yet.
            try? await Task.sleep(nanoseconds: 300_000_000)  // 300 ms
        } else {
            loadError = "Failed to load \(id). The file may be corrupt or unsupported."
        }
        isLoading = false
    }

    /// Releases the model from memory.
    func unload() {
        llm = nil
        loadedModelID = nil
        loadError = nil
    }

    // MARK: - Inference

    /// Generates a response for the given message list.
    ///
    /// Throws `LocalLLMError.busy` if a generation is already in progress — the
    /// caller should show a "still thinking…" message rather than queuing another
    /// inference request.
    func generate(modelID: String, messages: [LLMMessage]) async throws -> String {
        guard let llm else { throw LocalLLMError.notLoaded }
        guard !isGenerating else { throw LocalLLMError.busy }

        isGenerating = true
        defer { isGenerating = false }

        guard !messages.isEmpty else { return "" }

        let systemContent = messages.first(where: { $0.role == "system" })?.content ?? ""
        let nonSystem = messages.filter { $0.role != "system" }

        // Build prior chat history and extract the final (unanswered) user message.
        var history: [Chat] = []
        var lastUserMessage = ""

        var i = 0
        while i < nonSystem.count {
            let msg = nonSystem[i]
            if msg.role == "user" {
                let nextIndex = i + 1
                if nextIndex < nonSystem.count && nonSystem[nextIndex].role == "assistant" {
                    history.append((role: .user, content: msg.content))
                    history.append((role: .bot, content: nonSystem[nextIndex].content))
                    i += 2
                } else {
                    lastUserMessage = msg.content
                    i += 1
                }
            } else {
                i += 1
            }
        }

        if lastUserMessage.isEmpty {
            lastUserMessage = nonSystem.last?.content ?? ""
        }

        // Update ONLY the preprocess closure — do NOT set `llm.template = ...`.
        // The template property's didSet fires an async Task to register the stop
        // sequence on LLMCore.  If getCompletion() starts before that Task runs,
        // the model has no stop sequence and generates all 4096 tokens (looks like
        // a lockup).  Updating only `preprocess` is synchronous and safe.
        let template = Self.template(for: modelID, systemPrompt: systemContent)
        llm.preprocess = template.preprocess

        let prompt = llm.preprocess(lastUserMessage, history)
        let response = await llm.getCompletion(from: prompt)
        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Template helpers

    static func template(for modelID: String, systemPrompt: String) -> Template {
        let sysOrNil: String? = systemPrompt.isEmpty ? nil : systemPrompt
        if modelID.hasPrefix("llama") {
            return Template(
                system: (
                    "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n",
                    "<|eot_id|>\n"
                ),
                user: (
                    "<|start_header_id|>user<|end_header_id|>\n\n",
                    "<|eot_id|>\n"
                ),
                bot: (
                    "<|start_header_id|>assistant<|end_header_id|>\n\n",
                    "<|eot_id|>\n"
                ),
                stopSequence: "<|eot_id|>",
                systemPrompt: sysOrNil
            )
        } else if modelID.hasPrefix("phi") {
            return Template(
                system: ("<|system|>\n", "<|end|>\n"),
                user: ("<|user|>\n", "<|end|>\n"),
                bot: ("<|assistant|>\n", "<|end|>\n"),
                stopSequence: "<|end|>",
                systemPrompt: sysOrNil
            )
        }
        return .chatML(sysOrNil)
    }

    static func stopSequence(for modelID: String) -> String {
        if modelID.hasPrefix("llama") { return "<|eot_id|>" }
        if modelID.hasPrefix("phi")   { return "<|end|>" }
        return "<|im_end|>"  // chatML fallback
    }
}

// MARK: - Errors

enum LocalLLMError: LocalizedError {
    case notLoaded
    case loadFailed(String)
    case busy

    var errorDescription: String? {
        switch self {
        case .notLoaded:
            return "No local model is loaded. Download and select a model in Settings."
        case .loadFailed(let name):
            return "Failed to load \(name). Try deleting and re-downloading it."
        case .busy:
            return "The model is still generating a response. Please wait."
        }
    }
}
