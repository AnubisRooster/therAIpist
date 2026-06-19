from app.core.config import settings
from app.services.providers.base import ChatMessage, ChatResult, LLMProvider
from app.services.providers.ollama import OllamaProvider
from app.services.providers.openrouter import OpenRouterProvider
from app.services.providers.stt_base import STTProvider, TranscriptResult
from app.services.providers.stt_mock import MockSTTProvider


def get_provider(provider_name: str, config: type[settings] = settings):
    providers = {
        "ollama": OllamaProvider(config),
        "openrouter": OpenRouterProvider(config),
    }
    if provider_name not in providers:
        raise ValueError(f"Unknown provider '{provider_name}'. Available: {list(providers.keys())}")
    return providers[provider_name]


def get_stt_provider(config: type[settings] = settings) -> STTProvider:
    return MockSTTProvider()


__all__ = [
    "ChatMessage", "ChatResult",
    "LLMProvider", "OllamaProvider", "OpenRouterProvider",
    "STTProvider", "TranscriptResult", "MockSTTProvider",
    "get_provider", "get_stt_provider",
]
