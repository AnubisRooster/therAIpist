import httpx

from app.core.config import settings
from app.services.providers.base import LLMProvider, ChatMessage, ChatResult


class OllamaProvider(LLMProvider):
    def __init__(self, config=settings):
        self.base_url = config.ollama_base_url
        self.default_model = config.ollama_default_model

    @property
    def provider_name(self) -> str:
        return "ollama"

    async def list_models(self) -> list[str]:
        try:
            async with httpx.AsyncClient() as client:
                resp = await client.get(f"{self.base_url}/api/tags", timeout=5)
                resp.raise_for_status()
                data = resp.json()
            return [m["name"] for m in data.get("models", [])]
        except Exception:
            return []

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
            "options": {
                "temperature": temperature,
                "num_predict": max_tokens,
            },
            "stream": False,
        }
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                f"{self.base_url}/api/chat",
                json=payload,
                timeout=120,
            )
            resp.raise_for_status()
            data = resp.json()

        return ChatResult(
            content=data["message"]["content"],
            model=data.get("model", model_name),
            provider=self.provider_name,
            token_count_prompt=data.get("prompt_eval_count", 0),
            token_count_completion=data.get("eval_count", 0),
        )

    async def embed(self, text: str, model: str | None = None) -> list[float]:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                f"{self.base_url}/api/embeddings",
                json={"model": model or self.default_model, "prompt": text},
                timeout=30,
            )
            resp.raise_for_status()
            return resp.json()["embedding"]
