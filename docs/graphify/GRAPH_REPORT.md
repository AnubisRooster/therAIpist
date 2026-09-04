# Graph Report - therAIpist  (2026-09-04)

## Corpus Check
- Large corpus: 229 files · ~1,871,764 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2422 nodes · 5741 edges · 124 communities (103 shown, 13 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 548 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINView
- AgentContext
- SafetyServiceTests
- InMemoryVectorStore
- Float
- .get()
- chat_service.py
- schemas.py
- OnboardingView.swift
- SessionModel
- MemoryService
- asyncio
- Base
- database.py
- LocalModelService
- dreams.py
- FastAPI
- OpenRouterModel
- VoiceConversationController
- NarrativeView
- View
- asyncio
- insights.py
- String
- DashboardView.swift
- Coordinator
- ChatServiceStreamingTests
- Session
- SwiftUI
- Identifiable
- InsightCaptureServiceTests
- ChatView
- api/graph.py
- ChatService
- ChatService
- VoiceService
- LocalLLMEngine
- TTSCoordinator
- VoicePickerView
- CompanionPersonality
- Codable
- LocalModel
- .resolve()
- VoiceTranscriptTests
- NoteModel
- SpiritualTradition
- .makeInMemoryContainer()
- asyncio
- String
- String
- MoodEntryModel
- test_dreams.py
- GraphService
- SpeechService
- DreamModel
- GraphNodeModel
- String
- SettingsView.swift
- Selfward
- GraphExportServiceTests
- LLMProvider
- .buildIncremental()
- asyncio
- SelfwardDesktop
- SwiftData
- SafetyService
- DownloadProgressDelegate
- .processMessage()
- Persona
- VoiceStatusBar
- XCTestCase
- test_notes.py
- graph_ui.py
- sessions.py
- api/voice.py
- TherapyService
- VoiceService
- AppleFoundationEngine
- Theme
- DashboardService
- ActiveImaginationTests
- GlobalMemoryServiceTests
- FlowLayout
- MemoryModel
- PersonaKind
- ModelPickerView
- .body
- MessageModel
- SpiritualPersonaTests
- test_auth.py
- GlobalMemoryService
- EncryptedBackupDocument
- InsightsView.swift
- test_graph_ui.py
- test_safety.py
- test_voice.py
- CodingKeys
- NarrativeExportService
- DashboardSheet
- DashboardView
- test_dashboard.py
- test_sessions.py
- api/safety.py
- test_chat.py
- MarkdownText
- NarrativeTests
- TestModalityPrompts
- get_dashboard_service()
- LocalLLMError
- OpenRouterModelFilterTests
- Phase
- env.py
- test_health_endpoint()
- graphify_pipeline.py
- therapist

## God Nodes (most connected - your core abstractions)
1. `SessionModel` - 135 edges
2. `GraphService` - 45 edges
3. `LocalModelService` - 42 edges
4. `SwiftData` - 35 edges
5. `ChatService` - 34 edges
6. `MemoryService` - 34 edges
7. `VoiceConversationController` - 34 edges
8. `Base` - 31 edges
9. `ChatService` - 31 edges
10. `NarrativeView` - 29 edges

## Surprising Connections (you probably didn't know these)
- `provider()` --uses--> `Settings`  [INFERRED]
  tests/test_providers/test_ollama.py → app/core/config.py
- `provider()` --uses--> `Settings`  [INFERRED]
  tests/test_providers/test_openrouter.py → app/core/config.py
- `TestGraphNodeOperations` --uses--> `GraphNode`  [INFERRED]
  tests/test_graph.py → app/models/graph.py
- `TestEpisodicMemory` --uses--> `EpisodicMemory`  [INFERRED]
  tests/test_memory.py → app/models/memory.py
- `graph_service()` --uses--> `GraphService`  [INFERRED]
  tests/test_graph.py → app/services/graph_service.py

## Import Cycles
- None detected.

## Communities (124 total, 13 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINView"
Cohesion: 0.06
Nodes (39): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+31 more)

