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
    }

    func processMessage(session: SessionModel, userMessage: String, context: ModelContext) async -> ChatResult {
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
                agentResponse: nil
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

        // Pre-warm the local engine if this session uses it. If no model file is
        // present, give clear guidance instead of a confusing generic reply.
        if provider == "local" {
            guard localModelFileExists(model) else {
                return configError(
                    "No on-device model is downloaded yet. Open Settings → On-Device Models to download one, or switch this session to OpenRouter using the model chip at the top.",
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
            assistantResponse = try await llm.sendMessage(
                provider: provider,
                model: model,
                messages: llmMessages
            )
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
                "No OpenRouter API key is set, so cloud replies aren't available. Add your key in Settings, or switch this session to an on-device model using the model chip at the top.",
                session: session, context: context
            )
        } catch LocalLLMError.notLoaded, LLMError.localModelNotDownloaded {
            return configError(
                "The on-device model couldn't be loaded. Try re-downloading it in Settings → On-Device Models, or switch to OpenRouter for this session.",
                session: session, context: context
            )
        } catch {
            assistantResponse = "I'm here to listen. Could you tell me more about that?"
            tokenCount = 0
        }

        let boundaryCheck = safety.checkBoundaryViolation(assistantResponse)
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
            agentResponse: agentResult.agentName != "integrative_agent" ? agentResult.content : nil
        )
    }

    /// Inserts a guidance message as an assistant bubble so configuration
    /// problems (no API key, no downloaded model) are visible in the chat
    /// rather than silently swallowed.
    private func configError(_ message: String, session: SessionModel, context: ModelContext) -> ChatResult {
        context.insert(MessageModel(session: session, role: "assistant", content: message))
        return ChatResult(response: message, isCrisis: false, tokenCount: 0, agentResponse: nil)
    }
}
