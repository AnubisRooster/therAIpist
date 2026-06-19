from pydantic import BaseModel
from typing import Optional


class ChatRequest(BaseModel):
    session_id: str
    message: str
    stream: bool = False


class ChatResponse(BaseModel):
    response: str
    message_id: str
    session_id: str
    provider_used: str
    model_used: str
    token_count: dict


class SessionCreate(BaseModel):
    title: str = ""
    provider: str = "ollama"
    model: str = ""
    system_prompt: str = ""
    modality: str = "integrated"
    mode: str = "auto"
    local_model: str = ""


class SessionUpdate(BaseModel):
    title: Optional[str] = None
    provider: Optional[str] = None
    model: Optional[str] = None
    system_prompt: Optional[str] = None
    modality: Optional[str] = None
    mode: Optional[str] = None
    local_model: Optional[str] = None


class SessionResponse(BaseModel):
    id: str
    title: str
    provider: str
    model: str
    system_prompt: str
    modality: str = "integrated"
    mode: str = "auto"
    local_model: str = ""
    created_at: str
    updated_at: str
    message_count: int = 0


class MessageResponse(BaseModel):
    id: str
    session_id: str
    role: str
    content: str
    metadata: dict
    created_at: str


class EpisodicMemoryResponse(BaseModel):
    id: str
    session_id: str | None = None
    content: str
    summary: str
    importance: float
    timestamp: str
    created_at: str


class SemanticMemoryResponse(BaseModel):
    id: str
    key: str
    value: str
    category: str
    confidence: float
    updated_at: str


class ProceduralMemoryResponse(BaseModel):
    id: str
    context: str
    technique: str
    effectiveness: float
    tags: list[str]
    created_at: str


class MemorySearchRequest(BaseModel):
    query: str
    limit: int = 5
    min_score: float = 0.0


class MemorySearchResponse(BaseModel):
    memory_id: str
    content: str
    summary: str
    timestamp: str
    session_id: str | None = None
    importance: float
    score: float


class StoreSemanticRequest(BaseModel):
    key: str
    value: str
    category: str = "general"
    confidence: float = 0.5


class StoreProceduralRequest(BaseModel):
    context: str
    technique: str
    effectiveness: float = 0.5
    tags: list[str] = []


class ConsolidateRequest(BaseModel):
    session_id: str
    user_message: str
    assistant_response: str


class GraphNodeCreate(BaseModel):
    type: str
    label: str
    properties: dict = {}
    strength: float = 1.0
    session_id: str | None = None


class GraphNodeResponse(BaseModel):
    id: str
    type: str
    label: str
    properties: dict
    strength: float
    session_id: str | None = None
    first_seen: str
    last_seen: str


class GraphEdgeCreate(BaseModel):
    source_id: str
    target_id: str
    relationship: str
    weight: float = 1.0
    metadata: dict = {}
    session_id: str | None = None


class GraphEdgeResponse(BaseModel):
    id: str
    source_id: str
    target_id: str
    relationship: str
    weight: float
    metadata: dict
    session_id: str | None = None
    created_at: str


class GraphConnectionResponse(BaseModel):
    nodes: list[dict]
    edges: list[dict]


class GraphSessionResponse(BaseModel):
    nodes: list[dict]
    edges: list[dict]


class GraphExtractRequest(BaseModel):
    session_id: str
    user_message: str
    assistant_response: str


class GraphExtractResponse(BaseModel):
    nodes_stored: int
    edges_stored: int


class GraphThemeResponse(BaseModel):
    theme: str
    strength: float
    properties: dict
    related_entities: list[dict]


class GraphPatternResponse(BaseModel):
    pattern: str
    source: dict
    target: dict
    relationship: str
    weight: float


class HealthResponse(BaseModel):
    status: str
    providers: dict


class RepeatingLoopResponse(BaseModel):
    pattern: str
    description: str
    frequency: str
    entities_involved: list[str] = []


class CycleResponse(BaseModel):
    nodes: list[str]
    description: str


class AdlerianInsightResponse(BaseModel):
    type: str
    observation: str
    evidence: list[str] = []


class DBTRecommendationResponse(BaseModel):
    skill_category: str
    recommendation: str
    rationale: str


class ShadowObservationResponse(BaseModel):
    observation: str
    evidence: list[str] = []
    defense_type: str


class ModalityInsightResponse(BaseModel):
    observation: str
    evidence: list[str] = []


class InsightSummaryResponse(BaseModel):
    session_id: str
    repeating_loops: list[RepeatingLoopResponse] = []
    modality_insights: list[ModalityInsightResponse] = []
    adlerian_insights: list[AdlerianInsightResponse] = []
    dbt_recommendations: list[DBTRecommendationResponse] = []
    shadow_observations: list[ShadowObservationResponse] = []
    cycles: list[CycleResponse] = []


class ProgressResponse(BaseModel):
    session_id: str
    total_sessions: int = 0
    messages_exchanged: int = 0
    graph_nodes: int = 0
    graph_edges: int = 0
    strongest_themes: list[dict] = []
    emotional_range: list[str] = []


