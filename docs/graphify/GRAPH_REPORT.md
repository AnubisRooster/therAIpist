# Graph Report - therAIpist  (2026-09-06)

## Corpus Check
- Large corpus: 230 files · ~1,872,213 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2426 nodes · 5744 edges · 124 communities (108 shown, 8 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 558 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- ChatService
- cytoscape.min.js
- LocalModelService
- PINView
- OpenRouterModel
- AgentContext
- SwiftData
- InMemoryVectorStore
- ChatMessage
- SessionModel
- View
- DreamService
- asyncio
- database.py
- schemas.py
- Base
- VoiceConversationController
- AgentContext
- DashboardView.swift
- InsightService
- String
- SettingsView.swift
- notes.py
- .get()
- ChatService
- Coordinator
- MemoryService
- Identifiable
- LocalLLMEngine
- asyncio
- Session
- ChatView
- VoiceService
- GraphService
- SafetyServiceTests
- TagCapsule
- api/memory.py
- DreamModel
- NarrativeView
- VoicePickerView
- Codable
- VoiceTranscriptTests
- TTSCoordinator
- SpeechService
- LocalLLMError
- String
- MemoryModel
- SpiritualTradition
- .makeInMemoryContainer()
- asyncio
- MoodEntryModel
- test_dreams.py
- SafetyService
- GraphNodeModel
- NarrativeDocument
- PersonaKind
- .resolve()
- BackupService
- asyncio
- graph_ui.py
- String
- NoteModel
- GraphExportServiceTests
- LLMProvider
- SafetyService.swift
- SelfwardDesktop
- api/voice.py
- Theme
- Persona
- VoiceStatusBar
- XCTestCase
- test_notes.py
- sessions.py
- conftest.py
- SwiftUI
- Float
- DashboardService
- GlobalMemoryServiceTests
- FlowLayout
- SessionRow
- ActiveImaginationTests
- Components.swift
- SpiritualPersonaTests
- test_auth.py
- mode.py
- EncryptedBackupDocument
- CompanionPersonality
- test_graph_ui.py
- test_safety.py
- test_voice.py
- api/safety.py
- therapy.py
- GlobalMemoryService
- CompanionGender
- CodingKeys
- .schedule()
- DashboardSheet
- test_dashboard.py
- test_sessions.py
- .body
- DashboardService
- VoiceService
- TTSKeyProvider
- InsightsView.swift
- test_chat.py
- MarkdownText
- NodeConnectionsSheet
- TestModalityPrompts
- BackupError
- Phase
- XMLParserRecorder
- test_safety_enforcement.py
- env.py
- test_health_endpoint()
- graphify_pipeline.py
- therapist

## God Nodes (most connected - your core abstractions)
1. `SessionModel` - 135 edges
2. `GraphService` - 46 edges
3. `AgentContext` - 44 edges
4. `LocalModelService` - 42 edges
5. `Base` - 37 edges
6. `ChatService` - 35 edges
7. `SwiftData` - 35 edges
8. `MemoryService` - 34 edges
9. `VoiceConversationController` - 34 edges
10. `ChatMessage` - 31 edges

## Surprising Connections (you probably didn't know these)
- `TestQdrantVectorStore` --uses--> `Settings`  [INFERRED]
  tests/test_vector_store.py → app/core/config.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/conftest.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_insights.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_memory.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_therapy.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (124 total, 8 thin omitted)

### Community 0 - "ChatService"
Cohesion: 0.05
Nodes (34): MessageModel, Bool, ChatResult, ChatService, AsyncThrowingStream, Bool, Error, Int (+26 more)

### Community 1 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 2 - "LocalModelService"
Cohesion: 0.05
Nodes (52): Int64, DownloadProgressDelegate, HFModel, HFSibling, HuggingFaceModelService, LocalModel, LocalModelKind, appleFoundation (+44 more)

### Community 3 - "PINView"
Cohesion: 0.06
Nodes (40): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+32 more)

### Community 4 - "OpenRouterModel"
Cohesion: 0.05
Nodes (38): CodingKey, Decoder, Hashable, CodingKeys, architecture, contextLength, id, inputModalities (+30 more)

### Community 5 - "AgentContext"
Cohesion: 0.10
Nodes (29): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentResult, AgentOrchestrator, AdlerianAgent (+21 more)

### Community 6 - "SwiftData"
Cohesion: 0.07
Nodes (13): Foundation, BadgeBackfillService, ModelContext, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int (+5 more)

### Community 7 - "InMemoryVectorStore"
Cohesion: 0.07
Nodes (15): AsyncSession, cosine_similarity(), get_vector_store(), InMemoryVectorStore, ABC, QdrantVectorStore, reset_vector_store(), SearchResult (+7 more)

### Community 8 - "ChatMessage"
Cohesion: 0.10
Nodes (22): health_check(), get, Settings, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel (+14 more)

