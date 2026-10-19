# Graph Report - therAIpist  (2026-10-19)

## Corpus Check
- Large corpus: 233 files · ~778,243 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2731 nodes · 6816 edges · 144 communities (98 shown, 46 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 707 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- LocalModelService
- PINService
- Float
- BackupRestorePlan
- AgentContext
- SessionModel
- ChatMessage
- sqlalchemy_ext_asyncio
- ConversationCompactorTests
- OnboardingView.swift
- asyncio
- schemas.py
- dreams.py
- database.py
- DashboardView.swift
- GraphService
- String
- AutoBackupService
- Error
- Session
- AggregatedGraph
- insights.py
- .buildIncremental()
- vector_store.py
- View
- ChatView
- NarrativeView
- MemoryService
- SelfwardDesktop
- graphify_pipeline.py
- LocalLLMEngine
- asyncio
- TherapyService
- .get()
- ChatService
- Foundation
- SettingsView
- String
- Codable
- .makeInMemoryContainer()
- SafetyServiceTests
- VoiceConversationController
- notes.py
- AppleFoundationEngine
- NoteModel
- InsightCaptureServiceTests
- XCTest
- api/memory.py
- VoicePickerView
- GraphNodeModel
- KeychainService
- ChatService
- XCTestCase
- VoiceTranscriptTests
- pytest
- TTSCoordinator
- api/voice.py
- Coordinator
- MockLLM
- test_dreams.py
- asyncio
- SpeechService
- Theme
- GraphService
- .trendSummary()
- PersonaKind
- .ephemeralDefaults()
- graph_ui.py
- DreamModel
- LLMError
- ModelService
- .classifyHTTPFailure()
- LLMProvider
- FakeKeychain
- asyncio
- SafetyService
- MarkdownText
- SwiftUI
- GraphServiceTests
- TestQdrantVectorStore
- Persona
- ModelServiceTests
- test_notes.py
- env.py
- sessions.py
- SessionRow
- DashboardService
- BackupFolderPicker
- GlobalMemoryServiceTests
- OpenRouterModel
- .decrypt()
- String
- ModelPickerView
- ActiveImaginationTests
- CompanionPersonality
- SpiritualPersonaTests
- test_auth.py
- .body
- agents.py
- CodingKeys
- EncryptedBackupDocument
- test_graph_ui.py
- test_safety.py
- chat.py
- CompanionGender
- .sizeThatFits()
- VoiceSettingsView
- CodingKeys
- .processMessage()
- .writePDF()
- DashboardSheet
- DashboardView
- InsightServiceTests
- test_dashboard.py
- test_sessions.py
- QdrantVectorStore
- VoiceService
- TTSKeyProvider
- .schedule()
- .stripMarkdown()
- NodeConnectionsSheet
- test_chat.py
- GlobalMemoryService
- cosine_similarity()
- ShareSheet
- TestModalityPrompts
- LocalLLMError
- VoiceStatusBar
- GraphExportServiceTests.swift
- .decode()
- httpx
- Phase
- PackageDescription
- therapist

## God Nodes (most connected - your core abstractions)
1. `SessionModel` - 145 edges
2. `ChatService` - 50 edges
3. `GraphService` - 46 edges
4. `LocalModelService` - 46 edges
5. `AgentContext` - 44 edges
6. `SwiftData` - 39 edges
7. `MockLLM` - 39 edges
8. `Base` - 37 edges
9. `ChatService` - 35 edges
10. `MemoryService` - 34 edges

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

## Communities (144 total, 46 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "LocalModelService"
Cohesion: 0.05
Nodes (36): DownloadProgressDelegate, HFModel, HFSibling, HuggingFaceModelService, LocalModel, LocalModelKind, appleFoundation, gguf (+28 more)

### Community 2 - "PINService"
Cohesion: 0.06
Nodes (27): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+19 more)

### Community 3 - "Float"
Cohesion: 0.07
Nodes (22): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+14 more)

