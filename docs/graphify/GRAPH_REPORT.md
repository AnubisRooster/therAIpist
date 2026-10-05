# Graph Report - therAIpist  (2026-10-05)

## Corpus Check
- Large corpus: 233 files · ~983,588 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2734 nodes · 6769 edges · 134 communities (94 shown, 40 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 666 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- AutoBackupService
- PINService
- OpenRouterModel
- BackupRestorePlan
- AgentContext
- SessionModel
- ChatMessage
- SpeechService
- sqlalchemy_ext_asyncio
- LocalModelService
- schemas.py
- ConversationCompactorTests
- OnboardingView.swift
- asyncio
- View
- graphify_pipeline.py
- DashboardView.swift
- AgentContext
- ChatService
- NarrativeView
- dreams.py
- ChatService
- vector_store.py
- LocalLLMEngine
- Error
- .models()
- Float
- InsightCaptureServiceTests
- insights.py
- .buildIncremental()
- Theme
- FastAPI
- MemoryService
- Session
- SettingsView
- SelfwardDesktop
- asyncio
- GraphService
- ChatView
- VoiceConversationController
- notes.py
- InMemoryVectorStore
- SwiftUI
- SwiftData
- .makeInMemoryContainer()
- AppleFoundationEngine
- AggregatedGraph
- SafetyServiceTests
- api/memory.py
- Codable
- VoiceTranscriptTests
- api/voice.py
- TherapyService
- LLMError
- GraphNodeModel
- SpiritualTradition
- asyncio
- TTSCoordinator
- String
- DreamModel
- GraphService
- Coordinator
- test_dreams.py
- Foundation
- String
- PersonaKind
- .ephemeralDefaults()
- graph_ui.py
- GraphExportServiceTests
- .classifyHTTPFailure()
- LLMProvider
- asyncio
- .body
- GraphServiceTests
- Persona
- test_notes.py
- env.py
- dashboard.py
- SafetyService
- DashboardService
- .graphML()
- BackupFolderPicker
- GlobalMemoryServiceTests
- MemoryService
- .processMessage()
- LocalModelService.swift
- .decrypt()
- String
- ActiveImaginationTests
- agents.py
- .trendSummary()
- CompanionPersonality
- SpiritualPersonaTests
- test_auth.py
- get_db()
- chat_service.py
- EncryptedBackupDocument
- pytest
- test_graph_ui.py
- test_safety.py
- chat.py
- VoiceService
- CompanionGender
- .sizeThatFits()
- CodingKeys
- EmbeddingService
- NoteService
- .schedule()
- DashboardSheet
- ShareSheet
- test_dashboard.py
- test_sessions.py
- TTSKeyProvider
- VoiceSettingsView
- GlobalMemoryService
- XCTestCase
- test_chat.py
- cosine_similarity()
- VoiceStatusBar
- TestModalityPrompts
- GraphExportServiceTests.swift
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

## Communities (134 total, 40 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "AutoBackupService"
Cohesion: 0.06
Nodes (19): AutoBackupConfig, AutoBackupService, .decoder, .encoder, .folderDisplayName, .isEnabled, .lastBackupDate, .passphrase (+11 more)

### Community 2 - "PINService"
Cohesion: 0.05
Nodes (28): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+20 more)

### Community 3 - "OpenRouterModel"
Cohesion: 0.05
Nodes (25): CodingKeys, architecture, contextLength, id, inputModalities, modality, name, outputModalities (+17 more)

### Community 4 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (18): CommonCrypto, CryptoKit, BackupCrypto, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot, BackupPlanner (+10 more)

### Community 5 - "AgentContext"
Cohesion: 0.11
Nodes (22): AgentContext, AgentResult, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent, IntegrativeAgent (+14 more)

### Community 6 - "SessionModel"
Cohesion: 0.10
Nodes (15): SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, DreamsView, .body (+7 more)

### Community 7 - "ChatMessage"
Cohesion: 0.10
Nodes (12): Settings, ChatMessage, ChatResult, LLMProvider, get_provider(), get_stt_provider(), OllamaProvider, OpenRouterProvider (+4 more)

### Community 8 - "SpeechService"
Cohesion: 0.07
Nodes (12): SpeechService, PersonasSettingsView, .body, VoicePickerView, .body, .defaultVoices, .enhancedVoices, .premiumVoices (+4 more)

### Community 9 - "sqlalchemy_ext_asyncio"
Cohesion: 0.18
Nodes (7): Base, GraphEdge, GraphNode, Note, VoiceRecording, db_session(), graph_service()

