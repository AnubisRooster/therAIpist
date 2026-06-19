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

# Diagnostic / prescriptive language an assistant must not produce. These target
# the assistant *claiming* a diagnosis or prescribing medication, not a user
# simply mentioning a condition.
BOUNDARY_PATTERNS = [
    r"\bi\s+diagnose\s+you\b",
    r"\byou\s+are\s+(being\s+)?diagnosed\b",
    r"\byou\s+(clearly\s+|definitely\s+|probably\s+)?have\s+(a\s+|an\s+)?"
    r"(disorder|depression|anxiety\s+disorder|bipolar|schizophrenia|ptsd|ocd|"
    r"major\s+depressive\s+disorder|personality\s+disorder)\b",
    r"\bi\s+prescribe\b",
    r"\b(take|start|stop)\s+(this\s+|the\s+|taking\s+)?"
    r"(medication|meds|prozac|xanax|zoloft|lexapro|antidepressants?)\b",
]

# Negation cues that, when they directly precede a crisis phrase, indicate the
# user is *not* in crisis (e.g. "I don't want to die").
NEGATION_PATTERN = re.compile(
    r"\b(?:don'?t|do not|did not|didn'?t|not|never|no longer|"
    r"wouldn'?t|would not|won'?t|will not|isn'?t|aren'?t)\b"
)

RESOURCE_MESSAGE = (
    "If you're experiencing thoughts of harming yourself or others, "
    "please reach out for support immediately:\n"
    "- National Crisis Hotline: 988\n"
    "- Crisis Text Line: Text HOME to 741741\n"
    "- Emergency Services: 911\n\n"
    "These resources are available 24/7 and are staffed by trained professionals."
)

# Replacement used when an assistant response violates a clinical boundary.
FILTERED_RESPONSE_MESSAGE = (
    "I want to be careful here. I can't offer a clinical diagnosis or "
    "medication advice — those need a licensed professional who can assess you "
    "directly. What I can do is help you explore what you're feeling and think "
    "through your options. Could you tell me more about what's been going on?"
)


def _is_negated(text: str, start: int) -> bool:
    """Return True when a negation cue immediately precedes ``start``."""
    prefix = text[max(0, start - 25):start]
    return bool(NEGATION_PATTERN.search(prefix))


class SafetyService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def check_user_message(self, session_id: str, message: str) -> list[SafetyEvent]:
        events: list[SafetyEvent] = []
        lower = message.lower()

        for pattern in CRISIS_PATTERNS:
            match = re.search(pattern, lower)
            if match and not _is_negated(lower, match.start()):
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

        for pattern in BOUNDARY_PATTERNS:
            match = re.search(pattern, lower)
            if match:
                event = SafetyEvent(
                    session_id=session_id,
                    event_type="boundary_violation",
                    level="warning",
                    source="assistant",
                    message="Response may contain diagnostic or prescriptive language",
                    detail=f"Matched pattern: {pattern}",
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