### Community 4 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (18): CommonCrypto, CryptoKit, BackupCrypto, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot, BackupPlanner (+10 more)

### Community 5 - "AgentContext"
Cohesion: 0.11
Nodes (22): AgentContext, AgentResult, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent, IntegrativeAgent (+14 more)

### Community 6 - "SessionModel"
Cohesion: 0.08
Nodes (16): SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, DreamsView, .body (+8 more)

### Community 7 - "ChatMessage"
Cohesion: 0.08
Nodes (14): Settings, ChatMessage, ChatResult, LLMProvider, get_stt_provider(), OllamaProvider, OpenRouterProvider, STTProvider (+6 more)

### Community 8 - "sqlalchemy_ext_asyncio"
Cohesion: 0.19
Nodes (8): Base, GraphEdge, GraphNode, VoiceRecording, AgentService, get_provider(), db_session(), graph_service()

### Community 9 - "ConversationCompactorTests"
Cohesion: 0.11
Nodes (3): ConversationCompactor, StoredState, ConversationCompactorTests

### Community 10 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (31): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+23 more)

### Community 11 - "asyncio"
Cohesion: 0.09
Nodes (6): TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 12 - "schemas.py"
Cohesion: 0.13
Nodes (27): create_edge(), create_node(), extract(), health_check(), get_mode_service(), GlobalDashboardResponse, GraphConnectionResponse, GraphEdgeCreate (+19 more)

### Community 13 - "dreams.py"
Cohesion: 0.12
Nodes (16): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+8 more)

### Community 14 - "database.py"
Cohesion: 0.09
Nodes (15): get_events(), get_safety_service(), get_summary(), get_progress(), get_therapy_service(), suggest_intervention(), get_db(), init_db() (+7 more)

### Community 15 - "DashboardView.swift"
Cohesion: 0.11
Nodes (20): Charts, GlobalMemoryModel, GlobalMemoryService, .body, FlowTagView, .body, GlobalMemoriesListView, .body (+12 more)

### Community 16 - "GraphService"
Cohesion: 0.09
Nodes (8): get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph(), get_themes(), list_nodes(), GraphService

### Community 17 - "String"
Cohesion: 0.12
Nodes (6): MemoryModel, MoodEntryModel, NarrativeDocument, SafetyEventModel, VoiceRecordingModel, NarrativeTests

### Community 18 - "AutoBackupService"
Cohesion: 0.18
Nodes (8): AutoBackupConfig, AutoBackupService, .decoder, .encoder, .folderDisplayName, .isEnabled, .lastBackupDate, AvailableAutoBackup

### Community 19 - "Error"
Cohesion: 0.11
Nodes (6): ChatServiceStreamingTests, MockStreamingLLM, Error, keyDerivationFailed, malformed, sealFailed

### Community 20 - "Session"
Cohesion: 0.22
Nodes (16): get_mode(), set_mode(), Session, ModeService, test_get_mode_default(), test_get_mode_not_found(), test_resolve_provider_auto(), test_resolve_provider_cloud() (+8 more)

### Community 21 - "AggregatedGraph"
Cohesion: 0.18
Nodes (7): AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, GraphVisualizationSheet, .body, GraphVisualizationSheetTests

### Community 22 - "insights.py"
Cohesion: 0.16
Nodes (17): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), refresh_insights() (+9 more)

### Community 23 - ".buildIncremental()"
Cohesion: 0.19
Nodes (4): MessageModel, NarrativeService, Source, NarrativeServiceTests

### Community 24 - "vector_store.py"
Cohesion: 0.13
Nodes (5): get_vector_store(), InMemoryVectorStore, reset_vector_store(), SearchResult, VectorStore

### Community 25 - "View"
Cohesion: 0.13
Nodes (12): AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body, PersonaAvatar, RoundedCorner (+4 more)

### Community 26 - "ChatView"
Cohesion: 0.13
Nodes (6): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona

### Community 27 - "NarrativeView"
Cohesion: 0.12
Nodes (14): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+6 more)

