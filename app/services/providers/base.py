from abc import ABC, abstractmethod

from pydantic import BaseModel


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatResult(BaseModel):
    content: str
    model: str
    provider: str
    token_count_prompt: int = 0
    token_count_completion: int = 0


class LLMProvider(ABC):
    @abstractmethod
    async def chat(
        self,
        messages: list[ChatMessage],
        model: str | None = None,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> ChatResult:
        ...

    @abstractmethod
    async def embed(self, text: str, model: str | None = None) -> list[float]:
        ...

    @abstractmethod
    async def list_models(self) -> list[str]:
        ...

    @property
    @abstractmethod
    def provider_name(self) -> str:
        ...
