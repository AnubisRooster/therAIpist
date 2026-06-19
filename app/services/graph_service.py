from __future__ import annotations

import json
import uuid
from datetime import datetime, timezone
from typing import Any

from sqlalchemy import select, or_, and_, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.graph import GraphNode, GraphEdge, VALID_NODE_TYPES, VALID_RELATIONSHIPS
from app.services.providers.base import ChatMessage
from app.services.providers import get_provider

EXTRACTION_SYSTEM_PROMPT = """You are a psychological entity extractor. Analyze the therapy conversation and extract psychological entities as structured JSON.

Entity types:
- person: People mentioned (self, family, friends, colleagues)
- event: Specific life events or situations
- emotion: Feelings and emotional states
- belief: Core beliefs, assumptions, or recurring thoughts
- theme: Recurring themes or patterns

Relationship types:
- CAUSES: One entity directly causes another
- TRIGGERS: One entity triggers another (specific stimulus-response)
- SUPPRESSES: One entity suppresses or numbs another
- COMPENSATES_FOR: One entity compensates for another
- ASSOCIATED_WITH: General association between entities

Output ONLY valid JSON with this structure:
{
  "nodes": [{"type": "emotion", "label": "anxiety", "properties": {"intensity": "high"}, "strength": 0.9}],
  "edges": [{"source_label": "anxiety", "target_label": "work_stress", "relationship": "CAUSES", "weight": 0.8}]
}

Use snake_case for labels. Include at most 10 nodes and 10 edges.
If nothing to extract, return {"nodes": [], "edges": []}."""


