import Foundation
import SwiftData
// swiftlint:disable cyclomatic_complexity function_body_length
// processMessage branches across many safety paths and error surfaces.
/// All SwiftData reads/writes here run on the main actor because the
/// `ModelContext` passed in is the app's main context, which is NOT safe to use
/// off the main thread. The expensive work (network / on-device inference) is
/// performed behind `await` calls that suspend without blocking the UI.
@MainActor
final class ChatService { // swiftlint:disable:this type_body_length
    static let shared = ChatService()

    private let safety = SafetyService.shared
    private let llm: LLMSending
    private let therapy = TherapyService.shared
    private let memoryService = MemoryService.shared
    private let graphService = GraphService.shared
    private let globalMemoryService = GlobalMemoryService.shared
    private let orchestrator = AgentOrchestrator()
    private let summaryCompactor: ConversationCompactor

    /// Allows tests to inject a mock LLM. Production uses LLMService.shared.
    /// `localModelFileExists` is injectable so the "no model downloaded" path is
    /// testable without touching the real filesystem.
    private let localModelFileExists: (String) -> Bool

    init(llm: LLMSending = LLMService.shared,
         localModelFileExists: @escaping (String) -> Bool = ChatService.defaultLocalModelExists,
         summaryCompactor: ConversationCompactor = .shared) {
        self.llm = llm
        self.localModelFileExists = localModelFileExists
        self.summaryCompactor = summaryCompactor
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
            context.insert(MessageModel(session: session,
                                    role: "assistant",
                                    content: CrisisResources.localizedResourceMessage()))

            return ChatResult(
                response: CrisisResources.localizedResourceMessage(),
                isCrisis: true,
                tokenCount: 0,
                agentResponse: nil,
                wasReplacedForSafety: true
            )
        }

