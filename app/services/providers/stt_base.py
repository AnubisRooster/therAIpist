from abc import ABC, abstractmethod


class TranscriptResult:
    def __init__(self, text: str, duration_seconds: float = 0.0, confidence: float = 1.0):
        self.text = text
        self.duration_seconds = duration_seconds
        self.confidence = confidence


class STTProvider(ABC):
    @abstractmethod
    async def transcribe(self, audio_path: str) -> TranscriptResult:
        ...

    @property
    @abstractmethod
    def provider_name(self) -> str:
        ...
