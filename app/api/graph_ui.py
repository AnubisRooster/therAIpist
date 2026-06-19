from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import (
    GraphVisualizationResponse,
    GraphStatsResponse,
    GraphTimelineResponse,
)
from app.services.graph_ui_service import GraphUIService

router = APIRouter(prefix="/graph-ui", tags=["graph-ui"])


async def get_graph_ui_service(db: AsyncSession = Depends(get_db)) -> GraphUIService:
    return GraphUIService(db=db)


@router.get("/{session_id}/visualization", response_model=GraphVisualizationResponse)
async def get_visualization(
    session_id: str,
    service: GraphUIService = Depends(get_graph_ui_service),
):
    return await service.get_visualization(session_id)


@router.get("/{session_id}/stats", response_model=GraphStatsResponse)
async def get_stats(
    session_id: str,
    service: GraphUIService = Depends(get_graph_ui_service),
):
    return await service.get_stats(session_id)


@router.get("/{session_id}/timeline", response_model=GraphTimelineResponse)
async def get_timeline(
    session_id: str,
    service: GraphUIService = Depends(get_graph_ui_service),
):
    return await service.get_timeline(session_id)
