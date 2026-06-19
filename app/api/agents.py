from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.schemas import AgentResponse, AgentRouteResponse
from app.services.agent_service import AgentService

router = APIRouter(prefix="/agents", tags=["agents"])


async def get_agent_service(db: AsyncSession = Depends(get_db)) -> AgentService:
    return AgentService(db=db)


@router.post("/route", response_model=AgentRouteResponse)
async def route_message(
    session_id: str,
    message: str,
    service: AgentService = Depends(get_agent_service),
):
    result = await service.process_message(session_id, message)
    if "error" in result:
        raise HTTPException(status_code=404, detail=result["error"])
    return AgentRouteResponse(**result)


@router.get("/list", response_model=list[AgentResponse])
async def list_agents():
    from app.agents.orchestrator import AgentOrchestrator
    orch = AgentOrchestrator()
    return [
        AgentResponse(name=a.name)
        for a in orch.agents
    ]
