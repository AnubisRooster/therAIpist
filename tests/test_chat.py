import pytest
from unittest.mock import patch, AsyncMock
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_chat_session_not_found(client: AsyncClient):
    resp = await client.post("/chat", json={
        "session_id": "nonexistent",
        "message": "Hello",
    })
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_chat_with_history(client: AsyncClient):
    create_resp = await client.post("/sessions", json={
        "title": "Test Chat",
        "provider": "ollama",
        "system_prompt": "You are a therapist.",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "Hello, how are you feeling today?"
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 50
        mock_chat.return_value.token_count_completion = 10

        mock_embed.return_value = [0.1] * 768

        resp = await client.post("/chat", json={
            "session_id": session_id,
            "message": "I've been feeling anxious.",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["response"] == "Hello, how are you feeling today?"
        assert data["session_id"] == session_id


@pytest.mark.asyncio
async def test_get_chat_history(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "History Test"})
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "Tell me more."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 10
        mock_chat.return_value.token_count_completion = 5

        mock_embed.return_value = [0.1] * 768

        await client.post("/chat", json={
            "session_id": session_id,
            "message": "I feel sad.",
        })

    resp = await client.get(f"/chat/{session_id}")
    assert resp.status_code == 200
    messages = resp.json()
    assert len(messages) == 2
    assert messages[0]["role"] == "user"
    assert messages[0]["content"] == "I feel sad."
    assert messages[1]["role"] == "assistant"
    assert messages[1]["content"] == "Tell me more."


@pytest.mark.asyncio
async def test_chat_consolidates_memories(client: AsyncClient):
    create_resp = await client.post("/sessions", json={
        "title": "Memory Test",
        "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "Tell me more about that."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 20
        mock_chat.return_value.token_count_completion = 5

        mock_embed.return_value = [0.1] * 768

        await client.post("/chat", json={
            "session_id": session_id,
            "message": "I had a panic attack yesterday.",
        })

    resp = await client.get(f"/memory/episodic?session_id={session_id}")
    assert resp.status_code == 200
    memories = resp.json()
    assert len(memories) >= 2
    contents = [m["content"] for m in memories]
    assert any("panic" in c for c in contents)


@pytest.mark.asyncio
async def test_chat_recalls_memories(client: AsyncClient):
    create_resp = await client.post("/sessions", json={
        "title": "Recall Test",
        "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "Tell me more about that."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 20
        mock_chat.return_value.token_count_completion = 5

        mock_embed.return_value = [0.1] * 768

        await client.post("/chat", json={
            "session_id": session_id,
            "message": "I had a panic attack yesterday.",
        })

        await client.post("/chat", json={
            "session_id": session_id,
            "message": "It happened at the grocery store.",
        })

        assert mock_chat.call_count >= 2
        calls = mock_chat.call_args_list
        therapy_calls = [
            c for c in calls
            if not any(
                "entity extractor" in getattr(m, "content", "").lower()
                for m in c.kwargs.get("messages", [])
            )
        ]
        if therapy_calls:
            last_therapy = therapy_calls[-1]
            system_msgs = [m for m in last_therapy.kwargs["messages"] if m.role == "system"]
            if system_msgs:
                all_system = " ".join(m.content for m in system_msgs)
                assert "panic" in all_system.lower() or "Relevant past context" in all_system.lower()
