from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import ChatRequest, ChatResponse, MessageResponse
from app.services.chat_service import ChatService

router = APIRouter(tags=["chat"])


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest, db: AsyncSession = Depends(get_db)):
    service = ChatService(db)
    try:
        response_text, message_id, token_count, provider_used, model_used = await service.chat(
            request.session_id, request.message
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chat error: {str(e)}")

    return ChatResponse(
        response=response_text,
        message_id=message_id,
        session_id=request.session_id,
        provider_used=provider_used,
        model_used=model_used,
        token_count=token_count,
    )


@router.get("/chat/{session_id}", response_model=list[MessageResponse])
async def get_chat_history(session_id: str, db: AsyncSession = Depends(get_db)):
    service = ChatService(db)
    session = await service.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    messages = await service.get_messages(session_id)
    return [
        MessageResponse(
            id=m.id,
            session_id=m.session_id,
            role=m.role,
            content=m.content,
            metadata=m.metadata_dict(),
            created_at=m.created_at,
        )
        for m in messages
    ]
