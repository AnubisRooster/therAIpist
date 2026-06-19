import uuid
from datetime import datetime, timezone

from sqlalchemy import String, Text, Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base

SAFETY_LEVELS = {"info", "warning", "critical"}
SAFETY_EVENT_TYPES = {
    "crisis_keyword", "crisis_llm", "boundary_violation",
    "referral_given", "response_filtered", "repetitive_harm",
}


class SafetyEvent(Base):
    __tablename__ = "safety_events"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id: Mapped[str] = mapped_column(String, ForeignKey("sessions.id", ondelete="CASCADE"), index=True)
    event_type: Mapped[str] = mapped_column(String)
    level: Mapped[str] = mapped_column(String, default="info")
    source: Mapped[str] = mapped_column(String, default="user")
    message: Mapped[str] = mapped_column(Text, default="")
    detail: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())
