from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import SafetyEventResponse, SafetySummaryResponse
from app.services.safety_service import SafetyService

router = APIRouter(prefix="/safety", tags=["safety"])


async def get_safety_service(db: AsyncSession = Depends(get_db)) -> SafetyService:
    return SafetyService(db=db)


@router.get("/events/{session_id}", response_model=list[SafetyEventResponse])
async def get_events(
    session_id: str,
    service: SafetyService = Depends(get_safety_service),
):
    events = await service.get_events(session_id)
    return [
        SafetyEventResponse(
            id=e.id, session_id=e.session_id, event_type=e.event_type,
            level=e.level, source=e.source, message=e.message,
            detail=e.detail, created_at=e.created_at,
        )
        for e in events
    ]


@router.get("/summary", response_model=SafetySummaryResponse)
async def get_summary(
    service: SafetyService = Depends(get_safety_service),
):
    return await service.get_summary()
