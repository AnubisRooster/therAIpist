from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import (
    GraphNodeResponse,
    GraphEdgeResponse,
    GraphNodeCreate,
    GraphEdgeCreate,
    GraphExtractRequest,
    GraphExtractResponse,
    GraphSessionResponse,
    GraphConnectionResponse,
    GraphThemeResponse,
    GraphPatternResponse,
)
from app.services.graph_service import GraphService

router = APIRouter(prefix="/graph", tags=["graph"])


async def get_graph_service(db: AsyncSession = Depends(get_db)) -> GraphService:
    return GraphService(db=db)


@router.post("/nodes", response_model=GraphNodeResponse, status_code=201)
async def create_node(
    data: GraphNodeCreate,
    service: GraphService = Depends(get_graph_service),
):
    try:
        node = await service.add_node(
            node_type=data.type,
            label=data.label,
            properties=data.properties,
            strength=data.strength,
            session_id=data.session_id,
        )
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    return GraphNodeResponse(
        id=node.id,
        type=node.type,
        label=node.label,
        properties=node.props_dict(),
        strength=node.strength,
        session_id=node.session_id,
        first_seen=node.first_seen,
        last_seen=node.last_seen,
    )


@router.get("/nodes", response_model=list[GraphNodeResponse])
async def list_nodes(
    type: str | None = Query(None),
    query: str | None = Query(None),
    session_id: str | None = Query(None),
    limit: int = Query(50),
    service: GraphService = Depends(get_graph_service),
):
    nodes = await service.find_nodes(
        node_type=type, query=query, session_id=session_id, limit=limit
    )
    return [
        GraphNodeResponse(
            id=n.id, type=n.type, label=n.label,
            properties=n.props_dict(), strength=n.strength,
            session_id=n.session_id, first_seen=n.first_seen, last_seen=n.last_seen,
        )
        for n in nodes
    ]


@router.get("/nodes/{node_id}", response_model=GraphNodeResponse)
async def get_node(
    node_id: str,
    service: GraphService = Depends(get_graph_service),
):
    node = await service.get_node(node_id)
    if not node:
        raise HTTPException(status_code=404, detail="Node not found")
    return GraphNodeResponse(
        id=node.id, type=node.type, label=node.label,
        properties=node.props_dict(), strength=node.strength,
        session_id=node.session_id, first_seen=node.first_seen, last_seen=node.last_seen,
    )


@router.post("/edges", response_model=GraphEdgeResponse, status_code=201)
async def create_edge(
    data: GraphEdgeCreate,
    service: GraphService = Depends(get_graph_service),
):
    try:
        edge = await service.add_edge(
            source_id=data.source_id,
            target_id=data.target_id,
            relationship=data.relationship,
            weight=data.weight,
            metadata=data.metadata,
            session_id=data.session_id,
        )
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    return GraphEdgeResponse(
        id=edge.id, source_id=edge.source_id, target_id=edge.target_id,
        relationship=edge.relationship, weight=edge.weight,
        metadata=edge.meta_dict(), session_id=edge.session_id,
        created_at=edge.created_at,
    )


@router.get("/connections/{node_id}", response_model=GraphConnectionResponse)
async def get_connections(
    node_id: str,
    max_depth: int = Query(2),
    service: GraphService = Depends(get_graph_service),
):
    node = await service.get_node(node_id)
    if not node:
        raise HTTPException(status_code=404, detail="Node not found")
    return await service.get_connections(node_id, max_depth=max_depth)


@router.get("/session/{session_id}", response_model=GraphSessionResponse)
async def get_session_graph(
    session_id: str,
    service: GraphService = Depends(get_graph_service),
):
    return await service.get_session_graph(session_id)


@router.post("/extract", response_model=GraphExtractResponse)
async def extract(
    data: GraphExtractRequest,
    service: GraphService = Depends(get_graph_service),
):
    result = await service.extract_and_store(
        session_id=data.session_id,
        user_message=data.user_message,
        assistant_response=data.assistant_response,
    )
    return GraphExtractResponse(**result)


@router.get("/themes/{session_id}", response_model=list[GraphThemeResponse])
async def get_themes(
    session_id: str,
    service: GraphService = Depends(get_graph_service),
):
    themes = await service.get_themes(session_id)
    return [
        GraphThemeResponse(
            theme=t["theme"], strength=t["strength"],
            properties=t["properties"], related_entities=t["related_entities"],
        )
        for t in themes
    ]


@router.get("/patterns/{session_id}", response_model=list[GraphPatternResponse])
async def get_patterns(
    session_id: str,
    service: GraphService = Depends(get_graph_service),
):
    patterns = await service.get_patterns(session_id)
    return [
        GraphPatternResponse(
            pattern=p["pattern"], source=p["source"],
            target=p["target"], relationship=p["relationship"],
            weight=p["weight"],
        )
        for p in patterns
    ]
