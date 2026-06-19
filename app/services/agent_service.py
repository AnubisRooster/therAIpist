from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.agents import AgentOrchestrator, AgentContext
from app.models.graph import GraphNode, GraphEdge
from app.models.safety import SafetyEvent
from app.models.session import Session


class AgentService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.orchestrator = AgentOrchestrator()

    async def process_message(self, session_id: str, user_message: str) -> dict:
        session_result = await self.db.execute(
            select(Session).where(Session.id == session_id)
        )
        session = session_result.scalar_one_or_none()
        if not session:
            return {"error": "Session not found"}

        nodes_result = await self.db.execute(
            select(GraphNode).where(GraphNode.session_id == session_id)
        )
        nodes = list(nodes_result.scalars().all())
        graph_context = {"nodes": [{"type": n.type, "label": n.label} for n in nodes]}

        events_result = await self.db.execute(
            select(SafetyEvent).where(SafetyEvent.session_id == session_id).order_by(SafetyEvent.created_at.desc()).limit(10)
        )
        safety_events = [
            {"level": e.level, "event_type": e.event_type, "message": e.message}
            for e in list(events_result.scalars().all())
        ]

        ctx = AgentContext(
            session_id=session_id,
            user_message=user_message,
            modality=session.modality,
            mode=session.mode,
            graph_context=graph_context,
            safety_events=safety_events,
        )

        result = await self.orchestrator.route(ctx)
        all_results = await self.orchestrator.route_all(ctx)

        return {
            "primary_agent": result.agent_name,
            "response": result.content,
            "confidence": result.confidence,
            "interventions": result.interventions,
            "all_agents": [
                {"agent": r.agent_name, "confidence": r.confidence, "interventions": r.interventions}
                for r in all_results
            ],
        }
