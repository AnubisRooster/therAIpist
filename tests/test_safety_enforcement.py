import pytest
from unittest.mock import patch, AsyncMock

from app.services.safety_service import FILTERED_RESPONSE_MESSAGE


@pytest.mark.asyncio
async def test_boundary_response_is_filtered(client):
    create_resp = await client.post("/sessions", json={
        "title": "Boundary Filter", "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "I diagnose you with major depressive disorder."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 10
        mock_chat.return_value.token_count_completion = 5
        mock_embed.return_value = [0.1] * 768

        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "I feel low all the time.",
        })

    assert resp.status_code == 200
    data = resp.json()
    # The unsafe diagnostic content must not reach the user.
    assert "major depressive disorder" not in data["response"].lower()
    assert data["response"] == FILTERED_RESPONSE_MESSAGE

    events_resp = await client.get(f"/safety/events/{session_id}")
    events = events_resp.json()
    assert any(e["event_type"] == "boundary_violation" for e in events)


@pytest.mark.asyncio
async def test_negation_is_not_crisis(client):
    create_resp = await client.post("/sessions", json={
        "title": "Negation", "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "I'm really glad to hear that."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 10
        mock_chat.return_value.token_count_completion = 5
        mock_embed.return_value = [0.1] * 768

        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "Don't worry, I don't want to die — I'm feeling better.",
        })

    assert resp.status_code == 200
    data = resp.json()
    assert "988" not in data["response"]

    events_resp = await client.get(f"/safety/events/{session_id}")
    events = events_resp.json()
    assert not any(e["event_type"] == "crisis_keyword" for e in events)


@pytest.mark.asyncio
async def test_crisis_resource_message_consistent(client):
    create_resp = await client.post("/sessions", json={
        "title": "Crisis Consistency", "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed:
        mock_embed.return_value = [0.1] * 768
        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "I want to kill myself",
        })

    assert resp.status_code == 200
    response = resp.json()["response"]
    assert "988" in response
    assert "741741" in response
    assert "911" in response
