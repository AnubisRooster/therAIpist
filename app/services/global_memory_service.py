from __future__ import annotations

from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.global_memory import GlobalMemory


class GlobalMemoryService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def store(
        self,
        content: str,
        type: str = "semantic",
        importance: float = 0.5,
        session_id: str | None = None,
        keywords: str = "",
    ) -> GlobalMemory:
        memory = GlobalMemory(
            session_id=session_id,
            type=type,
            content=content,
            keywords=keywords,
            importance=importance,
        )
        self.db.add(memory)
        await self.db.commit()
        await self.db.refresh(memory)
        return memory

    async def recall(self, query: str, top_k: int = 5) -> list[GlobalMemory]:
        if not query.strip():
            return []

        lower_query = query.lower()
        query_words = set(lower_query.split())

        result = await self.db.execute(
            select(GlobalMemory).order_by(GlobalMemory.importance.desc()).limit(50)
        )
        all_memories = list(result.scalars().all())

        scored = []
        for mem in all_memories:
            word_count = sum(1 for w in query_words if w in mem.content.lower() or w in mem.keywords.lower())
            if word_count > 0:
                score = word_count / max(len(query_words), 1) + mem.importance * 0.5
                scored.append((mem, score))

        scored.sort(key=lambda x: x[1], reverse=True)
        return [mem for mem, _ in scored[:top_k]]

    async def promote_if_valuable(
        self,
        user_message: str,
        assistant_response: str,
        session_id: str | None = None,
    ) -> GlobalMemory | None:
        importance_keywords = [
            "realized", "insight", "breakthrough", "always", "never", "since childhood",
            "my mother", "my father", "trauma", "afraid", "ashamed", "guilty",
            "i learned", "i discovered", "for the first time",
        ]
        combined = user_message.lower() + " " + assistant_response.lower()
        keyword_hits = sum(1 for kw in importance_keywords if kw in combined)

        importance = 0.3 + (keyword_hits / len(importance_keywords)) * 0.7
        if importance < 0.7:
            return None

        content = f"User: {user_message[:300]}\nTherapist: {assistant_response[:300]}"
        keywords = MemoryService_stub.extract_keywords_from(user_message + " " + assistant_response)

        return await self.store(
            content=content,
            type="semantic",
            importance=importance,
            session_id=session_id,
            keywords=keywords,
        )


def extract_keywords(text: str) -> str:
    stop_words = {
        "the", "a", "an", "is", "was", "were", "be", "been", "being",
        "have", "has", "had", "do", "does", "did", "will", "would",
        "can", "could", "shall", "should", "may", "might", "to", "of",
        "in", "for", "on", "with", "at", "by", "from", "as", "into",
        "through", "during", "before", "after", "above", "below",
        "between", "and", "but", "or", "nor", "not", "so", "yet",
        "i", "me", "my", "we", "our", "you", "your", "he", "she",
        "it", "they", "them", "this", "that", "these", "those",
    }
    words = text.lower().split()
    filtered = [w.strip(".,!?;:") for w in words if w.strip(".,!?;:") not in stop_words and len(w) > 3]
    counts: dict[str, int] = {}
    for w in filtered:
        counts[w] = counts.get(w, 0) + 1
    sorted_words = sorted(counts.items(), key=lambda x: x[1], reverse=True)
    return ", ".join(w for w, _ in sorted_words[:10])


MemoryService_stub = type("MemoryService_stub", (), {"extract_keywords_from": staticmethod(extract_keywords)})()
