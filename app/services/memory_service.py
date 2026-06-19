from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.memory import EpisodicMemory, SemanticMemory, ProceduralMemory
from app.services.vector_store import VectorStore, get_vector_store
from app.services.providers import get_provider
from app.services.providers.base import ChatMessage


EPISODIC_COLLECTION = "therapist_episodic"
EMBEDDING_SIZE = 768


class MemoryService:
    def __init__(
        self,
        db: AsyncSession,
        vector_store: VectorStore | None = None,
        provider_name: str | None = None,
        embedding_model: str | None = None,
    ):
        self.db = db
        self.vector_store = vector_store or get_vector_store(settings)
        self._provider = None
        # Embeddings always use a dedicated provider/model so vectors stay in a
        # single, consistent space (mixing providers corrupts similarity search).
        self._provider_name = provider_name or settings.embedding_provider
        self._embedding_model = embedding_model or settings.embedding_model
        self.embedding_size = settings.embedding_size
        # Namespace the collection by provider + size so switching embedding
        # backends can't silently compare incompatible vectors.
        self.collection_name = (
            f"{EPISODIC_COLLECTION}_{self._provider_name}_{self.embedding_size}"
        )

    async def _get_provider(self):
        if self._provider is None:
            self._provider = get_provider(self._provider_name, settings)
        return self._provider

    async def _embed(self, text: str) -> list[float]:
        provider = await self._get_provider()
        return await provider.embed(text, model=self._embedding_model)

    async def ensure_collection(self):
        await self.vector_store.ensure_collection(self.collection_name, self.embedding_size)

    # --- Episodic Memory ---

    async def store_episodic(
        self,
        content: str,
        session_id: str | None = None,
        importance: float = 0.5,
        summary: str = "",
    ) -> EpisodicMemory:
        await self.ensure_collection()
        embedding = await self._embed(content)
        point_id = str(uuid.uuid4())
        memory_id = str(uuid.uuid4())

        memory = EpisodicMemory(
            id=memory_id,
            session_id=session_id,
            content=content,
            embedding_id=point_id,
            importance=importance,
            summary=summary,
        )
        self.db.add(memory)

        await self.vector_store.store(
            self.collection_name,
            point_id,
            embedding,
            payload={
                "memory_id": memory_id,
                "session_id": session_id,
                "content": content[:500],
                "importance": importance,
                "summary": summary,
                "timestamp": memory.timestamp,
            },
        )
        await self.db.commit()
        await self.db.refresh(memory)
        return memory

    async def recall_episodic(
        self,
        query: str,
        limit: int = 5,
        min_score: float = 0.0,
    ) -> list[tuple[EpisodicMemory, float]]:
        await self.ensure_collection()
        query_embedding = await self._embed(query)
        results = await self.vector_store.search(
            self.collection_name,
            query_embedding,
            limit=limit,
        )
        memories: list[tuple[EpisodicMemory, float]] = []
        for r in results:
            if r.score < min_score:
                continue
            mem_id = r.payload.get("memory_id")
            if not mem_id:
                continue
            stmt = select(EpisodicMemory).where(EpisodicMemory.id == mem_id)
            result = await self.db.execute(stmt)
            mem = result.scalar_one_or_none()
            if mem:
                memories.append((mem, r.score))
        return memories

    async def list_episodic(self, session_id: str | None = None, limit: int = 50) -> list[EpisodicMemory]:
        stmt = select(EpisodicMemory).order_by(EpisodicMemory.created_at.desc()).limit(limit)
        if session_id:
            stmt = stmt.where(EpisodicMemory.session_id == session_id)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    # --- Semantic Memory ---

    async def store_semantic(self, key: str, value: str, category: str = "general", confidence: float = 0.5) -> SemanticMemory:
        stmt = select(SemanticMemory).where(SemanticMemory.key == key)
        result = await self.db.execute(stmt)
        existing = result.scalar_one_or_none()
        if existing:
            existing.value = value
            existing.confidence = confidence
            existing.category = category
            existing.updated_at = datetime.now(timezone.utc).isoformat()
            await self.db.commit()
            await self.db.refresh(existing)
            return existing
        memory = SemanticMemory(key=key, value=value, category=category, confidence=confidence)
        self.db.add(memory)
        await self.db.commit()
        await self.db.refresh(memory)
        return memory

    async def get_semantic(self, key: str) -> SemanticMemory | None:
        stmt = select(SemanticMemory).where(SemanticMemory.key == key)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()

    async def list_semantic(self, category: str | None = None) -> list[SemanticMemory]:
        stmt = select(SemanticMemory).order_by(SemanticMemory.updated_at.desc())
        if category:
            stmt = stmt.where(SemanticMemory.category == category)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def delete_semantic(self, key: str) -> bool:
        stmt = delete(SemanticMemory).where(SemanticMemory.key == key)
        result = await self.db.execute(stmt)
        await self.db.commit()
        return result.rowcount > 0

    # --- Procedural Memory ---

    async def store_procedural(
        self, context: str, technique: str, effectiveness: float = 0.5, tags: list[str] | None = None
    ) -> ProceduralMemory:
        memory = ProceduralMemory(
            context=context,
            technique=technique,
            effectiveness=effectiveness,
        )
        if tags:
            memory.set_tags(tags)
        self.db.add(memory)
        await self.db.commit()
        await self.db.refresh(memory)
        return memory

    async def list_procedural(self, tag: str | None = None) -> list[ProceduralMemory]:
        stmt = select(ProceduralMemory).order_by(ProceduralMemory.effectiveness.desc())
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    # --- Consolidation ---

    async def consolidate_conversation(
        self, session_id: str, user_message: str, assistant_response: str
    ) -> list[EpisodicMemory]:
        memories = []

        user_mem = await self.store_episodic(
            content=user_message,
            session_id=session_id,
            importance=0.6,
            summary=f"User said: {user_message[:100]}",
        )
        memories.append(user_mem)

        assistant_mem = await self.store_episodic(
            content=assistant_response,
            session_id=session_id,
            importance=0.5,
            summary=f"Therapist responded: {assistant_response[:100]}",
        )
        memories.append(assistant_mem)

        return memories

    async def build_context_prompt(self, user_message: str, max_memories: int = 3) -> str:
        recalled = await self.recall_episodic(user_message, limit=max_memories, min_score=0.3)
        if not recalled:
            return ""

        lines = ["Relevant past context:"]
        for mem, score in recalled:
            lines.append(f"- [{mem.timestamp[:10]}] (relevance: {score:.2f}) {mem.content[:300]}")
        return "\n".join(lines)
