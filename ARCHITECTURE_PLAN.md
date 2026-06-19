# Psychotherapist AI — Architecture & Build Plan

## 1. Architecture Overview

```
┌──────────────────────┐      REST API       ┌──────────────────────┐
│   iOS App (SwiftUI)  │ ◄─────────────────► │  FastAPI Backend      │
│   iPhone 16 Client   │                      │  (Server / Mac / VPS)│
└──────────────────────┘                      └───────┬──────────────┘
                                                       │
                          ┌────────────────────────────┼────────────────────────────┐
                          │                            │                            │
                    ┌─────▼──────┐             ┌───────▼───────┐          ┌─────────▼─────────┐
                    │  SQLite DB  │             │  Qdrant       │          │  Provider Layer    │
                    │  (iOS +     │             │  (Vector DB)  │          │  ─────────────     │
                    │   Server)   │             │               │          │  Ollama │ OpenRouter│
                    └────────────┘             └───────────────┘          └───────────────────┘
```

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Database** | SQLite | Ships with iOS; zero-config; file-based sync possible |
| **LLM Access** | Provider abstraction | Ollama (local) or OpenRouter (cloud) selectable at runtime |
| **Backend** | FastAPI + Python 3.12 | Async-first; Pydantic validation; LangGraph compatible |
| **Vector Store** | Qdrant | Can be self-hosted; gRPC/REST; efficient on-device options |
| **Knowledge Graph** | Neo4j (server) / SQLite adjacency (on-device) | Phase 3 decision — start with SQLite adjacency lists |
| **iOS UI** | SwiftUI + URLSession | Native; modern; async/await networking |

---

## 2. Directory Structure

```
Therapist/
├── pyproject.toml              # Python project config
├── README.md
├── docker-compose.yml          # Qdrant + Neo4j for dev
│
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app, lifespan, CORS
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   ├── router.py           # Aggregates all routers
│   │   ├── chat.py             # POST /chat, GET /chat/{id}
│   │   ├── sessions.py         # CRUD sessions
│   │   ├── memory.py           # Phase 2: memory recall/search
│   │   ├── insights.py         # Phase 4: insight endpoints
│   │   └── health.py           # GET /health
│   │
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py           # Settings via pydantic-settings
│   │   ├── database.py         # SQLAlchemy engine + session
│   │   └── dependencies.py     # FastAPI dependency injection
│   │
│   ├── models/
│   │   ├── __init__.py
│   │   ├── base.py             # SQLAlchemy declarative base
│   │   ├── conversation.py     # Conversation + Message ORM models
│   │   ├── session.py          # Session ORM model
│   │   ├── memory.py           # Phase 2: memory ORM model
│   │   └── schemas.py          # Pydantic request/response schemas
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── chat_service.py     # Core chat orchestration
│   │   ├── providers/
│   │   │   ├── __init__.py
│   │   │   ├── base.py         # Abstract LLM provider
│   │   │   ├── ollama.py       # Ollama provider
│   │   │   └── openrouter.py   # OpenRouter provider
│   │   └── memory_service.py   # Phase 2
│   │
│   ├── knowledge_graph/        # Phase 3+
│   │   └── __init__.py
│   │
│   └── agents/                 # Phase 16
│       └── __init__.py
│
├── tests/
│   ├── __init__.py
│   ├── conftest.py             # Fixtures: test DB, test client
│   ├── test_health.py
│   ├── test_chat.py
│   ├── test_providers/
│   │   ├── __init__.py
│   │   ├── test_base.py
│   │   ├── test_ollama.py
│   │   └── test_openrouter.py
│   └── test_sessions.py
│
└── ios/                        # Future: SwiftUI project
    └── Therapist/
        ├── TherapistApp.swift
        ├── Models/
        ├── Views/
        ├── Services/
        └── Resources/
```

---

## 3. Database Schema (Phase 1 — SQLite)

