import os

from app.services.providers.stt_base import STTProvider, TranscriptResult


class MockSTTProvider(STTProvider):
    @property
    def provider_name(self) -> str:
        return "mock"

    async def transcribe(self, audio_path: str) -> TranscriptResult:
        size = os.path.getsize(audio_path) if os.path.exists(audio_path) else 0
        duration = size / 16000.0
        return TranscriptResult(
            text=f"[Transcribed from audio: {size} bytes, {duration:.1f}s]",
            duration_seconds=duration,
            confidence=0.95,
        )
