from __future__ import annotations

import math
import uuid
from abc import ABC, abstractmethod
from dataclasses import dataclass, field

import httpx

from app.core.config import settings


@dataclass
class SearchResult:
    point_id: str
    score: float
    payload: dict


class VectorStore(ABC):
    @abstractmethod
    async def store(self, collection: str, point_id: str, vector: list[float], payload: dict) -> None:
        ...

    @abstractmethod
    async def search(self, collection: str, vector: list[float], limit: int = 5) -> list[SearchResult]:
        ...

    @abstractmethod
    async def delete(self, collection: str, point_id: str) -> None:
        ...

    @abstractmethod
    async def ensure_collection(self, collection: str, vector_size: int) -> None:
        ...


def cosine_similarity(a: list[float], b: list[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    norm_a = math.sqrt(sum(x * x for x in a))
    norm_b = math.sqrt(sum(x * x for x in b))
    if norm_a == 0 or norm_b == 0:
        return 0.0
    return dot / (norm_a * norm_b)


class InMemoryVectorStore(VectorStore):
    def __init__(self):
        self._collections: dict[str, dict[str, tuple[list[float], dict]]] = {}

    async def ensure_collection(self, collection: str, vector_size: int) -> None:
        if collection not in self._collections:
            self._collections[collection] = {}

    async def store(self, collection: str, point_id: str, vector: list[float], payload: dict) -> None:
        if collection not in self._collections:
            self._collections[collection] = {}
        self._collections[collection][point_id] = (vector, payload)

    async def search(self, collection: str, vector: list[float], limit: int = 5) -> list[SearchResult]:
        if collection not in self._collections:
            return []
        scored: list[SearchResult] = []
        for pid, (vec, payload) in self._collections[collection].items():
            score = cosine_similarity(vector, vec)
            scored.append(SearchResult(point_id=pid, score=score, payload=payload))
        scored.sort(key=lambda r: r.score, reverse=True)
        return scored[:limit]

    async def delete(self, collection: str, point_id: str) -> None:
        if collection in self._collections:
            self._collections[collection].pop(point_id, None)

    def clear(self):
        self._collections.clear()


class QdrantVectorStore(VectorStore):
    def __init__(self, url: str | None = None, api_key: str | None = None):
        self.url = (url or settings.qdrant_url).rstrip("/")
        self.api_key = api_key or settings.qdrant_api_key

    async def _request(self, method: str, path: str, **kwargs) -> httpx.Response:
        url = f"{self.url}{path}"
        headers = kwargs.pop("headers", {"Content-Type": "application/json"})
        if self.api_key:
            headers["api-key"] = self.api_key
        async with httpx.AsyncClient() as client:
            resp = await client.request(method, url, headers=headers, **kwargs)
            resp.raise_for_status()
            return resp

    async def ensure_collection(self, collection: str, vector_size: int) -> None:
        try:
            await self._request("GET", f"/collections/{collection}")
        except httpx.HTTPStatusError as e:
            if e.response.status_code == 404:
                create_payload = {
                    "name": collection,
                    "vectors": {"size": vector_size, "distance": "Cosine"},
                }
                await self._request("PUT", f"/collections/{collection}", json=create_payload)
                return
            raise

    async def store(self, collection: str, point_id: str, vector: list[float], payload: dict) -> None:
        body = {
            "points": [
                {
                    "id": point_id,
                    "vector": vector,
                    "payload": payload,
                }
            ]
        }
        await self._request("PUT", f"/collections/{collection}/points", json=body)

    async def search(self, collection: str, vector: list[float], limit: int = 5) -> list[SearchResult]:
        body = {"vector": vector, "limit": limit, "with_payload": True}
        resp = await self._request("POST", f"/collections/{collection}/points/search", json=body)
        data = resp.json()
        results = []
        for point in data.get("result", []):
            results.append(SearchResult(
                point_id=str(point["id"]),
                score=point["score"],
                payload=point.get("payload", {}),
            ))
        return results

    async def delete(self, collection: str, point_id: str) -> None:
        body = {"points": [point_id]}
        await self._request("POST", f"/collections/{collection}/points/delete", json=body)


_vector_store_instance: VectorStore | None = None


def get_vector_store(config=settings) -> VectorStore:
    global _vector_store_instance
    if _vector_store_instance is not None:
        return _vector_store_instance
    store_type = config.vector_store_type
    if store_type == "qdrant":
        _vector_store_instance = QdrantVectorStore(url=config.qdrant_url, api_key=config.qdrant_api_key)
    else:
        _vector_store_instance = InMemoryVectorStore()
    return _vector_store_instance


def reset_vector_store():
    global _vector_store_instance
    _vector_store_instance = None