class InterventionSuggestionResponse(BaseModel):
    intervention: str
    modality: str
    rationale: str
    description: str


class NoteCreate(BaseModel):
    session_id: str
    note_type: str = "session_note"
    title: str = ""
    content: str = ""
    structured_data: dict = {}


class NoteUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    structured_data: Optional[dict] = None


class NoteResponse(BaseModel):
    id: str
    session_id: str
    note_type: str
    title: str
    content: str
    structured_data: dict
    created_at: str
    updated_at: str


class NodeTypeCount(BaseModel):
    label: str
    strength: float


class SessionDashboardResponse(BaseModel):
    session_id: str
    exists: bool = False
    title: str = ""
    modality: str = ""
    provider: str = ""
    created_at: str = ""
    updated_at: str = ""
    messages_exchanged: int = 0
    graph_nodes: int = 0
    graph_edges: int = 0
    nodes_by_type: dict = {}
    emotions: list[dict] = []
    top_themes: list[dict] = []
    recent_notes: list[dict] = []
    progress: dict = {}


class SessionSummary(BaseModel):
    id: str
    title: str
    modality: str
    message_count: int = 0
    updated_at: str


class GlobalDashboardResponse(BaseModel):
    total_sessions: int = 0
    total_messages: int = 0
    total_graph_nodes: int = 0
    total_graph_edges: int = 0
    active_sessions: int = 0
    sessions: list[SessionSummary] = []
    modality_distribution: dict = {}
    nodes_by_type: dict = {}
    top_themes_globally: list[dict] = []
    recent_notes: list[dict] = []


class GraphVisualizationNode(BaseModel):
    id: str
    label: str
    type: str
    strength: float
    size: float
    color: str
    shape: str
    properties: dict = {}
    first_seen: str = ""
    last_seen: str = ""


class GraphVisualizationEdge(BaseModel):
    id: str
    source: str
    target: str
    relationship: str
    weight: float
    width: float
    label: str = ""
    session_id: str | None = None


class GraphVisualizationResponse(BaseModel):
    nodes: list[GraphVisualizationNode] = []
    edges: list[GraphVisualizationEdge] = []


class GraphStatsResponse(BaseModel):
    total_nodes: int = 0
    total_edges: int = 0
    density: float = 0
    nodes_by_type: dict = {}
    edges_by_relationship: dict = {}
    isolated_nodes: int = 0
    degree_distribution: dict = {}


class TimelineEvent(BaseModel):
    type: str
    timestamp: str
    node_id: str | None = None
    label: str | None = None
    node_type: str | None = None
    strength: float | None = None
    source_id: str | None = None
    target_id: str | None = None
    relationship: str | None = None
    weight: float | None = None
    source_label: str | None = None
    target_label: str | None = None


class GraphTimelineResponse(BaseModel):
    timeline: list[TimelineEvent] = []


class DreamCreate(BaseModel):
    session_id: str
    title: str = ""
    narrative: str = ""
    feelings: list[str] = []
    dream_date: str | None = None


class DreamUpdate(BaseModel):
    title: str | None = None
    narrative: str | None = None
    feelings: list[str] | None = None
    dream_date: str | None = None


class DreamResponse(BaseModel):
    id: str
    session_id: str
    title: str
    narrative: str
    feelings: list[str]
    symbols: list[dict]
    analysis: dict = {}
    dream_date: str
    created_at: str


class DreamAnalysisResponse(BaseModel):
    id: str
    session_id: str
    title: str
    analysis: dict = {}
    symbols: list[dict] = []


class DreamSymbolExtractResponse(BaseModel):
    symbols_extracted: int = 0
    nodes_stored: int = 0


class VoiceRecordingResponse(BaseModel):
    id: str
    session_id: str
    duration_seconds: float = 0.0
    transcript: str = ""
    mime_type: str = "audio/wav"
    created_at: str


class VoiceChatResponse(BaseModel):
    transcript: str
    response: str
    message_id: str
    session_id: str
    recording_id: str
    provider_used: str
    model_used: str
    token_count: dict


class SafetyEventResponse(BaseModel):
    id: str
    session_id: str
    event_type: str
    level: str
    source: str
    message: str = ""
    detail: str = ""
    created_at: str


class AgentResponse(BaseModel):
    name: str


class AgentRouteResponse(BaseModel):
    primary_agent: str = ""
    response: str = ""
    confidence: float = 0.0
    interventions: list[str] = []
    all_agents: list[dict] = []


class ModeSetRequest(BaseModel):
    mode: str
    local_model: str = ""


class ModeResponse(BaseModel):
    session_id: str
    mode: str | None = None
    provider: str | None = None
    local_model: str = ""
    local_available: bool = False
    sync_enabled: bool = False


class ModeUpdateResponse(BaseModel):
    session_id: str
    mode: str
    provider: str
    local_model: str = ""


class RecentSafetyEvent(BaseModel):
    id: str
    session_id: str
    event_type: str
    level: str
    message: str = ""
    created_at: str


class SafetySummaryResponse(BaseModel):
    total_events: int = 0
    critical_count: int = 0
    warning_count: int = 0
    info_count: int = 0
    recent_events: list[RecentSafetyEvent] = []
