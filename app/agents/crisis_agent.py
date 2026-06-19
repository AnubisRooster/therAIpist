from app.agents.base import TherapyAgent, AgentContext, AgentResult


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
            content="If you're experiencing thoughts of harming yourself or others, "
                    "please reach out for support immediately:\n"
                    "- National Crisis Hotline: 988\n"
                    "- Crisis Text Line: Text HOME to 741741\n"
                    "- Emergency Services: 911\n\n"
                    "These resources are available 24/7.",
            agent_name=self.name,
            confidence=1.0,
            interventions=["crisis_referral"],
            metadata={"event_count": len(ctx.safety_events)},
        )
