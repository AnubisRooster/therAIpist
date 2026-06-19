from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import router
from app.core.config import settings
from app.core.database import init_db
from app.core.security import require_api_key


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield


app = FastAPI(title="Psychotherapist AI", version="0.1.0", lifespan=lifespan)

# Per the CORS spec a wildcard origin cannot be combined with credentials.
# Only allow credentials when origins are explicitly listed.
allow_credentials = settings.cors_allow_credentials and "*" not in settings.cors_origins

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router, dependencies=[Depends(require_api_key)])
