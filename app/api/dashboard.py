from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import SessionDashboardResponse, GlobalDashboardResponse
from app.services.dashboard_service import DashboardService

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


async def get_dashboard_service(db: AsyncSession = Depends(get_db)) -> DashboardService:
    return DashboardService(db=db)


@router.get("/session/{session_id}", response_model=SessionDashboardResponse)
async def get_session_dashboard(
    session_id: str,
    service: DashboardService = Depends(get_dashboard_service),
):
    return await service.get_session_dashboard(session_id)


@router.get("/global", response_model=GlobalDashboardResponse)
async def get_global_dashboard(
    service: DashboardService = Depends(get_dashboard_service),
):
    return await service.get_global_dashboard()
