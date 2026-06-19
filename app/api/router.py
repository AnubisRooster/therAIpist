from fastapi import APIRouter

from app.api.health import router as health_router
from app.api.sessions import router as sessions_router
from app.api.chat import router as chat_router
from app.api.memory import router as memory_router
from app.api.graph import router as graph_router
from app.api.insights import router as insights_router
from app.api.therapy import router as therapy_router
from app.api.notes import router as notes_router
from app.api.dashboard import router as dashboard_router
from app.api.graph_ui import router as graph_ui_router
from app.api.dreams import router as dreams_router
from app.api.voice import router as voice_router
from app.api.safety import router as safety_router
from app.api.mode import router as mode_router
from app.api.agents import router as agents_router

router = APIRouter()
router.include_router(health_router)
router.include_router(sessions_router)
router.include_router(chat_router)
router.include_router(memory_router)
router.include_router(graph_router)
router.include_router(insights_router)
router.include_router(therapy_router)
router.include_router(notes_router)
router.include_router(dashboard_router)
router.include_router(graph_ui_router)
router.include_router(dreams_router)
router.include_router(voice_router)
router.include_router(safety_router)
router.include_router(mode_router)
router.include_router(agents_router)
