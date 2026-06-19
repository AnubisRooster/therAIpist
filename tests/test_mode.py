from __future__ import annotations

import pytest
import pytest_asyncio
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.session import Session
from app.services.mode_service import ModeService, VALID_MODES
from app.core.config import settings


@pytest_asyncio.fixture
async def test_session(db_session: AsyncSession):
    session = Session(
        id="mode-test-session",
        title="Mode Test",
        provider="ollama",
        model="llama3.2",
        system_prompt="",
        modality="integrated",
        mode="auto",
        local_model="",
    )
    db_session.add(session)
    await db_session.commit()
    yield session
    await db_session.delete(session)
    await db_session.commit()


@pytest.mark.asyncio
async def test_get_mode_default(db_session: AsyncSession, test_session):
    svc = ModeService(db=db_session)
    result = await svc.get_mode(test_session.id)
    assert result["session_id"] == test_session.id
    assert result["mode"] == "auto"
    assert result["provider"] == "ollama"
    assert result["local_available"] == settings.local_mode


@pytest.mark.asyncio
async def test_get_mode_not_found(db_session: AsyncSession):
    svc = ModeService(db=db_session)
    result = await svc.get_mode("nonexistent")
    assert result["mode"] is None


@pytest.mark.asyncio
async def test_set_mode_local(db_session: AsyncSession, test_session):
    svc = ModeService(db=db_session)
    updated = await svc.set_mode(test_session.id, "local", local_model="llama3.2")
    assert updated is not None
    assert updated.mode == "local"
    assert updated.provider == "ollama"
    assert updated.local_model == "llama3.2"

    result = await svc.get_mode(test_session.id)
    assert result["mode"] == "local"
    assert result["provider"] == "ollama"


@pytest.mark.asyncio
async def test_set_mode_cloud(db_session: AsyncSession, test_session):
    svc = ModeService(db=db_session)
    updated = await svc.set_mode(test_session.id, "cloud")
    assert updated is not None
    assert updated.mode == "cloud"
    assert updated.provider == "openrouter"


@pytest.mark.asyncio
async def test_set_mode_invalid(db_session: AsyncSession, test_session):
    svc = ModeService(db=db_session)
    with pytest.raises(ValueError, match="Invalid mode"):
        await svc.set_mode(test_session.id, "nonexistent")


@pytest.mark.asyncio
async def test_resolve_provider_local():
    session = Session(mode="local", provider="ollama")
    svc = ModeService(db=None)  # type: ignore
    assert svc.resolve_provider(session) == "ollama"


@pytest.mark.asyncio
async def test_resolve_provider_cloud():
    session = Session(mode="cloud", provider="openrouter")
    svc = ModeService(db=None)  # type: ignore
    assert svc.resolve_provider(session) == "openrouter"


@pytest.mark.asyncio
async def test_resolve_provider_hybrid():
    session = Session(mode="hybrid", provider="ollama")
    svc = ModeService(db=None)  # type: ignore
    assert svc.resolve_provider(session) == "ollama"


@pytest.mark.asyncio
async def test_resolve_provider_auto():
    session = Session(mode="auto", provider="ollama")
    svc = ModeService(db=None)  # type: ignore
    assert svc.resolve_provider(session) == "ollama"


@pytest.mark.asyncio
async def test_set_mode_not_found(db_session: AsyncSession):
    svc = ModeService(db=db_session)
    result = await svc.set_mode("nonexistent", "local")
    assert result is None


@pytest.mark.asyncio
async def test_set_mode_preserves_provider_when_no_local_model(db_session: AsyncSession, test_session):
    svc = ModeService(db=db_session)
    test_session.provider = "openrouter"
    await db_session.commit()
    updated = await svc.set_mode(test_session.id, "hybrid")
    assert updated.mode == "hybrid"
    assert updated.provider == "openrouter"
