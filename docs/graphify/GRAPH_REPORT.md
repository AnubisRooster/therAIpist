# Graph Report - therAIpist  (2026-09-19)

## Corpus Check
- Large corpus: 245 files · ~1,905,662 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2695 nodes · 6644 edges · 126 communities (109 shown, 17 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 645 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- LocalModelService
- PINService
- Foundation
- Float
- BackupRestorePlan
- AgentContext
- SpeechService
- OpenRouterModel
- SessionModel
- AutoBackupService
- KeychainService
- sqlalchemy_ext_asyncio
- database.py
- ChatMessage
- schemas.py
- OnboardingView.swift
- ChatService
- DashboardView.swift
- dreams.py
- asyncio
- graphify_pipeline.py
- ConversationCompactorTests
- LocalLLMError
- XCTestCase
- VoiceConversationController
- insights.py
- GraphService
- .buildIncremental()
- NarrativeView
- MemoryService
- vector_store.py
- SelfwardDesktop
- LocalLLMEngine
- asyncio
- TTSCoordinator
- SettingsView
- Identifiable
- ChatService
- notes.py
- NoteModel
- InsightCaptureServiceTests
- ChatView
- .makeInMemoryContainer()
- api/memory.py
- String
- CompanionPersonality
- Codable
- View
- String
- .ephemeralDefaults()
- VoiceTranscriptTests
- SpiritualTradition
- Coordinator
- pytest
- asyncio
- TherapyService
- String
- GraphNodeModel
- MoodEntryModel
- DashboardView
- test_dreams.py
- NarrativeDocument
- SafetyServiceTests
- NewSessionView
- asyncio
- AnimatedEmptyState
- .processMessage()
- GraphExportServiceTests
- LLMProvider
- TestQdrantVectorStore
- .body
- SafetyService
- SwiftUI
- .classifyHTTPFailure()
- VoiceStatusBar
- BackupFolderPicker
- Persona
- String
- test_notes.py
- env.py
- graph_ui.py
- sessions.py
- api/voice.py
- Theme
- DashboardService
- NodeConnectionsSheet
- ActiveImaginationTests
- PersonaKind
- ChatServiceCompactionTests
- LLMError
- SpiritualPersonaTests
- .decrypt()
- test_auth.py
- VoiceService
- EncryptedBackupDocument
- GraphServiceTests
- test_graph_ui.py
- test_safety.py
- mode.py
- GlobalMemoryService
- .sizeThatFits()
- CodingKeys
- .historyTokenBudget()
- .schedule()
- test_dashboard.py
- test_sessions.py
- chat.py
- therapy.py
- QdrantVectorStore
- RoundedCorner
- test_chat.py
- cosine_similarity()
- TestModalityPrompts
- DreamService
- httpx
- Phase
- PackageDescription
- therapist

## God Nodes (most connected - your core abstractions)
1. `SessionModel` - 143 edges
2. `GraphService` - 46 edges
3. `LocalModelService` - 46 edges
4. `AgentContext` - 44 edges
5. `ChatService` - 44 edges
6. `SwiftData` - 39 edges
7. `Base` - 37 edges
8. `ChatService` - 35 edges
9. `MemoryService` - 34 edges
10. `MockLLM` - 34 edges

## Surprising Connections (you probably didn't know these)
- `TestQdrantVectorStore` --uses--> `Settings`  [INFERRED]
  tests/test_vector_store.py → app/core/config.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/conftest.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_graph.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_insights.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_memory.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (126 total, 17 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "LocalModelService"
Cohesion: 0.05
Nodes (53): Int64, DownloadProgressDelegate, HFModel, HFSibling, HuggingFaceModelService, LocalModel, LocalModelKind, appleFoundation (+45 more)

### Community 2 - "PINService"
Cohesion: 0.06
Nodes (39): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+31 more)

### Community 3 - "Foundation"
Cohesion: 0.05
Nodes (23): AVAudioRecorder, BackupKit, Foundation, BadgeBackfillService, GlobalMemoryService, Int, ModelContext, String (+15 more)

### Community 4 - "Float"
Cohesion: 0.07
Nodes (32): ClosedRange, AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent (+24 more)

### Community 5 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (32): CommonCrypto, CryptoKit, Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot (+24 more)

### Community 6 - "AgentContext"
Cohesion: 0.11
Nodes (25): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+17 more)

### Community 7 - "SpeechService"
Cohesion: 0.06
Nodes (33): AVSpeechSynthesisVoiceQuality, AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, ElevenLabsTTSEngine, SpeechService, AVSpeechSynthesisVoice, Bool (+25 more)

### Community 8 - "OpenRouterModel"
Cohesion: 0.06
Nodes (30): CodingKey, Decoder, Hashable, CodingKeys, architecture, contextLength, id, inputModalities (+22 more)

