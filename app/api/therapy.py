from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import (
    ProgressResponse,
    InterventionSuggestionResponse,
)
from app.services.therapy_service import TherapyService

router = APIRouter(prefix="/therapy", tags=["therapy"])


async def get_therapy_service(db: AsyncSession = Depends(get_db)) -> TherapyService:
    return TherapyService(db=db)


@router.get("/{session_id}/progress", response_model=ProgressResponse)
async def get_progress(
    session_id: str,
    service: TherapyService = Depends(get_therapy_service),
):
    progress = await service.get_progress(session_id)
    return ProgressResponse(**progress)


@router.get("/{session_id}/interventions", response_model=InterventionSuggestionResponse)
async def suggest_intervention(
    session_id: str,
    service: TherapyService = Depends(get_therapy_service),
):
    result = await service.suggest_intervention(session_id)
    if result is None:
        return InterventionSuggestionResponse(
            intervention="", modality="", rationale="No session data available.", description="",
        )
    return InterventionSuggestionResponse(**result)