### Community 2 - "AgentContext"
Cohesion: 0.08
Nodes (37): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentContext, AgentResult, TherapyAgent (+29 more)

### Community 3 - "SafetyServiceTests"
Cohesion: 0.06
Nodes (30): CommonCrypto, CryptoKit, Error, BackupError, keyDerivationFailed, malformed, sealFailed, BackupService (+22 more)

### Community 4 - "InMemoryVectorStore"
Cohesion: 0.05
Nodes (27): Settings, AsyncSession, cosine_similarity(), get_vector_store(), InMemoryVectorStore, ABC, QdrantVectorStore, reset_vector_store() (+19 more)

### Community 5 - "Float"
Cohesion: 0.07
Nodes (32): ClosedRange, AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent (+24 more)

### Community 6 - ".get()"
Cohesion: 0.06
Nodes (27): Combine, ElevenLabsTTSEngine, APIKeyProvider, KeychainService, Bool, String, TTSKeyProvider, .displayName (+19 more)

### Community 7 - "chat_service.py"
Cohesion: 0.10
Nodes (20): ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, get_provider(), OllamaProvider, ChatResult (+12 more)

### Community 8 - "schemas.py"
Cohesion: 0.10
Nodes (37): chat(), get_chat_history(), AsyncSession, get, post, get_mode(), get_mode_service(), AsyncSession (+29 more)

### Community 9 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 10 - "SessionModel"
Cohesion: 0.14
Nodes (11): SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String, GraphView (+3 more)

### Community 11 - "MemoryService"
Cohesion: 0.11
Nodes (21): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+13 more)

### Community 12 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 13 - "Base"
Cohesion: 0.16
Nodes (13): Base, GraphEdge, GraphNode, EpisodicMemory, ProceduralMemory, SemanticMemory, DeclarativeBase, db_session() (+5 more)

### Community 14 - "database.py"
Cohesion: 0.09
Nodes (27): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), get_progress(), get_therapy_service() (+19 more)

### Community 15 - "LocalModelService"
Cohesion: 0.11
Nodes (21): LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, Bool, .downloadedLocalModels, .localAvailable, .resolvedLocalModel (+13 more)

### Community 16 - "dreams.py"
Cohesion: 0.13
Nodes (19): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+11 more)

### Community 17 - "FastAPI"
Cohesion: 0.11
Nodes (21): health_check(), get, create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete (+13 more)

### Community 18 - "OpenRouterModel"
Cohesion: 0.10
Nodes (25): CodingKey, Decoder, CodingKeys, architecture, contextLength, id, inputModalities, modality (+17 more)

### Community 19 - "VoiceConversationController"
Cohesion: 0.15
Nodes (15): Equatable, Bool, Never, String, Task, TimeInterval, Timer, Void (+7 more)

### Community 20 - "NarrativeView"
Cohesion: 0.11
Nodes (23): Font, CGFloat, NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body (+15 more)

### Community 21 - "View"
Cohesion: 0.12
Nodes (25): Actions, AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body, PersonaAvatar (+17 more)

### Community 22 - "asyncio"
Cohesion: 0.12
Nodes (10): db_session(), graph_service(), insight_service(), asyncio, fixture, TestBuildContext, TestCycleDetection, TestGenerateInsights (+2 more)

### Community 23 - "insights.py"
Cohesion: 0.16
Nodes (21): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+13 more)

### Community 24 - "String"
Cohesion: 0.16
Nodes (18): BYOKLLMKit, LLMMessage, OpenRouterRequest, Bool, LLMError, apiError, emptyResponse, .errorDescription (+10 more)

### Community 25 - "DashboardView.swift"
Cohesion: 0.13
Nodes (22): Charts, GlobalMemoryModel, .body, FlowTagView, .body, GlobalMemoriesListView, .body, .filtered (+14 more)

