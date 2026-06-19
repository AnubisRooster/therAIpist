from __future__ import annotations

from app.agents.base import TherapyAgent, AgentContext, AgentResult
from app.agents.crisis_agent import CrisisAgent
from app.agents.specialized_agents import (
    AdlerianAgent,
    JungianAgent,
    DBTAgent,
    IntegrativeAgent,
)


class AgentOrchestrator:
    def __init__(self):
        self.agents: list[TherapyAgent] = [
            CrisisAgent(),
            AdlerianAgent(),
            JungianAgent(),
            DBTAgent(),
            IntegrativeAgent(),
        ]

    def register_agent(self, agent: TherapyAgent):
        self.agents.append(agent)

    async def route(self, ctx: AgentContext) -> AgentResult:
        scored = [(agent, agent.can_handle(ctx)) for agent in self.agents]
        scored.sort(key=lambda x: x[1], reverse=True)

        best_agent, best_score = scored[0] if scored else (None, 0)

        if best_agent and best_score > 0:
            return await best_agent.process(ctx)

        fallback = IntegrativeAgent()
        return await fallback.process(ctx)

    async def route_all(self, ctx: AgentContext) -> list[AgentResult]:
        results = []
        for agent in self.agents:
            score = agent.can_handle(ctx)
            if score > 0:
                result = await agent.process(ctx)
                results.append(result)
        return results