### Community 10 - "LocalModelService"
Cohesion: 0.11
Nodes (20): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, .downloadedLocalModels, .localAvailable, .resolvedLocalModel (+12 more)

### Community 11 - "schemas.py"
Cohesion: 0.11
Nodes (31): create_edge(), create_node(), extract(), get_connections(), get_node(), get_patterns(), get_session_graph(), get_themes() (+23 more)

### Community 12 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (3): ConversationCompactor, StoredState, ConversationCompactorTests

### Community 13 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (31): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+23 more)

### Community 14 - "asyncio"
Cohesion: 0.09
Nodes (6): TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 15 - "View"
Cohesion: 0.09
Nodes (18): AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body, PersonaAvatar, RoundedCorner (+10 more)

### Community 16 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (11): STTProvider, TranscriptResult, MockSTTProvider, test_delete_recording(), test_delete_recording_not_found(), test_list_recordings(), test_list_recordings_empty(), test_upload_audio() (+3 more)

### Community 17 - "DashboardView.swift"
Cohesion: 0.09
Nodes (27): Charts, NoteModel, DashboardView, .allDreams, .allEdges, .allMemories, .allNodes, .allNotes (+19 more)

### Community 18 - "AgentContext"
Cohesion: 0.13
Nodes (16): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+8 more)

### Community 19 - "ChatService"
Cohesion: 0.16
Nodes (4): ChatService, ChatServiceE2ETests, ChatServiceCompactionTests, MockLLM

### Community 20 - "NarrativeView"
Cohesion: 0.09
Nodes (16): NarrativeExportService, NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document (+8 more)

### Community 21 - "dreams.py"
Cohesion: 0.12
Nodes (16): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+8 more)

### Community 22 - "ChatService"
Cohesion: 0.11
Nodes (12): create_session(), delete_session(), get_session(), list_sessions(), update_session(), get_chat_service(), Message, SessionCreate (+4 more)

### Community 23 - "vector_store.py"
Cohesion: 0.10
Nodes (8): get_vector_store(), QdrantVectorStore, reset_vector_store(), SearchResult, VectorStore, cleanup_vector_store(), client(), db_session()

### Community 24 - "LocalLLMEngine"
Cohesion: 0.12
Nodes (9): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, LocalLLMEngineTests (+1 more)

### Community 25 - "Error"
Cohesion: 0.10
Nodes (6): ChatServiceStreamingTests, MockStreamingLLM, Error, keyDerivationFailed, malformed, sealFailed

### Community 26 - ".models()"
Cohesion: 0.11
Nodes (5): DownloadProgressDelegate, HFModel, HFSibling, HuggingFaceModelService, HuggingFaceCatalogTests

### Community 27 - "Float"
Cohesion: 0.13
Nodes (14): GlobalMemoryModel, MemoryModel, Float, VectorStore, GlobalMemoriesListView, .body, .filtered, GlobalMemoryDetailView (+6 more)

### Community 28 - "InsightCaptureServiceTests"
Cohesion: 0.12
Nodes (3): DreamCandidate, InsightCaptureService, InsightCaptureServiceTests

### Community 29 - "insights.py"
Cohesion: 0.16
Nodes (17): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), refresh_insights() (+9 more)

### Community 30 - ".buildIncremental()"
Cohesion: 0.19
Nodes (4): MessageModel, NarrativeService, Source, NarrativeServiceTests

### Community 31 - "Theme"
Cohesion: 0.11
Nodes (10): .body, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament, .line, NewSessionView, .body (+2 more)

### Community 32 - "FastAPI"
Cohesion: 0.13
Nodes (10): health_check(), get_progress(), get_therapy_service(), suggest_intervention(), init_db(), require_api_key(), lifespan(), HealthResponse (+2 more)

### Community 33 - "MemoryService"
Cohesion: 0.16
Nodes (6): EpisodicMemory, ProceduralMemory, SemanticMemory, MemoryService, db_session(), memory_service()

### Community 34 - "Session"
Cohesion: 0.22
Nodes (14): Session, ModeService, test_get_mode_default(), test_get_mode_not_found(), test_resolve_provider_auto(), test_resolve_provider_cloud(), test_resolve_provider_hybrid(), test_resolve_provider_local() (+6 more)

### Community 35 - "SettingsView"
Cohesion: 0.13
Nodes (11): AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection, SettingsView (+3 more)

### Community 36 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (6): SelfwardDesktop, run(), run(), run(), create(), run()

### Community 37 - "asyncio"
Cohesion: 0.13
Nodes (5): TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 39 - "ChatView"
Cohesion: 0.14
Nodes (6): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona

### Community 40 - "VoiceConversationController"
Cohesion: 0.19
Nodes (3): VoiceConversationController, .silenceInterval, VoiceUtterance

