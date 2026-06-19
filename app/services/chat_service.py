from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import settings
from app.models.conversation import Message
from app.models.session import Session
from app.models.schemas import SessionCreate
from app.services.providers.base import ChatMessage
from app.services.providers import get_provider
from app.services.memory_service import MemoryService
from app.services.graph_service import GraphService
from app.services.therapy_service import TherapyService
from app.services.safety_service import (
    SafetyService,
    RESOURCE_MESSAGE,
    FILTERED_RESPONSE_MESSAGE,
)
from app.services.mode_service import ModeService
from app.services.global_memory_service import GlobalMemoryService


class ChatService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_session(self, data: SessionCreate) -> Session:
        session = Session(
            title=data.title,
            provider=data.provider or "ollama",
            model=data.model,
            system_prompt=data.system_prompt,
            modality=data.modality or "integrated",
        )
        self.db.add(session)
        await self.db.commit()
        await self.db.refresh(session)
        return session

    async def get_session(self, session_id: str) -> Session | None:
        result = await self.db.execute(
            select(Session)
            .options(selectinload(Session.messages))
            .where(Session.id == session_id)
        )
        return result.scalar_one_or_none()

    async def list_sessions(self, skip: int = 0, limit: int = 50) -> list[Session]:
        result = await self.db.execute(
            select(Session)
            .options(selectinload(Session.messages))
            .order_by(Session.updated_at.desc())
            .offset(skip).limit(limit)
        )
        return list(result.scalars().all())

    async def update_session(self, session_id: str, data: dict) -> Session | None:
        session = await self.get_session(session_id)
        if not session:
            return None
        for key, value in data.items():
            if value is not None and hasattr(session, key):
                setattr(session, key, value)
        session.updated_at = datetime.now(timezone.utc).isoformat()
        await self.db.commit()
        await self.db.refresh(session)
        return session

    async def delete_session(self, session_id: str) -> bool:
        session = await self.get_session(session_id)
        if not session:
            return False
        await self.db.delete(session)
        await self.db.commit()
        return True

    async def get_messages(self, session_id: str) -> list[Message]:
        result = await self.db.execute(
            select(Message)
            .where(Message.session_id == session_id)
            .order_by(Message.created_at.asc())
        )
        return list(result.scalars().all())

    async def chat(self, session_id: str, user_message: str) -> tuple[str, str, dict, str, str]:
        session = await self.get_session(session_id)
        if not session:
            raise ValueError(f"Session {session_id} not found")

        safety_service = SafetyService(db=self.db)
        safety_events = await safety_service.check_user_message(session_id, user_message)
        if safety_events:
            await self.db.commit()

        mode_service = ModeService(db=self.db)
        resolved_provider = mode_service.resolve_provider(session)
        provider = get_provider(resolved_provider, settings)

        # MemoryService uses its own dedicated embedding provider (see settings)
        # so vector spaces stay consistent regardless of the chat provider.
        memory_service = MemoryService(db=self.db)
        global_memory_service = GlobalMemoryService(db=self.db)

        memory_context = await memory_service.build_context_prompt(
            user_message,
            max_memories=settings.memory_recall_limit,
        )

        global_memories = await global_memory_service.recall(user_message, top_k=3)
        if global_memories:
            global_lines = ["\nRelevant cross-session memories:"]
            for gm in global_memories:
                global_lines.append(f"- {gm.content[:200]}")
            if memory_context:
                memory_context += "\n" + "\n".join(global_lines)
            else:
                memory_context = "\n".join(global_lines)

        therapy_service = TherapyService(db=self.db, provider_name=resolved_provider)
        modality_prompt = therapy_service.get_modality_prompt(session.modality)

        messages = []
        system_parts = [modality_prompt]
        if session.system_prompt:
            system_parts.append(session.system_prompt)
        if memory_context:
            system_parts.append(memory_context)

        messages.append(ChatMessage(role="system", content="\n\n".join(system_parts)))

        history = await self.get_messages(session_id)
        for msg in history:
            messages.append(ChatMessage(role=msg.role, content=msg.content))

        messages.append(ChatMessage(role="user", content=user_message))

        if safety_service.needs_referral(safety_events):
            response_content = RESOURCE_MESSAGE
            await safety_service.log_referral(session_id)
            result_model = None
            result_provider = resolved_provider
            token_count_prompt = 0
            token_count_completion = 0
        else:
            result = await provider.chat(
                messages=messages,
                model=session.model or None,
            )
            boundary_events = await safety_service.check_response(session_id, result.content)
            if boundary_events:
                await self.db.commit()

            # Enforce the boundary: replace a diagnostic/prescriptive response
            # rather than only logging it.
            if safety_service.should_filter_response(boundary_events):
                response_content = FILTERED_RESPONSE_MESSAGE
            else:
                response_content = result.content
            result_model = result.model
            result_provider = result.provider
            token_count_prompt = result.token_count_prompt
            token_count_completion = result.token_count_completion

        user_msg = Message(
            session_id=session_id,
            role="user",
            content=user_message,
        )
        self.db.add(user_msg)

        assistant_msg = Message(
            session_id=session_id,
            role="assistant",
            content=response_content,
        )
        assistant_msg.set_metadata({
            "provider": result_provider,
            "model": result_model or "",
            "token_count_prompt": token_count_prompt,
            "token_count_completion": token_count_completion,
        })
        self.db.add(assistant_msg)

        if not safety_service.needs_referral(safety_events):
            await memory_service.consolidate_conversation(
                session_id=session_id,
                user_message=user_message,
                assistant_response=response_content,
            )

            graph_service = GraphService(db=self.db, provider_name=resolved_provider)
            await graph_service.extract_and_store(
                session_id=session_id,
                user_message=user_message,
                assistant_response=response_content,
            )

            await global_memory_service.promote_if_valuable(
                user_message=user_message,
                assistant_response=response_content,
                session_id=session_id,
            )

        session.updated_at = datetime.now(timezone.utc).isoformat()
        await self.db.commit()
        await self.db.refresh(assistant_msg)

        token_count = {
            "prompt": token_count_prompt,
            "completion": token_count_completion,
        }

        return (
            response_content,
            assistant_msg.id,
            token_count,
            result_provider,
            result_model or "",
        )
