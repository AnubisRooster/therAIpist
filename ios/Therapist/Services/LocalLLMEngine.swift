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

        let template = Self.template(for: id, systemPrompt: "")

        // llama_model_load_from_file is synchronous and CPU-bound — run off main.
        let loaded: LLM? = await Task.detached(priority: .userInitiated) {
            LLM(from: url, template: template, maxTokenCount: 4096)
        }.value

        if let loaded {
            loaded.postprocess = { _ in }  // suppress default print to stdout
            llm = loaded
            loadedModelID = id
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
    /// The system message (role == "system") is extracted and injected into the
    /// model template; the remaining messages are formatted as the conversation
    /// history with the last user turn as the prompt.
    func generate(modelID: String, messages: [LLMMessage]) async throws -> String {
        guard let llm else { throw LocalLLMError.notLoaded }
        guard !messages.isEmpty else { return "" }

        let systemContent = messages.first(where: { $0.role == "system" })?.content ?? ""
        let nonSystem = messages.filter { $0.role != "system" }

        // Build prior chat history and extract the final (unanswered) user message.
        // `Chat` = (role: Role, content: String) where Role is a top-level enum in LLM module.
        var history: [Chat] = []
        var lastUserMessage = ""

        var i = 0
        while i < nonSystem.count {
            let msg = nonSystem[i]
            if msg.role == "user" {
                let nextIndex = i + 1
                if nextIndex < nonSystem.count && nonSystem[nextIndex].role == "assistant" {
                    // Completed exchange → history.
                    history.append((role: .user, content: msg.content))
                    history.append((role: .bot, content: nonSystem[nextIndex].content))
                    i += 2
                } else {
                    // Trailing, unanswered user message.
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

        // Update template with the real system prompt for this call.
        let updatedTemplate = Self.template(for: modelID, systemPrompt: systemContent)
        llm.template = updatedTemplate

        // Build the full formatted prompt from history + current user turn.
        let prompt = llm.preprocess(lastUserMessage, history)
        let response = await llm.getCompletion(from: prompt)
        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Template helpers

    /// Returns an LLM.swift `Template` appropriate for the given model ID.
    static func template(for modelID: String, systemPrompt: String) -> Template {
        let sysOrNil: String? = systemPrompt.isEmpty ? nil : systemPrompt
        if modelID.hasPrefix("llama") {
            // Llama 3.x instruct format.
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
            // Phi-3.5-mini instruct format.
            return Template(
                system: ("<|system|>\n", "<|end|>\n"),
                user: ("<|user|>\n", "<|end|>\n"),
                bot: ("<|assistant|>\n", "<|end|>\n"),
                stopSequence: "<|end|>",
                systemPrompt: sysOrNil
            )
        }
        // Fallback: chatML.
        return .chatML(sysOrNil)
    }
}

// MARK: - Errors

enum LocalLLMError: LocalizedError {
    case notLoaded
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .notLoaded:
            return "No local model is loaded. Download and select a model in Settings."
        case .loadFailed(let name):
            return "Failed to load \(name). Try deleting and re-downloading it."
        }
    }
}
