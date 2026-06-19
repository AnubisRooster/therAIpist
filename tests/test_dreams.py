import pytest
from unittest.mock import patch, AsyncMock, MagicMock
import json


@pytest.mark.asyncio
async def test_create_dream(client):
    create_resp = await client.post("/sessions", json={"title": "Dream Session"})
    session_id = create_resp.json()["id"]

    resp = await client.post("/dreams", json={
        "session_id": session_id,
        "title": "Flying dream",
        "narrative": "I was flying over a city at night.",
        "feelings": ["freedom", "fear"],
    })
    assert resp.status_code == 201
    data = resp.json()
    assert data["title"] == "Flying dream"
    assert "flying" in data["narrative"]
    assert "freedom" in data["feelings"]
    assert data["analysis"] == {}


@pytest.mark.asyncio
async def test_list_dreams(client):
    create_resp = await client.post("/sessions", json={"title": "Dream List"})
    session_id = create_resp.json()["id"]

    await client.post("/dreams", json={
        "session_id": session_id, "title": "Dream 1",
    })
    await client.post("/dreams", json={
        "session_id": session_id, "title": "Dream 2",
    })

    resp = await client.get(f"/dreams/{session_id}")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) == 2


@pytest.mark.asyncio
async def test_get_dream(client):
    create_resp = await client.post("/sessions", json={"title": "Get Dream"})
    session_id = create_resp.json()["id"]

    dream_resp = await client.post("/dreams", json={
        "session_id": session_id, "title": "My Dream",
    })
    dream_id = dream_resp.json()["id"]

    resp = await client.get(f"/dreams/detail/{dream_id}")
    assert resp.status_code == 200
    assert resp.json()["title"] == "My Dream"


@pytest.mark.asyncio
async def test_get_dream_not_found(client):
    resp = await client.get("/dreams/detail/nonexistent")
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_update_dream(client):
    create_resp = await client.post("/sessions", json={"title": "Update Dream"})
    session_id = create_resp.json()["id"]

    dream_resp = await client.post("/dreams", json={
        "session_id": session_id, "title": "Original",
    })
    dream_id = dream_resp.json()["id"]

    resp = await client.patch(f"/dreams/{dream_id}", json={
        "title": "Updated",
        "feelings": ["curiosity"],
    })
    assert resp.status_code == 200
    data = resp.json()
    assert data["title"] == "Updated"
    assert "curiosity" in data["feelings"]


@pytest.mark.asyncio
async def test_delete_dream(client):
    create_resp = await client.post("/sessions", json={"title": "Delete Dream"})
    session_id = create_resp.json()["id"]

    dream_resp = await client.post("/dreams", json={
        "session_id": session_id, "title": "To Delete",
    })
    dream_id = dream_resp.json()["id"]

    resp = await client.delete(f"/dreams/{dream_id}")
    assert resp.status_code == 204

    get_resp = await client.get(f"/dreams/detail/{dream_id}")
    assert get_resp.status_code == 404


@pytest.mark.asyncio
async def test_delete_dream_not_found(client):
    resp = await client.delete("/dreams/nonexistent")
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_analyze_dream(client):
    create_resp = await client.post("/sessions", json={"title": "Analyze Dream"})
    session_id = create_resp.json()["id"]

    dream_resp = await client.post("/dreams", json={
        "session_id": session_id,
        "title": "Ocean dream",
        "narrative": "I was standing on a cliff watching a huge wave approach.",
        "feelings": ["awe"],
    })
    dream_id = dream_resp.json()["id"]

    with patch("app.services.dream_service.DreamService._get_provider") as mock_get:
        mock_result = MagicMock()
        mock_result.content = json.dumps({
            "interpretation": "The ocean represents the unconscious mind.",
            "archetypes": ["Great Mother"],
            "shadow_elements": ["fear of being overwhelmed"],
            "key_symbols": [{"symbol": "ocean", "meaning": "the unconscious", "personal_significance": "unknown depths"}],
            "themes": ["confronting the unknown"],
            "guidance": "Explore what feels overwhelming in waking life.",
        })
        mock_provider = MagicMock()
        mock_provider.chat = AsyncMock(return_value=mock_result)
        mock_get.return_value = mock_provider

        resp = await client.post(f"/dreams/{dream_id}/analyze")
    assert resp.status_code == 200
    data = resp.json()
    assert "analysis" in data
    assert data["analysis"]["interpretation"] is not None
    assert len(data["symbols"]) >= 1