### Community 28 - "MemoryService"
Cohesion: 0.16
Nodes (6): EpisodicMemory, ProceduralMemory, SemanticMemory, MemoryService, db_session(), memory_service()

### Community 29 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (6): SelfwardDesktop, run(), run(), run(), create(), run()

### Community 30 - "graphify_pipeline.py"
Cohesion: 0.11
Nodes (8): test_delete_recording(), test_delete_recording_not_found(), test_list_recordings(), test_list_recordings_empty(), test_upload_audio(), test_upload_cleans_up_file(), test_voice_chat(), test_voice_chat_session_not_found()

### Community 31 - "LocalLLMEngine"
Cohesion: 0.17
Nodes (3): LocalLLMEngine, LocalLLMEngineTests, LLM

### Community 32 - "asyncio"
Cohesion: 0.13
Nodes (5): TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 33 - "TherapyService"
Cohesion: 0.12
Nodes (6): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), Note, DashboardService, TherapyService

### Community 34 - ".get()"
Cohesion: 0.13
Nodes (6): APIKeyProvider, .byokProviders, .cloudProvidersWithKeys, .body, .openAISection, ProviderRoutingTests

### Community 35 - "ChatService"
Cohesion: 0.15
Nodes (7): Message, SessionCreate, ChatService, db_session(), graph_service(), TestProgress, therapy_service()

### Community 36 - "Foundation"
Cohesion: 0.17
Nodes (4): BackupKit, Foundation, SwiftData, UserNotifications

### Community 37 - "SettingsView"
Cohesion: 0.14
Nodes (10): AboutYouSettingsView, .body, PrivacySettingsView, .body, SettingsTabView, .body, SettingsView, .autoBackupEnabled (+2 more)

### Community 38 - "String"
Cohesion: 0.21
Nodes (5): BYOKLLMKit, LLMMessage, LLMSending, LLMService, LLMStreaming

### Community 39 - "Codable"
Cohesion: 0.24
Nodes (14): AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData, EmbeddingRequest (+6 more)

### Community 41 - "SafetyServiceTests"
Cohesion: 0.12
Nodes (3): CrisisResources, Resource, SafetyServiceTests

### Community 42 - "VoiceConversationController"
Cohesion: 0.20
Nodes (3): VoiceConversationController, .silenceInterval, VoiceUtterance

### Community 43 - "notes.py"
Cohesion: 0.15
Nodes (9): create_note(), delete_note(), get_note_service(), list_notes(), update_note(), NoteCreate, NoteResponse, NoteUpdate (+1 more)

### Community 44 - "AppleFoundationEngine"
Cohesion: 0.14
Nodes (9): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+1 more)

### Community 45 - "NoteModel"
Cohesion: 0.20
Nodes (8): NoteModel, BadgeBackfillService, NoteService, NoteDetailView, .body, NotesListView, .body, .sorted

### Community 46 - "InsightCaptureServiceTests"
Cohesion: 0.18
Nodes (3): DreamCandidate, InsightCaptureService, InsightCaptureServiceTests

### Community 48 - "api/memory.py"
Cohesion: 0.18
Nodes (16): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), search_memories(), store_procedural(), store_semantic() (+8 more)

### Community 49 - "VoicePickerView"
Cohesion: 0.15
Nodes (8): VoicePickerView, .body, .defaultVoices, .enhancedVoices, .premiumVoices, VoiceRow, .body, .isSelected

### Community 50 - "GraphNodeModel"
Cohesion: 0.24
Nodes (11): GraphEdgeModel, GraphNodeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties (+3 more)

### Community 51 - "KeychainService"
Cohesion: 0.26
Nodes (4): .passphrase, KeychainService, KeychainStoring, Security

### Community 53 - "XCTestCase"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 55 - "pytest"
Cohesion: 0.14
Nodes (9): cleanup_vector_store(), client(), db_session(), db_session(), graph_service(), insight_service(), test_boundary_response_is_filtered(), test_crisis_resource_message_consistent() (+1 more)

