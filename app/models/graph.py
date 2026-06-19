import uuid
import json
from datetime import datetime, timezone

from sqlalchemy import String, Text, Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


VALID_NODE_TYPES = {"person", "event", "emotion", "belief", "theme"}
VALID_RELATIONSHIPS = {"CAUSES", "TRIGGERS", "SUPPRESSES", "COMPENSATES_FOR", "ASSOCIATED_WITH"}


class GraphNode(Base):
    __tablename__ = "graph_nodes"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    type: Mapped[str] = mapped_column(String)
    label: Mapped[str] = mapped_column(String, index=True)
    properties: Mapped[str] = mapped_column(Text, default="{}")
    strength: Mapped[float] = mapped_column(Float, default=1.0)
    session_id: Mapped[str | None] = mapped_column(String, ForeignKey("sessions.id", ondelete="CASCADE"), nullable=True)
    first_seen: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    last_seen: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())

    def props_dict(self) -> dict:
        return json.loads(self.properties)

    def set_props(self, data: dict):
        self.properties = json.dumps(data)


class GraphEdge(Base):
    __tablename__ = "graph_edges"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    source_id: Mapped[str] = mapped_column(String, ForeignKey("graph_nodes.id", ondelete="CASCADE"))
    target_id: Mapped[str] = mapped_column(String, ForeignKey("graph_nodes.id", ondelete="CASCADE"))
    relationship: Mapped[str] = mapped_column(String)
    weight: Mapped[float] = mapped_column(Float, default=1.0)
    meta_data: Mapped[str] = mapped_column("metadata", Text, default="{}")
    session_id: Mapped[str | None] = mapped_column(String, ForeignKey("sessions.id", ondelete="CASCADE"), nullable=True)
    created_at: Mapped[str] = mapped_column(String, default=lambda: datetime.now(timezone.utc).isoformat())

    def meta_dict(self) -> dict:
        return json.loads(self.meta_data)

    def set_meta(self, data: dict):
        self.meta_data = json.dumps(data)