### Community 26 - "Coordinator"
Cohesion: 0.11
Nodes (17): Context, Coordinator, GraphVisualizationView, ShareSheet, Any, String, Void, UIActivityViewController (+9 more)

### Community 27 - "ChatServiceStreamingTests"
Cohesion: 0.13
Nodes (8): ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM, AsyncThrowingStream, Error, String

### Community 28 - "Session"
Cohesion: 0.22
Nodes (18): Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture, test_get_mode_default(), test_get_mode_not_found() (+10 more)

### Community 29 - "SwiftUI"
Cohesion: 0.11
Nodes (15): AVFoundation, ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind (+7 more)

### Community 30 - "Identifiable"
Cohesion: 0.20
Nodes (11): Identifiable, AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL (+3 more)

### Community 31 - "InsightCaptureServiceTests"
Cohesion: 0.15
Nodes (8): BadgeBackfillService, ModelContext, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 32 - "ChatView"
Cohesion: 0.13
Nodes (13): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, Bool, Date (+5 more)

### Community 33 - "api/graph.py"
Cohesion: 0.19
Nodes (22): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+14 more)

### Community 34 - "ChatService"
Cohesion: 0.21
Nodes (6): ChatService, ChatServiceE2ETests, ModelContainer, ModelContext, String, MockLLM

### Community 35 - "ChatService"
Cohesion: 0.15
Nodes (9): Message, SessionCreate, ChatService, AsyncSession, db_session(), graph_service(), fixture, TestProgress (+1 more)

### Community 36 - "VoiceService"
Cohesion: 0.15
Nodes (9): VoiceRecording, get_stt_provider(), ABC, STTProvider, TranscriptResult, MockSTTProvider, AsyncSession, VoiceService (+1 more)

### Community 37 - "LocalLLMEngine"
Cohesion: 0.17
Nodes (10): LocalLLMEngine, Int, Never, String, Task, URL, Void, LocalLLMEngineTests (+2 more)

### Community 38 - "TTSCoordinator"
Cohesion: 0.20
Nodes (11): AnyCancellable, CheckedContinuation, PrefetchedSentence, text, Bool, Never, Task, Void (+3 more)

### Community 39 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 40 - "CompanionPersonality"
Cohesion: 0.11
Nodes (19): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+11 more)

### Community 41 - "Codable"
Cohesion: 0.27
Nodes (17): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+9 more)

### Community 42 - "LocalModel"
Cohesion: 0.13
Nodes (15): Hashable, LocalModel, LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma (+7 more)

### Community 43 - ".resolve()"
Cohesion: 0.22
Nodes (4): PersonaService, UserDefaults, PersonaTests, TestSupport

### Community 45 - "NoteModel"
Cohesion: 0.21
Nodes (9): NoteModel, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView, .body (+1 more)

### Community 46 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 47 - ".makeInMemoryContainer()"
Cohesion: 0.18
Nodes (6): InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, StaticString, UInt

### Community 48 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 49 - "String"
Cohesion: 0.20
Nodes (7): NarrativeDocument, SafetyEventModel, Date, Int, String, TimeInterval, VoiceRecordingModel

### Community 50 - "String"
Cohesion: 0.23
Nodes (11): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+3 more)

### Community 51 - "MoodEntryModel"
Cohesion: 0.23
Nodes (12): MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, MoodCheckInCard, .body (+4 more)

### Community 52 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 54 - "SpeechService"
Cohesion: 0.21
Nodes (9): AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, SpeechService, AVSpeechSynthesisVoice, String, Void, PersonasSettingsView (+1 more)

### Community 55 - "DreamModel"
Cohesion: 0.20
Nodes (11): DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings, .symbols (+3 more)

### Community 56 - "GraphNodeModel"
Cohesion: 0.33
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 57 - "String"
Cohesion: 0.23
Nodes (8): HFModel, HFSibling, HuggingFaceModelService, Data, Int, String, TimeInterval, .recommendedID