### Community 9 - "SessionModel"
Cohesion: 0.10
Nodes (18): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String (+10 more)

### Community 10 - "AutoBackupService"
Cohesion: 0.11
Nodes (23): AutoBackupConfig, AutoBackupService, .decoder, .encoder, .folderDisplayName, .isEnabled, .lastBackupDate, .passphrase (+15 more)

### Community 11 - "KeychainService"
Cohesion: 0.08
Nodes (18): Combine, APIKeyProvider, KeychainService, Bool, Data, String, TTSKeyProvider, .displayName (+10 more)

### Community 12 - "sqlalchemy_ext_asyncio"
Cohesion: 0.20
Nodes (15): app_agents, Base, Message, GraphEdge, Note, app_services_providers, get_provider(), collections (+7 more)

### Community 13 - "database.py"
Cohesion: 0.07
Nodes (34): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), get_dashboard_service(), get_global_dashboard() (+26 more)

### Community 14 - "ChatMessage"
Cohesion: 0.10
Nodes (20): Settings, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, OllamaProvider, OpenRouterProvider (+12 more)

### Community 15 - "schemas.py"
Cohesion: 0.11
Nodes (38): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+30 more)

### Community 16 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 17 - "ChatService"
Cohesion: 0.12
Nodes (24): get_chat_service(), AsyncSession, SessionCreate, Session, ChatService, AsyncSession, ModeService, AsyncSession (+16 more)

### Community 18 - "DashboardView.swift"
Cohesion: 0.10
Nodes (30): Charts, DreamModel, GlobalMemoryModel, .body, DreamDetailView, .body, .feelings, .symbols (+22 more)

### Community 19 - "dreams.py"
Cohesion: 0.11
Nodes (22): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+14 more)

### Community 20 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 21 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 22 - "ConversationCompactorTests"
Cohesion: 0.13
Nodes (8): ConversationCompactor, StoredState, Date, Int, String, ConversationCompactorTests, Int, String

### Community 23 - "LocalLLMError"
Cohesion: 0.08
Nodes (25): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+17 more)

### Community 24 - "XCTestCase"
Cohesion: 0.11
Nodes (12): ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM, AsyncThrowingStream, String, Error (+4 more)

### Community 25 - "VoiceConversationController"
Cohesion: 0.17
Nodes (12): Bool, Never, String, Task, TimeInterval, Timer, Void, VoiceConversationController (+4 more)

### Community 26 - "insights.py"
Cohesion: 0.16
Nodes (20): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+12 more)

### Community 27 - "GraphService"
Cohesion: 0.13
Nodes (7): GraphNode, GraphService, AsyncSession, AsyncSession, db_session(), graph_service(), fixture

### Community 28 - ".buildIncremental()"
Cohesion: 0.19
Nodes (11): MessageModel, Bool, NarrativeService, Source, Bool, Date, ModelContext, String (+3 more)

### Community 29 - "NarrativeView"
Cohesion: 0.12
Nodes (20): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+12 more)

### Community 30 - "MemoryService"
Cohesion: 0.16
Nodes (7): EpisodicMemory, ProceduralMemory, SemanticMemory, MemoryService, db_session(), memory_service(), fixture

### Community 31 - "vector_store.py"
Cohesion: 0.13
Nodes (9): AsyncSession, get_vector_store(), InMemoryVectorStore, ABC, reset_vector_store(), SearchResult, VectorStore, dataclasses (+1 more)

### Community 32 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 33 - "LocalLLMEngine"
Cohesion: 0.14
Nodes (11): LocalLLMEngine, Int, Never, String, Task, URL, Void, LocalLLMEngineTests (+3 more)

### Community 34 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 35 - "TTSCoordinator"
Cohesion: 0.15
Nodes (14): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+6 more)

### Community 36 - "SettingsView"
Cohesion: 0.13
Nodes (16): Binding, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+8 more)

### Community 37 - "Identifiable"
Cohesion: 0.21
Nodes (10): Identifiable, AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL (+2 more)

### Community 38 - "ChatService"
Cohesion: 0.21
Nodes (6): ChatService, ChatServiceE2ETests, ModelContainer, ModelContext, String, MockLLM

### Community 39 - "notes.py"
Cohesion: 0.14
Nodes (15): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+7 more)

### Community 40 - "NoteModel"
Cohesion: 0.19
Nodes (10): NoteModel, ModelContext, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView (+2 more)

### Community 41 - "InsightCaptureServiceTests"
Cohesion: 0.18
Nodes (6): DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 42 - "ChatView"
Cohesion: 0.15
Nodes (11): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, Bool, Date (+3 more)

### Community 43 - ".makeInMemoryContainer()"
Cohesion: 0.16
Nodes (6): InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, StaticString, UInt

### Community 44 - "api/memory.py"
Cohesion: 0.18
Nodes (19): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+11 more)

