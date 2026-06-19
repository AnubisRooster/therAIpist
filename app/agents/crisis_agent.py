from app.agents.base import TherapyAgent, AgentContext, AgentResult
from app.services.safety_service import RESOURCE_MESSAGE


class CrisisAgent(TherapyAgent):
    @property
    def name(self) -> str:
        return "crisis_agent"

    def can_handle(self, ctx: AgentContext) -> float:
        if ctx.safety_events:
            critical_events = [e for e in ctx.safety_events if e.get("level") == "critical"]
            if critical_events:
                return 1.0
        return 0.0

    async def process(self, ctx: AgentContext) -> AgentResult:
        return AgentResult(
            content=RESOURCE_MESSAGE,
            agent_name=self.name,
            confidence=1.0,
            interventions=["crisis_referral"],
            metadata={"event_count": len(ctx.safety_events)},
        )
