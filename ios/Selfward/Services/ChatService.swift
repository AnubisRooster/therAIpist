import Foundation
import SwiftData

/// All SwiftData reads/writes here run on the main actor because the
/// `ModelContext` passed in is the app's main context, which is NOT safe to use
/// off the main thread. The expensive work (network / on-device inference) is
/// performed behind `await` calls that suspend without blocking the UI.
@MainActor
final class ChatService {
    static let shared = ChatService()

    private let safety = SafetyService.shared
    private let llm: LLMSending
    private let therapy = TherapyService.shared
    private let memoryService = MemoryService.shared
    private let graphService = GraphService.shared
    private let globalMemoryService = GlobalMemoryService.shared
    private let orchestrator = AgentOrchestrator()

    /// Allows tests to inject a mock LLM. Production uses LLMService.shared.
    /// `localModelFileExists` is injectable so the "no model downloaded" path is
    /// testable without touching the real filesystem.
    private let localModelFileExists: (String) -> Bool

    init(llm: LLMSending = LLMService.shared,
         localModelFileExists: @escaping (String) -> Bool = ChatService.defaultLocalModelExists) {
        self.llm = llm
        self.localModelFileExists = localModelFileExists
    }

    static func defaultLocalModelExists(_ model: String) -> Bool {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return FileManager.default.fileExists(atPath: docs.appendingPathComponent("models/\(model).gguf").path)
    }

    struct ChatResult {
        let response: String
        let isCrisis: Bool
        let tokenCount: Int
        let agentResponse: String?
        /// True when `response` is a safety fallback (crisis resources or a
        /// boundary-violation redirect) rather than the model's own reply.
        /// Callers that speculatively synthesized speech for sentences of the
        /// in-progress reply (via `onSentence`) must discard that audio when
        /// this is true — the safety check requires nothing from the
        /// original reply is ever spoken.
        var wasReplacedForSafety = false
    }

