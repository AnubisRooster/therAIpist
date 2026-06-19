import pytest
import pytest_asyncio
from unittest.mock import patch, AsyncMock, MagicMock
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

from app.models.base import Base
from app.services.therapy_service import (
    TherapyService,
    MODALITY_PROMPTS,
    INTERVENTION_SUGGESTION_PROMPT,
    MODALITIES,
)
from app.services.graph_service import GraphService

TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"


@pytest_asyncio.fixture
async def db_session():
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)
    session_maker = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with session_maker() as session:
        yield session


@pytest_asyncio.fixture
async def therapy_service(db_session):
    return TherapyService(db=db_session, provider_name="ollama")


@pytest_asyncio.fixture
async def graph_service(db_session):
    return GraphService(db=db_session)


class TestModalityPrompts:
    def test_get_modality_prompt_adlerian(self, therapy_service):
        prompt = therapy_service.get_modality_prompt("adlerian")
        assert "Adlerian" in prompt or "Adler" in prompt
        assert "inferiority" in prompt.lower()

    def test_get_modality_prompt_jungian(self, therapy_service):
        prompt = therapy_service.get_modality_prompt("jungian")
        assert "shadow" in prompt.lower()
        assert "archetyp" in prompt.lower()

    def test_get_modality_prompt_dbt(self, therapy_service):
        prompt = therapy_service.get_modality_prompt("dbt")
        assert "DBT" in prompt or "dialectical" in prompt.lower()
        assert "mindfulness" in prompt.lower()

    def test_get_modality_prompt_integrated(self, therapy_service):
        prompt = therapy_service.get_modality_prompt("integrated")
        assert "Adlerian" in prompt
        assert "Jungian" in prompt
        assert "DBT" in prompt

    def test_get_modality_prompt_invalid_falls_back(self, therapy_service):
        prompt = therapy_service.get_modality_prompt("nonexistent")
        assert "Adlerian" in prompt

    def test_all_modalities_have_prompts(self):
        for mod in MODALITIES:
            assert mod in MODALITY_PROMPTS, f"Missing prompt for {mod}"


class TestProgress:
    @pytest.mark.asyncio
    async def test_progress_empty_session(self, therapy_service):
        progress = await therapy_service.get_progress("nonexistent")
        assert progress["session_id"] == "nonexistent"
        assert progress["graph_nodes"] == 0

    @pytest.mark.asyncio
    async def test_progress_with_data(self, therapy_service, graph_service):
        from app.models.schemas import SessionCreate
        from app.services.chat_service import ChatService

        chat = ChatService(db=therapy_service.db)
        session = await chat.create_session(SessionCreate(title="Progress Test"))
        session_id = session.id

        await graph_service.add_node(
            node_type="emotion", label="anxiety", session_id=session_id,
        )
        await graph_service.add_node(
            node_type="theme", label="perfectionism", strength=2.0, session_id=session_id,
        )

        progress = await therapy_service.get_progress(session_id)
        assert progress["session_id"] == session_id
        assert progress["graph_nodes"] == 2
        assert "anxiety" in progress["emotional_range"]
        assert len(progress["strongest_themes"]) >= 1
        assert progress["strongest_themes"][0]["label"] == "perfectionism"


class TestInterventionSuggestion:
    @pytest.mark.asyncio
    async def test_suggest_intervention_no_session(self, therapy_service):
        result = await therapy_service.suggest_intervention("nonexistent")
        assert result is None

    @pytest.mark.asyncio
    async def test_parse_intervention_json(self, therapy_service):
        text = '{"intervention": "Chain Analysis", "modality": "dbt", "rationale": "To understand behavior chain", "description": "Walk through the chain of events"}'
        result = therapy_service._parse_intervention(text)
        assert result is not None
        assert result["intervention"] == "Chain Analysis"
        assert result["modality"] == "dbt"

    @pytest.mark.asyncio
    async def test_parse_intervention_codeblock(self, therapy_service):
        text = '```json\n{"intervention": "Dream Analysis", "modality": "jungian", "rationale": "To explore unconscious content", "description": "Ask about the dream narrative"}\n```'
        result = therapy_service._parse_intervention(text)
        assert result is not None
        assert result["intervention"] == "Dream Analysis"

    @pytest.mark.asyncio
    async def test_parse_intervention_invalid(self, therapy_service):
        result = therapy_service._parse_intervention("not json")
        assert result is None

    @pytest.mark.asyncio
    async def test_suggest_intervention_with_data(self, therapy_service, graph_service, client):
        create_resp = await client.post("/sessions", json={
            "title": "Intervention Test",
            "modality": "dbt",
        })
        session_id = create_resp.json()["id"]

        await graph_service.add_node(
            node_type="emotion", label="anger", session_id=session_id,
        )

        mock_provider = MagicMock()
        mock_result = MagicMock()
        mock_result.content = '{"intervention": "Opposite Action", "modality": "dbt", "rationale": "Anger is present and opposite action can help regulate", "description": "Identify the action urge and do the opposite"}'
        mock_provider.chat = AsyncMock(return_value=mock_result)
        therapy_service._provider = mock_provider

        result = await therapy_service.suggest_intervention(session_id)
        assert result is not None
        assert result["intervention"] == "Opposite Action"
        assert result["modality"] == "dbt"

    @pytest.mark.asyncio
    async def test_suggest_intervention_provider_error(self, therapy_service, graph_service, client):
        create_resp = await client.post("/sessions", json={"title": "Error Test"})
        session_id = create_resp.json()["id"]

        await graph_service.add_node(
            node_type="emotion", label="fear", session_id=session_id,
        )

        mock_provider = MagicMock()
        mock_provider.chat = AsyncMock(side_effect=Exception("API error"))
        therapy_service._provider = mock_provider

        result = await therapy_service.suggest_intervention(session_id)
        assert result is None


