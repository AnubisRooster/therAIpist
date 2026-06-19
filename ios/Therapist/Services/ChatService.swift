import Foundation
import SwiftData

actor ChatService {
    static let shared = ChatService()

    private let safety = SafetyService.shared
    private let llm = LLMService.shared
    private let therapy = TherapyService.shared
    private let memoryService = MemoryService.shared
    private let graphService = GraphService.shared
    private let orchestrator = AgentOrchestrator()

    struct ChatResult {
        let response: String
        let isCrisis: Bool
        let tokenCount: Int
        let agentResponse: String?
    }

    func processMessage(session: SessionModel, userMessage: String, context: ModelContext) async -> ChatResult {
        let crisisCheck = safety.checkCrisis(userMessage)

        if crisisCheck.isCrisis {
            let event = SafetyEventModel(
                session: session,
                eventType: "crisis_keyword",
                level: crisisCheck.level,
                message: "Detected pattern: '\(crisisCheck.pattern ?? "")'"
            )
            context.insert(event)

            return ChatResult(
                response: resourceMessage,
                isCrisis: true,
                tokenCount: 0,
                agentResponse: nil
            )
        }

        let userMsg = MessageModel(session: session, role: "user", content: userMessage)
        context.insert(userMsg)

        let memories = memoryService.recallRelevant(session: session, query: userMessage)
        let memoryContext = memories.map { "- \($0.content)" }.joined(separator: "\n")

        let recentMessages = session.messages.suffix(10).map { ($0.role, $0.content) }

        let llmMessages = therapy.buildMessages(
            modality: session.modality,
            customPrompt: session.systemPrompt,
            messageHistory: recentMessages,
            userMessage: userMessage,
            memoryContext: memoryContext
        )

        let provider = session.provider.isEmpty ? "openrouter" : session.provider
        let model = session.model

        let assistantResponse: String
        let tokenCount: Int

        do {
            assistantResponse = try await llm.sendMessage(
                provider: provider,
                model: model,
                messages: llmMessages
            )
            tokenCount = assistantResponse.count / 4
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

        memoryService.consolidateRecentMessages(session: session, context: context)
        graphService.extractEntitiesFromMessage(session: session, message: userMessage)

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