@pytest.mark.asyncio
async def test_analyze_dream_not_found(client):
    resp = await client.post("/dreams/nonexistent/analyze")
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_analyze_dream_provider_error(client):
    create_resp = await client.post("/sessions", json={"title": "Error Dream"})
    session_id = create_resp.json()["id"]

    dream_resp = await client.post("/dreams", json={
        "session_id": session_id,
        "title": "Error dream",
        "narrative": "Nothing.",
    })
    dream_id = dream_resp.json()["id"]

    with patch("app.services.dream_service.DreamService._get_provider") as mock_get:
        mock_provider = MagicMock()
        mock_provider.chat = AsyncMock(side_effect=Exception("API error"))
        mock_get.return_value = mock_provider

        resp = await client.post(f"/dreams/{dream_id}/analyze")
    assert resp.status_code == 200
    data = resp.json()
    assert "unavailable" in data["analysis"].get("interpretation", "")


@pytest.mark.asyncio
async def test_extract_symbols_from_analyze(client):
    create_resp = await client.post("/sessions", json={"title": "Symbols"})
    session_id = create_resp.json()["id"]

    dream_resp = await client.post("/dreams", json={
        "session_id": session_id,
        "title": "Snake dream",
        "narrative": "A snake was coiled in my path.",
        "feelings": ["fear"],
    })
    dream_id = dream_resp.json()["id"]

    with patch("app.services.dream_service.DreamService._get_provider") as mock_get:
        mock_result = MagicMock()
        mock_result.content = json.dumps({
            "interpretation": "The snake represents transformation.",
            "key_symbols": [{"symbol": "snake", "meaning": "transformation"}],
        })
        mock_provider = MagicMock()
        mock_provider.chat = AsyncMock(return_value=mock_result)
        mock_get.return_value = mock_provider

        resp = await client.post(f"/dreams/{dream_id}/extract-symbols")
    assert resp.status_code == 200
    data = resp.json()
    assert data["nodes_stored"] >= 1


@pytest.mark.asyncio
async def test_extract_symbols_separate_calls(client):
    create_resp = await client.post("/sessions", json={"title": "Two Step"})
    session_id = create_resp.json()["id"]

    dream_resp = await client.post("/dreams", json={
        "session_id": session_id,
        "title": "River dream",
        "narrative": "I dreamed of a river.",
    })
    dream_id = dream_resp.json()["id"]

    with patch("app.services.dream_service.DreamService._get_provider") as mock_get:
        mock_result = MagicMock()
        mock_result.content = json.dumps({
            "interpretation": "The river is life's flow.",
            "key_symbols": [{"symbol": "river", "meaning": "life flow"}],
        })
        mock_provider = MagicMock()
        mock_provider.chat = AsyncMock(return_value=mock_result)
        mock_get.return_value = mock_provider

        analyze_resp = await client.post(f"/dreams/{dream_id}/analyze")
    assert analyze_resp.status_code == 200
    assert "river" in str(analyze_resp.json()["symbols"])

    resp = await client.post(f"/dreams/{dream_id}/extract-symbols")
    assert resp.status_code == 200
    assert resp.json()["nodes_stored"] >= 1


@pytest.mark.asyncio
async def test_extract_symbols_dream_not_found(client):
    resp = await client.post("/dreams/nonexistent/extract-symbols")
    assert resp.status_code == 200
    assert resp.json()["symbols_extracted"] == 0


@pytest.mark.asyncio
async def test_dream_date_default(client):
    create_resp = await client.post("/sessions", json={"title": "Date Test"})
    session_id = create_resp.json()["id"]

    resp = await client.post("/dreams", json={
        "session_id": session_id, "title": "Date dream",
    })
    assert resp.status_code == 201
    assert resp.json()["dream_date"] is not None


@pytest.mark.asyncio
async def test_dream_custom_date(client):
    create_resp = await client.post("/sessions", json={"title": "Custom Date"})
    session_id = create_resp.json()["id"]

    resp = await client.post("/dreams", json={
        "session_id": session_id,
        "title": "Old dream",
        "dream_date": "2024-01-15",
    })
    assert resp.status_code == 201
    assert resp.json()["dream_date"] == "2024-01-15"


@pytest.mark.asyncio
async def test_list_dreams_empty(client):
    resp = await client.get("/dreams/nonexistent")
    assert resp.status_code == 200
    assert resp.json() == []
