from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field


@dataclass
class AgentContext:
    session_id: str
    user_message: str
    modality: str = "integrated"
    mode: str = "auto"
    recent_memories: list[dict] = field(default_factory=list)
    graph_context: dict = field(default_factory=dict)
    insights: dict = field(default_factory=dict)
    safety_events: list[dict] = field(default_factory=list)


@dataclass
class AgentResult:
    content: str
    agent_name: str
    confidence: float = 1.0
    interventions: list[str] = field(default_factory=list)
    metadata: dict = field(default_factory=dict)


class TherapyAgent(ABC):
    @property
    @abstractmethod
    def name(self) -> str: ...

    @abstractmethod
    def can_handle(self, ctx: AgentContext) -> float:
        ...

    @abstractmethod
    async def process(self, ctx: AgentContext) -> AgentResult:
        ...
