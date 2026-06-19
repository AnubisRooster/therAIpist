from __future__ import annotations

import pytest

from app.agents.base import TherapyAgent, AgentContext, AgentResult
from app.agents.orchestrator import AgentOrchestrator
from app.agents.crisis_agent import CrisisAgent
from app.agents.specialized_agents import (
    AdlerianAgent,
    JungianAgent,
    DBTAgent,
    IntegrativeAgent,
)


class MockAgent(TherapyAgent):
    @property
    def name(self):
        return "mock_agent"

    def can_handle(self, ctx: AgentContext) -> float:
        return 0.5

    async def process(self, ctx: AgentContext) -> AgentResult:
        return AgentResult(content="mock", agent_name=self.name, confidence=0.5)


class HighPriorityAgent(TherapyAgent):
    @property
    def name(self):
        return "high_priority"

    def can_handle(self, ctx: AgentContext) -> float:
        return 0.95

    async def process(self, ctx: AgentContext) -> AgentResult:
        return AgentResult(content="high", agent_name=self.name, confidence=0.95)


@pytest.mark.asyncio
async def test_crisis_agent_high_score_with_critical_events():
    agent = CrisisAgent()
    ctx = AgentContext(
        session_id="s1",
        user_message="help",
        safety_events=[{"level": "critical", "event_type": "crisis_keyword"}],
    )
    assert agent.can_handle(ctx) == 1.0


@pytest.mark.asyncio
async def test_crisis_agent_zero_score_no_events():
    agent = CrisisAgent()
    ctx = AgentContext(session_id="s1", user_message="hello")
    assert agent.can_handle(ctx) == 0.0


@pytest.mark.asyncio
async def test_crisis_agent_returns_resource_message():
    agent = CrisisAgent()
    ctx = AgentContext(
        session_id="s1",
        user_message="help",
        safety_events=[{"level": "critical"}],
    )
    result = await agent.process(ctx)
    assert "988" in result.content
    assert "741741" in result.content
    assert "crisis_referral" in result.interventions


@pytest.mark.asyncio
async def test_adlerian_agent_score_for_adlerian_modality():
    agent = AdlerianAgent()
    ctx = AgentContext(session_id="s1", user_message="test", modality="adlerian")
    assert agent.can_handle(ctx) >= 0.9


@pytest.mark.asyncio
async def test_jungian_agent_score_for_dream_keyword():
    agent = JungianAgent()
    ctx = AgentContext(session_id="s1", user_message="I had a dream about flying")
    assert agent.can_handle(ctx) >= 0.7


@pytest.mark.asyncio
async def test_dbt_agent_score_for_dbt_modality():
    agent = DBTAgent()
    ctx = AgentContext(session_id="s1", user_message="test", modality="dbt")
    assert agent.can_handle(ctx) >= 0.9


@pytest.mark.asyncio
async def test_integrative_agent_always_returns_positive():
    agent = IntegrativeAgent()
    ctx = AgentContext(session_id="s1", user_message="test")
    assert agent.can_handle(ctx) > 0


@pytest.mark.asyncio
async def test_orchestrator_routes_to_highest_score():
    orch = AgentOrchestrator()
    orch.agents = [MockAgent(), HighPriorityAgent()]
    ctx = AgentContext(session_id="s1", user_message="test")
    result = await orch.route(ctx)
    assert result.agent_name == "high_priority"
    assert result.content == "high"


@pytest.mark.asyncio
async def test_orchestrator_fallback_when_no_agents():
    orch = AgentOrchestrator()
    orch.agents = []
    ctx = AgentContext(session_id="s1", user_message="test")
    result = await orch.route(ctx)
    assert result.agent_name == "integrative_agent"


@pytest.mark.asyncio
async def test_orchestrator_route_all():
    orch = AgentOrchestrator()
    orch.agents = [MockAgent(), HighPriorityAgent()]
    ctx = AgentContext(session_id="s1", user_message="test")
    results = await orch.route_all(ctx)
    assert len(results) == 2
    names = [r.agent_name for r in results]
    assert "mock_agent" in names
    assert "high_priority" in names


@pytest.mark.asyncio
async def test_orchestrator_register_agent():
    orch = AgentOrchestrator()
    initial_count = len(orch.agents)
    orch.register_agent(MockAgent())
    assert len(orch.agents) == initial_count + 1
