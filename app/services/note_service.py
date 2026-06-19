from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.note import Note, NOTE_TYPES


NOTE_TEMPLATES = {
    "soap": {
        "subjective": "",
        "objective": "",
        "assessment": "",
        "plan": "",
    },
    "dap": {
        "data": "",
        "assessment": "",
        "plan": "",
    },
    "freeform": {},
}


class NoteService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_note(
        self,
        session_id: str,
        note_type: str = "session_note",
        title: str = "",
        content: str = "",
        structured_data: dict | None = None,
    ) -> Note:
        if note_type not in NOTE_TYPES:
            raise ValueError(f"Invalid note type '{note_type}'. Valid: {sorted(NOTE_TYPES)}")

        note = Note(
            session_id=session_id,
            note_type=note_type,
            title=title,
            content=content,
        )
        if structured_data:
            note.set_data(structured_data)
        self.db.add(note)
        await self.db.commit()
        await self.db.refresh(note)
        return note

    async def get_note(self, note_id: str) -> Note | None:
        result = await self.db.execute(select(Note).where(Note.id == note_id))
        return result.scalar_one_or_none()

    async def list_notes(self, session_id: str, note_type: str | None = None) -> list[Note]:
        stmt = select(Note).where(Note.session_id == session_id).order_by(Note.created_at.desc())
        if note_type:
            stmt = stmt.where(Note.note_type == note_type)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def update_note(
        self,
        note_id: str,
        title: str | None = None,
        content: str | None = None,
        structured_data: dict | None = None,
    ) -> Note | None:
        note = await self.get_note(note_id)
        if not note:
            return None
        if title is not None:
            note.title = title
        if content is not None:
            note.content = content
        if structured_data is not None:
            merged = {**note.data_dict(), **structured_data}
            note.set_data(merged)
        note.updated_at = datetime.now(timezone.utc).isoformat()
        await self.db.commit()
        await self.db.refresh(note)
        return note

    async def delete_note(self, note_id: str) -> bool:
        note = await self.get_note(note_id)
        if not note:
            return False
        await self.db.delete(note)
        await self.db.commit()
        return True
