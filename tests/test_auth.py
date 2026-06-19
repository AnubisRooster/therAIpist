import pytest
from httpx import AsyncClient

from app.core.config import settings


@pytest.fixture
def api_key():
    """Enable API-key auth for the duration of a test, then restore."""
    original = settings.api_key
    settings.api_key = "secret-test-key"
    yield "secret-test-key"
    settings.api_key = original


@pytest.mark.asyncio
async def test_auth_disabled_allows_request(client: AsyncClient):
    # settings.api_key defaults to "" → auth disabled
    resp = await client.get("/health")
    assert resp.status_code == 200


@pytest.mark.asyncio
async def test_missing_key_is_rejected(client: AsyncClient, api_key):
    resp = await client.get("/health")
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_bearer_key_accepted(client: AsyncClient, api_key):
    resp = await client.get("/health", headers={"Authorization": f"Bearer {api_key}"})
    assert resp.status_code == 200


@pytest.mark.asyncio
async def test_x_api_key_accepted(client: AsyncClient, api_key):
    resp = await client.get("/health", headers={"X-API-Key": api_key})
    assert resp.status_code == 200


@pytest.mark.asyncio
async def test_wrong_key_rejected(client: AsyncClient, api_key):
    resp = await client.get("/health", headers={"Authorization": "Bearer wrong"})
    assert resp.status_code == 401

    resp = await client.get("/health", headers={"X-API-Key": "wrong"})
    assert resp.status_code == 401
