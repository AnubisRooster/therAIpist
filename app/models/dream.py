import uuid
import json
from datetime import datetime, timezone

from sqlalchemy import String, Text, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Dream(Base):
    __tablename__ = "dreams"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id: Mapped[str] = mapped_column(String, ForeignKey("sessions.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String, default="")
    narrative: Mapped[str] = mapped_column(Text, default="")
    feelings: Mapped[str] = mapped_column(Text, default="[]")
    symbols: Mapped[str] = mapped_column(Text, default="[]")
    analysis: Mapped[str] = mapped_column(Text, default="")
    dream_date: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat()[:10])
    created_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())

    def feeling_list(self) -> list[str]:
        return json.loads(self.feelings)

    def set_feelings(self, feelings: list[str]):
        self.feelings = json.dumps(feelings)

    def symbol_list(self) -> list[dict]:
        return json.loads(self.symbols)

    def set_symbols(self, symbols: list[dict]):
        self.symbols = json.dumps(symbols)