```sql
-- Core tables for Phase 1

CREATE TABLE sessions (
    id              TEXT PRIMARY KEY,          -- UUID
    title           TEXT NOT NULL DEFAULT '',
    provider        TEXT NOT NULL DEFAULT 'ollama',  -- 'ollama' | 'openrouter'
    model           TEXT NOT NULL DEFAULT '',
    system_prompt   TEXT NOT NULL DEFAULT '',
    created_at      TEXT NOT NULL,              -- ISO 8601
    updated_at      TEXT NOT NULL               -- ISO 8601
);

CREATE TABLE messages (
    id              TEXT PRIMARY KEY,          -- UUID
    session_id      TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    role            TEXT NOT NULL,             -- 'user' | 'assistant' | 'system'
    content         TEXT NOT NULL,
    metadata        TEXT DEFAULT '{}',         -- JSON blob (token count, latency, etc.)
    created_at      TEXT NOT NULL,             -- ISO 8601
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

CREATE INDEX idx_messages_session_id ON messages(session_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

### Phase 2 additions (Memory Layer)

```sql
CREATE TABLE episodic_memories (
    id              TEXT PRIMARY KEY,
    session_id      TEXT REFERENCES sessions(id),
    content         TEXT NOT NULL,
    embedding_id    TEXT,                      -- Reference to Qdrant point ID
    importance      REAL DEFAULT 0.5,          -- 0.0 to 1.0
    timestamp       TEXT NOT NULL,
    created_at      TEXT NOT NULL
);

CREATE TABLE semantic_memories (
    id              TEXT PRIMARY KEY,
    key             TEXT NOT NULL UNIQUE,       -- e.g. 'user_name', 'fears_heights'
    value           TEXT NOT NULL,
    confidence      REAL DEFAULT 0.5,
    updated_at      TEXT NOT NULL
);
```

### Phase 3 additions (Knowledge Graph)

```sql
CREATE TABLE graph_nodes (
    id              TEXT PRIMARY KEY,
    type            TEXT NOT NULL,             -- 'person' | 'event' | 'emotion' | 'belief' | 'theme'
    label           TEXT NOT NULL,
    properties      TEXT DEFAULT '{}',         -- JSON
    created_at      TEXT NOT NULL
);

CREATE TABLE graph_edges (
    id              TEXT PRIMARY KEY,
    source_id       TEXT NOT NULL REFERENCES graph_nodes(id),
    target_id       TEXT NOT NULL REFERENCES graph_nodes(id),
    relationship    TEXT NOT NULL,             -- 'CAUSES' | 'TRIGGERS' | 'SUPPRESSES' | 'COMPENSATES_FOR'
    weight          REAL DEFAULT 1.0,
    created_at      TEXT NOT NULL
);

CREATE INDEX idx_edges_source ON graph_edges(source_id);
CREATE INDEX idx_edges_target ON graph_edges(target_id);
```

---

## 4. Provider Abstraction Layer

### Interface

```python
class LLMProvider(ABC):
    """Abstract base for LLM providers."""

    @abstractmethod
    async def chat(
        self,
        messages: list[ChatMessage],
        model: str | None = None,
        temperature: float = 0.7,
        max_tokens: int = 4096,
        stream: bool = False,
    ) -> ChatResult:
        """Send a chat completion request."""
        ...

    @abstractmethod
    async def embed(self, text: str) -> list[float]:
        """Generate embedding vector."""
        ...

    @property
    @abstractmethod
    def available_models(self) -> list[str]:
        """Return list of available models."""
        ...

    @property
    @abstractmethod
    def provider_name(self) -> str:
        """Return 'ollama' or 'openrouter'."""
        ...
```

### Factory

```python
def get_provider(provider_name: str, config: Settings) -> LLMProvider:
    providers = {
        "ollama": OllamaProvider(config),
        "openrouter": OpenRouterProvider(config),
    }
    return providers[provider_name]
