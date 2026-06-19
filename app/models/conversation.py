import uuid
import json
from datetime import datetime, timezone

from sqlalchemy import String, Text, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class Message(Base):
    __tablename__ = "messages"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id: Mapped[str] = mapped_column(String, ForeignKey("sessions.id", ondelete="CASCADE"))
    role: Mapped[str] = mapped_column(String)
    content: Mapped[str] = mapped_column(Text)
    meta_data: Mapped[str] = mapped_column("metadata", Text, default="{}")
    created_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())

    session = relationship("Session", back_populates="messages")

    def metadata_dict(self) -> dict:
        return json.loads(self.meta_data)

    def set_metadata(self, data: dict):
        self.meta_data = json.dumps(data)
