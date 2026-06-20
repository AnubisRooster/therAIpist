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
    private let llm = LLMService.shared
    private let therapy = TherapyService.shared
    private let memoryService = MemoryService.shared
    private let graphService = GraphService.shared
    private let globalMemoryService = GlobalMemoryService.shared
    private let orchestrator = AgentOrchestrator()

    struct ChatResult {
        let response: String
        let isCrisis: Bool
        let tokenCount: Int
        let agentResponse: String?
    }

    func processMessage(session: SessionModel, userMessage: String, context: ModelContext) async -> ChatResult {
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
            modality: session.modality,
            customPrompt: session.systemPrompt,
            messageHistory: recentMessages,
            userMessage: userMessage,
            memoryContext: memoryContext
        )

        let model = session.resolvedModel

        // Pre-warm the local engine if this session uses it.
        if provider == "local" {
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
        } catch {
            assistantResponse = "I'm here to listen. Could you tell me more about that?"
            tokenCount = 0
        }

        let boundaryCheck = safety.checkBoundaryViolation(assistantResponse)
        let finalResponse = boundaryCheck.isViolation
            ? "I notice you're asking about something beyond my scope. As a therapeutic support, I can help you explore your feelings and experiences. Would you like to tell me more about what brought you here today?"
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
}
