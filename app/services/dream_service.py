from __future__ import annotations

import json
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.dream import Dream
from app.services.providers import get_provider
from app.services.providers.base import ChatMessage
from app.services.graph_service import GraphService

DREAM_ANALYSIS_PROMPT = """You are a Jungian dream analyst. Analyze the following dream using analytical psychology.

Consider:
- Archetypal themes and images present in the dream
- Shadow content — repressed or disowned aspects surfacing
- Persona dynamics — how the dreamer presents vs. who they are
- Anima/Animus figures and their significance
- Individuation markers — signs of psychological growth
- Personal associations the dreamer might explore

Output ONLY valid JSON:
{
  "interpretation": "Your comprehensive Jungian interpretation of the dream",
  "archetypes": ["list of archetypes identified"],
  "shadow_elements": ["list of shadow elements"],
  "key_symbols": [{"symbol": "symbol name", "meaning": "Jungian meaning", "personal_significance": "possible personal meaning"}],
  "themes": ["recurring themes identified"],
  "guidance": "therapeutic guidance based on the dream"
}"""

SYMBOL_EXTRACTION_PROMPT = """You are a dream symbol analyst. Extract key symbols from the following dream narrative.

Output ONLY valid JSON:
{
  "symbols": [
    {"symbol": "the symbol", "type": "object|person|animal|place|action|emotion", "significance": "brief Jungian significance"}
  ]
}"""


class DreamService:
    def __init__(self, db: AsyncSession, provider_name: str = "ollama"):
        self.db = db
        self._provider_name = provider_name
        self._provider = None
        self._graph_service = GraphService(db, provider_name)

    async def _get_provider(self):
        if self._provider is None:
            self._provider = get_provider(self._provider_name, settings)
        return self._provider

    async def create_dream(
        self,
        session_id: str,
        title: str = "",
        narrative: str = "",
        feelings: list[str] | None = None,
        dream_date: str | None = None,
    ) -> Dream:
        dream = Dream(
            session_id=session_id,
            title=title,
            narrative=narrative,
            dream_date=dream_date or datetime.now(timezone.utc).isoformat()[:10],
        )
        if feelings:
            dream.set_feelings(feelings)
        self.db.add(dream)
        await self.db.commit()
        await self.db.refresh(dream)
        return dream

    async def get_dream(self, dream_id: str) -> Dream | None:
        result = await self.db.execute(select(Dream).where(Dream.id == dream_id))
        return result.scalar_one_or_none()

    async def list_dreams(self, session_id: str) -> list[Dream]:
        result = await self.db.execute(
            select(Dream).where(Dream.session_id == session_id).order_by(Dream.dream_date.desc())
        )
        return list(result.scalars().all())

    async def update_dream(
        self,
        dream_id: str,
        title: str | None = None,
        narrative: str | None = None,
        feelings: list[str] | None = None,
        dream_date: str | None = None,
    ) -> Dream | None:
        dream = await self.get_dream(dream_id)
        if not dream:
            return None
        if title is not None:
            dream.title = title
        if narrative is not None:
            dream.narrative = narrative
        if feelings is not None:
            dream.set_feelings(feelings)
        if dream_date is not None:
            dream.dream_date = dream_date
        await self.db.commit()
        await self.db.refresh(dream)
        return dream

    async def delete_dream(self, dream_id: str) -> bool:
        dream = await self.get_dream(dream_id)
        if not dream:
            return False
        await self.db.delete(dream)
        await self.db.commit()
        return True

    async def analyze_dream(self, dream_id: str) -> Dream | None:
        dream = await self.get_dream(dream_id)
        if not dream:
            return None

        provider = await self._get_provider()
        messages = [
            ChatMessage(role="system", content=DREAM_ANALYSIS_PROMPT),
            ChatMessage(role="user", content=f"Dream title: {dream.title}\n\nNarrative:\n{dream.narrative}\n\nFeelings: {', '.join(dream.feeling_list())}"),
        ]
        try:
            result = await provider.chat(messages=messages, model=None, temperature=0.4, max_tokens=2000)
        except Exception:
            dream.analysis = '{"interpretation": "Analysis unavailable."}'
            await self.db.commit()
            await self.db.refresh(dream)
            return dream

        analysis_text = result.content.strip()
        if analysis_text.startswith("```"):
            lines = analysis_text.split("\n")
            analysis_text = "\n".join(lines[1:-1])

        try:
            parsed = json.loads(analysis_text)
            dream.analysis = json.dumps(parsed)
            dream.set_symbols([
                {"symbol": s["symbol"], "type": s.get("type", "unknown"), "meaning": s.get("meaning", "")}
                for s in parsed.get("key_symbols", [])
            ])
        except (json.JSONDecodeError, KeyError):
            dream.analysis = json.dumps({"interpretation": result.content[:2000]})

        await self.db.commit()
        await self.db.refresh(dream)
        return dream

    async def extract_and_store_symbols(self, dream_id: str) -> dict:
        dream = await self.get_dream(dream_id)
        if not dream:
            return {"symbols_stored": 0, "nodes_stored": 0}

        has_symbols = bool(dream.symbol_list())
        if not dream.analysis and not has_symbols:
            dream = await self.analyze_dream(dream_id)
            if not dream:
                return {"symbols_stored": 0, "nodes_stored": 0}

        symbols = dream.symbol_list() if dream.symbol_list() else []
        if not symbols:
            provider = await self._get_provider()
            messages = [
                ChatMessage(role="system", content=SYMBOL_EXTRACTION_PROMPT),
                ChatMessage(role="user", content=f"Dream narrative:\n{dream.narrative}"),
            ]
            try:
                result = await provider.chat(messages=messages, model=None, temperature=0.2, max_tokens=1000)
                text = result.content.strip()
                if text.startswith("```"):
                    lines = text.split("\n")
                    text = "\n".join(lines[1:-1])
                extracted = json.loads(text)
                symbols = extracted.get("symbols", [])
                dream.set_symbols(symbols)
                await self.db.commit()
                await self.db.refresh(dream)
            except Exception:
                return {"symbols_stored": 0, "nodes_stored": 0}

        stored = 0
        for sym in symbols:
            try:
                await self._graph_service.merge_node(
                    node_type="theme",
                    label=sym.get("symbol", sym.get("symbol", "unknown")).lower().replace(" ", "_"),
                    properties={"type": sym.get("type", "symbol"), "meaning": sym.get("significance", sym.get("meaning", ""))},
                    strength=0.8,
                    session_id=dream.session_id,
                )
                stored += 1
            except ValueError:
                pass

        return {"symbols_extracted": len(symbols), "nodes_stored": stored}