### Community 58 - "SettingsView.swift"
Cohesion: 0.18
Nodes (13): AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, SettingsTabView, .body (+5 more)

### Community 60 - "GraphExportServiceTests"
Cohesion: 0.29
Nodes (3): GraphExportServiceTests, Int, ModelContainer

### Community 61 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 62 - ".buildIncremental()"
Cohesion: 0.29
Nodes (7): LLMSending, NarrativeService, Source, Bool, Date, ModelContext, String

### Community 63 - "asyncio"
Cohesion: 0.22
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 66 - "SafetyService"
Cohesion: 0.23
Nodes (5): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService

### Community 67 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (11): Int64, DownloadProgressDelegate, Double, Error, URL, Void, Result, URLSession (+3 more)

### Community 68 - ".processMessage()"
Cohesion: 0.25
Nodes (8): ChatResult, AsyncThrowingStream, Bool, Error, Int, ModelContext, String, Void

### Community 69 - "Persona"
Cohesion: 0.21
Nodes (4): Persona, .displayName, String, TherapyService

### Community 70 - "VoiceStatusBar"
Cohesion: 0.15
Nodes (13): CapturedBadgeRow, CrisisBanner, .body, MessageBubble, .body, .hasBadges, Color, Void (+5 more)

### Community 71 - "XCTestCase"
Cohesion: 0.14
Nodes (3): GraphServiceTests, HuggingFaceCatalogTests, XCTestCase

### Community 72 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 73 - "graph_ui.py"
Cohesion: 0.23
Nodes (8): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphUIService, AsyncSession

### Community 74 - "sessions.py"
Cohesion: 0.28
Nodes (12): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+4 more)

### Community 75 - "api/voice.py"
Cohesion: 0.27
Nodes (12): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+4 more)

### Community 76 - "TherapyService"
Cohesion: 0.19
Nodes (4): DashboardService, AsyncSession, AsyncSession, TherapyService

### Community 77 - "VoiceService"
Cohesion: 0.23
Nodes (9): AVAudioRecorder, ModelContext, String, URL, VoiceService, Error, XMLParserRecorder, NSObject (+1 more)

### Community 78 - "AppleFoundationEngine"
Cohesion: 0.21
Nodes (11): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+3 more)

### Community 79 - "Theme"
Cohesion: 0.26
Nodes (9): .body, Color, LinearGradient, String, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament (+1 more)

### Community 80 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 82 - "GlobalMemoryServiceTests"
Cohesion: 0.24
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 83 - "FlowLayout"
Cohesion: 0.21
Nodes (9): CGSize, CGRect, FlowLayout, CGFloat, CGRect, Layout, Path, ProposedViewSize (+1 more)

### Community 84 - "MemoryModel"
Cohesion: 0.38
Nodes (6): MemoryModel, Data, String, MemoryService, ModelContext, String

### Community 85 - "PersonaKind"
Cohesion: 0.17
Nodes (12): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+4 more)

### Community 86 - "ModelPickerView"
Cohesion: 0.27
Nodes (7): ModelPickerView, .body, .freeSorted, .paidSorted, Int, LLMProvider, String

### Community 87 - ".body"
Cohesion: 0.22
Nodes (10): App, AppRootView, .body, RootTabView, .body, SelfwardApp, .body, DashboardTabView (+2 more)

### Community 88 - "MessageModel"
Cohesion: 0.35
Nodes (5): MessageModel, Bool, NarrativeServiceTests, ModelContainer, String

### Community 90 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 91 - "GlobalMemoryService"
Cohesion: 0.33
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 92 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 93 - "InsightsView.swift"
Cohesion: 0.22
Nodes (7): IndexSet, DreamsView, .body, InsightsView, .body, NotesView, .body

