import pytest
from unittest.mock import patch, AsyncMock, MagicMock

from app.services.providers.openrouter import OpenRouterProvider
from app.services.providers.base import ChatMessage
from app.core.config import Settings


@pytest.fixture
def provider():
    config = Settings(openrouter_api_key="test-key")
    return OpenRouterProvider(config)


@pytest.mark.asyncio
async def test_openrouter_chat(provider):
    messages = [ChatMessage(role="user", content="Hello")]
    with patch("httpx.AsyncClient.post", new_callable=AsyncMock) as mock_post:
        mock_response = MagicMock()
        mock_response.json.return_value = {
            "choices": [{"message": {"content": "Hi there!"}}],
            "model": "openai/gpt-4o",
            "usage": {"prompt_tokens": 15, "completion_tokens": 8},
        }
        mock_post.return_value = mock_response

        result = await provider.chat(messages)
        assert result.content == "Hi there!"
        assert result.model == "openai/gpt-4o"
        assert result.provider == "openrouter"
        assert result.token_count_prompt == 15
        assert result.token_count_completion == 8
