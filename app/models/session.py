import uuid
from datetime import datetime, timezone

from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class Session(Base):
    __tablename__ = "sessions"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title: Mapped[str] = mapped_column(String, default="")
    provider: Mapped[str] = mapped_column(String, default="ollama")
    model: Mapped[str] = mapped_column(String, default="")
    system_prompt: Mapped[str] = mapped_column(Text, default="")
    modality: Mapped[str] = mapped_column(String, default="integrated")
    mode: Mapped[str] = mapped_column(String, default="auto")
    local_model: Mapped[str] = mapped_column(String, default="")
    created_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    updated_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())

    messages = relationship("Message", back_populates="session", cascade="all, delete-orphan")