### Community 94 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 95 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 96 - "test_voice.py"
Cohesion: 0.36
Nodes (9): asyncio, test_delete_recording(), test_delete_recording_not_found(), test_list_recordings(), test_list_recordings_empty(), test_upload_audio(), test_upload_cleans_up_file(), test_voice_chat() (+1 more)

### Community 97 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 98 - "NarrativeExportService"
Cohesion: 0.36
Nodes (4): NarrativeExportService, String, URL, NSParagraphStyle

### Community 99 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 100 - "DashboardView"
Cohesion: 0.25
Nodes (9): DashboardView, .allDreams, .allEdges, .allMemories, .allNodes, .allNotes, .globalMemories, .recentNotes (+1 more)

### Community 101 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 102 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 103 - "api/safety.py"
Cohesion: 0.39
Nodes (7): get_events(), get_safety_service(), get_summary(), AsyncSession, get, SafetyEventResponse, SafetyService

### Community 104 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 105 - "MarkdownText"
Cohesion: 0.38
Nodes (5): AttributedString, MarkdownText, .attributed, .body, String

### Community 108 - "get_dashboard_service()"
Cohesion: 0.40
Nodes (6): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), AsyncSession, get, DashboardService

### Community 109 - "LocalLLMError"
Cohesion: 0.33
Nodes (6): LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout

### Community 111 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

### Community 113 - "test_health_endpoint()"
Cohesion: 0.50
Nodes (3): AsyncClient, asyncio, test_health_endpoint()

## Knowledge Gaps
- **203 isolated node(s):** `.body`, `.body`, `.body`, `.resolvedProvider`, `.resolvedModel` (+198 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 558 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `SafetyServiceTests`, `DashboardView.swift`, `ChatServiceStreamingTests`, `SwiftUI`, `Identifiable`, `InsightCaptureServiceTests`, `ChatView`, `ChatService`, `.resolve()`, `NoteModel`, `.makeInMemoryContainer()`, `String`, `String`, `DreamModel`, `GraphNodeModel`, `GraphExportServiceTests`, `.buildIncremental()`, `.processMessage()`, `XCTestCase`, `VoiceService`, `DashboardService`, `MemoryModel`, `ModelPickerView`, `MessageModel`, `SpiritualPersonaTests`, `InsightsView.swift`, `DashboardView`?**
  _High betweenness centrality (0.090) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `PINView`, `.get()`, `OnboardingView.swift`, `SessionModel`, `LocalModelService`, `NarrativeView`, `DashboardView.swift`, `SwiftUI`, `Identifiable`, `ChatView`, `VoicePickerView`, `NoteModel`, `String`, `MoodEntryModel`, `SpeechService`, `DreamModel`, `SettingsView.swift`, `VoiceStatusBar`, `ModelPickerView`, `.body`, `InsightsView.swift`, `DashboardView`, `MarkdownText`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Why does `Foundation` connect `SwiftData` to `PINView`, `SafetyServiceTests`, `Float`, `.get()`, `LocalLLMEngine`, `CompanionPersonality`, `Codable`, `LocalModel`, `Persona`, `AppleFoundationEngine`, `DashboardService`, `String`, `OpenRouterModel`, `String`, `SwiftUI`, `Identifiable`, `InsightCaptureServiceTests`?**
  _High betweenness centrality (0.038) - this node is a cross-community bridge._
- **Are the 32 inferred relationships involving `SessionModel` (e.g. with `.hasActiveCrisis` and `.body`) actually correct?**
  _`SessionModel` has 32 INFERRED edges - model-reasoned connections that need verification._
- **Are the 17 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 17 INFERRED edges - model-reasoned connections that need verification._
- **Are the 7 inferred relationships involving `LocalModelService` (e.g. with `.localAvailable` and `.resolvedLocalModel`) actually correct?**
  _`LocalModelService` has 7 INFERRED edges - model-reasoned connections that need verification._
- **What connects `.body`, `.body`, `.body` to the rest of the system?**
  _203 weakly-connected nodes found - possible documentation gaps or missing edges._