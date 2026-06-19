import pytest
from unittest.mock import patch, AsyncMock, MagicMock


@pytest.mark.asyncio
async def test_crisis_detection_in_chat(client):
    create_resp = await client.post("/sessions", json={
        "title": "Safety Chat", "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_embed.return_value = [0.1] * 768

        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "I want to kill myself",
        })
    assert resp.status_code == 200
    data = resp.json()
    assert "988" in data["response"]
    assert "Crisis Text Line" in data["response"]
    assert "741741" in data["response"]

    events_resp = await client.get(f"/safety/events/{session_id}")
    events = events_resp.json()
    assert len(events) >= 2
    event_types = {e["event_type"] for e in events}
    assert "crisis_keyword" in event_types
    assert "referral_given" in event_types
    assert any(e["level"] == "critical" for e in events)


@pytest.mark.asyncio
async def test_crisis_detection_multiple_patterns(client):
    create_resp = await client.post("/sessions", json={"title": "Multi Pattern"})
    session_id = create_resp.json()["id"]

    test_messages = [
        "I want to die",
        "I'm going to hurt myself",
        "I have no reason to live",
        "I can't go on anymore",
    ]

    for msg in test_messages:
        with patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed:
            mock_embed.return_value = [0.1] * 768
            resp = await client.post("/chat", json={
                "session_id": session_id,
                "message": msg,
            })
        assert resp.status_code == 200
        assert "988" in resp.json()["response"]

    events_resp = await client.get(f"/safety/events/{session_id}")
    events = events_resp.json()
    assert len(events) >= 4


@pytest.mark.asyncio
async def test_normal_message_no_crisis(client):
    create_resp = await client.post("/sessions", json={
        "title": "Normal", "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "I understand how you feel."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 10
        mock_chat.return_value.token_count_completion = 5
        mock_embed.return_value = [0.1] * 768

        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "I've been feeling anxious lately.",
        })
    assert resp.status_code == 200
    assert "988" not in resp.json()["response"]
    assert "741741" not in resp.json()["response"]

    events_resp = await client.get(f"/safety/events/{session_id}")
    assert events_resp.json() == []


@pytest.mark.asyncio
async def test_safety_summary(client):
    create_resp = await client.post("/sessions", json={"title": "Summary Session"})
    session_id = create_resp.json()["id"]

    with patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed:
        mock_embed.return_value = [0.1] * 768
        await client.post("/chat", json={
            "session_id": session_id,
            "message": "I want to kill myself",
        })

    resp = await client.get("/safety/summary")
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_events"] >= 2
    assert data["critical_count"] >= 1
    assert data["warning_count"] == 0


@pytest.mark.asyncio
async def test_safety_events_empty(client):
    resp = await client.get("/safety/events/nonexistent")
    assert resp.status_code == 200
    assert resp.json() == []


@pytest.mark.asyncio
async def test_boundary_detection(client):
    create_resp = await client.post("/sessions", json={
        "title": "Boundary Test", "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "I diagnose you with generalized anxiety disorder."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 10
        mock_chat.return_value.token_count_completion = 5
        mock_embed.return_value = [0.1] * 768

        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "I feel anxious all the time.",
        })
    assert resp.status_code == 200

    events_resp = await client.get(f"/safety/events/{session_id}")
    events = events_resp.json()
    boundary_events = [e for e in events if e["event_type"] == "boundary_violation"]
    assert len(boundary_events) >= 1


@pytest.mark.asyncio
async def test_referral_logged(client):
    create_resp = await client.post("/sessions", json={"title": "Referral"})
    session_id = create_resp.json()["id"]

    with patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed:
        mock_embed.return_value = [0.1] * 768

        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "I want to end my life",
        })
    assert resp.status_code == 200

    events_resp = await client.get(f"/safety/events/{session_id}")
    events = events_resp.json()
    event_types = {e["event_type"] for e in events}
    assert "referral_given" in event_types


@pytest.mark.asyncio
async def test_normal_chat_still_works_with_safety(client):
    create_resp = await client.post("/sessions", json={
        "title": "Normal Safety", "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "Tell me more about that."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 10
        mock_chat.return_value.token_count_completion = 5
        mock_embed.return_value = [0.1] * 768

        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "I had a good day today.",
        })
    assert resp.status_code == 200
    assert resp.json()["response"] == "Tell me more about that."

    events_resp = await client.get(f"/safety/events/{session_id}")
    assert events_resp.json() == []
