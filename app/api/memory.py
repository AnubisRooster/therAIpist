from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import (
    EpisodicMemoryResponse,
    SemanticMemoryResponse,
    ProceduralMemoryResponse,
    MemorySearchRequest,
    MemorySearchResponse,
    StoreSemanticRequest,
    StoreProceduralRequest,
    ConsolidateRequest,
)
from app.services.memory_service import MemoryService

router = APIRouter(prefix="/memory", tags=["memory"])


async def get_memory_service(
    db: AsyncSession = Depends(get_db),
) -> MemoryService:
    return MemoryService(db=db)


@router.post("/search", response_model=list[MemorySearchResponse])
async def search_memories(
    request: MemorySearchRequest,
    memory_service: MemoryService = Depends(get_memory_service),
):
    recalled = await memory_service.recall_episodic(
        request.query, limit=request.limit, min_score=request.min_score
    )
    return [
        MemorySearchResponse(
            memory_id=mem.id,
            content=mem.content[:500],
            summary=mem.summary,
            timestamp=mem.timestamp,
            session_id=mem.session_id,
            importance=mem.importance,
            score=score,
        )
        for mem, score in recalled
    ]


@router.get("/episodic", response_model=list[EpisodicMemoryResponse])
async def list_episodic(
    session_id: str | None = Query(None),
    limit: int = Query(50),
    memory_service: MemoryService = Depends(get_memory_service),
):
    memories = await memory_service.list_episodic(session_id=session_id, limit=limit)
    return [
        EpisodicMemoryResponse(
            id=mem.id,
            session_id=mem.session_id,
            content=mem.content[:500],
            summary=mem.summary,
            importance=mem.importance,
            timestamp=mem.timestamp,
            created_at=mem.created_at,
        )
        for mem in memories
    ]


@router.get("/semantic", response_model=list[SemanticMemoryResponse])
async def list_semantic(
    category: str | None = Query(None),
    memory_service: MemoryService = Depends(get_memory_service),
):
    memories = await memory_service.list_semantic(category=category)
    return [
        SemanticMemoryResponse(
            id=mem.id,
            key=mem.key,
            value=mem.value,
            category=mem.category,
            confidence=mem.confidence,
            updated_at=mem.updated_at,
        )
        for mem in memories
    ]


@router.post("/semantic", response_model=SemanticMemoryResponse, status_code=201)
async def store_semantic(
    request: StoreSemanticRequest,
    memory_service: MemoryService = Depends(get_memory_service),
):
    mem = await memory_service.store_semantic(
        key=request.key,
        value=request.value,
        category=request.category,
        confidence=request.confidence,
    )
    return SemanticMemoryResponse(
        id=mem.id,
        key=mem.key,
        value=mem.value,
        category=mem.category,
        confidence=mem.confidence,
        updated_at=mem.updated_at,
    )


@router.get("/procedural", response_model=list[ProceduralMemoryResponse])
async def list_procedural(
    memory_service: MemoryService = Depends(get_memory_service),
):
    memories = await memory_service.list_procedural()
    return [
        ProceduralMemoryResponse(
            id=mem.id,
            context=mem.context,
            technique=mem.technique,
            effectiveness=mem.effectiveness,
            tags=mem.tag_list(),
            created_at=mem.created_at,
        )
        for mem in memories
    ]


@router.post("/procedural", response_model=ProceduralMemoryResponse, status_code=201)
async def store_procedural(
    request: StoreProceduralRequest,
    memory_service: MemoryService = Depends(get_memory_service),
):
    mem = await memory_service.store_procedural(
        context=request.context,
        technique=request.technique,
        effectiveness=request.effectiveness,
        tags=request.tags,
    )
    return ProceduralMemoryResponse(
        id=mem.id,
        context=mem.context,
        technique=mem.technique,
        effectiveness=mem.effectiveness,
        tags=mem.tag_list(),
        created_at=mem.created_at,
    )


@router.post("/consolidate", status_code=200)
async def consolidate(
    request: ConsolidateRequest,
    memory_service: MemoryService = Depends(get_memory_service),
):
    memories = await memory_service.consolidate_conversation(
        session_id=request.session_id,
        user_message=request.user_message,
        assistant_response=request.assistant_response,
    )
    return {"stored": len(memories)}
