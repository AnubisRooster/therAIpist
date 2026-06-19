import pytest
import os
from unittest.mock import patch, AsyncMock, MagicMock


@pytest.mark.asyncio
async def test_upload_audio(client):
    create_resp = await client.post("/sessions", json={"title": "Voice Session"})
    session_id = create_resp.json()["id"]

    resp = await client.post(
        "/voice/upload",
        data={"session_id": session_id},
        files={"audio": ("test.wav", b"fake audio content", "audio/wav")},
    )
    assert resp.status_code == 201
    data = resp.json()
    assert data["session_id"] == session_id
    assert "Transcribed" in data["transcript"]
    assert data["duration_seconds"] > 0


@pytest.mark.asyncio
async def test_list_recordings(client):
    create_resp = await client.post("/sessions", json={"title": "List Recordings"})
    session_id = create_resp.json()["id"]

    await client.post(
        "/voice/upload",
        data={"session_id": session_id},
        files={"audio": ("a.wav", b"audio 1", "audio/wav")},
    )
    await client.post(
        "/voice/upload",
        data={"session_id": session_id},
        files={"audio": ("b.wav", b"audio 2", "audio/wav")},
    )

    resp = await client.get(f"/voice/recordings/{session_id}")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) == 2


@pytest.mark.asyncio
async def test_list_recordings_empty(client):
    resp = await client.get("/voice/recordings/nonexistent")
    assert resp.status_code == 200
    assert resp.json() == []


@pytest.mark.asyncio
async def test_delete_recording(client):
    create_resp = await client.post("/sessions", json={"title": "Delete Recording"})
    session_id = create_resp.json()["id"]

    upload_resp = await client.post(
        "/voice/upload",
        data={"session_id": session_id},
        files={"audio": ("delete.wav", b"delete me", "audio/wav")},
    )
    recording_id = upload_resp.json()["id"]

    resp = await client.delete(f"/voice/recordings/{recording_id}")
    assert resp.status_code == 204

    list_resp = await client.get(f"/voice/recordings/{session_id}")
    assert len(list_resp.json()) == 0


@pytest.mark.asyncio
async def test_delete_recording_not_found(client):
    resp = await client.delete("/voice/recordings/nonexistent")
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_voice_chat(client):
    create_resp = await client.post("/sessions", json={
        "title": "Voice Chat", "provider": "ollama",
    })
    session_id = create_resp.json()["id"]

    with (
        patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
        patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
    ):
        mock_chat.return_value.content = "I hear you. Tell me more."
        mock_chat.return_value.model = "llama3.2"
        mock_chat.return_value.provider = "ollama"
        mock_chat.return_value.token_count_prompt = 50
        mock_chat.return_value.token_count_completion = 10
        mock_embed.return_value = [0.1] * 768

        resp = await client.post(
            "/voice/chat",
            data={"session_id": session_id},
            files={"audio": ("chat.wav", b"voice chat content", "audio/wav")},
        )
    assert resp.status_code == 200
    data = resp.json()
    assert "transcript" in data
    assert data["response"] == "I hear you. Tell me more."
    assert data["session_id"] == session_id
    assert data["recording_id"] is not None


@pytest.mark.asyncio
async def test_voice_chat_session_not_found(client):
    resp = await client.post(
        "/voice/chat",
        data={"session_id": "nonexistent"},
        files={"audio": ("test.wav", b"audio", "audio/wav")},
    )
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_upload_cleans_up_file(client):
    create_resp = await client.post("/sessions", json={"title": "Cleanup"})
    session_id = create_resp.json()["id"]

    upload_resp = await client.post(
        "/voice/upload",
        data={"session_id": session_id},
        files={"audio": ("cleanup.wav", b"cleanup test", "audio/wav")},
    )
    recording_id = upload_resp.json()["id"]

    from app.core.config import settings
    import glob
    uploaded_files = glob.glob(os.path.join(settings.voice_upload_dir, f"{recording_id}*"))
    assert len(uploaded_files) == 1

    await client.delete(f"/voice/recordings/{recording_id}")
    remaining = glob.glob(os.path.join(settings.voice_upload_dir, f"{recording_id}*"))
    assert len(remaining) == 0
