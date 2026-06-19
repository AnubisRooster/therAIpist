import pytest
from unittest.mock import patch, AsyncMock, MagicMock

from app.services.providers.ollama import OllamaProvider
from app.services.providers.base import ChatMessage
from app.core.config import Settings


@pytest.fixture
def provider():
    config = Settings(ollama_base_url="http://localhost:11434")
    return OllamaProvider(config)


@pytest.mark.asyncio
async def test_ollama_chat(provider):
    messages = [ChatMessage(role="user", content="Hello")]
    with patch("httpx.AsyncClient.post", new_callable=AsyncMock) as mock_post:
        mock_response = MagicMock()
        mock_response.json.return_value = {
            "message": {"content": "Hi there!"},
            "model": "llama3.2",
            "prompt_eval_count": 10,
            "eval_count": 5,
        }
        mock_post.return_value = mock_response

        result = await provider.chat(messages)
        assert result.content == "Hi there!"
        assert result.model == "llama3.2"
        assert result.provider == "ollama"
