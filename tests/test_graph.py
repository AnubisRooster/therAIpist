import pytest
import pytest_asyncio
from unittest.mock import patch, AsyncMock, MagicMock
from sqlalchemy import select
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

from app.models.base import Base
from app.models.graph import GraphNode, GraphEdge, VALID_NODE_TYPES, VALID_RELATIONSHIPS
from app.services.graph_service import GraphService
from app.core.config import Settings

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


class TestGraphNodeOperations:
    @pytest.mark.asyncio
    async def test_add_node(self, graph_service, db_session):
        node = await graph_service.add_node(
            node_type="emotion",
            label="anxiety",
            properties={"intensity": "high", "frequency": "daily"},
            strength=0.9,
            session_id="s1",
        )
        assert node.id is not None
        assert node.type == "emotion"
        assert node.label == "anxiety"
        assert node.strength == 0.9
        assert node.session_id == "s1"
        assert node.props_dict() == {"intensity": "high", "frequency": "daily"}

        result = await db_session.execute(select(GraphNode).where(GraphNode.id == node.id))
        db_node = result.scalar_one()
        assert db_node.label == "anxiety"

    @pytest.mark.asyncio
    async def test_add_node_invalid_type(self, graph_service):
        with pytest.raises(ValueError, match="Invalid node type"):
            await graph_service.add_node(node_type="invalid", label="test")

    @pytest.mark.asyncio
    async def test_merge_node_creates_new(self, graph_service):
        node = await graph_service.merge_node(
            node_type="belief", label="I am not good enough", strength=1.0, session_id="s1",
        )
        assert node is not None
        assert node.label == "I am not good enough"
        assert node.strength == 1.0

    @pytest.mark.asyncio
    async def test_merge_node_updates_existing(self, graph_service):
        first = await graph_service.merge_node(
            node_type="belief", label="I am not good enough", strength=1.0, session_id="s1",
        )
        original_strength = first.strength
        await graph_service.merge_node(
            node_type="belief", label="I am not good enough", strength=1.0, session_id="s1",
        )
        fetched = await graph_service.get_node(first.id)
        assert fetched.strength > original_strength

    @pytest.mark.asyncio
    async def test_get_node(self, graph_service):
        created = await graph_service.add_node(node_type="emotion", label="joy")
        fetched = await graph_service.get_node(created.id)
        assert fetched is not None
        assert fetched.label == "joy"

    @pytest.mark.asyncio
    async def test_get_node_not_found(self, graph_service):
        fetched = await graph_service.get_node("nonexistent")
        assert fetched is None

    @pytest.mark.asyncio
    async def test_find_nodes_by_type(self, graph_service):
        await graph_service.add_node(node_type="emotion", label="joy")
        await graph_service.add_node(node_type="emotion", label="sadness")
        await graph_service.add_node(node_type="person", label="mother")

        emotions = await graph_service.find_nodes(node_type="emotion")
        assert len(emotions) == 2

    @pytest.mark.asyncio
    async def test_find_nodes_by_query(self, graph_service):
        await graph_service.add_node(node_type="person", label="father")
        await graph_service.add_node(node_type="person", label="mother")
        await graph_service.add_node(node_type="theme", label="family")

        results = await graph_service.find_nodes(query="father")
        assert len(results) == 1
        assert results[0].label == "father"

    @pytest.mark.asyncio
    async def test_find_nodes_by_session(self, graph_service):
        await graph_service.add_node(node_type="emotion", label="fear", session_id="s1")
        await graph_service.add_node(node_type="emotion", label="anger", session_id="s2")

        s1_nodes = await graph_service.find_nodes(session_id="s1")
        assert len(s1_nodes) == 1
        assert s1_nodes[0].label == "fear"

    @pytest.mark.asyncio
    async def test_delete_node(self, graph_service):
        node = await graph_service.add_node(node_type="emotion", label="temporary")
        deleted = await graph_service.delete_node(node.id)
        assert deleted is True
        fetched = await graph_service.get_node(node.id)
        assert fetched is None

    @pytest.mark.asyncio
    async def test_delete_node_not_found(self, graph_service):
        deleted = await graph_service.delete_node("nope")
        assert deleted is False