### Community 41 - "notes.py"
Cohesion: 0.14
Nodes (9): create_note(), delete_note(), get_note_service(), list_notes(), update_note(), NoteCreate, NoteResponse, NoteUpdate (+1 more)

### Community 42 - "InMemoryVectorStore"
Cohesion: 0.14
Nodes (3): InMemoryVectorStore, TestInMemoryVectorStore, TestQdrantVectorStore

### Community 43 - "SwiftUI"
Cohesion: 0.11
Nodes (13): AVFoundation, MarkdownText, .attributed, .body, CapturedBadgeRow, .body, CrisisBanner, .body (+5 more)

### Community 44 - "SwiftData"
Cohesion: 0.21
Nodes (3): Selfward, SwiftData, XCTest

### Community 45 - ".makeInMemoryContainer()"
Cohesion: 0.15
Nodes (3): InsightServiceTests, MemoryServiceTests, TestSupport

### Community 46 - "AppleFoundationEngine"
Cohesion: 0.14
Nodes (9): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+1 more)

### Community 47 - "AggregatedGraph"
Cohesion: 0.20
Nodes (10): AggregatedEdge, AggregatedGraph, AggregatedNode, Connection, GraphVisualizationSheet, .body, NodeConnectionsSheet, .body (+2 more)

### Community 48 - "SafetyServiceTests"
Cohesion: 0.13
Nodes (3): CrisisResources, Resource, SafetyServiceTests

### Community 49 - "api/memory.py"
Cohesion: 0.18
Nodes (16): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), search_memories(), store_procedural(), store_semantic() (+8 more)

### Community 50 - "Codable"
Cohesion: 0.27
Nodes (13): AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData, EmbeddingRequest (+5 more)

### Community 52 - "api/voice.py"
Cohesion: 0.18
Nodes (8): delete_recording(), get_voice_service(), list_recordings(), upload_audio(), voice_chat(), VoiceChatResponse, VoiceRecordingResponse, VoiceService

### Community 53 - "TherapyService"
Cohesion: 0.15
Nodes (7): TherapyService, db_session(), graph_service(), insight_service(), db_session(), graph_service(), therapy_service()

### Community 54 - "LLMError"
Cohesion: 0.11
Nodes (14): BYOKLLMKit, AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LLMError, apiError, contextLengthExceeded (+6 more)

### Community 55 - "GraphNodeModel"
Cohesion: 0.25
Nodes (11): GraphEdgeModel, GraphNodeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties (+3 more)

### Community 56 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 57 - "asyncio"
Cohesion: 0.16
Nodes (4): TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 58 - "TTSCoordinator"
Cohesion: 0.19
Nodes (5): PrefetchedSentence, text, TTSCoordinator, .isSpeaking, .provider

### Community 59 - "String"
Cohesion: 0.22
Nodes (4): MoodEntryModel, NarrativeDocument, SafetyEventModel, VoiceRecordingModel

### Community 60 - "DreamModel"
Cohesion: 0.20
Nodes (9): DreamModel, DreamService, DreamDetailView, .body, .feelings, .symbols, DreamsListView, .body (+1 more)

### Community 61 - "GraphService"
Cohesion: 0.29
Nodes (4): EdgeSpec, Extraction, GraphService, NodeSpec

### Community 63 - "test_dreams.py"
Cohesion: 0.21
Nodes (16): test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date(), test_dream_date_default() (+8 more)

### Community 64 - "Foundation"
Cohesion: 0.15
Nodes (4): BackupKit, Foundation, BadgeBackfillService, UserNotifications

### Community 65 - "String"
Cohesion: 0.29
Nodes (5): LLMMessage, OpenRouterRequest, unsupportedProvider, LLMService, LLMStreaming

### Community 66 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 68 - "graph_ui.py"
Cohesion: 0.17
Nodes (8): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), GraphStatsResponse, GraphTimelineResponse, GraphVisualizationResponse, GraphUIService

### Community 71 - "LLMProvider"
Cohesion: 0.12
Nodes (15): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+7 more)

### Community 73 - ".body"
Cohesion: 0.17
Nodes (10): AppRootView, .body, RootTabView, .body, SelfwardApp, .body, DashboardTabView, .body (+2 more)

### Community 75 - "Persona"
Cohesion: 0.21
Nodes (3): Persona, .displayName, TherapyService

### Community 76 - "test_notes.py"
Cohesion: 0.35
Nodes (11): test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes(), test_list_notes_empty_session(), test_note_types_defined() (+3 more)

