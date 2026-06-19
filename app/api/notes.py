from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import NoteCreate, NoteUpdate, NoteResponse
from app.services.note_service import NoteService

router = APIRouter(prefix="/notes", tags=["notes"])


async def get_note_service(db: AsyncSession = Depends(get_db)) -> NoteService:
    return NoteService(db=db)


@router.post("", response_model=NoteResponse, status_code=201)
async def create_note(
    data: NoteCreate,
    service: NoteService = Depends(get_note_service),
):
    try:
        note = await service.create_note(
            session_id=data.session_id,
            note_type=data.note_type,
            title=data.title,
            content=data.content,
            structured_data=data.structured_data,
        )
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    return NoteResponse(
        id=note.id, session_id=note.session_id, note_type=note.note_type,
        title=note.title, content=note.content,
        structured_data=note.data_dict(),
        created_at=note.created_at, updated_at=note.updated_at,
    )


@router.get("/{session_id}", response_model=list[NoteResponse])
async def list_notes(
    session_id: str,
    note_type: str | None = Query(None),
    service: NoteService = Depends(get_note_service),
):
    notes = await service.list_notes(session_id, note_type=note_type)
    return [
        NoteResponse(
            id=n.id, session_id=n.session_id, note_type=n.note_type,
            title=n.title, content=n.content,
            structured_data=n.data_dict(),
            created_at=n.created_at, updated_at=n.updated_at,
        )
        for n in notes
    ]


@router.patch("/{note_id}", response_model=NoteResponse)
async def update_note(
    note_id: str,
    data: NoteUpdate,
    service: NoteService = Depends(get_note_service),
):
    note = await service.update_note(
        note_id=note_id,
        title=data.title,
        content=data.content,
        structured_data=data.structured_data,
    )
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return NoteResponse(
        id=note.id, session_id=note.session_id, note_type=note.note_type,
        title=note.title, content=note.content,
        structured_data=note.data_dict(),
        created_at=note.created_at, updated_at=note.updated_at,
    )


@router.delete("/{note_id}", status_code=204)
async def delete_note(
    note_id: str,
    service: NoteService = Depends(get_note_service),
):
    deleted = await service.delete_note(note_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Note not found")
