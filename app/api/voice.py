from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import VoiceRecordingResponse, VoiceChatResponse, ChatResponse
from app.services.voice_service import VoiceService

router = APIRouter(prefix="/voice", tags=["voice"])


async def get_voice_service(db: AsyncSession = Depends(get_db)) -> VoiceService:
    return VoiceService(db=db)


@router.post("/upload", response_model=VoiceRecordingResponse, status_code=201)
async def upload_audio(
    session_id: str = Form(...),
    audio: UploadFile = File(...),
    service: VoiceService = Depends(get_voice_service),
):
    audio_data = await audio.read()
    recording = await service.upload_and_transcribe(
        session_id=session_id,
        audio_data=audio_data,
        filename=audio.filename or "recording.wav",
        mime_type=audio.content_type or "audio/wav",
    )
    return VoiceRecordingResponse(
        id=recording.id, session_id=recording.session_id,
        duration_seconds=recording.duration_seconds,
        transcript=recording.transcript, mime_type=recording.mime_type,
        created_at=recording.created_at,
    )


@router.get("/recordings/{session_id}", response_model=list[VoiceRecordingResponse])
async def list_recordings(
    session_id: str,
    service: VoiceService = Depends(get_voice_service),
):
    recordings = await service.list_recordings(session_id)
    return [
        VoiceRecordingResponse(
            id=r.id, session_id=r.session_id,
            duration_seconds=r.duration_seconds,
            transcript=r.transcript, mime_type=r.mime_type,
            created_at=r.created_at,
        )
        for r in recordings
    ]


@router.delete("/recordings/{recording_id}", status_code=204)
async def delete_recording(
    recording_id: str,
    service: VoiceService = Depends(get_voice_service),
):
    deleted = await service.delete_recording(recording_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Recording not found")


@router.post("/chat", response_model=VoiceChatResponse)
async def voice_chat(
    session_id: str = Form(...),
    audio: UploadFile = File(...),
    service: VoiceService = Depends(get_voice_service),
    db: AsyncSession = Depends(get_db),
):
    audio_data = await audio.read()
    recording = await service.upload_and_transcribe(
        session_id=session_id,
        audio_data=audio_data,
        filename=audio.filename or "recording.wav",
        mime_type=audio.content_type or "audio/wav",
    )

    from app.services.chat_service import ChatService

    chat = ChatService(db)
    try:
        response_text, message_id, token_count, provider_used, model_used = await chat.chat(
            session_id=session_id,
            user_message=recording.transcript,
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    return VoiceChatResponse(
        transcript=recording.transcript,
        response=response_text,
        message_id=message_id,
        session_id=session_id,
        recording_id=recording.id,
        provider_used=provider_used,
        model_used=model_used,
        token_count=token_count,
    )
