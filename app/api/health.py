from fastapi import APIRouter

from app.core.config import settings
from app.models.schemas import HealthResponse
from app.services.providers import get_provider

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthResponse)
async def health_check():
    providers = {}
    for name in ["ollama", "openrouter"]:
        try:
            provider = get_provider(name, settings)
            models = await provider.list_models()
            providers[name] = {"available": True, "models": models[:5]}
        except Exception as e:
            providers[name] = {"available": False, "error": str(e)}
    return HealthResponse(status="ok", providers=providers)
