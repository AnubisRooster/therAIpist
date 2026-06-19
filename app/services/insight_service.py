from __future__ import annotations

import json
from collections import defaultdict

from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.graph import GraphNode, GraphEdge
from app.models.conversation import Message
from app.models.session import Session
from app.services.graph_service import GraphService
from app.services.providers import get_provider
from app.services.providers.base import ChatMessage


MODALITY_INSIGHT_PROMPTS = {
    "adlerian": "Focus on lifestyle convictions, inferiority/superiority dynamics, social interest, early recollections, and birth order patterns.",
    "jungian": "Focus on shadow content, archetypal patterns, anima/animus dynamics, persona identification, and individuation progress.",
    "dbt": "Focus on skill deficits, emotional dysregulation patterns, behavioral chains, dialectical tensions, and skill generalization.",
    "integrated": "Incorporate Adlerian (lifestyle), Jungian (symbolic/shadow), and DBT (skill-based) perspectives as appropriate.",
    "free_form": "Focus on emergent themes, natural patterns, and the client's own framing of their experience without imposing a specific theoretical lens.",
    "cbt": "Focus on maladaptive automatic thoughts, cognitive distortions, core beliefs, and behavioral patterns that maintain difficulties.",
    "humanistic": "Focus on conditions of worth, incongruence between self-concept and experience, the client's organismic valuing process, and barriers to self-actualization.",
    "existential": "Focus on how the client confronts death, freedom, isolation, and meaninglessness. Examine authentic vs. inauthentic living and existential anxiety.",
    "gestalt": "Focus on contact boundary disturbances, unfinished business, present-moment awareness gaps, and resistance patterns in the field.",
    "somatic": "Focus on nervous system states, body-based holding patterns, incomplete defensive responses, and the relationship between sensation and meaning.",
    "narrative": "Focus on dominant problem stories, unique outcomes, externalized problem dynamics, and the re-authoring process.",
    "act": "Focus on experiential avoidance, cognitive fusion, values-behavior gap, defusion opportunities, and committed action steps.",
    "psychodynamic": "Focus on unconscious themes, defense mechanisms, transference patterns, early attachment templates, and relational repetitions.",
    "ifs": "Focus on parts mapping, protector-exile dynamics, Self-energy access, burdens, and the unburdening process.",
}

BASE_INSIGHT_OUTPUT = """
Output ONLY valid JSON with this structure:
{
  "repeating_loops": [
    {
      "pattern": "string describing the repeating pattern",
      "description": "detailed explanation of how this pattern manifests",
      "frequency": "occasional|frequent|persistent",
      "entities_involved": ["entity_label_1", "entity_label_2"]
    }
  ],
  "modality_insights": [
    {
      "observation": "string describing the insight from the modality framework",
      "evidence": ["specific evidence from session data"]
    }
  ]
}

Base your insights strictly on the data provided. Do not fabricate evidence."""


class InsightService:
    def __init__(self, db: AsyncSession, provider_name: str = "ollama"):
        self.db = db
        self._provider_name = provider_name
        self._provider = None
        self._graph_service = GraphService(db, provider_name)

    async def _get_provider(self):
        if self._provider is None:
            self._provider = get_provider(self._provider_name, settings)
        return self._provider

    async def _build_context(self, session_id: str) -> str:
        lines = []

        nodes_result = await self.db.execute(
            select(GraphNode).where(GraphNode.session_id == session_id)
        )
        nodes = list(nodes_result.scalars().all())
        if nodes:
            lines.append("Knowledge Graph Nodes:")
            for n in nodes:
                lines.append(f"  - {n.type}: \"{n.label}\" (strength: {n.strength})")

        if nodes:
            node_ids = [n.id for n in nodes]
            edges_result = await self.db.execute(
                select(GraphEdge).where(
                    or_(
                        GraphEdge.source_id.in_(node_ids),
                        GraphEdge.target_id.in_(node_ids),
                    )
                )
            )
            edges = list(edges_result.scalars().all())
            if edges:
                node_map = {n.id: n.label for n in nodes}
                lines.append("Relationships:")
                for e in edges:
                    src = node_map.get(e.source_id, e.source_id)
                    tgt = node_map.get(e.target_id, e.target_id)
                    lines.append(f"  - {src} --[{e.relationship}]--> {tgt}")

        msgs_result = await self.db.execute(
            select(Message)
            .where(Message.session_id == session_id)
            .order_by(Message.created_at.desc())
            .limit(6)
        )
        messages = list(reversed(list(msgs_result.scalars().all())))
        if messages:
            lines.append("\nRecent Conversation:")
            for m in messages:
                lines.append(f"  [{m.role}]: {m.content[:200]}")

        return "\n".join(lines)

    async def generate_insights(self, session_id: str) -> dict:
        context = await self._build_context(session_id)
        if not context.strip():
            return {"repeating_loops": [], "modality_insights": []}

        session_result = await self.db.execute(
            select(Session).where(Session.id == session_id)
        )
        session = session_result.scalar_one_or_none()
        modality = session.modality if session else "integrated"
        modality_focus = MODALITY_INSIGHT_PROMPTS.get(modality, MODALITY_INSIGHT_PROMPTS["integrated"])

        system_prompt = f"""You are a psychological insight engine. Analyze the therapy session data below and generate clinical insights.

Modality focus: {modality_focus}

{BASE_INSIGHT_OUTPUT}"""

        provider = await self._get_provider()
        messages = [
            ChatMessage(role="system", content=system_prompt),
            ChatMessage(role="user", content=f"Therapy Session Data:\n{context}"),
        ]
        try:
            result = await provider.chat(messages=messages, model=None, temperature=0.3, max_tokens=3000)
        except Exception:
            return {"repeating_loops": [], "modality_insights": []}
        return self._parse_insights(result.content)

    def _parse_insights(self, text: str) -> dict:
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
                return {"repeating_loops": [], "modality_insights": []}
        return {
            "repeating_loops": data.get("repeating_loops", []),
            "modality_insights": data.get("modality_insights", []),
        }

    async def detect_cycles(self, session_id: str, max_depth: int = 5) -> list[dict]:
        graph = await self._graph_service.get_session_graph(session_id)
        if not graph["nodes"] or not graph["edges"]:
            return []

        adj: dict[str, list[str]] = defaultdict(list)
        for edge in graph["edges"]:
            adj[edge["source_id"]].append(edge["target_id"])

        node_map = {n["id"]: n for n in graph["nodes"]}

        cycles: list[dict] = []
        seen: set[str] = set()
        visited: set[str] = set()
        path: list[str] = []
        path_set: set[str] = set()

        def dfs(node: str, depth: int):
            if depth > max_depth:
                return
            visited.add(node)
            path.append(node)
            path_set.add(node)

            for neighbor in adj.get(node, []):
                if neighbor in path_set:
                    cycle_start = path.index(neighbor)
                    cycle = path[cycle_start:]
                    cycle_labels = [node_map.get(n_id, {}).get("label", n_id) for n_id in cycle]
                    if len(set(cycle_labels)) < 2:
                        continue
                    canonical = "->".join(cycle_labels)
                    if canonical in seen:
                        continue
                    seen.add(canonical)
                    cycles.append({
                        "nodes": cycle_labels,
                        "description": f"Repeating cycle: {' → '.join(cycle_labels)}",
                    })
                elif neighbor not in visited:
                    dfs(neighbor, depth + 1)

            path.pop()
            path_set.discard(node)

        session_node_ids = [n["id"] for n in graph["nodes"]]
        for node_id in session_node_ids:
            if node_id not in visited:
                dfs(node_id, 0)

        return cycles