### Community 9 - "SessionModel"
Cohesion: 0.10
Nodes (20): SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String, DashboardView (+12 more)

### Community 10 - "View"
Cohesion: 0.10
Nodes (40): View, DreamsView, .body, AboutYouStep, .body, APIKeyStep, .body, BulletRow (+32 more)

### Community 11 - "DreamService"
Cohesion: 0.11
Nodes (23): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+15 more)

### Community 12 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 13 - "database.py"
Cohesion: 0.09
Nodes (26): list_agents(), get, post, route_message(), chat(), get_chat_history(), AsyncSession, get (+18 more)

### Community 14 - "schemas.py"
Cohesion: 0.14
Nodes (31): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+23 more)

### Community 15 - "Base"
Cohesion: 0.18
Nodes (8): Base, Message, GraphEdge, GraphNode, DeclarativeBase, db_session(), graph_service(), fixture

### Community 16 - "VoiceConversationController"
Cohesion: 0.16
Nodes (13): Equatable, Bool, Never, String, Task, TimeInterval, Timer, Void (+5 more)

### Community 17 - "AgentContext"
Cohesion: 0.15
Nodes (17): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+9 more)

### Community 18 - "DashboardView.swift"
Cohesion: 0.12
Nodes (23): Charts, GlobalMemoryModel, GlobalMemoryService, Int, ModelContext, String, .body, GlobalMemoriesListView (+15 more)

### Community 19 - "InsightService"
Cohesion: 0.14
Nodes (21): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+13 more)

### Community 20 - "String"
Cohesion: 0.16
Nodes (17): BYOKLLMKit, LLMMessage, LLMError, apiError, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded (+9 more)

### Community 21 - "SettingsView.swift"
Cohesion: 0.11
Nodes (23): ElevenLabsTTSEngine, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+15 more)

### Community 22 - "notes.py"
Cohesion: 0.13
Nodes (17): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+9 more)

### Community 23 - ".get()"
Cohesion: 0.12
Nodes (9): APIKeyProvider, KeychainService, Bool, String, .byokProviders, .cloudProvidersWithKeys, .openAISection, ProviderRoutingTests (+1 more)

### Community 24 - "ChatService"
Cohesion: 0.13
Nodes (10): SessionCreate, ChatService, AsyncSession, AsyncSession, TherapyService, db_session(), graph_service(), fixture (+2 more)

### Community 25 - "Coordinator"
Cohesion: 0.12
Nodes (16): Context, Coordinator, GraphVisualizationView, ShareSheet, Any, Void, UIActivityViewController, UIViewControllerRepresentable (+8 more)

### Community 26 - "MemoryService"
Cohesion: 0.16
Nodes (7): EpisodicMemory, ProceduralMemory, SemanticMemory, MemoryService, db_session(), memory_service(), fixture

### Community 27 - "Identifiable"
Cohesion: 0.20
Nodes (11): Identifiable, AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL (+3 more)

### Community 28 - "LocalLLMEngine"
Cohesion: 0.15
Nodes (11): LocalLLMEngine, Int, Never, String, Task, URL, Void, LocalLLMEngineTests (+3 more)

### Community 29 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 30 - "Session"
Cohesion: 0.23
Nodes (18): Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture, test_get_mode_default(), test_get_mode_not_found() (+10 more)

### Community 31 - "ChatView"
Cohesion: 0.16
Nodes (14): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, Bool, ChatService, Date (+6 more)

### Community 32 - "VoiceService"
Cohesion: 0.15
Nodes (9): VoiceRecording, get_stt_provider(), ABC, STTProvider, TranscriptResult, MockSTTProvider, AsyncSession, VoiceService (+1 more)

### Community 33 - "GraphService"
Cohesion: 0.15
Nodes (6): GraphService, AsyncSession, db_session(), graph_service(), insight_service(), fixture

### Community 34 - "SafetyServiceTests"
Cohesion: 0.14
Nodes (4): CrisisResources, Resource, String, SafetyServiceTests

### Community 35 - "TagCapsule"
Cohesion: 0.12
Nodes (17): Actions, Font, AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body (+9 more)

### Community 36 - "api/memory.py"
Cohesion: 0.17
Nodes (20): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+12 more)

### Community 37 - "DreamModel"
Cohesion: 0.15
Nodes (14): DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings, .symbols (+6 more)

### Community 38 - "NarrativeView"
Cohesion: 0.15
Nodes (19): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+11 more)

### Community 39 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 40 - "Codable"
Cohesion: 0.27
Nodes (18): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+10 more)

### Community 42 - "TTSCoordinator"
Cohesion: 0.23
Nodes (11): AnyCancellable, CheckedContinuation, PrefetchedSentence, text, Bool, Never, Task, Void (+3 more)

