from __future__ import annotations

import os
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.voice import VoiceRecording
from app.services.providers import get_stt_provider


class VoiceService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def upload_and_transcribe(
        self, session_id: str, audio_data: bytes, filename: str = "recording.wav", mime_type: str = "audio/wav"
    ) -> VoiceRecording:
        upload_dir = settings.voice_upload_dir
        os.makedirs(upload_dir, exist_ok=True)

        recording_id = str(uuid.uuid4())
        ext = os.path.splitext(filename)[1] or ".wav"
        file_path = os.path.join(upload_dir, f"{recording_id}{ext}")

        with open(file_path, "wb") as f:
            f.write(audio_data)

        stt = get_stt_provider()
        result = await stt.transcribe(file_path)

        recording = VoiceRecording(
            id=recording_id,
            session_id=session_id,
            file_path=file_path,
            duration_seconds=result.duration_seconds,
            transcript=result.text,
            mime_type=mime_type,
        )
        self.db.add(recording)
        await self.db.commit()
        await self.db.refresh(recording)
        return recording

    async def get_recording(self, recording_id: str) -> VoiceRecording | None:
        result = await self.db.execute(select(VoiceRecording).where(VoiceRecording.id == recording_id))
        return result.scalar_one_or_none()

    async def list_recordings(self, session_id: str) -> list[VoiceRecording]:
        result = await self.db.execute(
            select(VoiceRecording).where(VoiceRecording.session_id == session_id).order_by(VoiceRecording.created_at.desc())
        )
        return list(result.scalars().all())

    async def delete_recording(self, recording_id: str) -> bool:
        recording = await self.get_recording(recording_id)
        if not recording:
            return False
        if os.path.exists(recording.file_path):
            os.remove(recording.file_path)
        await self.db.delete(recording)
        await self.db.commit()
        return True
