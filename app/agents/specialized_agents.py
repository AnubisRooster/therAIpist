from app.agents.base import TherapyAgent, AgentContext, AgentResult


class AdlerianAgent(TherapyAgent):
    @property
    def name(self) -> str:
        return "adlerian_agent"

    def can_handle(self, ctx: AgentContext) -> float:
        if ctx.modality == "adlerian":
            return 0.9
        return 0.3

    async def process(self, ctx: AgentContext) -> AgentResult:
        return AgentResult(
            content=f"[Adlerian approach] Exploring the purpose and meaning behind: {ctx.user_message}",
            agent_name=self.name,
            confidence=0.85,
            interventions=["lifestyle_exploration", "early_recollection"],
            metadata={"modality": "adlerian"},
        )


class JungianAgent(TherapyAgent):
    @property
    def name(self) -> str:
        return "jungian_agent"

    def can_handle(self, ctx: AgentContext) -> float:
        if ctx.modality == "jungian":
            return 0.9
        if any("dream" in ctx.user_message.lower() for _ in [1]):
            return 0.7
        return 0.2

    async def process(self, ctx: AgentContext) -> AgentResult:
        return AgentResult(
            content=f"[Jungian approach] Exploring the symbolic dimension of: {ctx.user_message}",
            agent_name=self.name,
            confidence=0.85,
            interventions=["shadow_exploration", "active_imagination"],
            metadata={"modality": "jungian"},
        )


class DBTAgent(TherapyAgent):
    @property
    def name(self) -> str:
        return "dbt_agent"

    def can_handle(self, ctx: AgentContext) -> float:
        if ctx.modality == "dbt":
            return 0.9
        return 0.3

    async def process(self, ctx: AgentContext) -> AgentResult:
        return AgentResult(
            content=f"[DBT approach] Applying skills framework to: {ctx.user_message}",
            agent_name=self.name,
            confidence=0.85,
            interventions=["skill_coaching", "chain_analysis"],
            metadata={"modality": "dbt"},
        )


class IntegrativeAgent(TherapyAgent):
    @property
    def name(self) -> str:
        return "integrative_agent"

    def can_handle(self, ctx: AgentContext) -> float:
        return 0.5

    async def process(self, ctx: AgentContext) -> AgentResult:
        return AgentResult(
            content=f"[Integrative approach] Drawing from multiple therapeutic traditions for: {ctx.user_message}",
            agent_name=self.name,
            confidence=0.7,
            interventions=["integrated_response"],
            metadata={"modality": ctx.modality},
        )