```

Provider selection is per-session, stored in `sessions.provider`. The iOS app sends the desired provider with each session creation.

---

## 5. API Routes (Phase 1)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check + provider status |
| `POST` | `/sessions` | Create a new therapy session |
| `GET` | `/sessions` | List sessions (paginated) |
| `GET` | `/sessions/{id}` | Get session details |
| `PATCH` | `/sessions/{id}` | Update session (title, provider, model) |
| `DELETE` | `/sessions/{id}` | Delete session |
| `POST` | `/chat` | Send message, get response |
| `GET` | `/chat/{session_id}` | Get conversation history |

### Request/Response Shapes

**POST /chat**
```json
{
  "session_id": "uuid",
  "message": "I've been feeling anxious about work...",
  "stream": false
}
```
```json
{
  "response": "It sounds like work has been weighing on you...",
  "message_id": "uuid",
  "session_id": "uuid",
  "provider_used": "openrouter",
  "model_used": "gpt-4o",
  "token_count": {
    "prompt": 245,
    "completion": 128
  }
}
```

---

## 6. Configuration

```python
# app/core/config.py
class Settings(BaseSettings):
    # Database
    database_url: str = "sqlite+aiosqlite:///./therapist.db"

    # Provider: Ollama
    ollama_base_url: str = "http://localhost:11434"
    ollama_default_model: str = "llama3.2"

    # Provider: OpenRouter
    openrouter_api_key: str = ""
    openrouter_base_url: str = "https://openrouter.ai/api/v1"
    openrouter_default_model: str = "openai/gpt-4o"

    # CORS (allow iOS app)
    cors_origins: list[str] = ["*"]

    # Qdrant (Phase 2)
    qdrant_url: str = "http://localhost:6333"
    qdrant_collection: str = "therapist_memories"
```

Environment variables or `.env` file override all settings.

---

## 7. iOS Compatibility Considerations

| Concern | Solution |
|---------|----------|
| **SQLite on iOS** | iOS has built-in SQLite via `GRDB` or `SQLite.swift` — the backend schema maps 1:1 to on-device storage for offline scenarios |
| **Networking** | `URLSession` + async/await; retry with exponential backoff |
| **Streaming** | Server-Sent Events (SSE) for streaming chat responses |
| **Background** | Background tasks for memory consolidation (Phase 2+) |
| **Local LLM** | Future: connect to local Ollama instance on LAN, or use CoreML |
| **Security** | API key stored in Keychain; all communication over HTTPS |

---

## 8. Phase 1 Delivery Checklist

**Backend:**
- [ ] `pyproject.toml` with all dependencies (fastapi, uvicorn, sqlalchemy, aiosqlite, pydantic-settings, httpx)
- [ ] FastAPI app with lifespan management
- [ ] SQLite database with session + message tables
- [ ] Provider abstraction: `base.py`, `ollama.py`, `openrouter.py`
- [ ] POST `/chat` — send message, get AI response
- [ ] CRUD `/sessions`
- [ ] GET `/chat/{session_id}` — message history
- [ ] Provider switching per session
- [ ] Streaming support (SSE)
- [ ] Tests: health, chat, sessions, both providers
- [ ] `docker-compose.yml` for Qdrant (ready for Phase 2)

**Plan (this document):**
- [x] Architecture plan complete

---

## 9. Sequential Phase Roadmap

```
Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4 ──► Phase 5
(Found'n)   (Memory)    (Graph)     (Insight)   (Therapy)
    │           │            │            │           │
    ▼           ▼            ▼            ▼           ▼
Phase 6     Phase 7      Phase 8      Phase 9     Phase 10
(Notes)     (Dashboard)  (Graph UI)   (Dreams)    (Voice)
    │           │            │            │           │
    ▼           ▼            ▼            ▼           ▼
Phase 11 ──► Phase 12 ──► Phase 13 ─── Phase 14 ──► Phase 15
(Safety)    (iOS App)   (Windows)     (Local)     (Hybrid)
    │
    ▼
Phase 16
(Agents)
```

**Critical path**: Phase 1 → 2 → 3 → 4 → 5 must be built sequentially — each depends on the previous. Phases 6–16 branch and can be parallelized where resources allow.

---

## 10. Next Steps

1. Review and approve this architecture plan
2. Scaffold the Python project (`pyproject.toml`, directory structure, config)
3. Implement database models and migrations
4. Implement provider abstraction layer
5. Implement chat service
6. Implement API routes
7. Write tests
8. Verify with both Ollama and OpenRouter
