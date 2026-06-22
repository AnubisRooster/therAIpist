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

    /// Tracks an in-flight load so concurrent callers serialize instead of
    /// racing (which could leave two half-loaded models or unload one mid-use).
    private var loadingTask: Task<Void, Never>?

    private init() {}

    // MARK: - Lifecycle

    /// Loads the GGUF at `url` for `id`.  No-ops if `id` is already loaded.
    /// Concurrent calls are serialized: a second call waits for the in-flight
    /// load to finish rather than starting a competing one.
    func loadModel(id: String, url: URL) async {
        if loadedModelID == id, llm != nil { return }

        // If a load is already running, wait for it before deciding what to do.
        if let loadingTask {
            await loadingTask.value
            if loadedModelID == id, llm != nil { return }
        }

        let task = Task { await self.performLoad(id: id, url: url) }
        loadingTask = task
        await task.value
        loadingTask = nil
    }

    private func performLoad(id: String, url: URL) async {
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
        // maxTokenCount sets BOTH the context window AND the generation cap in
        // LLM.swift. 2048 keeps memory low and bounds a runaway generation to a
        // few minutes worst case (the 90 s timeout in generate() catches it first),
        // while leaving ample room for our capped prompt (~800 tokens).
        let loaded: LLM? = await Task.detached(priority: .userInitiated) {
            LLM(from: url, stopSequence: stopSeq, maxTokenCount: 2048)
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
        isGenerating = false
    }

    /// Cancels in-progress generation. Safe to call from the Stop button.
    func stopGeneration() {
        llm?.stop()
        isGenerating = false
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

        // Race inference against a 90-second hard timeout.
        // If the prompt overflows the model's context window, llama.cpp may
        // silently stall; this ensures the engine always recovers.
        let response = try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                await llm.getCompletion(from: prompt)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: 90_000_000_000)  // 90 s
                return "__TIMEOUT__"
            }
            // First result wins.
            let first = try await group.next() ?? ""
            group.cancelAll()
            if first == "__TIMEOUT__" {
                llm.stop()
                throw LocalLLMError.timeout
            }
            return first
        }

        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)

        // LLM.swift returns "" when prepareContext fails (e.g. the prompt exceeds
        // the context window) — surface that as a clear, recoverable error rather
        // than an empty chat bubble. "LLM is being used" is its busy sentinel.
        if trimmed.isEmpty || trimmed == "LLM is being used" {
            throw LocalLLMError.timeout
        }

        return trimmed
    }

    // MARK: - Template helpers

    static func template(for modelID: String, systemPrompt: String) -> Template {
        let sysOrNil: String? = systemPrompt.isEmpty ? nil : systemPrompt
        if modelID.hasPrefix("llama") {
            // NOTE: do NOT include "<|begin_of_text|>" here — LLM.swift's encode()
            // already prepends the BOS token. Adding it again produces a double-BOS
            // that breaks Llama 3's generation (the model fails to emit <|eot_id|>
            // and runs to the token cap, which looks like a freeze).
            return Template(
                system: (
                    "<|start_header_id|>system<|end_header_id|>\n\n",
                    "<|eot_id|>"
                ),
                user: (
                    "<|start_header_id|>user<|end_header_id|>\n\n",
                    "<|eot_id|>"
                ),
                bot: (
                    "<|start_header_id|>assistant<|end_header_id|>\n\n",
                    "<|eot_id|>"
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
        } else if modelID.hasPrefix("gemma") {
            // Gemma 2 instruct format uses <start_of_turn> / <end_of_turn>.
            // Gemma has no dedicated system role, so the system prompt is emitted
            // ONCE as a leading user turn via the `system` slot (LLM.swift renders
            // system.prefix + systemPrompt + system.suffix a single time). We must
            // NOT bake the system prompt into `user.prefix`, because that prefix is
            // re-applied to every user turn and would repeat the whole prompt each
            // round.
            return Template(
                system: ("<start_of_turn>user\n", "<end_of_turn>\n"),
                user: ("<start_of_turn>user\n", "<end_of_turn>\n"),
                bot: ("<start_of_turn>model\n", "<end_of_turn>\n"),
                stopSequence: "<end_of_turn>",
                systemPrompt: sysOrNil
            )
        }
        // chatML fallback — Qwen 2.5, SmolLM2, and anything else using
        // <|im_start|> / <|im_end|> markers.
        return .chatML(sysOrNil)
    }

    static func stopSequence(for modelID: String) -> String {
        if modelID.hasPrefix("llama")  { return "<|eot_id|>" }
        if modelID.hasPrefix("phi")    { return "<|end|>" }
        if modelID.hasPrefix("gemma")  { return "<end_of_turn>" }
        return "<|im_end|>"  // chatML fallback (Qwen, SmolLM2, …)
    }
}

// MARK: - Errors

enum LocalLLMError: LocalizedError {
    case notLoaded
    case loadFailed(String)
    case busy
    case timeout

    var errorDescription: String? {
        switch self {
        case .notLoaded:
            return "No local model is loaded. Download and select a model in Settings."
        case .loadFailed(let name):
            return "Failed to load \(name). Try deleting and re-downloading it."
        case .busy:
            return "The model is still generating a response. Please wait."
        case .timeout:
            return "Response timed out. The prompt may be too long for this model's context window. Try the 1B model for faster responses."
        }
    }
}
