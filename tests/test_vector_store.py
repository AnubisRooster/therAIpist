import httpx
import pytest
from unittest.mock import patch, AsyncMock, MagicMock, PropertyMock

from app.services.vector_store import (
    InMemoryVectorStore,
    QdrantVectorStore,
    cosine_similarity,
    SearchResult,
    get_vector_store,
    reset_vector_store,
)
from app.core.config import Settings


class TestCosineSimilarity:
    def test_identical_vectors(self):
        v = [1.0, 2.0, 3.0]
        assert cosine_similarity(v, v) == pytest.approx(1.0)

    def test_orthogonal_vectors(self):
        a = [1.0, 0.0]
        b = [0.0, 1.0]
        assert cosine_similarity(a, b) == pytest.approx(0.0)

    def test_opposite_vectors(self):
        a = [1.0, 0.0]
        b = [-1.0, 0.0]
        assert cosine_similarity(a, b) == pytest.approx(-1.0)

    def test_zero_vector(self):
        a = [1.0, 0.0]
        b = [0.0, 0.0]
        assert cosine_similarity(a, b) == pytest.approx(0.0)

    def test_partial_match(self):
        a = [1.0, 0.0]
        b = [0.5, 0.5]
        expected = 0.5 / (1.0 * (0.5**2 + 0.5**2) ** 0.5)
        assert cosine_similarity(a, b) == pytest.approx(expected)


class TestInMemoryVectorStore:
    @pytest.fixture
    def store(self):
        return InMemoryVectorStore()

    @pytest.mark.asyncio
    async def test_store_and_search(self, store):
        await store.ensure_collection("test", 3)
        await store.store("test", "1", [1.0, 0.0, 0.0], {"text": "hello"})
        await store.store("test", "2", [0.0, 1.0, 0.0], {"text": "world"})

        results = await store.search("test", [1.0, 0.0, 0.0], limit=2)
        assert len(results) == 2
        assert results[0].point_id == "1"
        assert results[0].score == pytest.approx(1.0)
        assert results[0].payload["text"] == "hello"

    @pytest.mark.asyncio
    async def test_search_empty_collection(self, store):
        results = await store.search("nonexistent", [1.0, 0.0, 0.0])
        assert results == []

    @pytest.mark.asyncio
    async def test_delete(self, store):
        await store.ensure_collection("test", 3)
        await store.store("test", "1", [1.0, 0.0, 0.0], {})
        await store.delete("test", "1")
        results = await store.search("test", [1.0, 0.0, 0.0])
        assert len(results) == 0

    @pytest.mark.asyncio
    async def test_search_returns_top_k(self, store):
        await store.ensure_collection("test", 2)
        for i in range(10):
            await store.store("test", str(i), [float(i), float(10 - i)], {})

        results = await store.search("test", [9.0, 1.0], limit=3)
        assert len(results) == 3
        assert results[0].point_id == "9"

    @pytest.mark.asyncio
    async def test_ensure_collection_creates(self, store):
        assert "new_coll" not in store._collections
        await store.ensure_collection("new_coll", 128)
        assert "new_coll" in store._collections
        assert store._collections["new_coll"] == {}

    def test_clear(self):
        store = InMemoryVectorStore()
        store._collections["x"] = {}
        store.clear()
        assert store._collections == {}


class TestQdrantVectorStore:
    @pytest.fixture
    def store(self):
        return QdrantVectorStore(url="http://localhost:6333")

    @pytest.mark.asyncio
    async def test_ensure_collection_creates_when_missing(self, store):
        mock_resp_get = MagicMock(status_code=404)
        mock_resp_put = MagicMock()
        not_found = httpx.HTTPStatusError(
            message="Not Found",
            request=MagicMock(),
            response=mock_resp_get,
        )

        with patch.object(store, "_request") as mock_req:
            mock_req.side_effect = [
                not_found,
                mock_resp_put,
            ]

            await store.ensure_collection("test_coll", 768)

            assert mock_req.call_count == 2
            assert mock_req.call_args_list[0].args[0] == "GET"
            assert "test_coll" in mock_req.call_args_list[0].args[1]
            assert mock_req.call_args_list[1].args[0] == "PUT"
            assert "test_coll" in mock_req.call_args_list[1].args[1]

    @pytest.mark.asyncio
    async def test_store_sends_put_request(self, store):
        mock_resp = MagicMock()

        with patch.object(store, "_request") as mock_req:
            mock_req.return_value = mock_resp

            await store.store("test_coll", "point1", [0.1, 0.2], {"key": "val"})

            assert mock_req.call_count == 1
            call = mock_req.call_args_list[0]
            assert call.args[0] == "PUT"
            assert "test_coll/points" in call.args[1]
            body = call.kwargs["json"]
            assert body["points"][0]["id"] == "point1"
            assert body["points"][0]["vector"] == [0.1, 0.2]

    @pytest.mark.asyncio
    async def test_search_sends_post_and_parses(self, store):
        mock_resp = MagicMock()
        mock_resp.json.return_value = {
            "result": [
                {"id": "p1", "score": 0.95, "payload": {"text": "hello"}},
                {"id": "p2", "score": 0.80, "payload": {}},
            ]
        }

        with patch.object(store, "_request") as mock_req:
            mock_req.return_value = mock_resp

            results = await store.search("test_coll", [0.1, 0.2], limit=2)

            assert len(results) == 2
            assert results[0].point_id == "p1"
            assert results[0].score == 0.95
            assert results[0].payload["text"] == "hello"
            assert mock_req.call_args_list[0].args[0] == "POST"

    @pytest.mark.asyncio
    async def test_delete_sends_post(self, store):
        mock_resp = MagicMock()

        with patch.object(store, "_request") as mock_req:
            mock_req.return_value = mock_resp

            await store.delete("test_coll", "point1")

            assert mock_req.call_count == 1
            call = mock_req.call_args_list[0]
            assert call.args[0] == "POST"
            assert "points/delete" in call.args[1]
            assert call.kwargs["json"]["points"] == ["point1"]

    def test_get_vector_store_default(self):
        reset_vector_store()
        config = Settings(vector_store_type="in_memory")
        store = get_vector_store(config)
        assert isinstance(store, InMemoryVectorStore)
        reset_vector_store()

    def test_get_vector_store_qdrant(self):
        reset_vector_store()
        config = Settings(vector_store_type="qdrant", qdrant_url="http://localhost:6333")
        store = get_vector_store(config)
        assert isinstance(store, QdrantVectorStore)
        reset_vector_store()