### Community 45 - "String"
Cohesion: 0.23
Nodes (8): BYOKLLMKit, LLMMessage, unsupportedProvider, LLMService, LLMStreaming, AsyncThrowingStream, Data, String

### Community 46 - "CompanionPersonality"
Cohesion: 0.11
Nodes (19): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+11 more)

### Community 47 - "Codable"
Cohesion: 0.27
Nodes (18): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+10 more)

### Community 48 - "View"
Cohesion: 0.18
Nodes (13): PersonaAvatar, Bool, TagCapsule, .body, View, .body, ModelPickerView, .body (+5 more)

### Community 49 - "String"
Cohesion: 0.16
Nodes (8): MemoryModel, SafetyEventModel, Data, Date, Int, String, TimeInterval, VoiceRecordingModel

### Community 50 - ".ephemeralDefaults()"
Cohesion: 0.22
Nodes (4): PersonaService, UserDefaults, PersonaTests, TestSupport

### Community 52 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 53 - "Coordinator"
Cohesion: 0.16
Nodes (12): Coordinator, GraphVisualizationView, Coordinator, String, Void, UIViewRepresentable, WKNavigation, WKNavigationDelegate (+4 more)

### Community 54 - "pytest"
Cohesion: 0.15
Nodes (15): pytest, pytest_asyncio, cleanup_vector_store(), client(), db_session(), AsyncSession, fixture, db_session() (+7 more)

### Community 55 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 56 - "TherapyService"
Cohesion: 0.15
Nodes (8): DashboardService, AsyncSession, AsyncSession, TherapyService, db_session(), graph_service(), fixture, therapy_service()

### Community 57 - "String"
Cohesion: 0.24
Nodes (11): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+3 more)

### Community 58 - "GraphNodeModel"
Cohesion: 0.30
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 59 - "MoodEntryModel"
Cohesion: 0.22
Nodes (12): MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, MoodCheckInCard, .body (+4 more)

### Community 60 - "DashboardView"
Cohesion: 0.12
Nodes (18): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+10 more)

### Community 61 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 62 - "NarrativeDocument"
Cohesion: 0.19
Nodes (7): NarrativeDocument, NarrativeExportService, String, URL, NarrativeTests, ModelContainer, NSParagraphStyle

### Community 64 - "NewSessionView"
Cohesion: 0.15
Nodes (12): ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind, NewSessionView (+4 more)

### Community 65 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 66 - "AnimatedEmptyState"
Cohesion: 0.16
Nodes (14): Actions, Font, AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body (+6 more)

### Community 67 - ".processMessage()"
Cohesion: 0.16
Nodes (9): ChatResult, ChatResult, ModelContext, Bool, Int, ModelContext, String, Void (+1 more)

### Community 68 - "GraphExportServiceTests"
Cohesion: 0.29
Nodes (3): GraphExportServiceTests, Int, ModelContainer

### Community 69 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 70 - "TestQdrantVectorStore"
Cohesion: 0.19
Nodes (4): asyncio, fixture, TestInMemoryVectorStore, TestQdrantVectorStore

### Community 71 - ".body"
Cohesion: 0.17
Nodes (12): App, AppRootView, .body, RootTabView, .body, SelfwardApp, .body, DashboardTabView (+4 more)

### Community 72 - "SafetyService"
Cohesion: 0.21
Nodes (6): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService, re

### Community 73 - "SwiftUI"
Cohesion: 0.16
Nodes (8): AttributedString, AVFoundation, MarkdownText, .attributed, .body, String, Speech, SwiftUI

### Community 74 - ".classifyHTTPFailure()"
Cohesion: 0.26
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 75 - "VoiceStatusBar"
Cohesion: 0.14
Nodes (14): CapturedBadgeRow, CrisisBanner, .body, MessageBubble, .body, .hasBadges, Color, String (+6 more)

### Community 76 - "BackupFolderPicker"
Cohesion: 0.22
Nodes (9): BackupFolderPicker, Coordinator, Context, Coordinator, Result, URL, Void, UIDocumentPickerDelegate (+1 more)

### Community 77 - "Persona"
Cohesion: 0.21
Nodes (4): Persona, .displayName, String, TherapyService

### Community 78 - "String"
Cohesion: 0.25
Nodes (7): CrisisResources, Resource, SafetyService, StoreProtection, Bool, String, URL

### Community 79 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 80 - "env.py"
Cohesion: 0.17
Nodes (8): alembic, app_models, asyncio, logging_config, do_run_migrations(), run_migrations_online(), sqlalchemy_engine, typing

### Community 81 - "graph_ui.py"
Cohesion: 0.23
Nodes (8): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphUIService, AsyncSession

### Community 82 - "sessions.py"
Cohesion: 0.28
Nodes (12): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+4 more)