class TestGraphEdgeOperations:
    @pytest.mark.asyncio
    async def test_add_edge(self, graph_service):
        n1 = await graph_service.add_node(node_type="event", label="public speaking")
        n2 = await graph_service.add_node(node_type="emotion", label="anxiety")

        edge = await graph_service.add_edge(
            source_id=n1.id,
            target_id=n2.id,
            relationship="CAUSES",
            weight=0.9,
            session_id="s1",
        )
        assert edge.id is not None
        assert edge.source_id == n1.id
        assert edge.target_id == n2.id
        assert edge.relationship == "CAUSES"
        assert edge.weight == 0.9

    @pytest.mark.asyncio
    async def test_add_edge_invalid_relationship(self, graph_service):
        n1 = await graph_service.add_node(node_type="event", label="test")
        n2 = await graph_service.add_node(node_type="emotion", label="test")
        with pytest.raises(ValueError, match="Invalid relationship"):
            await graph_service.add_edge(
                source_id=n1.id, target_id=n2.id, relationship="INVALID",
            )

    @pytest.mark.asyncio
    async def test_get_connections(self, graph_service):
        work = await graph_service.add_node(node_type="event", label="work stress")
        anxiety = await graph_service.add_node(node_type="emotion", label="anxiety")
        insomnia = await graph_service.add_node(node_type="event", label="insomnia")

        await graph_service.add_edge(source_id=work.id, target_id=anxiety.id, relationship="CAUSES")
        await graph_service.add_edge(source_id=anxiety.id, target_id=insomnia.id, relationship="CAUSES")

        connections = await graph_service.get_connections(work.id, max_depth=2)
        assert len(connections["nodes"]) >= 2
        assert len(connections["edges"]) >= 2
        labels = [n["label"] for n in connections["nodes"]]
        assert "anxiety" in labels
        assert "insomnia" in labels


class TestSessionGraph:
    @pytest.mark.asyncio
    async def test_get_session_graph(self, graph_service):
        await graph_service.add_node(node_type="emotion", label="fear", session_id="s1")
        await graph_service.add_node(node_type="emotion", label="anger", session_id="s1")
        await graph_service.add_node(node_type="emotion", label="joy", session_id="s2")

        graph = await graph_service.get_session_graph("s1")
        assert len(graph["nodes"]) == 2
        labels = [n["label"] for n in graph["nodes"]]
        assert "fear" in labels
        assert "anger" in labels
        assert "joy" not in labels

    @pytest.mark.asyncio
    async def test_get_session_graph_empty(self, graph_service):
        graph = await graph_service.get_session_graph("nonexistent")
        assert graph == {"nodes": [], "edges": []}


class TestThemesAndPatterns:
    @pytest.mark.asyncio
    async def test_get_themes(self, graph_service):
        theme = await graph_service.add_node(node_type="theme", label="perfectionism", session_id="s1")
        emotion = await graph_service.add_node(node_type="emotion", label="shame", session_id="s1")
        await graph_service.add_edge(
            source_id=theme.id, target_id=emotion.id,
            relationship="CAUSES", session_id="s1",
        )

        themes = await graph_service.get_themes("s1")
        assert len(themes) >= 1
        assert themes[0]["theme"] == "perfectionism"
        assert len(themes[0]["related_entities"]) >= 1

    @pytest.mark.asyncio
    async def test_get_themes_no_themes(self, graph_service):
        await graph_service.add_node(node_type="emotion", label="joy", session_id="s1")
        themes = await graph_service.get_themes("s1")
        assert themes == []

    @pytest.mark.asyncio
    async def test_get_patterns(self, graph_service):
        n1 = await graph_service.add_node(node_type="event", label="criticism", session_id="s1")
        n2 = await graph_service.add_node(node_type="emotion", label="shame", session_id="s1")
        await graph_service.add_edge(
            source_id=n1.id, target_id=n2.id,
            relationship="TRIGGERS", weight=0.9, session_id="s1",
        )

        patterns = await graph_service.get_patterns("s1")
        assert len(patterns) >= 1
        assert "criticism" in patterns[0]["pattern"]
        assert "TRIGGERS" in patterns[0]["pattern"]

    @pytest.mark.asyncio
    async def test_get_patterns_empty(self, graph_service):
        patterns = await graph_service.get_patterns("empty")
        assert patterns == []


