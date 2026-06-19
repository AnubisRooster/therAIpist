from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

from app.core.config import settings
from app.models.base import Base

engine = create_async_engine(settings.database_url, echo=False)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def get_db() -> AsyncSession:
    async with async_session() as session:
        yield session


async def init_db():
    """Create tables directly from model metadata.

    Convenience for local development and tests. For production, manage the
    schema with Alembic migrations (`alembic upgrade head`) instead.
    """
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
