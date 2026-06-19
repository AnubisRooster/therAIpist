from __future__ import annotations

import re
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.safety import SafetyEvent, SAFETY_LEVELS, SAFETY_EVENT_TYPES
from app.models.conversation import Message

CRISIS_PATTERNS = [
    r"\b(kill myself|kill me|end my life|take my own life)\b",
    r"\b(suicide|suicidal|want to die|better off dead)\b",
    r"\b(self[- ]?harm|cutting|hurt myself)\b",
    r"\b(no reason to live|can\'?t go on|don\'?t want to live)\b",
    r"\b(harm myself|hurt myself|injure myself)\b",
]

BOUNDARY_PATTERNS = [
    r"\b(diagnos(e|is)\s+(you|me)|prescribe|medication)\b",
    r"\b(roman\s*tic|lover|sexual|dating|marry)\s+(me|you)\b" if False else r"(?!x)x",
]

RESOURCE_MESSAGE = (
    "If you're experiencing thoughts of harming yourself or others, "
    "please reach out for support immediately:\n"
    "- National Crisis Hotline: 988\n"
    "- Crisis Text Line: Text HOME to 741741\n"
    "- Emergency Services: 911\n\n"
    "These resources are available 24/7 and are staffed by trained professionals."
)


class SafetyService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def check_user_message(self, session_id: str, message: str) -> list[SafetyEvent]:
        events: list[SafetyEvent] = []
        lower = message.lower()

        for pattern in CRISIS_PATTERNS:
            if re.search(pattern, lower):
                event = SafetyEvent(
                    session_id=session_id,
                    event_type="crisis_keyword",
                    level="critical",
                    source="user",
                    message="Crisis keyword detected in user message",
                    detail=f"Matched pattern: {pattern}",
                )
                self.db.add(event)
                events.append(event)
                break

        return events

    async def check_response(self, session_id: str, response: str) -> list[SafetyEvent]:
        events: list[SafetyEvent] = []
        lower = response.lower()

        disallowed_phrases = [
            "i diagnose you", "you have", "you are diagnosed",
            "i prescribe", "take this medication",
        ]
        for phrase in disallowed_phrases:
            if phrase in lower:
                event = SafetyEvent(
                    session_id=session_id,
                    event_type="boundary_violation",
                    level="warning",
                    source="assistant",
                    message="Response may contain diagnostic or prescriptive language",
                    detail=f"Found phrase: '{phrase}'",
                )
                self.db.add(event)
                events.append(event)
                break

        return events

    async def log_referral(self, session_id: str) -> SafetyEvent:
        event = SafetyEvent(
            session_id=session_id,
            event_type="referral_given",
            level="info",
            source="system",
            message="Crisis resource referral provided",
            detail=RESOURCE_MESSAGE,
        )
        self.db.add(event)
        await self.db.commit()
        await self.db.refresh(event)
        return event

    async def get_events(self, session_id: str) -> list[SafetyEvent]:
        result = await self.db.execute(
            select(SafetyEvent)
            .where(SafetyEvent.session_id == session_id)
            .order_by(SafetyEvent.created_at.desc())
        )
        return list(result.scalars().all())

    async def get_summary(self) -> dict:
        result = await self.db.execute(
            select(SafetyEvent).order_by(SafetyEvent.created_at.desc()).limit(50)
        )
        events = list(result.scalars().all())

        critical = [e for e in events if e.level == "critical"]
        warnings = [e for e in events if e.level == "warning"]
        infos = [e for e in events if e.level == "info"]

        recent = [
            {
                "id": e.id, "session_id": e.session_id,
                "event_type": e.event_type, "level": e.level,
                "message": e.message, "created_at": e.created_at,
            }
            for e in events[:20]
        ]

        return {
            "total_events": len(events),
            "critical_count": len(critical),
            "warning_count": len(warnings),
            "info_count": len(infos),
            "recent_events": recent,
        }

    def needs_referral(self, events: list[SafetyEvent]) -> bool:
        return any(e.level == "critical" and e.source == "user" for e in events)

    def should_filter_response(self, events: list[SafetyEvent]) -> bool:
        return any(e.event_type == "boundary_violation" for e in events)