### Community 56 - "TTSCoordinator"
Cohesion: 0.17
Nodes (5): PrefetchedSentence, text, TTSCoordinator, .isSpeaking, .provider

### Community 57 - "api/voice.py"
Cohesion: 0.18
Nodes (8): delete_recording(), get_voice_service(), list_recordings(), upload_audio(), voice_chat(), VoiceChatResponse, VoiceRecordingResponse, VoiceService

### Community 60 - "test_dreams.py"
Cohesion: 0.21
Nodes (16): test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date(), test_dream_date_default() (+8 more)

### Community 61 - "asyncio"
Cohesion: 0.16
Nodes (4): TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 62 - "SpeechService"
Cohesion: 0.18
Nodes (3): SpeechService, PersonasSettingsView, .body

### Community 63 - "Theme"
Cohesion: 0.18
Nodes (6): .body, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament, .line

### Community 64 - "GraphService"
Cohesion: 0.32
Nodes (4): EdgeSpec, Extraction, GraphService, NodeSpec

### Community 65 - ".trendSummary()"
Cohesion: 0.21
Nodes (5): MoodStore, MoodCheckInCard, .body, .recentDaily, MoodDayAverage

### Community 66 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 68 - "graph_ui.py"
Cohesion: 0.20
Nodes (8): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), GraphStatsResponse, GraphTimelineResponse, GraphVisualizationResponse, GraphUIService

### Community 69 - "DreamModel"
Cohesion: 0.23
Nodes (9): DreamModel, DreamService, DreamDetailView, .body, .feelings, .symbols, DreamsListView, .body (+1 more)

### Community 70 - "LLMError"
Cohesion: 0.12
Nodes (14): AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LLMError, apiError, contextLengthExceeded, emptyResponse (+6 more)

### Community 71 - "ModelService"
Cohesion: 0.19
Nodes (5): ModelService, .freeModels, .paidModels, KeysAndProvidersSettingsView, .body

### Community 73 - "LLMProvider"
Cohesion: 0.12
Nodes (15): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+7 more)

### Community 76 - "SafetyService"
Cohesion: 0.21
Nodes (3): SafetyEvent, _is_negated(), SafetyService

### Community 77 - "MarkdownText"
Cohesion: 0.15
Nodes (10): MarkdownText, .attributed, .body, CapturedBadgeRow, .body, CrisisBanner, .body, MessageBubble (+2 more)

### Community 78 - "SwiftUI"
Cohesion: 0.16
Nodes (7): AVFoundation, NewSessionView, .body, .defaultProviderLabel, .personaName, Speech, SwiftUI

### Community 81 - "Persona"
Cohesion: 0.21
Nodes (3): Persona, .displayName, TherapyService

### Community 83 - "test_notes.py"
Cohesion: 0.35
Nodes (11): test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes(), test_list_notes_empty_session(), test_note_types_defined() (+3 more)

### Community 84 - "env.py"
Cohesion: 0.17
Nodes (3): do_run_migrations(), run_migrations_online(), upgrade()

### Community 85 - "sessions.py"
Cohesion: 0.28
Nodes (7): create_session(), delete_session(), get_session(), list_sessions(), update_session(), SessionResponse, SessionUpdate

### Community 86 - "SessionRow"
Cohesion: 0.21
Nodes (10): .body, ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind (+2 more)

### Community 87 - "DashboardService"
Cohesion: 0.33
Nodes (3): DashboardService, GlobalDashboard, SessionDashboard

### Community 90 - "OpenRouterModel"
Cohesion: 0.26
Nodes (7): ModelPricing, ModelsResponse, OpenRouterArchitecture, OpenRouterModel, .isFree, .isTextFirst, .shortName

### Community 93 - "ModelPickerView"
Cohesion: 0.27
Nodes (4): ModelPickerView, .body, .freeSorted, .paidSorted

### Community 96 - "CompanionPersonality"
Cohesion: 0.18
Nodes (11): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, machiavelli (+3 more)

