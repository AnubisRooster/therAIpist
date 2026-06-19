from __future__ import annotations

from collections import Counter, defaultdict

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.graph import GraphNode, GraphEdge


NODE_COLORS = {
    "person": "#4A90D9",
    "event": "#F5A623",
    "emotion": "#D0021B",
    "belief": "#7ED321",
    "theme": "#9013FE",
}
NODE_SHAPES = {
    "person": "circle",
    "event": "diamond",
    "emotion": "triangle",
    "belief": "square",
    "theme": "star",
}
DEFAULT_COLOR = "#AAAAAA"
DEFAULT_SHAPE = "dot"


class GraphUIService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_visualization(self, session_id: str) -> dict:
        nodes_result = await self.db.execute(
            select(GraphNode).where(GraphNode.session_id == session_id)
        )
        nodes = list(nodes_result.scalars().all())

        if not nodes:
            return {"nodes": [], "edges": []}

        node_ids = [n.id for n in nodes]
        edges_result = await self.db.execute(
            select(GraphEdge).where(
                GraphEdge.source_id.in_(node_ids),
            )
        )
        edges = list(edges_result.scalars().all())

        vis_nodes = []
        for n in nodes:
            color = NODE_COLORS.get(n.type, DEFAULT_COLOR)
            shape = NODE_SHAPES.get(n.type, DEFAULT_SHAPE)
            vis_nodes.append({
                "id": n.id,
                "label": n.label,
                "type": n.type,
                "strength": n.strength,
                "size": max(10, n.strength * 15),
                "color": color,
                "shape": shape,
                "properties": n.props_dict(),
                "first_seen": n.first_seen,
                "last_seen": n.last_seen,
            })

        vis_edges = []
        for e in edges:
            vis_edges.append({
                "id": e.id,
                "source": e.source_id,
                "target": e.target_id,
                "relationship": e.relationship,
                "weight": e.weight,
                "width": max(1, e.weight * 3),
                "label": e.relationship,
                "session_id": e.session_id,
            })

        return {"nodes": vis_nodes, "edges": vis_edges}

    async def get_stats(self, session_id: str) -> dict:
        nodes_result = await self.db.execute(
            select(GraphNode).where(GraphNode.session_id == session_id)
        )
        nodes = list(nodes_result.scalars().all())

        if not nodes:
            return {
                "total_nodes": 0, "total_edges": 0, "density": 0,
                "nodes_by_type": {}, "edges_by_relationship": {},
                "isolated_nodes": 0, "degree_distribution": {},
            }

        node_ids = [n.id for n in nodes]
        edges_result = await self.db.execute(
            select(GraphEdge).where(
                GraphEdge.source_id.in_(node_ids),
            )
        )
        edges = list(edges_result.scalars().all())

        n = len(nodes)
        m = len(edges)
        max_possible = n * (n - 1)
        density = round(m / max_possible, 4) if max_possible > 0 else 0

        nodes_by_type = dict(Counter(n.type for n in nodes))
        edges_by_relationship = dict(Counter(e.relationship for e in edges))

        degree: dict[str, int] = defaultdict(int)
        for e in edges:
            degree[e.source_id] += 1
            degree[e.target_id] += 1
        isolated = sum(1 for node in nodes if degree.get(node.id, 0) == 0)
        degree_dist = dict(Counter(degree.values()))

        return {
            "total_nodes": n,
            "total_edges": m,
            "density": density,
            "nodes_by_type": nodes_by_type,
            "edges_by_relationship": edges_by_relationship,
            "isolated_nodes": isolated,
            "degree_distribution": degree_dist,
        }

    async def get_timeline(self, session_id: str) -> dict:
        nodes_result = await self.db.execute(
            select(GraphNode).where(GraphNode.session_id == session_id).order_by(GraphNode.first_seen.asc())
        )
        nodes = list(nodes_result.scalars().all())

        if not nodes:
            return {"timeline": []}

        node_ids = [n.id for n in nodes]
        edges_result = await self.db.execute(
            select(GraphEdge).where(
                GraphEdge.source_id.in_(node_ids),
            ).order_by(GraphEdge.created_at.asc())
        )
        edges = list(edges_result.scalars().all())

        events = []
        for n in nodes:
            events.append({
                "type": "node_added",
                "node_id": n.id,
                "label": n.label,
                "node_type": n.type,
                "strength": n.strength,
                "timestamp": n.first_seen,
            })
        for e in edges:
            events.append({
                "type": "edge_added",
                "source_id": e.source_id,
                "target_id": e.target_id,
                "relationship": e.relationship,
                "weight": e.weight,
                "timestamp": e.created_at,
            })

        events.sort(key=lambda e: e["timestamp"])

        node_map = {n.id: n for n in nodes}
        for event in events:
            if event["type"] == "edge_added":
                src = node_map.get(event["source_id"])
                tgt = node_map.get(event["target_id"])
                event["source_label"] = src.label if src else event["source_id"]
                event["target_label"] = tgt.label if tgt else event["target_id"]

        return {"timeline": events}
