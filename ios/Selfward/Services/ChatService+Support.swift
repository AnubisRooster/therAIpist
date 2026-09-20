import Foundation
import SwiftData

/// Support helpers used by `ChatService.processMessage`, split out so the main
/// service file stays under the lint `file_length` cap. Each block here is
/// either unit-testable in isolation or a small message-formatting helper; no
/// shared mutable state lives in this file.
@MainActor
extension ChatService {

    static func defaultLocalModelExists(_ model: String) -> Bool {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return FileManager.default.fileExists(atPath: docs.appendingPathComponent("models/\(model).gguf").path)
    }

    /// Splits `text` at the first sentence-ending punctuation (`.`, `!`,
    /// `?`) or newline, returning that leading sentence (trimmed) and
    /// everything after it — `nil` if `text` has no complete sentence yet.
    /// Skips stray boundary-only fragments (e.g. leading whitespace before a
    /// stray period) by recursing into the remainder. Pure so it's
    /// unit-testable without any network or LLM involved.
    static func splitFirstSentence(from text: String) -> (sentence: String, rest: String)? {
        guard let boundary = text.firstIndex(where: { ".!?\n".contains($0) }) else { return nil }
        let end = text.index(after: boundary)
        let sentence = String(text[text.startIndex..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
        let rest = String(text[end...])
        // A fragment with no letters/digits (e.g. a stray leading "." with
        // only whitespace before it) isn't a real sentence — skip it rather
        // than firing onSentence with punctuation alone.
        guard sentence.rangeOfCharacter(from: .alphanumerics) != nil else { return splitFirstSentence(from: rest) }
        return (sentence, rest)
    }

    /// Consumes a streamed reply, firing `onSentence` for each complete
    /// sentence as it arrives (merging runs of very short sentences — e.g.
    /// "Ok." — into the next one, so a one- or two-word utterance never
    /// becomes its own separate TTS call), then flushing whatever's left
    /// once the stream ends. Returns the full accumulated reply.
    static func streamAndSplitSentences(_ stream: AsyncThrowingStream<String, Error>,
                                        onSentence: ((String) -> Void)?,
                                        minChunkLength: Int = 20) async throws -> String {
        var full = ""
        var buffer = ""
        var pendingBatch = ""

        for try await delta in stream {
            full += delta
            guard onSentence != nil else { continue }
            buffer += delta
            while let (sentence, rest) = splitFirstSentence(from: buffer) {
                buffer = rest
                pendingBatch = pendingBatch.isEmpty ? sentence : pendingBatch + " " + sentence
                if pendingBatch.count >= minChunkLength {
                    onSentence?(pendingBatch)
                    pendingBatch = ""
                }
            }
        }

        if onSentence != nil {
            let trailing = ((pendingBatch.isEmpty ? "" : pendingBatch + " ") + buffer)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !trailing.isEmpty { onSentence?(trailing) }
        }

        return full
    }

    /// Inserts a guidance message as an assistant bubble so configuration
    /// problems (no API key, no downloaded model) are visible in the chat
    /// rather than silently swallowed.
    func configError(_ message: String, session: SessionModel, context: ModelContext) -> ChatResult {
        context.insert(MessageModel(session: session, role: "assistant", content: message))
        return ChatResult(response: message, isCrisis: false, tokenCount: 0, agentResponse: nil)
    }

    /// History token budget for a provider: cloud models size the budget from
    /// their advertised `context_length` (falling back to a sane default),
    /// unchanged from before; on-device models account for the real cost of
    /// the system prompt, recalled memories, and the current message, not
    /// just a fixed fraction of the window — see
    /// `ConversationCompactor.localHistoryBudget`. This matters most for
    /// Apple Foundation Models, which hard-cap a session's total input at
    /// 4096 tokens (`GenerationError.exceededContextWindowSize`) regardless
    /// of device RAM, unlike llama.cpp's RAM-scaled window.
    func historyTokenBudget(provider: String, model: String,
                            systemPrompt: String = "", memoryContext: String = "",
                            userMessage: String = "") -> Int {
        guard provider == "local" else {
            let knownContextLength = ModelService.cachedContextLength(for: model)
            return ConversationCompactor.historyTokenBudget(
                provider: provider,
                knownContextLength: knownContextLength,
                localContextWindow: nil
            )
        }
        let maxWindow = model == "apple-foundation" ? appleFoundationMaxInputTokens : LocalLLMEngine.contextWindow()
        return ConversationCompactor.localHistoryBudget(
            maxWindow: maxWindow,
            systemPrompt: systemPrompt,
            memoryContext: memoryContext,
            userMessage: userMessage
        )
    }

    /// Summarizes a block of older turns into a compact rolling recap. Uses the
    /// same injected backend as the main reply so mocks stay consistent in
    /// tests, and runs before the main generation so the engine is idle.
    static func summarizeBlock(_ block: String,
                               using llm: LLMSending,
                               provider: String,
                               model: String) async throws -> String {
        let instruction = """
        You produce a rolling recap of a long therapy conversation so earlier context is kept.
        Fold in what the client shared: themes, facts, names, events, feelings, and commitments.

        Keep the summary under 150 words. Write in the third person as a session recap.
        Do not address the client. Skip filler openers such as 'The client discussed'.
        """
        let request = [
            LLMMessage(role: "system", content: instruction),
            LLMMessage(role: "user", content: block)
        ]
        return try await llm.sendMessage(provider: provider, model: model, messages: request)
    }
}
