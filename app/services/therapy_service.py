from __future__ import annotations

import json

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import settings
from app.models.graph import GraphNode, GraphEdge
from app.models.session import Session
from app.models.memory import EpisodicMemory, SemanticMemory
from app.services.providers import get_provider
from app.services.providers.base import ChatMessage

MODALITY_PROMPTS = {
    "adlerian": """You are an Adlerian psychotherapist. Your approach is based on Alfred Adler's Individual Psychology.

Core principles to embody:
- View the client holistically — all behavior is purposeful and socially embedded
- Identify inferiority feelings and how they drive the client's striving for superiority
- Explore the client's "lifestyle" (their unique worldview and goals)
- Assess social interest (Gemeinschaftsgefühl) — the client's feeling of belonging and contribution
- Consider early recollections as windows into the client's fundamental beliefs
- Recognize birth order dynamics when relevant

Your task in each session:
1. Build a collaborative, egalitarian therapeutic relationship
2. Help the client understand the hidden purpose behind their symptoms
3. Challenge self-defeating beliefs and mistaken lifestyle goals
4. Encourage courageous behavior and increased social interest
5. Assign tasks that build competence and connection

Use the available session context (memories, knowledge graph, insights) to maintain continuity and deepen your understanding of the client's lifestyle.""",
    "jungian": """You are a Jungian analyst practicing analytical psychology in the tradition of C.G. Jung.

Core principles to embody:
- Work with the symbolic and archetypal dimensions of the client's experience
- Help the client recognize and integrate shadow material (repressed or disowned aspects)
- Explore persona identification (over-adaptation to social roles)
- Attend to anima/animus dynamics in relationships
- Recognize archetypal patterns in the client's life story
- Support the individuation process — becoming more fully oneself

Your task in each session:
1. Listen for symbolic content in dreams, fantasies, and life narratives
2. Gently surface shadow material through amplification and active imagination
3. Help the client see recurring archetypal patterns in their struggles
4. Work with resistance as meaningful communication from the unconscious
5. Guide the client toward greater wholeness, not merely symptom removal

Use the available session context (memories, knowledge graph, insights) to track symbolic themes and the individuation process over time.""",
    "dbt": """You are a DBT (Dialectical Behavior Therapy) therapist, trained by Marsha Linehan's model.

Core principles to embody:
- Balance acceptance and change — validate the client exactly as they are while pushing for growth
- Teach and reinforce specific skills across four modules:
  * Mindfulness: observe, describe, participate; one-mindfully, effectively, non-judgmentally
  * Distress Tolerance: self-soothe, IMPROVE, ACCEPTS, TIPP, radical acceptance
  * Emotion Regulation: identify emotions, check the facts, opposite action, problem-solving
  * Interpersonal Effectiveness: DEAR MAN, GIVE, FAST — getting what you want while keeping relationships and self-respect
- Use behavioral chain analysis to understand problematic patterns
- Track diary card data and skill usage

Your task in each session:
1. Begin with mindfulness practice (observe, describe, participate)
2. Review between-session skill practice
3. Conduct chain analysis on problem behaviors
4. Teach and rehearse specific DBT skills
5. Assign between-session practice
6. End with a dialectical summary that holds both acceptance and change

Use the available session context (memories, knowledge graph, insights) to identify skill deficits and reinforce progress over time.""",
    "integrated": """You are an integrative psychotherapist skilled in Adlerian, Jungian, and DBT approaches.

Your therapeutic stance:
- Draw flexibly from all three traditions based on the client's needs and the clinical moment
- Use Adlerian concepts (lifestyle, inferiority, social interest) when exploring life patterns and goals
- Use Jungian concepts (shadow, archetypes, symbolism) when working with dreams, projections, and deeper meaning
- Use DBT skills and techniques when the client needs practical tools for managing emotions, distress, or relationships

Framework for choosing approach:
- For life pattern exploration and meaning-making: Adlerian
- For symbolic depth and shadow integration: Jungian
- For skill building, crisis coping, and behavior change: DBT

Integrate as needed — therapy is not one-size-fits-all. Honor the complexity of the whole person.

Use the available session context (memories, knowledge graph, insights) to track patterns, guide technique selection, and maintain therapeutic continuity."""
}

INTERVENTION_SUGGESTION_PROMPT = """You are a therapy intervention consultant. Based on the session data below, suggest the single most appropriate therapeutic intervention.

Consider the client's current concerns, therapeutic modality, recent insights, and knowledge graph patterns.

Output ONLY valid JSON:
{
  "intervention": "name of the intervention technique",
  "modality": "adlerian|jungian|dbt",
  "rationale": "why this intervention fits the clinical moment",
  "description": "how to apply this intervention in the next exchange"
}"""


