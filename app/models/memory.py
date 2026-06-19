import uuid
import json
from datetime import datetime, timezone

from sqlalchemy import String, Text, Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class EpisodicMemory(Base):
    __tablename__ = "episodic_memories"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id: Mapped[str | None] = mapped_column(String, ForeignKey("sessions.id", ondelete="SET NULL"), nullable=True)
    content: Mapped[str] = mapped_column(Text)
    embedding_id: Mapped[str | None] = mapped_column(String, nullable=True)
    importance: Mapped[float] = mapped_column(Float, default=0.5)
    summary: Mapped[str] = mapped_column(Text, default="")
    timestamp: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    created_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())


class SemanticMemory(Base):
    __tablename__ = "semantic_memories"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    key: Mapped[str] = mapped_column(String, unique=True, index=True)
    value: Mapped[str] = mapped_column(Text)
    category: Mapped[str] = mapped_column(String, default="general")
    confidence: Mapped[float] = mapped_column(Float, default=0.5)
    updated_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())


class ProceduralMemory(Base):
    __tablename__ = "procedural_memories"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    context: Mapped[str] = mapped_column(String, index=True)
    technique: Mapped[str] = mapped_column(Text)
    effectiveness: Mapped[float] = mapped_column(Float, default=0.5)
    tags: Mapped[str] = mapped_column(Text, default="[]")
    created_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())

    def tag_list(self) -> list[str]:
        return json.loads(self.tags)

    def set_tags(self, tags: list[str]):
        self.tags = json.dumps(tags)
