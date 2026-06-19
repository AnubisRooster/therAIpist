import pytest
from unittest.mock import patch, AsyncMock, MagicMock


@pytest.mark.asyncio
async def test_session_dashboard_empty(client):
    resp = await client.get("/dashboard/session/nonexistent")
    assert resp.status_code == 200
    data = resp.json()
    assert data["session_id"] == "nonexistent"
    assert data["exists"] is False


@pytest.mark.asyncio
async def test_session_dashboard_with_data(client):
    create_resp = await client.post("/sessions", json={
        "title": "Dashboard Session",
        "modality": "adlerian",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "I see. Tell me more."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 10
        mock_chat.return_value.token_count_completion = 5
        mock_embed.return_value = [0.1] * 768

        await client.post("/chat", json={
            "session_id": session_id, "message": "I feel anxious.",
        })

    await client.post("/graph/nodes", json={
        "type": "emotion", "label": "anxiety", "session_id": session_id,
    })
    await client.post("/graph/nodes", json={
        "type": "theme", "label": "perfectionism", "strength": 2.0, "session_id": session_id,
    })
    await client.post("/notes", json={
        "session_id": session_id, "title": "Session note",
        "content": "Good progress.",
    })

    resp = await client.get(f"/dashboard/session/{session_id}")
    assert resp.status_code == 200
    data = resp.json()
    assert data["exists"] is True
    assert data["modality"] == "adlerian"
    assert data["graph_nodes"] >= 2
    assert len(data["emotions"]) >= 1
    assert len(data["top_themes"]) >= 1
    assert len(data["recent_notes"]) >= 1
    assert data["messages_exchanged"] >= 2


@pytest.mark.asyncio
async def test_session_dashboard_summary_fields(client):
    create_resp = await client.post("/sessions", json={"title": "Summary Test"})
    session_id = create_resp.json()["id"]

    resp = await client.get(f"/dashboard/session/{session_id}")
    data = resp.json()
    assert data["title"] == "Summary Test"
    assert "nodes_by_type" in data
    assert "progress" in data


@pytest.mark.asyncio
async def test_global_dashboard_empty(client):
    resp = await client.get("/dashboard/global")
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_sessions"] >= 0
    assert "sessions" in data
    assert "modality_distribution" in data


@pytest.mark.asyncio
async def test_global_dashboard_with_data(client):
    await client.post("/sessions", json={"title": "S1", "modality": "adlerian"})
    await client.post("/sessions", json={"title": "S2", "modality": "dbt"})
    await client.post("/sessions", json={"title": "S3", "modality": "adlerian"})

    resp = await client.get("/dashboard/global")
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_sessions"] >= 3
    assert data["modality_distribution"].get("adlerian", 0) >= 2
    assert data["modality_distribution"].get("dbt", 0) >= 1
    assert len(data["sessions"]) >= 3


@pytest.mark.asyncio
async def test_global_dashboard_tracks_graph_data(client):
    create_resp = await client.post("/sessions", json={"title": "Graph Session"})
    session_id = create_resp.json()["id"]

    await client.post("/graph/nodes", json={
        "type": "emotion", "label": "fear", "session_id": session_id,
    })
    await client.post("/graph/nodes", json={
        "type": "theme", "label": "control", "session_id": session_id,
    })

    resp = await client.get("/dashboard/global")
    data = resp.json()
    assert data["total_graph_nodes"] >= 2
    assert "fear" not in str(data.get("top_themes_globally", []))
    assert any("control" in str(t) for t in data.get("top_themes_globally", []))


@pytest.mark.asyncio
async def test_global_dashboard_recent_notes(client):
    create_resp = await client.post("/sessions", json={"title": "Notes Session"})
    session_id = create_resp.json()["id"]

    await client.post("/notes", json={
        "session_id": session_id, "title": "Global Note", "content": "Test",
    })

    resp = await client.get("/dashboard/global")
    data = resp.json()
    assert len(data["recent_notes"]) >= 1
    assert data["recent_notes"][0]["title"] == "Global Note"
