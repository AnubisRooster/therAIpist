import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_session(client: AsyncClient):
    resp = await client.post("/sessions", json={"title": "Test Session"})
    assert resp.status_code == 201
    data = resp.json()
    assert data["title"] == "Test Session"
    assert data["provider"] == "ollama"
    assert "id" in data


@pytest.mark.asyncio
async def test_list_sessions(client: AsyncClient):
    await client.post("/sessions", json={"title": "Session 1"})
    await client.post("/sessions", json={"title": "Session 2"})
    resp = await client.get("/sessions")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) == 2


@pytest.mark.asyncio
async def test_get_session(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "My Session"})
    session_id = create_resp.json()["id"]
    resp = await client.get(f"/sessions/{session_id}")
    assert resp.status_code == 200
    assert resp.json()["title"] == "My Session"


@pytest.mark.asyncio
async def test_get_session_not_found(client: AsyncClient):
    resp = await client.get("/sessions/nonexistent-id")
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_update_session(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "Original"})
    session_id = create_resp.json()["id"]
    resp = await client.patch(f"/sessions/{session_id}", json={"title": "Updated"})
    assert resp.status_code == 200
    assert resp.json()["title"] == "Updated"


@pytest.mark.asyncio
async def test_delete_session(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "To Delete"})
    session_id = create_resp.json()["id"]
    resp = await client.delete(f"/sessions/{session_id}")
    assert resp.status_code == 204
    get_resp = await client.get(f"/sessions/{session_id}")
    assert get_resp.status_code == 404