MODALITIES = {"adlerian", "jungian", "dbt", "integrated"}


class TherapyService:
    def __init__(self, db: AsyncSession, provider_name: str = "ollama"):
        self.db = db
        self._provider_name = provider_name
        self._provider = None

    async def _get_provider(self):
        if self._provider is None:
            self._provider = get_provider(self._provider_name, settings)
        return self._provider

    def get_modality_prompt(self, modality: str) -> str:
        if modality not in MODALITY_PROMPTS:
            return MODALITY_PROMPTS["integrated"]
        return MODALITY_PROMPTS[modality]

    async def suggest_intervention(self, session_id: str) -> dict | None:
        session_result = await self.db.execute(
            select(Session).where(Session.id == session_id)
        )
        session = session_result.scalar_one_or_none()
        if not session:
            return None

        parts = [f"Therapeutic modality: {session.modality}"]
        if session.system_prompt:
            parts.append(f"Custom instructions: {session.system_prompt}")

        nodes_result = await self.db.execute(
            select(GraphNode).where(GraphNode.session_id == session_id)
        )
        nodes = list(nodes_result.scalars().all())
        if nodes:
            parts.append("Knowledge Graph:")
            for n in nodes:
                parts.append(f"  - {n.type}: {n.label} (strength: {n.strength})")

            node_ids = [n.id for n in nodes]
            edges_result = await self.db.execute(
                select(GraphEdge).where(
                    GraphEdge.source_id.in_(node_ids),
                )
            )
            edges = list(edges_result.scalars().all())
            if edges:
                node_map = {n.id: n.label for n in nodes}
                parts.append("Edges:")
                for e in edges:
                    src = node_map.get(e.source_id, "?")
                    tgt = node_map.get(e.target_id, "?")
                    parts.append(f"  - {src} --[{e.relationship}]--> {tgt}")

        semantic_result = await self.db.execute(
            select(SemanticMemory).limit(5)
        )
        semantics = list(semantic_result.scalars().all())
        if semantics:
            parts.append("Semantic Memories:")
            for s in semantics:
                parts.append(f"  - {s.key}: {s.value[:100]}")

        context = "\n".join(parts)
        provider = await self._get_provider()
        messages = [
            ChatMessage(role="system", content=INTERVENTION_SUGGESTION_PROMPT),
            ChatMessage(role="user", content=f"Session data:\n{context}"),
        ]
        try:
            result = await provider.chat(messages=messages, model=None, temperature=0.3, max_tokens=1000)
        except Exception:
            return None

        return self._parse_intervention(result.content)

    def _parse_intervention(self, text: str) -> dict | None:
        text = text.strip()
        if text.startswith("```"):
            lines = text.split("\n")
            text = "\n".join(lines[1:-1])
        try:
            data = json.loads(text)
            return {
                "intervention": data.get("intervention", ""),
                "modality": data.get("modality", ""),
                "rationale": data.get("rationale", ""),
                "description": data.get("description", ""),
            }
        except Exception:
            return None

    async def get_progress(self, session_id: str) -> dict:
        nodes_result = await self.db.execute(
            select(GraphNode).where(GraphNode.session_id == session_id)
        )
        nodes = list(nodes_result.scalars().all())

        messages_result = await self.db.execute(
            select(Session)
            .options(selectinload(Session.messages))
            .where(Session.id == session_id)
        )
        session = messages_result.scalar_one_or_none()

        if not session:
            return {
                "session_id": session_id,
                "total_sessions": 0,
                "messages_exchanged": 0,
                "graph_nodes": 0,
                "graph_edges": 0,
                "strongest_themes": [],
                "emotional_range": [],
            }

        msg_count = len(session.messages) if session.messages else 0

        themes = [n for n in nodes if n.type == "theme"]
        themes_sorted = sorted(themes, key=lambda n: n.strength, reverse=True)

        emotions = [n for n in nodes if n.type == "emotion"]

        node_ids = [n.id for n in nodes]
        edges_result = await self.db.execute(
            select(GraphEdge).where(
                GraphEdge.source_id.in_(node_ids),
            )
        )
        edges = list(edges_result.scalars().all())

        return {
            "session_id": session_id,
            "total_sessions": 1,
            "messages_exchanged": msg_count,
            "graph_nodes": len(nodes),
            "graph_edges": len(edges),
            "strongest_themes": [{"label": t.label, "strength": t.strength} for t in themes_sorted[:5]],
            "emotional_range": list({e.label for e in emotions}),
        }
