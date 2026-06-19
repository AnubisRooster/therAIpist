import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.note import NOTE_TYPES


@pytest.mark.asyncio
async def test_create_session_note(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "Note Session"})
    session_id = create_resp.json()["id"]

    resp = await client.post("/notes", json={
        "session_id": session_id,
        "note_type": "session_note",
        "title": "First session",
        "content": "Client presented with anxiety concerns.",
        "structured_data": {"mood": "anxious", "risk_level": "low"},
    })
    assert resp.status_code == 201
    data = resp.json()
    assert data["note_type"] == "session_note"
    assert data["title"] == "First session"
    assert data["structured_data"]["mood"] == "anxious"
    assert data["structured_data"]["risk_level"] == "low"


@pytest.mark.asyncio
async def test_create_journal_entry(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "Journal Session"})
    session_id = create_resp.json()["id"]

    resp = await client.post("/notes", json={
        "session_id": session_id,
        "note_type": "journal",
        "title": "Today's reflection",
        "content": "I felt better after our conversation.",
    })
    assert resp.status_code == 201
    assert resp.json()["note_type"] == "journal"


@pytest.mark.asyncio
async def test_create_note_invalid_type(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "Bad Note"})
    session_id = create_resp.json()["id"]

    resp = await client.post("/notes", json={
        "session_id": session_id,
        "note_type": "invalid_type",
    })
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_list_notes(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "List Notes"})
    session_id = create_resp.json()["id"]

    await client.post("/notes", json={
        "session_id": session_id, "note_type": "session_note", "title": "Note 1",
    })
    await client.post("/notes", json={
        "session_id": session_id, "note_type": "journal", "title": "Journal 1",
    })
    await client.post("/notes", json={
        "session_id": session_id, "note_type": "session_note", "title": "Note 2",
    })

    resp = await client.get(f"/notes/{session_id}")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) == 3

    resp = await client.get(f"/notes/{session_id}?note_type=session_note")
    assert len(resp.json()) == 2

    resp = await client.get(f"/notes/{session_id}?note_type=journal")
    assert len(resp.json()) == 1


@pytest.mark.asyncio
async def test_list_notes_empty_session(client: AsyncClient):
    resp = await client.get("/notes/nonexistent")
    assert resp.status_code == 200
    assert resp.json() == []


@pytest.mark.asyncio
async def test_update_note(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "Update Note"})
    session_id = create_resp.json()["id"]

    note_resp = await client.post("/notes", json={
        "session_id": session_id,
        "title": "Original",
        "content": "Original content",
    })
    note_id = note_resp.json()["id"]

    resp = await client.patch(f"/notes/{note_id}", json={
        "title": "Updated",
        "content": "Updated content",
        "structured_data": {"key": "value"},
    })
    assert resp.status_code == 200
    data = resp.json()
    assert data["title"] == "Updated"
    assert data["content"] == "Updated content"
    assert data["structured_data"]["key"] == "value"


@pytest.mark.asyncio
async def test_update_note_not_found(client: AsyncClient):
    resp = await client.patch("/notes/nonexistent", json={"title": "Nope"})
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_delete_note(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "Delete Note"})
    session_id = create_resp.json()["id"]

    note_resp = await client.post("/notes", json={
        "session_id": session_id,
        "title": "To Delete",
    })
    note_id = note_resp.json()["id"]

    resp = await client.delete(f"/notes/{note_id}")
    assert resp.status_code == 204

    get_resp = await client.get(f"/notes/{note_id}")
    # listing by note_id doesn't exist, but listing by session shows none
    list_resp = await client.get(f"/notes/{session_id}")
    assert len(list_resp.json()) == 0


@pytest.mark.asyncio
async def test_delete_note_not_found(client: AsyncClient):
    resp = await client.delete("/notes/nonexistent")
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_soap_note_template(client: AsyncClient):
    create_resp = await client.post("/sessions", json={"title": "SOAP"})
    session_id = create_resp.json()["id"]

    resp = await client.post("/notes", json={
        "session_id": session_id,
        "note_type": "session_note",
        "title": "SOAP Note",
        "content": "Structured SOAP note",
        "structured_data": {
            "subjective": "Client reports feeling anxious",
            "objective": "Client appeared tense",
            "assessment": "Generalized anxiety symptoms",
            "plan": "Continue weekly sessions, practice breathing exercises",
        },
    })
    assert resp.status_code == 201
    data = resp.json()
    assert data["structured_data"]["subjective"] == "Client reports feeling anxious"
    assert data["structured_data"]["plan"] == "Continue weekly sessions, practice breathing exercises"


@pytest.mark.asyncio
async def test_note_types_defined():
    assert "session_note" in NOTE_TYPES
    assert "journal" in NOTE_TYPES
    assert "reflection" in NOTE_TYPES
