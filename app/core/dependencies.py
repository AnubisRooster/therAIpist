from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.services.chat_service import ChatService


async def get_chat_service(db: AsyncSession = Depends(get_db)) -> ChatService:
    return ChatService(db=db)
