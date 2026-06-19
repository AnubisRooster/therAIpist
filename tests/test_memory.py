import pytest
import pytest_asyncio
from unittest.mock import patch, AsyncMock, MagicMock
from sqlalchemy import select
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

from app.models.base import Base
from app.models.memory import EpisodicMemory, SemanticMemory, ProceduralMemory
from app.services.memory_service import MemoryService
from app.services.vector_store import InMemoryVectorStore
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
async def memory_service(db_session):
    vector_store = InMemoryVectorStore()
    svc = MemoryService(db=db_session, vector_store=vector_store)
    mock_provider = MagicMock()
    mock_provider.embed = AsyncMock(return_value=[0.1] * 768)
    svc._provider = mock_provider
    return svc


class TestEpisodicMemory:
    @pytest.mark.asyncio
    async def test_store_episodic(self, memory_service, db_session):
        mem = await memory_service.store_episodic(
            content="I feel anxious about my job interview tomorrow",
            session_id="session-1",
            importance=0.8,
            summary="User expressed anxiety about job interview",
        )
        assert mem.id is not None
        assert mem.content == "I feel anxious about my job interview tomorrow"
        assert mem.session_id == "session-1"
        assert mem.importance == 0.8
        assert mem.embedding_id is not None

        result = await db_session.execute(select(EpisodicMemory).where(EpisodicMemory.id == mem.id))
        db_mem = result.scalar_one()
        assert db_mem is not None
        assert db_mem.content == mem.content

    @pytest.mark.asyncio
    async def test_recall_empty_db(self, memory_service):
        memory_service._provider.embed = AsyncMock(return_value=[0.0] * 768)
        results = await memory_service.recall_episodic("anything", limit=5)
        assert results == []

    @pytest.mark.asyncio
    async def test_list_episodic_by_session(self, memory_service):
        await memory_service.store_episodic(content="Session 1 event", session_id="s1")
        await memory_service.store_episodic(content="Session 2 event", session_id="s2")

        s1_mems = await memory_service.list_episodic(session_id="s1")
        assert len(s1_mems) == 1
        assert s1_mems[0].content == "Session 1 event"

        all_mems = await memory_service.list_episodic()
        assert len(all_mems) == 2


class TestSemanticMemory:
    @pytest.mark.asyncio
    async def test_store_and_get_semantic(self, memory_service):
        mem = await memory_service.store_semantic(
            key="user_name", value="Alice", category="identity", confidence=0.9
        )
        assert mem.key == "user_name"
        assert mem.value == "Alice"

        retrieved = await memory_service.get_semantic("user_name")
        assert retrieved is not None
        assert retrieved.value == "Alice"

    @pytest.mark.asyncio
    async def test_semantic_update_existing(self, memory_service):
        await memory_service.store_semantic(key="user_name", value="Alice")
        await memory_service.store_semantic(key="user_name", value="Bob", confidence=0.8)

        retrieved = await memory_service.get_semantic("user_name")
        assert retrieved.value == "Bob"
        assert retrieved.confidence == 0.8

    @pytest.mark.asyncio
    async def test_semantic_not_found(self, memory_service):
        retrieved = await memory_service.get_semantic("nonexistent")
        assert retrieved is None

    @pytest.mark.asyncio
    async def test_list_semantic_by_category(self, memory_service):
        await memory_service.store_semantic(key="k1", value="v1", category="cat_a")
        await memory_service.store_semantic(key="k2", value="v2", category="cat_b")

        cat_a = await memory_service.list_semantic(category="cat_a")
        assert len(cat_a) == 1
        assert cat_a[0].key == "k1"

    @pytest.mark.asyncio
    async def test_delete_semantic(self, memory_service):
        await memory_service.store_semantic(key="to_delete", value="val")
        deleted = await memory_service.delete_semantic("to_delete")
        assert deleted is True

        retrieved = await memory_service.get_semantic("to_delete")
        assert retrieved is None

    @pytest.mark.asyncio
    async def test_delete_nonexistent(self, memory_service):
        deleted = await memory_service.delete_semantic("nope")
        assert deleted is False


class TestProceduralMemory:
    @pytest.mark.asyncio
    async def test_store_procedural(self, memory_service):
        mem = await memory_service.store_procedural(
            context="anxiety during social situations",
            technique="grounding exercises: 5-4-3-2-1 method",
            effectiveness=0.8,
            tags=["anxiety", "grounding", "CBT"],
        )
        assert mem.context == "anxiety during social situations"
        assert "grounding" in mem.technique
        assert mem.tag_list() == ["anxiety", "grounding", "CBT"]

    @pytest.mark.asyncio
    async def test_list_procedural(self, memory_service):
        await memory_service.store_procedural(context="panic", technique="breathing", effectiveness=0.9)
        await memory_service.store_procedural(context="sadness", technique="journaling", effectiveness=0.6)

        all_mems = await memory_service.list_procedural()
        assert len(all_mems) == 2
        assert all_mems[0].effectiveness >= all_mems[1].effectiveness


class TestConsolidation:
    @pytest.mark.asyncio
    async def test_consolidate_conversation(self, memory_service):
        mems = await memory_service.consolidate_conversation(
            session_id="s1",
            user_message="I've been feeling depressed lately",
            assistant_response="It sounds like you're going through a difficult time.",
        )
        assert len(mems) == 2
        assert mems[0].session_id == "s1"
        assert "depressed" in mems[0].content
        assert mems[1].session_id == "s1"
        assert "difficult time" in mems[1].content

    @pytest.mark.asyncio
    async def test_build_context_prompt_with_memories(self, memory_service):
        await memory_service.store_episodic(
            content="I had a panic attack at work last week",
            importance=0.9,
        )
        memory_service._provider.embed = AsyncMock(return_value=[1.0] * 768)

        prompt = await memory_service.build_context_prompt(
            "I'm feeling anxious about going to work",
            max_memories=3,
        )
        assert "panic attack" in prompt
        assert "Relevant past context" in prompt

    @pytest.mark.asyncio
    async def test_build_context_prompt_empty(self, memory_service):
        memory_service._provider.embed = AsyncMock(return_value=[0.0] * 768)
        prompt = await memory_service.build_context_prompt("something new", max_memories=3)
        assert prompt == ""