    /// - Parameter onSentence: called once per complete sentence as the
    ///   reply streams in (for cloud providers that support it — see
    ///   `LLMStreaming`), *before* the safety/boundary check runs on the
    ///   finished reply. Callers may use this to start synthesizing speech
    ///   for each sentence early, overlapping that work with the rest of the
    ///   reply still generating — but must not play any of it until this
    ///   method returns with `wasReplacedForSafety == false`, since a
    ///   violation detected later in the reply replaces the whole thing.
    func processMessage(session: SessionModel, userMessage: String, context: ModelContext,
                        onSentence: ((String) -> Void)? = nil) async -> ChatResult {
        let persona = PersonaService.resolve(for: session)
        let globalMemories = globalMemoryService.recall(query: userMessage, context: context)
        var crossSessionContext = ""
        if !globalMemories.isEmpty {
            let lines = globalMemories.map { "- \($0.content)" }
            crossSessionContext = "Relevant cross-session memories:\n" + lines.joined(separator: "\n")
        }
        let crisisCheck = safety.checkCrisis(userMessage)

        if crisisCheck.isCrisis {
            let event = SafetyEventModel(
                session: session,
                eventType: "crisis_keyword",
                level: crisisCheck.level,
                message: "Detected pattern: '\(crisisCheck.pattern ?? "")'"
            )
            context.insert(event)

            // Persist the exchange so the crisis resources are visible in the
            // conversation (not just flashed as a caption).
            context.insert(MessageModel(session: session, role: "user", content: userMessage))
            context.insert(MessageModel(session: session, role: "assistant", content: resourceMessage))

            return ChatResult(
                response: resourceMessage,
                isCrisis: true,
                tokenCount: 0,
                agentResponse: nil,
                wasReplacedForSafety: true
            )
        }

        // Capture conversation history BEFORE inserting the new user message, so
        // the current turn isn't duplicated (it is appended separately by
        // buildMessages). Sort chronologically — SwiftData relationships are
        // unordered, so suffix() on the raw set could send turns out of order.
        let provider = session.resolvedProvider
        let historyLimit = provider == "local" ? 6 : 10
        let recentMessages = session.messages
            .sorted { $0.createdAt < $1.createdAt }
            .suffix(historyLimit)
            .map { ($0.role, $0.content) }

        let userMsg = MessageModel(session: session, role: "user", content: userMessage)
        context.insert(userMsg)

        let memories = memoryService.recallRelevant(session: session, query: userMessage, context: context)
        var memoryContext = memories.map { "- \($0.content)" }.joined(separator: "\n")
        if !crossSessionContext.isEmpty {
            if !memoryContext.isEmpty {
                memoryContext += "\n\n"
            }
            memoryContext += crossSessionContext
        }

        let llmMessages = therapy.buildMessages(
            persona: persona,
            modality: session.modality,
            customPrompt: session.systemPrompt,
            messageHistory: recentMessages,
            userMessage: userMessage,
            memoryContext: memoryContext
        )

        let model = session.resolvedModel

        // Pre-warm the local engine if this session uses a GGUF model.
        // Apple Foundation Models are system-provided — no file to check or load.
        if provider == "local" && model != "apple-foundation" {
            guard localModelFileExists(model) else {
                return configError(
                    "No on-device model is downloaded yet. Open Settings → Models to download one, or switch this session to a cloud model using the model chip at the top.",
                    session: session, context: context
                )
            }
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = docs.appendingPathComponent("models/\(model).gguf")
            await LocalLLMEngine.shared.loadModel(id: model, url: filePath)
        }

        let assistantResponse: String
        let tokenCount: Int

        do {
            if let streaming = llm as? LLMStreaming {
                assistantResponse = try await Self.streamAndSplitSentences(
                    streaming.streamMessage(provider: provider, model: model, messages: llmMessages),
                    onSentence: onSentence
                )
            } else {
                // No streaming support (Anthropic, on-device, or a test
                // mock) — same single round trip as before. Still reports
                // the whole reply through `onSentence` once, so callers
                // don't need to special-case non-streaming providers.
                let text = try await llm.sendMessage(provider: provider, model: model, messages: llmMessages)
                if !text.isEmpty { onSentence?(text) }
                assistantResponse = text
            }
            tokenCount = assistantResponse.count / 4
        } catch LocalLLMError.busy {
            return ChatResult(
                response: "I'm still thinking about your last message — please wait a moment before sending another.",
                isCrisis: false,
                tokenCount: 0,
                agentResponse: nil
            )
        } catch LocalLLMError.timeout {
            return ChatResult(
                response: "That response timed out — the prompt may have been too long for this model. Try the 1B model for faster replies, or switch to OpenRouter for this session.",
                isCrisis: false,
                tokenCount: 0,
                agentResponse: nil
            )
        } catch LLMError.noAPIKey {
            return configError(
                "No API key is set for this provider, so cloud replies aren't available. Add your key in Settings → Keys & Providers, or switch this session to an on-device model using the model chip at the top.",
                session: session, context: context
            )
        } catch LocalLLMError.notLoaded, LLMError.localModelNotDownloaded {
            return configError(
                "The on-device model couldn't be loaded. Try re-downloading it in Settings → Models, or switch to a cloud model for this session.",
                session: session, context: context
            )
        } catch {
            assistantResponse = "I'm here to listen. Could you tell me more about that?"
            tokenCount = 0
        }

        let boundaryCheck = safety.checkBoundaryViolation(assistantResponse, persona: persona.kind)
        let finalResponse = boundaryCheck.isViolation
            ? "I want to be honest with you — that's beyond what I can safely help with, and I'm not able to give medical or diagnostic advice. But I'm right here with you. Want to tell me more about what's going on?"
            : assistantResponse

        if boundaryCheck.isViolation {
            let event = SafetyEventModel(
                session: session,
                eventType: "boundary_violation",
                level: "warning",
                message: "Detected pattern: '\(boundaryCheck.pattern ?? "")'"
            )
            context.insert(event)
        }

        let assistantMsg = MessageModel(session: session, role: "assistant", content: finalResponse, tokenCount: tokenCount)
        context.insert(assistantMsg)

        // Snapshot counts before extraction so we can badge the assistant message.
        let nodeIDsBefore   = Set(session.graphNodes.map(\.id))
        let edgeIDsBefore   = Set(session.graphNodes.flatMap(\.outgoingEdges).map(\.id))
        let memoryIDsBefore = Set(session.memories.map(\.id))

        // Embed and store this exchange locally for semantic recall.
        memoryService.recordExchange(
            session: session,
            userMessage: userMessage,
            assistantResponse: finalResponse,
            context: context
        )
        memoryService.consolidateRecentMessages(session: session, context: context)
        graphService.extractEntitiesFromMessage(session: session, message: userMessage, context: context)

        let promoted = globalMemoryService.promoteIfValuable(
            userMessage: userMessage,
            assistantResponse: finalResponse,
            sessionID: session.id,
            context: context
        )

        // Dream capture: detect dream language in user message.
        if let dream = InsightCaptureService.detectDream(in: userMessage) {
            DreamService.shared.recordDream(
                session: session,
                narrative: dream.narrative,
                feelings: dream.feelings,
                symbols: dream.symbols,
                context: context
            )
            assistantMsg.capturedDream = true
        }

        // Note capture: upsert one auto summary note per session.
        if let summary = InsightCaptureService.summaryNote(for: session) {
            if let existing = InsightCaptureService.existingSummaryNote(for: session) {
                existing.title = summary.title
                existing.content = summary.content
                existing.updatedAt = Date()
            } else {
                let note = NoteModel(session: session, type: "reflection",
                                     title: summary.title, content: summary.content)
                note.structuredData = InsightCaptureService.summaryNoteMarker
                context.insert(note)
                assistantMsg.capturedNote = true
            }
        }

        // Stamp the assistant message with how much was captured this turn.
        assistantMsg.capturedNodeCount   = session.graphNodes.filter { !nodeIDsBefore.contains($0.id) }.count
        assistantMsg.capturedEdgeCount   = session.graphNodes.flatMap(\.outgoingEdges).filter { !edgeIDsBefore.contains($0.id) }.count
        assistantMsg.capturedMemoryCount = session.memories.filter { !memoryIDsBefore.contains($0.id) }.count
        assistantMsg.capturedGlobalMemory = promoted != nil

        let agentCtx = AgentContext(
            sessionId: session.id,
            userMessage: userMessage,
            modality: session.modality,
            recentMemories: memories.map(\.content),
            graphContext: session.graphNodes.map { "\($0.label) (\($0.type))" },
            safetyEvents: session.safetyEvents.map { SafetyEventSummary(level: $0.level, eventType: $0.eventType, message: $0.message) }
        )
        let agentResult = await orchestrator.route(context: agentCtx)

        return ChatResult(
            response: finalResponse,
            isCrisis: false,
            tokenCount: tokenCount,
            agentResponse: agentResult.agentName != "integrative_agent" ? agentResult.content : nil,
            wasReplacedForSafety: boundaryCheck.isViolation
        )
    }

    /// Splits `text` at the first sentence-ending punctuation (`.`, `!`,
    /// `?`) or newline, returning that leading sentence (trimmed) and
    /// everything after it — `nil` if `text` has no complete sentence yet.
    /// Skips stray boundary-only fragments (e.g. leading whitespace before a
    /// stray period) by recursing into the remainder. Pure/static so it's
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
    private static func streamAndSplitSentences(_ stream: AsyncThrowingStream<String, Error>,
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
    private func configError(_ message: String, session: SessionModel, context: ModelContext) -> ChatResult {
        context.insert(MessageModel(session: session, role: "assistant", content: message))
        return ChatResult(response: message, isCrisis: false, tokenCount: 0, agentResponse: nil)
    }
}
