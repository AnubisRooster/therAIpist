from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import ModeResponse, ModeUpdateResponse, ModeSetRequest
from app.services.mode_service import ModeService

router = APIRouter(prefix="/mode", tags=["mode"])


async def get_mode_service(db: AsyncSession = Depends(get_db)) -> ModeService:
    return ModeService(db=db)


@router.get("/{session_id}", response_model=ModeResponse)
async def get_mode(
    session_id: str,
    service: ModeService = Depends(get_mode_service),
):
    return await service.get_mode(session_id)


@router.patch("/{session_id}", response_model=ModeUpdateResponse)
async def set_mode(
    session_id: str,
    data: ModeSetRequest,
    service: ModeService = Depends(get_mode_service),
):
    try:
        session = await service.set_mode(
            session_id=session_id,
            mode=data.mode,
            local_model=data.local_model,
        )
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return ModeUpdateResponse(
        session_id=session.id,
        mode=session.mode,
        provider=session.provider,
        local_model=session.local_model,
    )