### Community 98 - "test_auth.py"
Cohesion: 0.33
Nodes (6): api_key(), test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected(), test_wrong_key_rejected(), test_x_api_key_accepted()

### Community 99 - ".body"
Cohesion: 0.29
Nodes (5): AppRootView, .body, RootTabView, SelfwardApp, .body

### Community 100 - "agents.py"
Cohesion: 0.24
Nodes (5): get_agent_service(), list_agents(), route_message(), AgentResponse, AgentRouteResponse

### Community 101 - "CodingKeys"
Cohesion: 0.20
Nodes (9): CodingKeys, architecture, contextLength, id, inputModalities, modality, name, outputModalities (+1 more)

### Community 103 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (8): test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty(), test_visualization_with_data()

### Community 104 - "test_safety.py"
Cohesion: 0.36
Nodes (8): test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty(), test_safety_summary()

### Community 105 - "chat.py"
Cohesion: 0.33
Nodes (5): chat(), get_chat_history(), ChatRequest, ChatResponse, MessageResponse

### Community 106 - "CompanionGender"
Cohesion: 0.22
Nodes (8): CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine, unspecified

### Community 108 - "VoiceSettingsView"
Cohesion: 0.25
Nodes (5): ProviderKeySection, VoiceSettingsView, .body, .elevenLabsSection, .onDeviceSection

### Community 109 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 112 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 113 - "DashboardView"
Cohesion: 0.25
Nodes (9): DashboardView, .allDreams, .allEdges, .allMemories, .allNodes, .allNotes, .globalMemories, .recentNotes (+1 more)

### Community 115 - "test_dashboard.py"
Cohesion: 0.39
Nodes (7): test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 116 - "test_sessions.py"
Cohesion: 0.50
Nodes (6): test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 119 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 123 - "NodeConnectionsSheet"
Cohesion: 0.32
Nodes (5): Connection, NodeConnectionsSheet, .body, .connections, WebKit

### Community 124 - "test_chat.py"
Cohesion: 0.54
Nodes (5): test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 129 - "LocalLLMError"
Cohesion: 0.33
Nodes (6): LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout

### Community 130 - "VoiceStatusBar"
Cohesion: 0.33
Nodes (5): VoiceStatusBar, .body, .icon, .label, .tint

### Community 134 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **213 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+208 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 589 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **46 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `Float`, `DashboardView.swift`, `String`, `Error`, `AggregatedGraph`, `.buildIncremental()`, `ChatView`, `.makeInMemoryContainer()`, `NoteModel`, `InsightCaptureServiceTests`, `GraphNodeModel`, `ChatService`, `MockLLM`, `GraphService`, `PersonaKind`, `.ephemeralDefaults()`, `DreamModel`, `FakeKeychain`, `SwiftUI`, `GraphServiceTests`, `SessionRow`, `DashboardService`, `.decrypt()`, `ModelPickerView`, `.configError()`, `.processMessage()`, `DashboardView`, `InsightServiceTests`, `VoiceService`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _213 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `cytoscape.min.js` be split into smaller, more focused modules?**
  _Cohesion score 0.051462904911180773 - nodes in this community are weakly interconnected._
- **Why does `View` connect `View` to `LocalModelService`, `VoiceStatusBar`, `PINService`, `SessionModel`, `OnboardingView.swift`, `DashboardView.swift`, `AggregatedGraph`, `ChatView`, `NarrativeView`, `SettingsView`, `NoteModel`, `VoicePickerView`, `GraphNodeModel`, `SpeechService`, `.trendSummary()`, `DreamModel`, `ModelService`, `MarkdownText`, `SwiftUI`, `SessionRow`, `ModelPickerView`, `.body`, `VoiceSettingsView`, `DashboardView`, `NodeConnectionsSheet`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Should `LocalModelService` be split into smaller, more focused modules?**
  _Cohesion score 0.05266106442577031 - nodes in this community are weakly interconnected._