class TestExtraction:
    @pytest.mark.asyncio
    async def test_parse_extraction_json(self, graph_service):
        text = '{"nodes": [{"type": "emotion", "label": "anxiety"}], "edges": []}'
        result = graph_service._parse_extraction(text)
        assert len(result["nodes"]) == 1
        assert result["nodes"][0]["label"] == "anxiety"

    @pytest.mark.asyncio
    async def test_parse_extraction_codeblock(self, graph_service):
        text = '```json\n{"nodes": [{"type": "emotion", "label": "sadness"}], "edges": []}\n```'
        result = graph_service._parse_extraction(text)
        assert len(result["nodes"]) == 1
        assert result["nodes"][0]["label"] == "sadness"

    @pytest.mark.asyncio
    async def test_parse_extraction_invalid(self, graph_service):
        result = graph_service._parse_extraction("not json")
        assert result == {"nodes": [], "edges": []}

    @pytest.mark.asyncio
    async def test_parse_extraction_embedded_json(self, graph_service):
        text = 'Here is the data: {"nodes": [{"type": "person", "label": "mother"}], "edges": []}'
        result = graph_service._parse_extraction(text)
        assert len(result["nodes"]) == 1
        assert result["nodes"][0]["label"] == "mother"

    @pytest.mark.asyncio
    async def test_extract_and_store(self, graph_service, db_session):
        mock_provider = MagicMock()
        mock_result = MagicMock()
        mock_result.content = '{"nodes": [{"type": "emotion", "label": "anxiety", "strength": 0.9}, {"type": "event", "label": "work_pressure", "strength": 0.8}], "edges": [{"source_label": "work_pressure", "target_label": "anxiety", "relationship": "CAUSES", "weight": 0.9}]}'
        mock_provider.chat = AsyncMock(return_value=mock_result)
        graph_service._provider = mock_provider

        result = await graph_service.extract_and_store(
            session_id="s1",
            user_message="I'm overwhelmed at work",
            assistant_response="Tell me more about the pressure.",
        )
        assert result["nodes_stored"] == 2
        assert result["edges_stored"] == 1

        nodes = await graph_service.find_nodes(session_id="s1")
        assert len(nodes) == 2
        labels = [n.label for n in nodes]
        assert "anxiety" in labels
        assert "work_pressure" in labels

    @pytest.mark.asyncio
    async def test_extract_and_store_merges_existing(self, graph_service):
        mock_provider = MagicMock()
        mock_result = MagicMock()
        mock_result.content = '{"nodes": [{"type": "emotion", "label": "anxiety", "strength": 0.5}], "edges": []}'
        mock_provider.chat = AsyncMock(return_value=mock_result)
        graph_service._provider = mock_provider

        await graph_service.extract_and_store("s1", "msg", "resp")
        strength_before = (await graph_service.find_nodes(session_id="s1"))[0].strength

        mock_result.content = '{"nodes": [{"type": "emotion", "label": "anxiety", "strength": 0.5}], "edges": []}'
        await graph_service.extract_and_store("s1", "msg2", "resp2")

        nodes = await graph_service.find_nodes(session_id="s1")
        assert len(nodes) == 1
        assert nodes[0].strength > strength_before

    @pytest.mark.asyncio
    async def test_extract_and_store_provider_error(self, graph_service):
        mock_provider = MagicMock()
        mock_provider.chat = AsyncMock(side_effect=Exception("API error"))
        graph_service._provider = mock_provider

        result = await graph_service.extract_and_store("s1", "msg", "resp")
        assert result["nodes_stored"] == 0
        assert result["edges_stored"] == 0


class TestGraphChatIntegration:
    @pytest.mark.asyncio
    async def test_extract_and_store_with_edge(self, graph_service):
        mock_provider = MagicMock()
        mock_result = MagicMock()
        mock_result.content = '{"nodes": [{"type": "event", "label": "traffic_jam", "strength": 0.7}, {"type": "emotion", "label": "frustration", "strength": 0.8}], "edges": [{"source_label": "traffic_jam", "target_label": "frustration", "relationship": "TRIGGERS", "weight": 0.9}]}'
        mock_provider.chat = AsyncMock(return_value=mock_result)
        graph_service._provider = mock_provider

        await graph_service.extract_and_store("s1", "Traffic made me angry", "I understand.")

        graph = await graph_service.get_session_graph("s1")
        assert len(graph["nodes"]) == 2
        assert len(graph["edges"]) == 1
        assert graph["edges"][0]["relationship"] == "TRIGGERS"

    @pytest.mark.asyncio
    async def test_invalid_edge_relationship_skipped(self, graph_service):
        mock_provider = MagicMock()
        mock_result = MagicMock()
        mock_result.content = '{"nodes": [{"type": "event", "label": "rain", "strength": 0.5}, {"type": "emotion", "label": "sadness", "strength": 0.5}], "edges": [{"source_label": "rain", "target_label": "sadness", "relationship": "MAKES", "weight": 0.5}]}'
        mock_provider.chat = AsyncMock(return_value=mock_result)
        graph_service._provider = mock_provider

        result = await graph_service.extract_and_store("s1", "Rain makes me sad", "OK")
        assert result["nodes_stored"] == 2
        assert result["edges_stored"] == 0
