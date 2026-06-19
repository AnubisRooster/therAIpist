import hmac

from fastapi import Header, HTTPException, status

from app.core.config import settings


async def require_api_key(
    authorization: str | None = Header(default=None),
    x_api_key: str | None = Header(default=None),
) -> None:
    """Authenticate requests when an API key is configured.

    Accepts either ``Authorization: Bearer <key>`` or ``X-API-Key: <key>``.
    When ``settings.api_key`` is empty, authentication is disabled (local dev).
    """
    if not settings.api_key:
        return

    provided: str | None = None
    if authorization and authorization.lower().startswith("bearer "):
        provided = authorization[7:].strip()
    elif x_api_key:
        provided = x_api_key.strip()

    if not provided or not hmac.compare_digest(provided, settings.api_key):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API key",
            headers={"WWW-Authenticate": "Bearer"},
        )
