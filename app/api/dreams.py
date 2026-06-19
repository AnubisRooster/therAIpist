from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import (
    DreamCreate,
    DreamUpdate,
    DreamResponse,
    DreamAnalysisResponse,
    DreamSymbolExtractResponse,
)
from app.services.dream_service import DreamService

router = APIRouter(prefix="/dreams", tags=["dreams"])


async def get_dream_service(db: AsyncSession = Depends(get_db)) -> DreamService:
    return DreamService(db=db)


@router.post("", response_model=DreamResponse, status_code=201)
async def create_dream(
    data: DreamCreate,
    service: DreamService = Depends(get_dream_service),
):
    dream = await service.create_dream(
        session_id=data.session_id,
        title=data.title,
        narrative=data.narrative,
        feelings=data.feelings,
        dream_date=data.dream_date,
    )
    return DreamResponse(
        id=dream.id, session_id=dream.session_id, title=dream.title,
        narrative=dream.narrative, feelings=dream.feeling_list(),
        symbols=dream.symbol_list(),
        analysis=json_loads(dream.analysis) if dream.analysis else {},
        dream_date=dream.dream_date, created_at=dream.created_at,
    )


@router.get("/{session_id}", response_model=list[DreamResponse])
async def list_dreams(
    session_id: str,
    service: DreamService = Depends(get_dream_service),
):
    dreams = await service.list_dreams(session_id)
    return [
        DreamResponse(
            id=d.id, session_id=d.session_id, title=d.title,
            narrative=d.narrative, feelings=d.feeling_list(),
            symbols=d.symbol_list(),
            analysis=json_loads(d.analysis) if d.analysis else {},
            dream_date=d.dream_date, created_at=d.created_at,
        )
        for d in dreams
    ]


@router.get("/detail/{dream_id}", response_model=DreamResponse)
async def get_dream(
    dream_id: str,
    service: DreamService = Depends(get_dream_service),
):
    dream = await service.get_dream(dream_id)
    if not dream:
        raise HTTPException(status_code=404, detail="Dream not found")
    return DreamResponse(
        id=dream.id, session_id=dream.session_id, title=dream.title,
        narrative=dream.narrative, feelings=dream.feeling_list(),
        symbols=dream.symbol_list(),
        analysis=json_loads(dream.analysis) if dream.analysis else {},
        dream_date=dream.dream_date, created_at=dream.created_at,
    )


@router.patch("/{dream_id}", response_model=DreamResponse)
async def update_dream(
    dream_id: str,
    data: DreamUpdate,
    service: DreamService = Depends(get_dream_service),
):
    dream = await service.update_dream(
        dream_id=dream_id,
        title=data.title,
        narrative=data.narrative,
        feelings=data.feelings,
        dream_date=data.dream_date,
    )
    if not dream:
        raise HTTPException(status_code=404, detail="Dream not found")
    return DreamResponse(
        id=dream.id, session_id=dream.session_id, title=dream.title,
        narrative=dream.narrative, feelings=dream.feeling_list(),
        symbols=dream.symbol_list(),
        analysis=json_loads(dream.analysis) if dream.analysis else {},
        dream_date=dream.dream_date, created_at=dream.created_at,
    )


@router.delete("/{dream_id}", status_code=204)
async def delete_dream(
    dream_id: str,
    service: DreamService = Depends(get_dream_service),
):
    deleted = await service.delete_dream(dream_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Dream not found")


@router.post("/{dream_id}/analyze", response_model=DreamAnalysisResponse)
async def analyze_dream(
    dream_id: str,
    service: DreamService = Depends(get_dream_service),
):
    dream = await service.analyze_dream(dream_id)
    if not dream:
        raise HTTPException(status_code=404, detail="Dream not found")
    return DreamAnalysisResponse(
        id=dream.id, session_id=dream.session_id, title=dream.title,
        analysis=json_loads(dream.analysis) if dream.analysis else {},
        symbols=dream.symbol_list(),
    )


@router.post("/{dream_id}/extract-symbols", response_model=DreamSymbolExtractResponse)
async def extract_symbols(
    dream_id: str,
    service: DreamService = Depends(get_dream_service),
):
    result = await service.extract_and_store_symbols(dream_id)
    return DreamSymbolExtractResponse(**result)


def json_loads(s: str) -> dict:
    import json
    try:
        return json.loads(s)
    except (json.JSONDecodeError, TypeError):
        return {}
