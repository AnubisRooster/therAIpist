from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.session import Session
from app.models.schemas import SessionCreate, SessionUpdate
from app.services.providers import get_provider

VALID_MODES = {"auto", "local", "cloud", "hybrid"}


class ModeService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def set_mode(self, session_id: str, mode: str, local_model: str = "") -> Session | None:
        if mode not in VALID_MODES:
            raise ValueError(f"Invalid mode '{mode}'. Valid: {sorted(VALID_MODES)}")

        result = await self.db.execute(select(Session).where(Session.id == session_id))
        session = result.scalar_one_or_none()
        if not session:
            return None

        session.mode = mode
        if local_model:
            session.local_model = local_model

        if mode == "local":
            session.provider = "ollama"
        elif mode == "cloud":
            session.provider = "openrouter"

        session.updated_at = datetime.now(timezone.utc).isoformat()
        await self.db.commit()
        await self.db.refresh(session)
        return session

    async def get_mode(self, session_id: str) -> dict:
        result = await self.db.execute(select(Session).where(Session.id == session_id))
        session = result.scalar_one_or_none()
        if not session:
            return {"session_id": session_id, "mode": None}

        return {
            "session_id": session.id,
            "mode": session.mode,
            "provider": session.provider,
            "local_model": session.local_model,
            "local_available": settings.local_mode or session.mode in ("local", "hybrid"),
            "sync_enabled": settings.sync_enabled,
        }

    def resolve_provider(self, session: Session) -> str:
        if session.mode == "local":
            return "ollama"
        elif session.mode == "cloud":
            return "openrouter"
        elif session.mode == "hybrid":
            return session.provider or "ollama"
        return session.provider or "ollama"
