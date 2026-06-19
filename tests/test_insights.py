import pytest
import pytest_asyncio
from unittest.mock import patch, AsyncMock, MagicMock
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from httpx import AsyncClient

from app.models.base import Base
from app.services.insight_service import (
    InsightService,
    MODALITY_INSIGHT_PROMPTS,
    BASE_INSIGHT_OUTPUT,
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
async def graph_service(db_session):
    return GraphService(db=db_session)


@pytest_asyncio.fixture
async def insight_service(db_session):
    return InsightService(db=db_session, provider_name="ollama")


class TestParseInsights:
    @pytest.mark.asyncio
    async def test_parse_full_insights_json(self, insight_service):
        text = """{
            "repeating_loops": [
                {"pattern": "anxiety leads to avoidance", "description": "When anxious, avoids social situations", "frequency": "frequent", "entities_involved": ["anxiety", "avoidance"]}
            ],
            "modality_insights": [
                {"observation": "Client feels inadequate at work", "evidence": ["mentions being 'not good enough'"]}
            ]
        }"""
        result = insight_service._parse_insights(text)
        assert len(result["repeating_loops"]) == 1
        assert len(result["modality_insights"]) == 1
        assert result["modality_insights"][0]["observation"] == "Client feels inadequate at work"

    @pytest.mark.asyncio
    async def test_parse_codeblock(self, insight_service):
        text = '```json\n{"repeating_loops": [], "modality_insights": []}\n```'
        result = insight_service._parse_insights(text)
        assert result == {"repeating_loops": [], "modality_insights": []}

    @pytest.mark.asyncio
    async def test_parse_embedded_json(self, insight_service):
        text = 'Here are insights: {"repeating_loops": [{"pattern": "test", "description": "test", "frequency": "occasional", "entities_involved": []}], "modality_insights": []}'
        result = insight_service._parse_insights(text)
        assert len(result["repeating_loops"]) == 1

    @pytest.mark.asyncio
    async def test_parse_invalid(self, insight_service):
        result = insight_service._parse_insights("not json")
        assert result == {"repeating_loops": [], "modality_insights": []}


class TestBuildContext:
    @pytest.mark.asyncio
    async def test_build_context_empty_session(self, insight_service, db_session):
        context = await insight_service._build_context("nonexistent")
        assert context.strip() == ""

    @pytest.mark.asyncio
    async def test_build_context_with_graph(self, insight_service, db_session, graph_service):
        await graph_service.add_node(node_type="emotion", label="anxiety", session_id="s1")
        context = await insight_service._build_context("s1")
        assert "anxiety" in context
        assert "Knowledge Graph Nodes" in context

    @pytest.mark.asyncio
    async def test_build_context_with_edges(self, insight_service, db_session, graph_service):
        n1 = await graph_service.add_node(node_type="event", label="work", session_id="s1")
        n2 = await graph_service.add_node(node_type="emotion", label="stress", session_id="s1")
        await graph_service.add_edge(
            source_id=n1.id, target_id=n2.id, relationship="CAUSES", session_id="s1",
        )
        context = await insight_service._build_context("s1")
        assert "work" in context
        assert "stress" in context
        assert "CAUSES" in context
        assert "Relationships" in context


class TestCycleDetection:
    @pytest.mark.asyncio
    async def test_no_cycles(self, insight_service, graph_service):
        await graph_service.add_node(node_type="emotion", label="happy", session_id="s1")
        cycles = await insight_service.detect_cycles("s1")
        assert cycles == []

    @pytest.mark.asyncio
    async def test_simple_cycle(self, insight_service, graph_service):
        a = await graph_service.add_node(node_type="emotion", label="anxiety", session_id="s1")
        b = await graph_service.add_node(node_type="event", label="avoidance", session_id="s1")
        await graph_service.add_edge(source_id=a.id, target_id=b.id, relationship="CAUSES", session_id="s1")
        await graph_service.add_edge(source_id=b.id, target_id=a.id, relationship="TRIGGERS", session_id="s1")

        cycles = await insight_service.detect_cycles("s1")
        assert len(cycles) >= 1
        assert "anxiety" in cycles[0]["description"]
        assert "avoidance" in cycles[0]["description"]

    @pytest.mark.asyncio
    async def test_longer_cycle(self, insight_service, graph_service):
        a = await graph_service.add_node(node_type="emotion", label="shame", session_id="s1")
        b = await graph_service.add_node(node_type="event", label="hiding", session_id="s1")
        c = await graph_service.add_node(node_type="emotion", label="relief", session_id="s1")
        await graph_service.add_edge(source_id=a.id, target_id=b.id, relationship="CAUSES", session_id="s1")
        await graph_service.add_edge(source_id=b.id, target_id=c.id, relationship="CAUSES", session_id="s1")
        await graph_service.add_edge(source_id=c.id, target_id=a.id, relationship="COMPENSATES_FOR", session_id="s1")

        cycles = await insight_service.detect_cycles("s1")
        assert len(cycles) >= 1

    @pytest.mark.asyncio
    async def test_cycle_empty_session(self, insight_service):
        cycles = await insight_service.detect_cycles("no_data")
        assert cycles == []


class TestGenerateInsights:
    @pytest.mark.asyncio
    async def test_generate_insights_empty_session(self, insight_service):
        with patch("app.services.insight_service.InsightService._get_provider") as mock_get:
            insights = await insight_service.generate_insights("empty")
            assert insights == {"repeating_loops": [], "modality_insights": []}
            mock_get.assert_not_called()

    @pytest.mark.asyncio
    async def test_generate_insights_with_data(self, insight_service, graph_service):
        await graph_service.add_node(node_type="emotion", label="anxiety", session_id="s1")
        await graph_service.add_node(node_type="event", label="work_pressure", session_id="s1")

        mock_provider = MagicMock()
        mock_result = MagicMock()
        mock_result.content = """{
            "repeating_loops": [{"pattern": "anxiety loop", "description": "Work pressure causes anxiety", "frequency": "frequent", "entities_involved": ["work_pressure", "anxiety"]}],
            "modality_insights": [{"observation": "Anxiety about work performance", "evidence": ["work_pressure node present"]}]
        }"""
        mock_provider.chat = AsyncMock(return_value=mock_result)
        insight_service._provider = mock_provider

        insights = await insight_service.generate_insights("s1")
        assert len(insights["repeating_loops"]) == 1
        assert insights["repeating_loops"][0]["pattern"] == "anxiety loop"
        assert len(insights["modality_insights"]) == 1

    @pytest.mark.asyncio
    async def test_generate_insights_provider_error(self, insight_service, graph_service):
        await graph_service.add_node(node_type="emotion", label="fear", session_id="s1")

        mock_provider = MagicMock()
        mock_provider.chat = AsyncMock(side_effect=Exception("API error"))
        insight_service._provider = mock_provider

        insights = await insight_service.generate_insights("s1")
        assert insights == {"repeating_loops": [], "modality_insights": []}


class TestInsightsAPI:
    @pytest.mark.asyncio
    async def test_get_insights_empty_session(self, client):
        resp = await client.get("/insights/nonexistent")
        assert resp.status_code == 200
        data = resp.json()
        assert data["session_id"] == "nonexistent"
        assert data["repeating_loops"] == []
        assert data["modality_insights"] == []

    @pytest.mark.asyncio
    async def test_get_cycles_empty(self, client):
        resp = await client.get("/insights/nonexistent/cycles")
        assert resp.status_code == 200
        assert resp.json() == []

    @pytest.mark.asyncio
    async def test_refresh_insights(self, client):
        with patch("app.services.insight_service.InsightService._get_provider") as mock_get:
            resp = await client.post("/insights/nonexistent/refresh")
        assert resp.status_code == 200
        data = resp.json()
        assert data["session_id"] == "nonexistent"

    @pytest.mark.asyncio
    async def test_get_insights_with_llm_insights(self, client):
        create_resp = await client.post("/sessions", json={"title": "Insight Test", "provider": "ollama"})
        session_id = create_resp.json()["id"]

        await client.post("/graph/nodes", json={"type": "emotion", "label": "anxiety", "session_id": session_id})
        await client.post("/graph/nodes", json={"type": "event", "label": "work_pressure", "session_id": session_id})

        with patch(
            "app.services.insight_service.InsightService._get_provider",
        ) as mock_get:
            mock_result = MagicMock()
            mock_result.content = """{
                "repeating_loops": [{"pattern": "procrastination cycle", "description": "Puts off work then feels guilty", "frequency": "frequent", "entities_involved": ["work", "guilt"]}],
                "modality_insights": [{"observation": "Perfectionistic patterns driving procrastination", "evidence": ["procrastination pattern suggests fear of imperfection"]}]
            }"""
            mock_provider = MagicMock()
            mock_provider.chat = AsyncMock(return_value=mock_result)
            mock_get.return_value = mock_provider

            resp = await client.get(f"/insights/{session_id}")
        assert resp.status_code == 200
        data = resp.json()
        assert data["session_id"] == session_id
        assert len(data["repeating_loops"]) == 1
        assert data["repeating_loops"][0]["pattern"] == "procrastination cycle"
        assert len(data["modality_insights"]) == 1
