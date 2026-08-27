import Foundation

protocol TherapyAgent {
    var name: String { get }
    func canHandle(context: AgentContext) -> Float
    func process(context: AgentContext) async -> AgentResult
}

struct AgentContext {
    let sessionId: String
    let userMessage: String
    let modality: String
    let recentMemories: [String]
    let graphContext: [String]
    let safetyEvents: [SafetyEventSummary]
}

struct AgentResult {
    let content: String
    let agentName: String
    let confidence: Float
    let interventions: [String]
}

struct SafetyEventSummary {
    let level: String
    let eventType: String
    let message: String
}

class CrisisAgent: TherapyAgent {
    var name: String { "crisis_agent" }

    func canHandle(context: AgentContext) -> Float {
        if context.safetyEvents.contains(where: { $0.level == "critical" }) {
            return 1.0
        }
        return 0.0
    }

    func process(context: AgentContext) async -> AgentResult {
        AgentResult(
            content: resourceMessage,
            agentName: name,
            confidence: 1.0,
            interventions: ["crisis_referral"]
        )
    }
}

class AdlerianAgent: TherapyAgent {
    var name: String { "adlerian_agent" }

    func canHandle(context: AgentContext) -> Float {
        context.modality == "adlerian" ? 0.9 : 0.3
    }

    func process(context: AgentContext) async -> AgentResult {
        AgentResult(
            content: "[Adlerian approach] Exploring the purpose and meaning behind: \(context.userMessage)",
            agentName: name,
            confidence: 0.85,
            interventions: ["lifestyle_exploration", "early_recollection"]
        )
    }
}

class JungianAgent: TherapyAgent {
    var name: String { "jungian_agent" }

    func canHandle(context: AgentContext) -> Float {
        if context.modality == "jungian" { return 0.9 }
        if context.userMessage.lowercased().contains("dream") { return 0.7 }
        return 0.2
    }

    func process(context: AgentContext) async -> AgentResult {
        AgentResult(
            content: "[Jungian approach] Exploring the symbolic dimension of: \(context.userMessage)",
            agentName: name,
            confidence: 0.85,
            interventions: ["shadow_exploration", "active_imagination"]
        )
    }
}

class DBTAgent: TherapyAgent {
    var name: String { "dbt_agent" }

    func canHandle(context: AgentContext) -> Float {
        context.modality == "dbt" ? 0.9 : 0.3
    }

    func process(context: AgentContext) async -> AgentResult {
        AgentResult(
            content: "[DBT approach] Applying skills framework to: \(context.userMessage)",
            agentName: name,
            confidence: 0.85,
            interventions: ["skill_coaching", "chain_analysis"]
        )
    }
}

class IntegrativeAgent: TherapyAgent {
    var name: String { "integrative_agent" }

    func canHandle(context: AgentContext) -> Float { 0.5 }

    func process(context: AgentContext) async -> AgentResult {
        AgentResult(
            content: "[Integrative approach] Drawing from multiple therapeutic traditions for: \(context.userMessage)",
            agentName: name,
            confidence: 0.7,
            interventions: ["integrated_response"]
        )
    }
}

class AgentOrchestrator {
    private var agents: [TherapyAgent] = [
        CrisisAgent(),
        AdlerianAgent(),
        JungianAgent(),
        DBTAgent(),
        IntegrativeAgent(),
    ]

    func registerAgent(_ agent: TherapyAgent) {
        agents.append(agent)
    }

    func route(context: AgentContext) async -> AgentResult {
        let scored = agents.map { ($0, $0.canHandle(context: context)) }
            .sorted { $0.1 > $1.1 }

        guard let best = scored.first, best.1 > 0 else {
            return await IntegrativeAgent().process(context: context)
        }
        return await best.0.process(context: context)
    }

    func routeAll(context: AgentContext) async -> [AgentResult] {
        var results: [AgentResult] = []
        for agent in agents where agent.canHandle(context: context) > 0 {
            results.append(await agent.process(context: context))
        }
        return results
    }

    var agentNames: [String] {
        agents.map(\.name)
    }
}
