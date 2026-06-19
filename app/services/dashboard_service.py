from __future__ import annotations

from collections import Counter

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.session import Session
from app.models.conversation import Message
from app.models.graph import GraphNode, GraphEdge
from app.models.note import Note
from app.models.memory import EpisodicMemory, SemanticMemory
from app.services.therapy_service import TherapyService
from app.services.graph_service import GraphService


class DashboardService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_session_dashboard(self, session_id: str) -> dict:
        session_result = await self.db.execute(
            select(Session)
            .options(selectinload(Session.messages))
            .where(Session.id == session_id)
        )
        session = session_result.scalar_one_or_none()
        if not session:
            return {"session_id": session_id, "exists": False}

        msg_count = len(session.messages) if session.messages else 0

        nodes_result = await self.db.execute(
            select(GraphNode).where(GraphNode.session_id == session_id)
        )
        nodes = list(nodes_result.scalars().all())

        node_type_counts = Counter(n.type for n in nodes)
        node_ids = [n.id for n in nodes]

        edge_count = 0
        if node_ids:
            edges_result = await self.db.execute(
                select(func.count()).select_from(GraphEdge).where(
                    GraphEdge.source_id.in_(node_ids),
                )
            )
            edge_count = edges_result.scalar() or 0

        emotion_nodes = [n for n in nodes if n.type == "emotion"]
        theme_nodes = sorted(
            [n for n in nodes if n.type == "theme"],
            key=lambda n: n.strength, reverse=True,
        )

        notes_result = await self.db.execute(
            select(Note).where(Note.session_id == session_id).order_by(Note.created_at.desc()).limit(5)
        )
        recent_notes = list(notes_result.scalars().all())

        therapy = TherapyService(db=self.db)
        progress = await therapy.get_progress(session_id)

        return {
            "session_id": session_id,
            "exists": True,
            "title": session.title,
            "modality": session.modality,
            "provider": session.provider,
            "created_at": session.created_at,
            "updated_at": session.updated_at,
            "messages_exchanged": msg_count,
            "graph_nodes": len(nodes),
            "graph_edges": edge_count,
            "nodes_by_type": dict(node_type_counts),
            "emotions": [{"label": n.label, "strength": n.strength} for n in emotion_nodes],
            "top_themes": [{"label": t.label, "strength": t.strength} for t in theme_nodes[:5]],
            "recent_notes": [
                {"id": n.id, "title": n.title, "note_type": n.note_type, "created_at": n.created_at}
                for n in recent_notes
            ],
            "progress": progress,
        }

    async def get_global_dashboard(self) -> dict:
        sessions_result = await self.db.execute(
            select(Session).options(selectinload(Session.messages)).order_by(Session.updated_at.desc())
        )
        sessions = list(sessions_result.scalars().all())

        total_sessions = len(sessions)
        total_messages = sum(len(s.messages) for s in sessions if s.messages)

        active_sessions = [s for s in sessions if s.messages and len(s.messages) >= 2]

        modality_counter = Counter(s.modality for s in sessions)

        nodes_result = await self.db.execute(select(GraphNode))
        all_nodes = list(nodes_result.scalars().all())
        total_nodes = len(all_nodes)
        node_type_counts = Counter(n.type for n in all_nodes)

        theme_nodes = [n for n in all_nodes if n.type == "theme"]
        global_themes = Counter(n.label for n in theme_nodes).most_common(10)

        edges_result = await self.db.execute(select(func.count()).select_from(GraphEdge))
        total_edges = edges_result.scalar() or 0

        notes_result = await self.db.execute(
            select(Note).order_by(Note.created_at.desc()).limit(10)
        )
        recent_notes = list(notes_result.scalars().all())

        return {
            "total_sessions": total_sessions,
            "total_messages": total_messages,
            "total_graph_nodes": total_nodes,
            "total_graph_edges": total_edges,
            "active_sessions": len(active_sessions),
            "sessions": [
                {
                    "id": s.id,
                    "title": s.title,
                    "modality": s.modality,
                    "message_count": len(s.messages) if s.messages else 0,
                    "updated_at": s.updated_at,
                }
                for s in sessions[:10]
            ],
            "modality_distribution": dict(modality_counter),
            "nodes_by_type": dict(node_type_counts),
            "top_themes_globally": [{"label": label, "count": count} for label, count in global_themes],
            "recent_notes": [
                {"id": n.id, "title": n.title, "note_type": n.note_type, "session_id": n.session_id, "created_at": n.created_at}
                for n in recent_notes
            ],
        }