        // Block requests that seek concrete self-harm methods: respond with a
        // safe refusal plus crisis resources, and never forward to the model.
        if safety.checkSelfHarmMethod(userMessage) {
            let event = SafetyEventModel(
                session: session,
                eventType: "self_harm_method",
                level: "critical",
                message: "Detected self-harm method-seeking language"
            )
            context.insert(event)
            let refusal = CrisisResources.methodRefusalMessage()
            context.insert(MessageModel(session: session, role: "user", content: userMessage))
            context.insert(MessageModel(session: session, role: "assistant", content: refusal))
            return ChatResult(
                response: refusal,
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
        let history = session.messages
            .sorted { $0.createdAt < $1.createdAt }
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

        let model = session.resolvedModel

        // Pre-warm the local engine if this session uses a GGUF model.
        // Apple Foundation Models are system-provided — no file to check or load.
        if provider == "local" && model != "apple-foundation" {
            guard localModelFileExists(model) else {
                return configError(
                    "No on-device model is downloaded yet. Open Settings → Models to download one, or switch " +
                    "this session to a cloud model using the model chip at the top.",
                    session: session, context: context
                )
            }
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = docs.appendingPathComponent("models/\(model).gguf")
            await LocalLLMEngine.shared.loadModel(id: model, url: filePath)
        }

        // Fit the history to the model's context window instead of a hard
        // "last N messages" trim:
        //   - Cloud providers get a large token budget based on the model's
        //     advertised context_length (falling back to a sane default).
        //   - On-device models re-evaluate the whole prompt every turn, so
        //     their history is folded into a rolling summary of the older
        //     turns plus the most recent turns kept verbatim. Their budget
        //     also accounts for the real cost of the system prompt, recalled
        //     memories, and the current message -- not just history -- since
        //     Apple Foundation's 4096-token cap is hard and doesn't scale.
        let systemPromptText = therapy.getSystemPrompt(persona: persona, modality: session.modality,
                                                        customPrompt: session.systemPrompt)
        let budget = historyTokenBudget(provider: provider, model: model, systemPrompt: systemPromptText,
                                        memoryContext: memoryContext, userMessage: userMessage)
        var priorSummary: String?
        var recentMessages: [(String, String)]
        if provider == "local" {
            let minimumRecentTurns = LocalLLMEngine.historyLimit()
            if let compacted = try? await summaryCompactor.compact(
                messages: history,
                sessionID: session.id,
                budget: budget,
                minimumRecentTurns: minimumRecentTurns,
                summarizer: { block in
                    try await Self.summarizeBlock(block, using: self.llm, provider: provider, model: model)
                }
            ) {
                priorSummary = compacted.summary
                recentMessages = compacted.recent
            } else {
                // Summarizer unavailable (or failed): degrade to plain truncation
                // within the same budget rather than a blanket "last N" cut.
                recentMessages = ConversationCompactor.retainedHistory(history, budget: budget, minimumKeep: 3)
            }
        } else {
            recentMessages = ConversationCompactor.retainedHistory(history, budget: budget, minimumKeep: 3)
        }

        // Runs one generation attempt against a specific history/memory/summary
        // combination. Factored out so the context-overflow retry below can
        // re-run it with a smaller prompt without duplicating the streaming
        // vs. single-shot branching.
        func attemptGenerate(recentMessages: [(String, String)], memoryContext: String,
                             priorSummary: String) async throws -> (String, Int) {
            let llmMessages = therapy.buildMessages(
                persona: persona,
                modality: session.modality,
                customPrompt: session.systemPrompt,
                messageHistory: recentMessages,
                userMessage: userMessage,
                memoryContext: memoryContext,
                priorSummary: priorSummary
            )
            let text: String
            if let streaming = llm as? LLMStreaming {
                text = try await Self.streamAndSplitSentences(
                    streaming.streamMessage(provider: provider, model: model, messages: llmMessages),
                    onSentence: onSentence
                )
            } else {
                // No streaming support (Anthropic, on-device, or a test
                // mock) — same single round trip as before. Still reports
                // the whole reply through `onSentence` once, so callers
                // don't need to special-case non-streaming providers.
                text = try await llm.sendMessage(provider: provider, model: model, messages: llmMessages)
                if !text.isEmpty { onSentence?(text) }
            }
            return (text, text.count / 4)
        }

        let assistantResponse: String
        let tokenCount: Int

        do {
            (assistantResponse, tokenCount) = try await attemptGenerate(
                recentMessages: recentMessages, memoryContext: memoryContext, priorSummary: priorSummary ?? "")
        } catch LLMError.contextLengthExceeded where provider == "local" {
            // The budget above already accounts for the real cost of the
            // system prompt, memories, and this message -- if it still
            // overflowed, the char/4 token estimate most likely undercounted
            // this content's real size. Retry once with memory context
            // dropped and history cut hard before surfacing the error, so an
            // estimation miss doesn't dead-end the conversation outright.
            do {
                let fallbackHistory = ConversationCompactor.retainedHistory(history, budget: budget / 2, minimumKeep: 1)
                (assistantResponse, tokenCount) = try await attemptGenerate(
                    recentMessages: fallbackHistory, memoryContext: "", priorSummary: "")
            } catch {
                return ChatResult(
                    response: "This conversation has grown too long for the current model's context window, " +
                        "even after trimming it back. Start a new session, or switch to a model with a larger context.",
                    isCrisis: false,
                    tokenCount: 0,
                    agentResponse: nil
                )
            }
        } catch LocalLLMError.busy {
            return ChatResult(
                response: "I'm still thinking about your last message — please wait a moment before sending another.",
                isCrisis: false,
                tokenCount: 0,
                agentResponse: nil
            )
        } catch LocalLLMError.timeout {
            return ChatResult(
                response: "That response timed out — the prompt may have been too long for this model. " +
                "Try the 1B model for faster replies, or switch to OpenRouter for this session.",
                isCrisis: false,
                tokenCount: 0,
                agentResponse: nil
            )
        } catch LLMError.noAPIKey {
            return configError(
                "No API key is set for this provider, so cloud replies aren't available. Add your key in " +
                "Settings → Keys & Providers, or switch this session to an on-device model using the " +
                "model chip at the top.",
                session: session, context: context
            )
        } catch LocalLLMError.notLoaded, LLMError.localModelNotDownloaded {
            return configError(
                "The on-device model couldn't be loaded. Try re-downloading it in " +
                "Settings → Models, or switch to a cloud model for this session.",
                session: session, context: context
            )
        } catch LLMError.unsupportedProvider(let name) {
            return configError(
                "This session's provider (\"\(name)\") isn't recognized. Switch providers in Settings → " +
                "Keys & Providers, or pick a different model for this session using the model chip at the top.",
                session: session, context: context
            )
        } catch LLMError.emptyResponse {
            assistantResponse = "I didn't quite catch a full response there — could you say that again, " +
                "or try again in a moment."
            tokenCount = 0
        } catch LLMError.rateLimited(let retryAfter) {
            // Should be rare (LLMService retries transients automatically), but
            // if the retries are exhausted or the provider sheds mid-stream,
            // surface it instead of pretending everything is fine.
            print("⚠️ ChatService: provider rate-limited (retryAfter: \(retryAfter ?? 0))")
            assistantResponse = "The provider is temporarily overloaded. Please try again in a moment."
            tokenCount = 0
        } catch LLMError.contextLengthExceeded {
            print("⚠️ ChatService: conversation exceeded the model's context window")
            assistantResponse = "This conversation has grown too long for the current model's context window. " +
                "Start a new session, or switch to a model with a larger context."
            tokenCount = 0
        } catch LLMError.apiError(let message) {
            // Real API failure (auth, malformed request, upstream 5xx) — expose a
            // terse, sanitized reason rather than the old "I'm here to listen"
            // swallow that hid every backend problem behind a canned reply.
            print("⚠️ ChatService: provider API error: \(message)")
            let shortReason = message.count > 160 ? String(message.prefix(160)) + "…" : message
            assistantResponse = "I couldn't reach the provider just now. \(shortReason)"
            tokenCount = 0
        } catch {
            // Anything not matched above (decode failures, unexpected HTTP
            // errors, rate limits, etc.) would otherwise vanish into this
            // generic fallback with zero trail. Logging it doesn't change
            // the user-facing behavior but means a real bug is at least
            // diagnosable instead of indistinguishable from a normal reply.
            print("⚠️ ChatService: unhandled LLM error: \(error)")
            assistantResponse = "I'm here to listen. Could you tell me more about that?"
            tokenCount = 0
        }

        let boundaryCheck = safety.checkBoundaryViolation(assistantResponse, persona: persona.kind)
        let finalResponse = boundaryCheck.isViolation
            ? "I want to be honest with you — that's beyond what I can safely help with, and I'm not able to " +
            "give medical or diagnostic advice. But I'm right here with you. Want to tell me more " +
            "about what's going on?"
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

        let assistantMsg = MessageModel(session: session,
                                role: "assistant",
                                content: finalResponse,
                                tokenCount: tokenCount)
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
        let recentUserMessages = history.filter { $0.0 == "user" }.map(\.1)
            .suffix(GraphService.recentContextWindow)
        graphService.extractEntitiesFromMessage(session: session, message: userMessage,
                                                recentMessages: Array(recentUserMessages), context: context)

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
        assistantMsg.capturedEdgeCount = session.graphNodes
            .flatMap(\.outgoingEdges)
            .filter { !edgeIDsBefore.contains($0.id) }
            .count
        assistantMsg.capturedMemoryCount = session.memories.filter { !memoryIDsBefore.contains($0.id) }.count
        assistantMsg.capturedGlobalMemory = promoted != nil

        // Persist now, before the agent-orchestration round trip below: the
        // assistant's reply is already visible to the user via the live
        // @Query the moment it was inserted above, but nothing durable
        // exists yet since ChatView only saves after this whole function
        // returns. `orchestrator.route` is another async/network call, and
        // if the app is backgrounded or the process is suspended or killed
        // during that gap, an unsaved reply the user already saw would be
        // silently lost. Saving here closes that window; a failure is
        // logged rather than swallowed so data loss isn't invisible.
        do {
            try context.save()
        } catch {
            print("⚠️ ChatService: failed to save assistant message: \(error)")
        }

        let agentCtx = AgentContext(
            sessionId: session.id,
            userMessage: userMessage,
            modality: session.modality,
            recentMemories: memories.map(\.content),
            graphContext: session.graphNodes.map { "\($0.label) (\($0.type))" },
            safetyEvents: session.safetyEvents.map {
                SafetyEventSummary(level: $0.level, eventType: $0.eventType, message: $0.message)
            }
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
}
// swiftlint:enable cyclomatic_complexity function_body_length