### Community 83 - "api/voice.py"
Cohesion: 0.23
Nodes (12): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+4 more)

### Community 84 - "Theme"
Cohesion: 0.23
Nodes (9): .body, Color, LinearGradient, String, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament (+1 more)

### Community 85 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 86 - "NodeConnectionsSheet"
Cohesion: 0.19
Nodes (10): Connection, NodeConnectionsSheet, .connections, ShareSheet, Any, Context, Int, UIActivityViewController (+2 more)

### Community 88 - "PersonaKind"
Cohesion: 0.17
Nodes (12): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+4 more)

### Community 89 - "ChatServiceCompactionTests"
Cohesion: 0.30
Nodes (3): ChatServiceCompactionTests, ModelContainer, ModelContext

### Community 90 - "LLMError"
Cohesion: 0.18
Nodes (10): LLMError, apiError, contextLengthExceeded, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded, noAPIKey (+2 more)

### Community 92 - ".decrypt()"
Cohesion: 0.38
Nodes (4): BackupService, Data, ModelContext, Payload

### Community 93 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 94 - "VoiceService"
Cohesion: 0.29
Nodes (5): VoiceRecording, get_stt_provider(), AsyncSession, VoiceService, settings

### Community 95 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 97 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 98 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 99 - "mode.py"
Cohesion: 0.28
Nodes (8): get_mode(), get_mode_service(), AsyncSession, get, patch, set_mode(), ModeSetRequest, ModeUpdateResponse

### Community 100 - "GlobalMemoryService"
Cohesion: 0.36
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 101 - ".sizeThatFits()"
Cohesion: 0.31
Nodes (7): CGSize, FlowLayout, CGFloat, CGRect, Layout, ProposedViewSize, Subviews

### Community 102 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 103 - ".historyTokenBudget()"
Cohesion: 0.28
Nodes (5): AsyncThrowingStream, Bool, Int, String, Void

### Community 104 - ".schedule()"
Cohesion: 0.36
Nodes (4): ReminderScheduler, Int, UNNotificationRequest, UNUserNotificationCenter

### Community 105 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 106 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 107 - "chat.py"
Cohesion: 0.36
Nodes (7): chat(), get_chat_history(), AsyncSession, get, post, ChatRequest, ChatResponse

### Community 108 - "therapy.py"
Cohesion: 0.36
Nodes (7): get_progress(), get_therapy_service(), AsyncSession, get, suggest_intervention(), InterventionSuggestionResponse, ProgressResponse

### Community 110 - "RoundedCorner"
Cohesion: 0.32
Nodes (6): RoundedCorner, CGFloat, CGRect, Path, Shape, UIRectCorner

### Community 111 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 114 - "DreamService"
Cohesion: 0.47
Nodes (3): DreamService, ModelContext, String

### Community 115 - "httpx"
Cohesion: 0.40
Nodes (4): httpx, AsyncClient, asyncio, test_health_endpoint()

### Community 116 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **208 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+203 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 600 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `Foundation`, `Float`, `AutoBackupService`, `DashboardView.swift`, `XCTestCase`, `.buildIncremental()`, `Identifiable`, `ChatService`, `NoteModel`, `InsightCaptureServiceTests`, `ChatView`, `.makeInMemoryContainer()`, `String`, `View`, `String`, `.ephemeralDefaults()`, `String`, `GraphNodeModel`, `DashboardView`, `NewSessionView`, `.processMessage()`, `GraphExportServiceTests`, `DashboardService`, `ChatServiceCompactionTests`, `SpiritualPersonaTests`, `.decrypt()`, `GraphServiceTests`, `DreamService`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `LocalModelService`, `PINService`, `Float`, `BackupRestorePlan`, `OpenRouterModel`, `SessionModel`, `KeychainService`, `LocalLLMError`, `.buildIncremental()`, `LocalLLMEngine`, `Identifiable`, `NoteModel`, `InsightCaptureServiceTests`, `String`, `CompanionPersonality`, `Codable`, `String`, `GraphNodeModel`, `SwiftUI`, `Persona`, `DashboardService`, `DreamService`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `LocalModelService`, `PINService`, `SpeechService`, `SessionModel`, `OnboardingView.swift`, `DashboardView.swift`, `NarrativeView`, `SettingsView`, `Identifiable`, `NoteModel`, `ChatView`, `String`, `MoodEntryModel`, `DashboardView`, `NewSessionView`, `AnimatedEmptyState`, `.body`, `SwiftUI`, `VoiceStatusBar`, `NodeConnectionsSheet`, `RoundedCorner`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 43 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `LocalModelService` (e.g. with `.downloadedLocalModels` and `.localAvailable`) actually correct?**
  _`LocalModelService` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _208 weakly-connected nodes found - possible documentation gaps or missing edges._