### Community 77 - "env.py"
Cohesion: 0.17
Nodes (3): do_run_migrations(), run_migrations_online(), upgrade()

### Community 78 - "dashboard.py"
Cohesion: 0.21
Nodes (6): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), GlobalDashboardResponse, SessionDashboardResponse, DashboardService

### Community 79 - "SafetyService"
Cohesion: 0.23
Nodes (3): SafetyEvent, _is_negated(), SafetyService

### Community 80 - "DashboardService"
Cohesion: 0.33
Nodes (3): DashboardService, GlobalDashboard, SessionDashboard

### Community 85 - ".processMessage()"
Cohesion: 0.20
Nodes (3): ChatResult, LocalPromptOverflow, LLMSending

### Community 87 - "LocalModelService.swift"
Cohesion: 0.17
Nodes (11): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3 (+3 more)

### Community 91 - "agents.py"
Cohesion: 0.25
Nodes (6): get_agent_service(), list_agents(), route_message(), AgentResponse, AgentRouteResponse, AgentService

### Community 93 - "CompanionPersonality"
Cohesion: 0.18
Nodes (11): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, machiavelli (+3 more)

### Community 95 - "test_auth.py"
Cohesion: 0.33
Nodes (6): api_key(), test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected(), test_wrong_key_rejected(), test_x_api_key_accepted()

### Community 96 - "get_db()"
Cohesion: 0.24
Nodes (6): get_events(), get_safety_service(), get_summary(), get_db(), SafetyEventResponse, SafetySummaryResponse

### Community 99 - "pytest"
Cohesion: 0.24
Nodes (4): test_health_endpoint(), test_boundary_response_is_filtered(), test_crisis_resource_message_consistent(), test_negation_is_not_crisis()

### Community 100 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (8): test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty(), test_visualization_with_data()

### Community 101 - "test_safety.py"
Cohesion: 0.36
Nodes (8): test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty(), test_safety_summary()

### Community 102 - "chat.py"
Cohesion: 0.33
Nodes (5): chat(), get_chat_history(), ChatRequest, ChatResponse, MessageResponse

### Community 104 - "CompanionGender"
Cohesion: 0.22
Nodes (8): CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine, unspecified

### Community 106 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 107 - "EmbeddingService"
Cohesion: 0.28
Nodes (3): EmbeddingService, .isAvailable, NaturalLanguage

### Community 110 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 112 - "test_dashboard.py"
Cohesion: 0.39
Nodes (7): test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 113 - "test_sessions.py"
Cohesion: 0.50
Nodes (6): test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 114 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 115 - "VoiceSettingsView"
Cohesion: 0.29
Nodes (4): VoiceSettingsView, .body, .elevenLabsSection, .onDeviceSection

### Community 119 - "test_chat.py"
Cohesion: 0.54
Nodes (5): test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 121 - "VoiceStatusBar"
Cohesion: 0.29
Nodes (5): VoiceStatusBar, .body, .icon, .label, .tint

### Community 124 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **210 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+205 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 608 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **40 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `AutoBackupService`, `OpenRouterModel`, `View`, `DashboardView.swift`, `ChatService`, `Error`, `Float`, `InsightCaptureServiceTests`, `.buildIncremental()`, `Theme`, `ChatView`, `.makeInMemoryContainer()`, `AggregatedGraph`, `GraphNodeModel`, `String`, `DreamModel`, `GraphService`, `PersonaKind`, `.ephemeralDefaults()`, `GraphExportServiceTests`, `GraphServiceTests`, `DashboardService`, `MemoryService`, `.processMessage()`, `.configError()`, `.decrypt()`, `VoiceService`, `NoteService`?**
  _High betweenness centrality (0.092) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _210 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `cytoscape.min.js` be split into smaller, more focused modules?**
  _Cohesion score 0.051462904911180773 - nodes in this community are weakly interconnected._
- **Why does `Foundation` connect `Foundation` to `PINService`, `OpenRouterModel`, `BackupRestorePlan`, `SessionModel`, `AgentContext`, `LocalLLMEngine`, `Float`, `InsightCaptureServiceTests`, `.buildIncremental()`, `SwiftUI`, `AppleFoundationEngine`, `AggregatedGraph`, `Codable`, `LLMError`, `String`, `DreamModel`, `GraphService`, `PersonaKind`, `Persona`, `DashboardService`, `LocalModelService.swift`, `VoiceService`, `EmbeddingService`, `NoteService`, `TTSKeyProvider`, `GlobalMemoryService`, `GraphExportServiceTests.swift`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Should `AutoBackupService` be split into smaller, more focused modules?**
  _Cohesion score 0.05798319327731093 - nodes in this community are weakly interconnected._