class TestTherapyAPI:
    @pytest.mark.asyncio
    async def test_get_progress_empty(self, client):
        resp = await client.get("/therapy/nonexistent/progress")
        assert resp.status_code == 200
        data = resp.json()
        assert data["session_id"] == "nonexistent"
        assert data["graph_nodes"] == 0

    @pytest.mark.asyncio
    async def test_get_progress_with_data(self, client):
        create_resp = await client.post("/sessions", json={"title": "Progress"})
        session_id = create_resp.json()["id"]

        await client.post("/graph/nodes", json={
            "type": "emotion", "label": "joy", "session_id": session_id,
        })

        resp = await client.get(f"/therapy/{session_id}/progress")
        assert resp.status_code == 200
        data = resp.json()
        assert data["graph_nodes"] == 1
        assert "joy" in data["emotional_range"]

    @pytest.mark.asyncio
    async def test_suggest_intervention_api(self, client):
        create_resp = await client.post("/sessions", json={
            "title": "Intervention",
            "modality": "jungian",
        })
        session_id = create_resp.json()["id"]

        with patch(
            "app.services.therapy_service.TherapyService._get_provider",
        ) as mock_get:
            mock_result = MagicMock()
            mock_result.content = '{"intervention": "Active Imagination", "modality": "jungian", "rationale": "To engage with unconscious imagery", "description": "Guide the client to dialogue with the image"}'
            mock_provider = MagicMock()
            mock_provider.chat = AsyncMock(return_value=mock_result)
            mock_get.return_value = mock_provider

            resp = await client.get(f"/therapy/{session_id}/interventions")
        assert resp.status_code == 200
        data = resp.json()
        assert data["intervention"] == "Active Imagination"

    @pytest.mark.asyncio
    async def test_suggest_intervention_no_data(self, client):
        resp = await client.get("/therapy/nonexistent/interventions")
        assert resp.status_code == 200
        data = resp.json()
        assert data["intervention"] == ""
        assert "No session data" in data["rationale"]

    @pytest.mark.asyncio
    async def test_chat_uses_modality_prompt(self, client):
        create_resp = await client.post("/sessions", json={
            "title": "Modality Chat",
            "provider": "ollama",
            "modality": "adlerian",
        })
        session_id = create_resp.json()["id"]

        with (
            patch("app.services.providers.ollama.OllamaProvider.chat", new_callable=AsyncMock) as mock_chat,
            patch("app.services.providers.ollama.OllamaProvider.embed", new_callable=AsyncMock) as mock_embed,
        ):
            mock_chat.return_value.content = "Tell me about your early life."
            mock_chat.return_value.model = "llama3.2"
            mock_chat.return_value.provider = "ollama"
            mock_chat.return_value.token_count_prompt = 50
            mock_chat.return_value.token_count_completion = 10

            mock_embed.return_value = [0.1] * 768

            resp = await client.post("/chat", json={
                "session_id": session_id,
                "message": "I often feel inferior to my siblings.",
            })
        assert resp.status_code == 200

        calls = mock_chat.call_args_list
        therapy_calls = [
            c for c in calls
            if not any(
                "entity extractor" in getattr(m, "content", "").lower()
                for m in c.kwargs.get("messages", [])
            )
        ]
        assert len(therapy_calls) >= 1
        therapy_call = therapy_calls[-1]
        system_msgs = [m for m in therapy_call.kwargs["messages"] if m.role == "system"]
        assert len(system_msgs) >= 1
        all_system = " ".join(m.content for m in system_msgs)
        assert "Adlerian" in all_system or "inferiority" in all_system.lower()

    @pytest.mark.asyncio
    async def test_session_creation_with_modality(self, client):
        for mod in ["adlerian", "jungian", "dbt", "integrated"]:
            resp = await client.post("/sessions", json={
                "title": f"{mod} session",
                "modality": mod,
            })
            assert resp.status_code == 201
            assert resp.json()["modality"] == mod

    @pytest.mark.asyncio
    async def test_session_update_modality(self, client):
        create_resp = await client.post("/sessions", json={"title": "Change Modality"})
        session_id = create_resp.json()["id"]

        resp = await client.patch(f"/sessions/{session_id}", json={"modality": "jungian"})
        assert resp.status_code == 200
        assert resp.json()["modality"] == "jungian"