### Community 43 - "SpeechService"
Cohesion: 0.18
Nodes (10): AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, SpeechService, AVSpeechSynthesisVoice, String, Void, PersonasSettingsView (+2 more)

### Community 44 - "LocalLLMError"
Cohesion: 0.13
Nodes (17): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+9 more)

### Community 45 - "String"
Cohesion: 0.22
Nodes (11): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+3 more)

### Community 46 - "MemoryModel"
Cohesion: 0.21
Nodes (11): MemoryModel, Data, EmbeddingService, .isAvailable, Bool, Data, String, MemoryService (+3 more)

### Community 47 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 48 - ".makeInMemoryContainer()"
Cohesion: 0.18
Nodes (6): InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, StaticString, UInt

### Community 49 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 50 - "MoodEntryModel"
Cohesion: 0.23
Nodes (12): MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, MoodCheckInCard, .body (+4 more)

### Community 51 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 52 - "SafetyService"
Cohesion: 0.18
Nodes (8): get_agent_service(), AsyncSession, SafetyEvent, AgentService, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService

### Community 53 - "GraphNodeModel"
Cohesion: 0.33
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 54 - "NarrativeDocument"
Cohesion: 0.19
Nodes (7): NarrativeDocument, NarrativeExportService, String, URL, NarrativeTests, ModelContainer, NSParagraphStyle

### Community 55 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 56 - ".resolve()"
Cohesion: 0.24
Nodes (3): .persona, PersonaTests, TestSupport

### Community 57 - "BackupService"
Cohesion: 0.29
Nodes (10): BackupService, MessageSnapshot, MoodSnapshot, Payload, SessionSnapshot, Data, Date, ModelContext (+2 more)

### Community 58 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 59 - "graph_ui.py"
Cohesion: 0.17
Nodes (11): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphStatsResponse, GraphTimelineResponse (+3 more)

### Community 60 - "String"
Cohesion: 0.19
Nodes (6): SafetyEventModel, Date, Int, String, TimeInterval, VoiceRecordingModel

### Community 61 - "NoteModel"
Cohesion: 0.26
Nodes (9): NoteModel, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView, .body (+1 more)

### Community 62 - "GraphExportServiceTests"
Cohesion: 0.29
Nodes (3): GraphExportServiceTests, Int, ModelContainer

### Community 63 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 64 - "SafetyService.swift"
Cohesion: 0.20
Nodes (7): CommonCrypto, CryptoKit, SafetyService, StoreProtection, Bool, URL, UserNotifications

### Community 66 - "api/voice.py"
Cohesion: 0.21
Nodes (13): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+5 more)

### Community 67 - "Theme"
Cohesion: 0.23
Nodes (9): .body, Color, LinearGradient, String, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament (+1 more)

### Community 68 - "Persona"
Cohesion: 0.21
Nodes (4): Persona, .displayName, String, TherapyService

### Community 69 - "VoiceStatusBar"
Cohesion: 0.15
Nodes (13): CapturedBadgeRow, CrisisBanner, .body, MessageBubble, .body, .hasBadges, Color, Void (+5 more)

### Community 70 - "XCTestCase"
Cohesion: 0.14
Nodes (3): GraphServiceTests, HuggingFaceCatalogTests, XCTestCase

### Community 71 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 72 - "sessions.py"
Cohesion: 0.28
Nodes (12): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+4 more)

### Community 73 - "conftest.py"
Cohesion: 0.21
Nodes (10): init_db(), Create tables directly from model metadata. Convenience for local development…, Authenticate requests when an API key is configured. Accepts either…, require_api_key(), lifespan(), cleanup_vector_store(), client(), db_session() (+2 more)

### Community 74 - "SwiftUI"
Cohesion: 0.19
Nodes (8): AVFoundation, NewSessionView, .body, .defaultProviderLabel, .personaName, String, Speech, SwiftUI

### Community 75 - "Float"
Cohesion: 0.27
Nodes (5): ClosedRange, Float, Int, String, VectorStore

### Community 76 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 77 - "GlobalMemoryServiceTests"
Cohesion: 0.24
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 78 - "FlowLayout"
Cohesion: 0.21
Nodes (9): CGSize, CGRect, FlowLayout, CGFloat, CGRect, Layout, Path, ProposedViewSize (+1 more)

### Community 79 - "SessionRow"
Cohesion: 0.23
Nodes (9): .body, ArchivedSessionsView, .body, ContentView, .body, SessionRow, .personaKind, DashboardTabView (+1 more)

### Community 81 - "Components.swift"
Cohesion: 0.24
Nodes (7): PersonaAvatar, RoundedCorner, CGFloat, .body, Shape, UIKit, UIRectCorner

### Community 83 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 84 - "mode.py"
Cohesion: 0.24
Nodes (9): get_mode(), get_mode_service(), AsyncSession, get, patch, set_mode(), ModeResponse, ModeSetRequest (+1 more)

