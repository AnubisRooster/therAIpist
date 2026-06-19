from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, String, Float, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class GlobalMemory(Base):
    __tablename__ = "global_memories"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id: Mapped[str | None] = mapped_column(String, nullable=True)
    type: Mapped[str] = mapped_column(String, default="semantic")
    content: Mapped[str] = mapped_column(Text, default="")
    keywords: Mapped[str] = mapped_column(String, default="")
    importance: Mapped[float] = mapped_column(Float, default=0.5)
    created_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())
