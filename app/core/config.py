from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "sqlite+aiosqlite:///./therapist.db"

    ollama_base_url: str = "http://localhost:11434"
    ollama_default_model: str = "llama3.2"

    openrouter_api_key: str = ""
    openrouter_base_url: str = "https://openrouter.ai/api/v1"
    openrouter_default_model: str = "openai/gpt-4o"

    cors_origins: list[str] = ["*"]

    vector_store_type: str = "in_memory"
    qdrant_url: str = "http://localhost:6333"
    qdrant_api_key: str = ""
    qdrant_collection: str = "therapist_memories"
    embedding_size: int = 768
    memory_recall_limit: int = 3
    memory_recall_min_score: float = 0.3

    voice_upload_dir: str = "./voice_uploads"
    voice_stt_provider: str = "mock"

    local_mode: bool = False
    sync_enabled: bool = False
    sync_server_url: str = ""
    local_data_dir: str = "./local_data"
    offline_embeddings: bool = True

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