### Community 85 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 86 - "CompanionPersonality"
Cohesion: 0.20
Nodes (10): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, playful (+2 more)

### Community 87 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 88 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 89 - "test_voice.py"
Cohesion: 0.36
Nodes (9): asyncio, test_delete_recording(), test_delete_recording_not_found(), test_list_recordings(), test_list_recordings_empty(), test_upload_audio(), test_upload_cleans_up_file(), test_voice_chat() (+1 more)

### Community 90 - "api/safety.py"
Cohesion: 0.28
Nodes (8): get_events(), get_safety_service(), get_summary(), AsyncSession, get, SafetyEventResponse, SafetySummaryResponse, SafetyService

### Community 91 - "therapy.py"
Cohesion: 0.31
Nodes (8): get_progress(), get_therapy_service(), AsyncSession, get, suggest_intervention(), InterventionSuggestionResponse, ProgressResponse, TherapyService

### Community 92 - "GlobalMemoryService"
Cohesion: 0.36
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 93 - "CompanionGender"
Cohesion: 0.22
Nodes (9): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+1 more)

### Community 94 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 95 - ".schedule()"
Cohesion: 0.36
Nodes (4): ReminderScheduler, Int, UNNotificationRequest, UNUserNotificationCenter

### Community 96 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 97 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 98 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 99 - ".body"
Cohesion: 0.32
Nodes (7): App, AppRootView, .body, RootTabView, SelfwardApp, .body, Scene

### Community 100 - "DashboardService"
Cohesion: 0.29
Nodes (5): get_global_dashboard(), get_session_dashboard(), get, DashboardService, AsyncSession

### Community 101 - "VoiceService"
Cohesion: 0.43
Nodes (5): AVAudioRecorder, ModelContext, String, URL, VoiceService

### Community 102 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 103 - "InsightsView.swift"
Cohesion: 0.25
Nodes (5): IndexSet, InsightsView, .body, NotesView, .body

### Community 104 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 105 - "MarkdownText"
Cohesion: 0.38
Nodes (5): AttributedString, MarkdownText, .attributed, .body, String

### Community 106 - "NodeConnectionsSheet"
Cohesion: 0.43
Nodes (6): Connection, NodeConnectionsSheet, .body, .connections, Int, String

### Community 108 - "BackupError"
Cohesion: 0.40
Nodes (5): Error, BackupError, keyDerivationFailed, malformed, sealFailed

### Community 109 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

### Community 110 - "XMLParserRecorder"
Cohesion: 0.50
Nodes (4): Error, XMLParserRecorder, NSObject, XMLParserDelegate

### Community 111 - "test_safety_enforcement.py"
Cohesion: 0.60
Nodes (4): asyncio, test_boundary_response_is_filtered(), test_crisis_resource_message_consistent(), test_negation_is_not_crisis()

### Community 113 - "test_health_endpoint()"
Cohesion: 0.50
Nodes (3): AsyncClient, asyncio, test_health_endpoint()

## Knowledge Gaps
- **203 isolated node(s):** `.body`, `.body`, `.body`, `.resolvedProvider`, `.resolvedModel` (+198 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 563 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `ChatService`, `OpenRouterModel`, `SwiftData`, `View`, `DashboardView.swift`, `Identifiable`, `ChatView`, `DreamModel`, `String`, `MemoryModel`, `.makeInMemoryContainer()`, `GraphNodeModel`, `PersonaKind`, `.resolve()`, `BackupService`, `String`, `NoteModel`, `GraphExportServiceTests`, `XCTestCase`, `SwiftUI`, `DashboardService`, `SessionRow`, `VoiceService`, `InsightsView.swift`?**
  _High betweenness centrality (0.102) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `LocalModelService`, `PINView`, `OpenRouterModel`, `SessionModel`, `DashboardView.swift`, `SettingsView.swift`, `Identifiable`, `ChatView`, `TagCapsule`, `DreamModel`, `NarrativeView`, `VoicePickerView`, `SpeechService`, `String`, `MoodEntryModel`, `NoteModel`, `VoiceStatusBar`, `SwiftUI`, `SessionRow`, `Components.swift`, `.body`, `InsightsView.swift`, `MarkdownText`, `NodeConnectionsSheet`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Why does `OpenRouterModel` connect `OpenRouterModel` to `Codable`, `Identifiable`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Are the 32 inferred relationships involving `SessionModel` (e.g. with `.hasActiveCrisis` and `.body`) actually correct?**
  _`SessionModel` has 32 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `AgentContext` (e.g. with `CrisisAgent` and `AgentOrchestrator`) actually correct?**
  _`AgentContext` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `.body`, `.body`, `.body` to the rest of the system?**
  _203 weakly-connected nodes found - possible documentation gaps or missing edges._