from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import (
    InsightSummaryResponse,
    RepeatingLoopResponse,
    AdlerianInsightResponse,
    DBTRecommendationResponse,
    ShadowObservationResponse,
    CycleResponse,
)
from app.services.insight_service import InsightService

router = APIRouter(prefix="/insights", tags=["insights"])


async def get_insight_service(db: AsyncSession = Depends(get_db)) -> InsightService:
    return InsightService(db=db)


@router.get("/{session_id}", response_model=InsightSummaryResponse)
async def get_all_insights(
    session_id: str,
    service: InsightService = Depends(get_insight_service),
):
    insights = await service.generate_insights(session_id)
    cycles = await service.detect_cycles(session_id)
    return InsightSummaryResponse(
        session_id=session_id,
        repeating_loops=[
            RepeatingLoopResponse(**loop) for loop in insights.get("repeating_loops", [])
        ],
        adlerian_insights=[
            AdlerianInsightResponse(**insight) for insight in insights.get("adlerian_insights", [])
        ],
        dbt_recommendations=[
            DBTRecommendationResponse(**rec) for rec in insights.get("dbt_recommendations", [])
        ],
        shadow_observations=[
            ShadowObservationResponse(**obs) for obs in insights.get("shadow_observations", [])
        ],
        cycles=[CycleResponse(**c) for c in cycles],
    )


@router.get("/{session_id}/cycles", response_model=list[CycleResponse])
async def get_cycles(
    session_id: str,
    service: InsightService = Depends(get_insight_service),
):
    cycles = await service.detect_cycles(session_id)
    return [CycleResponse(**c) for c in cycles]


@router.get("/{session_id}/adlerian", response_model=list[AdlerianInsightResponse])
async def get_adlerian_insights(
    session_id: str,
    service: InsightService = Depends(get_insight_service),
):
    insights = await service.generate_insights(session_id)
    return [AdlerianInsightResponse(**i) for i in insights.get("adlerian_insights", [])]


@router.get("/{session_id}/dbt", response_model=list[DBTRecommendationResponse])
async def get_dbt_recommendations(
    session_id: str,
    service: InsightService = Depends(get_insight_service),
):
    insights = await service.generate_insights(session_id)
    return [DBTRecommendationResponse(**r) for r in insights.get("dbt_recommendations", [])]


@router.get("/{session_id}/shadow", response_model=list[ShadowObservationResponse])
async def get_shadow_observations(
    session_id: str,
    service: InsightService = Depends(get_insight_service),
):
    insights = await service.generate_insights(session_id)
    return [ShadowObservationResponse(**o) for o in insights.get("shadow_observations", [])]


@router.post("/{session_id}/refresh", response_model=InsightSummaryResponse)
async def refresh_insights(
    session_id: str,
    service: InsightService = Depends(get_insight_service),
):
    insights = await service.generate_insights(session_id)
    cycles = await service.detect_cycles(session_id)
    return InsightSummaryResponse(
        session_id=session_id,
        repeating_loops=[
            RepeatingLoopResponse(**loop) for loop in insights.get("repeating_loops", [])
        ],
        adlerian_insights=[
            AdlerianInsightResponse(**insight) for insight in insights.get("adlerian_insights", [])
        ],
        dbt_recommendations=[
            DBTRecommendationResponse(**rec) for rec in insights.get("dbt_recommendations", [])
        ],
        shadow_observations=[
            ShadowObservationResponse(**obs) for obs in insights.get("shadow_observations", [])
        ],
        cycles=[CycleResponse(**c) for c in cycles],
    )
