import httpx

from app.core.config import settings
from app.services.providers.base import LLMProvider, ChatMessage, ChatResult


class OpenRouterProvider(LLMProvider):
    def __init__(self, config=settings):
        self.api_key = config.openrouter_api_key
        self.base_url = config.openrouter_base_url
        self.default_model = config.openrouter_default_model

    @property
    def provider_name(self) -> str:
        return "openrouter"

    async def list_models(self) -> list[str]:
        headers = {}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        try:
            async with httpx.AsyncClient() as client:
                resp = await client.get(
                    f"{self.base_url}/models",
                    headers=headers,
                    timeout=10,
                )
                resp.raise_for_status()
                data = resp.json()
            return [m["id"] for m in data.get("data", [])]
        except Exception:
            return ["openai/gpt-4o", "anthropic/claude-3.5-sonnet", "meta-llama/llama-3.2-90b"]

    async def chat(
        self,
        messages: list[ChatMessage],
        model: str | None = None,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> ChatResult:
        model_name = model or self.default_model
        payload = {
            "model": model_name,
            "messages": [m.model_dump() for m in messages],
            "temperature": temperature,
            "max_tokens": max_tokens,
        }
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                f"{self.base_url}/chat/completions",
                json=payload,
                headers=headers,
                timeout=120,
            )
            resp.raise_for_status()
            data = resp.json()

        choice = data["choices"][0]
        usage = data.get("usage", {})
        return ChatResult(
            content=choice["message"]["content"],
            model=data.get("model", model_name),
            provider=self.provider_name,
            token_count_prompt=usage.get("prompt_tokens", 0),
            token_count_completion=usage.get("completion_tokens", 0),
        )

    async def embed(self, text: str, model: str | None = None) -> list[float]:
        # OpenRouter does not reliably proxy an embeddings endpoint across
        # models. Use a dedicated embedding provider (settings.embedding_provider)
        # rather than this one for vector recall.
        raise NotImplementedError(
            "OpenRouter does not provide embeddings. Configure a dedicated "
            "embedding_provider (e.g. 'ollama') in settings."
        )