class GraphService:
    def __init__(self, db: AsyncSession, provider_name: str = "ollama"):
        self.db = db
        self._provider_name = provider_name
        self._provider = None

    async def _get_provider(self):
        if self._provider is None:
            self._provider = get_provider(self._provider_name, settings)
        return self._provider

    # --- Node Operations ---

    async def add_node(
        self,
        node_type: str,
        label: str,
        properties: dict | None = None,
        strength: float = 1.0,
        session_id: str | None = None,
    ) -> GraphNode:
        if node_type not in VALID_NODE_TYPES:
            raise ValueError(f"Invalid node type '{node_type}'. Valid: {VALID_NODE_TYPES}")

        node = GraphNode(
            type=node_type,
            label=label,
            strength=strength,
            session_id=session_id,
        )
        if properties:
            node.set_props(properties)
        self.db.add(node)
        await self.db.commit()
        await self.db.refresh(node)
        return node

    async def merge_node(
        self,
        node_type: str,
        label: str,
        properties: dict | None = None,
        strength: float = 1.0,
        session_id: str | None = None,
    ) -> GraphNode:
        stmt = select(GraphNode).where(
            GraphNode.type == node_type,
            GraphNode.label == label,
        )
        if session_id:
            stmt = stmt.where(GraphNode.session_id == session_id)
        result = await self.db.execute(stmt)
        existing = result.scalar_one_or_none()

        if existing:
            existing.strength = min(2.0, existing.strength + strength * 0.3)
            existing.last_seen = datetime.now(timezone.utc).isoformat()
            if properties:
                merged = {**existing.props_dict(), **properties}
                existing.set_props(merged)
            await self.db.commit()
            await self.db.refresh(existing)
            return existing

        return await self.add_node(node_type, label, properties, strength, session_id)

    async def get_node(self, node_id: str) -> GraphNode | None:
        result = await self.db.execute(select(GraphNode).where(GraphNode.id == node_id))
        return result.scalar_one_or_none()

    async def find_nodes(
        self,
        node_type: str | None = None,
        query: str | None = None,
        session_id: str | None = None,
        limit: int = 50,
    ) -> list[GraphNode]:
        stmt = select(GraphNode).order_by(GraphNode.strength.desc()).limit(limit)
        if node_type:
            stmt = stmt.where(GraphNode.type == node_type)
        if query:
            stmt = stmt.where(GraphNode.label.ilike(f"%{query}%"))
        if session_id:
            stmt = stmt.where(GraphNode.session_id == session_id)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def delete_node(self, node_id: str) -> bool:
        await self.db.execute(select(GraphEdge).where(
            or_(GraphEdge.source_id == node_id, GraphEdge.target_id == node_id)
        ))
        node = await self.get_node(node_id)
        if not node:
            return False
        await self.db.delete(node)
        await self.db.commit()
        return True

    # --- Edge Operations ---

    async def add_edge(
        self,
        source_id: str,
        target_id: str,
        relationship: str,
        weight: float = 1.0,
        metadata: dict | None = None,
        session_id: str | None = None,
    ) -> GraphEdge:
        if relationship not in VALID_RELATIONSHIPS:
            raise ValueError(f"Invalid relationship '{relationship}'. Valid: {VALID_RELATIONSHIPS}")

        edge = GraphEdge(
            source_id=source_id,
            target_id=target_id,
            relationship=relationship,
            weight=weight,
            session_id=session_id,
        )
        if metadata:
            edge.set_meta(metadata)
        self.db.add(edge)
        await self.db.commit()
        await self.db.refresh(edge)
        return edge

    async def get_connections(self, node_id: str, max_depth: int = 2) -> list[dict]:
        visited_nodes: set[str] = set()
        edges: list[dict] = []
        nodes: list[dict] = []
        current_ids = {node_id}

        for depth in range(max_depth + 1):
            if not current_ids:
                break
            stmt = select(GraphEdge).where(
                or_(GraphEdge.source_id.in_(current_ids), GraphEdge.target_id.in_(current_ids))
            )
            result = await self.db.execute(stmt)
            found_edges = list(result.scalars().all())

            next_ids: set[str] = set()
            for edge in found_edges:
                edge_dict = {
                    "id": edge.id,
                    "source_id": edge.source_id,
                    "target_id": edge.target_id,
                    "relationship": edge.relationship,
                    "weight": edge.weight,
                }
                if edge_dict not in edges:
                    edges.append(edge_dict)
                next_ids.add(edge.source_id)
                next_ids.add(edge.target_id)

            new_node_ids = next_ids - visited_nodes
            if new_node_ids:
                stmt_nodes = select(GraphNode).where(GraphNode.id.in_(new_node_ids))
                result_nodes = await self.db.execute(stmt_nodes)
                for n in result_nodes.scalars().all():
                    nodes.append({
                        "id": n.id,
                        "type": n.type,
                        "label": n.label,
                        "strength": n.strength,
                        "properties": n.props_dict(),
                    })
                visited_nodes.update(new_node_ids)
            current_ids = new_node_ids

        return {"nodes": nodes, "edges": edges}

    # --- Session Graph ---

    async def get_session_graph(self, session_id: str) -> dict:
        stmt_nodes = select(GraphNode).where(GraphNode.session_id == session_id)
        result_nodes = await self.db.execute(stmt_nodes)
        nodes = [
            {"id": n.id, "type": n.type, "label": n.label, "strength": n.strength, "properties": n.props_dict()}
            for n in result_nodes.scalars().all()
        ]

        node_ids = [n["id"] for n in nodes]
        if not node_ids:
            return {"nodes": [], "edges": []}

        stmt_edges = select(GraphEdge).where(
            or_(
                GraphEdge.source_id.in_(node_ids),
                GraphEdge.target_id.in_(node_ids),
            )
        )
        result_edges = await self.db.execute(stmt_edges)
        edges = [
            {"id": e.id, "source_id": e.source_id, "target_id": e.target_id, "relationship": e.relationship, "weight": e.weight}
            for e in result_edges.scalars().all()
        ]

        return {"nodes": nodes, "edges": edges}

    # --- Themes & Patterns ---

    async def get_themes(self, session_id: str) -> list[dict]:
        graph = await self.get_session_graph(session_id)
        theme_nodes = [n for n in graph["nodes"] if n["type"] == "theme"]
        results = []
        for theme in theme_nodes:
            connections = await self.get_connections(theme["id"], max_depth=1)
            related = []
            for n in connections.get("nodes", []):
                if n["id"] != theme["id"]:
                    related.append({"type": n["type"], "label": n["label"]})
            results.append({
                "theme": theme["label"],
                "strength": theme["strength"],
                "properties": theme["properties"],
                "related_entities": related,
            })
        results.sort(key=lambda r: r["strength"], reverse=True)
        return results

    async def get_patterns(self, session_id: str) -> list[dict]:
        graph = await self.get_session_graph(session_id)
        node_map = {n["id"]: n for n in graph["nodes"]}
        edge_list = graph["edges"]

        patterns = []
        for edge in edge_list:
            source = node_map.get(edge["source_id"])
            target = node_map.get(edge["target_id"])
            if not source or not target:
                continue
            if edge["relationship"] in ("CAUSES", "TRIGGERS"):
                patterns.append({
                    "pattern": f"{source['label']} → {edge['relationship']} → {target['label']}",
                    "source": source,
                    "target": target,
                    "relationship": edge["relationship"],
                    "weight": edge["weight"],
                })

        patterns.sort(key=lambda p: p["weight"], reverse=True)
        return patterns

    # --- LLM Extraction ---

    async def extract_from_conversation(
        self, user_message: str, assistant_response: str
    ) -> dict:
        provider = await self._get_provider()
        conversation = f"Client: {user_message}\n\nTherapist: {assistant_response}"
        messages = [
            ChatMessage(role="system", content=EXTRACTION_SYSTEM_PROMPT),
            ChatMessage(role="user", content=conversation),
        ]
        result = await provider.chat(messages=messages, model=None, temperature=0.1, max_tokens=2000)
        return self._parse_extraction(result.content)

    def _parse_extraction(self, text: str) -> dict:
        text = text.strip()
        if text.startswith("```"):
            lines = text.split("\n")
            text = "\n".join(lines[1:-1])
        try:
            data = json.loads(text)
        except json.JSONDecodeError:
            try:
                start = text.index("{")
                end = text.rindex("}") + 1
                data = json.loads(text[start:end])
            except (ValueError, json.JSONDecodeError):
                return {"nodes": [], "edges": []}
        return {
            "nodes": data.get("nodes", []),
            "edges": data.get("edges", []),
        }

    async def extract_and_store(
        self, session_id: str, user_message: str, assistant_response: str
    ) -> dict:
        try:
            extracted = await self.extract_from_conversation(user_message, assistant_response)
        except Exception:
            return {"nodes_stored": 0, "edges_stored": 0}

        node_map: dict[str, str] = {}
        nodes_stored = 0
        for node_data in extracted.get("nodes", []):
            try:
                node = await self.merge_node(
                    node_type=node_data.get("type", "theme"),
                    label=node_data.get("label", "unknown"),
                    properties=node_data.get("properties"),
                    strength=node_data.get("strength", 1.0),
                    session_id=session_id,
                )
                node_map[node_data.get("label", "")] = node.id
                nodes_stored += 1
            except ValueError:
                pass

        edges_stored = 0
        for edge_data in extracted.get("edges", []):
            source_label = edge_data.get("source_label", "")
            target_label = edge_data.get("target_label", "")
            source_id = node_map.get(source_label)
            target_id = node_map.get(target_label)
            if source_id and target_id:
                try:
                    await self.add_edge(
                        source_id=source_id,
                        target_id=target_id,
                        relationship=edge_data.get("relationship", "ASSOCIATED_WITH"),
                        weight=edge_data.get("weight", 1.0),
                        session_id=session_id,
                    )
                    edges_stored += 1
                except ValueError:
                    pass

        return {
            "nodes_stored": nodes_stored,
            "edges_stored": edges_stored,
        }
