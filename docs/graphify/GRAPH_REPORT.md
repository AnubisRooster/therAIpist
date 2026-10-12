# Graph Report - therAIpist  (2026-10-12)

## Corpus Check
- Large corpus: 233 files · ~983,067 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2734 nodes · 6801 edges · 131 communities (90 shown, 41 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 691 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- AutoBackupService
- PINService
- OpenRouterModel
- schemas.py
- BackupRestorePlan
- AgentContext
- SpeechService
- sqlalchemy_ext_asyncio
- SessionModel
- chat_service.py
- Base
- ConversationCompactorTests
- LocalModelService
- OnboardingView.swift
- GraphService
- MemoryService
- dreams.py
- asyncio
- graphify_pipeline.py
- AgentContext
- ChatService
- DashboardView.swift
- NarrativeView
- TherapyService
- LocalLLMEngine
- Error
- InsightCaptureServiceTests
- .buildIncremental()
- VoiceConversationController
- ModeService
- notes.py
- vector_store.py
- View
- SafetyService
- TTSCoordinator
- SettingsView
- SelfwardDesktop
- asyncio
- InMemoryVectorStore
- String
- ChatView
- SafetyServiceTests
- SwiftData
- .makeInMemoryContainer()
- AppleFoundationEngine
- AggregatedGraph
- Codable
- Theme
- String
- VoiceTranscriptTests
- String
- GraphNodeModel
- SpiritualTradition
- asyncio
- VoiceService
- DreamModel
- String
- Coordinator
- test_dreams.py
- Foundation
- NoteModel
- PersonaKind
- .ephemeralDefaults()
- LLMError
- GraphExportServiceTests
- .classifyHTTPFailure()
- LLMProvider
- asyncio
- .body
- VoiceStatusBar
- GraphServiceTests
- Persona
- test_notes.py
- env.py
- DownloadProgressDelegate
- DashboardService
- .graphML()
- BackupFolderPicker
- GlobalMemoryServiceTests
- GraphUIService
- MemoryService
- MoodEntryModel
- LocalModelService.swift
- .decrypt()
- ActiveImaginationTests
- agents.py
- Float
- CompanionPersonality
- SpiritualPersonaTests
- SafetyService
- test_auth.py
- EncryptedBackupDocument
- SessionRow
- pytest
- test_graph_ui.py
- test_safety.py
- GlobalMemoryService
- VoiceService
- CompanionGender
- .sizeThatFits()
- CodingKeys
- .processMessage()
- EmbeddingService
- .schedule()
- DashboardSheet
- DashboardView
- ShareSheet
- test_dashboard.py
- test_sessions.py
- QdrantVectorStore
- TTSKeyProvider
- GlobalMemoryService
- XCTestCase
- test_chat.py
- cosine_similarity()
- MarkdownText
- NewSessionView
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
  tests/test_therapy.py → app/models/base.py
- `TestGraphNodeOperations` --uses--> `GraphNode`  [INFERRED]
  tests/test_graph.py → app/models/graph.py
- `TestEpisodicMemory` --uses--> `EpisodicMemory`  [INFERRED]
  tests/test_memory.py → app/models/memory.py

## Import Cycles
- None detected.

## Communities (131 total, 41 thin omitted)

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

### Community 4 - "schemas.py"
Cohesion: 0.07
Nodes (49): health_check(), _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations() (+41 more)

### Community 5 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (18): CommonCrypto, CryptoKit, BackupCrypto, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot, BackupPlanner (+10 more)

### Community 6 - "AgentContext"
Cohesion: 0.11
Nodes (22): AgentContext, AgentResult, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent, IntegrativeAgent (+14 more)

### Community 7 - "SpeechService"
Cohesion: 0.05
Nodes (19): AVFoundation, SpeechService, PersonasSettingsView, .body, VoiceSettingsView, .body, .elevenLabsSection, .onDeviceSection (+11 more)

### Community 8 - "sqlalchemy_ext_asyncio"
Cohesion: 0.08
Nodes (17): chat(), get_chat_history(), create_session(), delete_session(), get_session(), list_sessions(), update_session(), get_db() (+9 more)

### Community 9 - "SessionModel"
Cohesion: 0.10
Nodes (15): SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, DreamsView, .body (+7 more)

### Community 10 - "chat_service.py"
Cohesion: 0.10
Nodes (12): Settings, ChatMessage, ChatResult, LLMProvider, get_provider(), get_stt_provider(), OllamaProvider, OpenRouterProvider (+4 more)

### Community 11 - "Base"
Cohesion: 0.17
Nodes (13): Base, GraphEdge, GraphNode, EpisodicMemory, SemanticMemory, Session, db_session(), graph_service() (+5 more)

### Community 12 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (3): ConversationCompactor, StoredState, ConversationCompactorTests

### Community 13 - "LocalModelService"
Cohesion: 0.11
Nodes (19): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, .downloadedLocalModels, .localAvailable, .resolvedLocalModel (+11 more)

### Community 14 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (31): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+23 more)

### Community 15 - "GraphService"
Cohesion: 0.10
Nodes (14): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+6 more)

### Community 16 - "MemoryService"
Cohesion: 0.10
Nodes (17): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), search_memories(), store_procedural(), store_semantic() (+9 more)

### Community 17 - "dreams.py"
Cohesion: 0.11
Nodes (16): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+8 more)

### Community 18 - "asyncio"
Cohesion: 0.09
Nodes (6): TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 19 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (11): STTProvider, TranscriptResult, MockSTTProvider, test_delete_recording(), test_delete_recording_not_found(), test_list_recordings(), test_list_recordings_empty(), test_upload_audio() (+3 more)

### Community 20 - "AgentContext"
Cohesion: 0.13
Nodes (16): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+8 more)

### Community 21 - "ChatService"
Cohesion: 0.16
Nodes (4): ChatService, ChatServiceE2ETests, ChatServiceCompactionTests, MockLLM

### Community 22 - "DashboardView.swift"
Cohesion: 0.10
Nodes (23): Charts, GlobalMemoryModel, .body, FlowTagView, .body, GlobalMemoriesListView, .body, .filtered (+15 more)

### Community 23 - "NarrativeView"
Cohesion: 0.09
Nodes (15): NarrativeExportService, NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document (+7 more)

### Community 24 - "TherapyService"
Cohesion: 0.09
Nodes (13): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), get_progress(), get_therapy_service(), suggest_intervention(), InterventionSuggestionResponse, ProgressResponse (+5 more)

### Community 25 - "LocalLLMEngine"
Cohesion: 0.12
Nodes (9): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, LocalLLMEngineTests (+1 more)

### Community 26 - "Error"
Cohesion: 0.10
Nodes (6): ChatServiceStreamingTests, MockStreamingLLM, Error, keyDerivationFailed, malformed, sealFailed

### Community 27 - "InsightCaptureServiceTests"
Cohesion: 0.12
Nodes (3): DreamCandidate, InsightCaptureService, InsightCaptureServiceTests

### Community 28 - ".buildIncremental()"
Cohesion: 0.18
Nodes (4): MessageModel, NarrativeService, Source, NarrativeServiceTests

### Community 29 - "VoiceConversationController"
Cohesion: 0.17
Nodes (3): VoiceConversationController, .silenceInterval, VoiceUtterance

### Community 30 - "ModeService"
Cohesion: 0.20
Nodes (15): get_mode(), get_mode_service(), ModeService, test_get_mode_default(), test_get_mode_not_found(), test_resolve_provider_auto(), test_resolve_provider_cloud(), test_resolve_provider_hybrid() (+7 more)

### Community 31 - "notes.py"
Cohesion: 0.14
Nodes (10): create_note(), delete_note(), get_note_service(), list_notes(), update_note(), Note, NoteCreate, NoteResponse (+2 more)

### Community 32 - "vector_store.py"
Cohesion: 0.12
Nodes (7): get_vector_store(), reset_vector_store(), SearchResult, VectorStore, cleanup_vector_store(), client(), db_session()

### Community 33 - "View"
Cohesion: 0.13
Nodes (11): AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, PersonaAvatar, RoundedCorner, TagCapsule (+3 more)

### Community 34 - "SafetyService"
Cohesion: 0.12
Nodes (7): get_events(), get_safety_service(), get_summary(), Message, SafetyEvent, _is_negated(), SafetyService

### Community 35 - "TTSCoordinator"
Cohesion: 0.14
Nodes (5): PrefetchedSentence, text, TTSCoordinator, .isSpeaking, .provider

### Community 36 - "SettingsView"
Cohesion: 0.13
Nodes (11): AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection, SettingsView (+3 more)

### Community 37 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (6): SelfwardDesktop, run(), run(), run(), create(), run()

### Community 38 - "asyncio"
Cohesion: 0.13
Nodes (5): TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 39 - "InMemoryVectorStore"
Cohesion: 0.14
Nodes (3): InMemoryVectorStore, TestInMemoryVectorStore, TestQdrantVectorStore

### Community 40 - "String"
Cohesion: 0.22
Nodes (5): BYOKLLMKit, LLMMessage, LLMSending, LLMService, LLMStreaming

### Community 41 - "ChatView"
Cohesion: 0.14
Nodes (6): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona

### Community 42 - "SafetyServiceTests"
Cohesion: 0.14
Nodes (3): CrisisResources, Resource, SafetyServiceTests

### Community 43 - "SwiftData"
Cohesion: 0.21
Nodes (3): Selfward, SwiftData, XCTest

### Community 44 - ".makeInMemoryContainer()"
Cohesion: 0.15
Nodes (3): InsightServiceTests, MemoryServiceTests, TestSupport

### Community 45 - "AppleFoundationEngine"
Cohesion: 0.14
Nodes (9): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+1 more)

### Community 46 - "AggregatedGraph"
Cohesion: 0.20
Nodes (10): AggregatedEdge, AggregatedGraph, AggregatedNode, Connection, GraphVisualizationSheet, .body, NodeConnectionsSheet, .body (+2 more)

### Community 47 - "Codable"
Cohesion: 0.27
Nodes (14): AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData, EmbeddingRequest (+6 more)

### Community 48 - "Theme"
Cohesion: 0.14
Nodes (8): .body, .body, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament, .emptyState, .line

### Community 49 - "String"
Cohesion: 0.19
Nodes (5): HFModel, HFSibling, HuggingFaceModelService, .recommendedID, HuggingFaceCatalogTests

### Community 51 - "String"
Cohesion: 0.20
Nodes (4): MemoryModel, NarrativeDocument, SafetyEventModel, VoiceRecordingModel

### Community 52 - "GraphNodeModel"
Cohesion: 0.29
Nodes (5): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec

### Community 53 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 54 - "asyncio"
Cohesion: 0.16
Nodes (4): TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 55 - "VoiceService"
Cohesion: 0.16
Nodes (7): delete_recording(), get_voice_service(), list_recordings(), upload_audio(), voice_chat(), VoiceRecording, VoiceService

### Community 56 - "DreamModel"
Cohesion: 0.20
Nodes (9): DreamModel, DreamService, DreamDetailView, .body, .feelings, .symbols, DreamsListView, .body (+1 more)

### Community 57 - "String"
Cohesion: 0.24
Nodes (10): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+2 more)

### Community 59 - "test_dreams.py"
Cohesion: 0.21
Nodes (16): test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date(), test_dream_date_default() (+8 more)

### Community 60 - "Foundation"
Cohesion: 0.15
Nodes (4): BackupKit, Foundation, BadgeBackfillService, UserNotifications

### Community 61 - "NoteModel"
Cohesion: 0.25
Nodes (7): NoteModel, NoteService, NoteDetailView, .body, NotesListView, .body, .sorted

### Community 62 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 64 - "LLMError"
Cohesion: 0.12
Nodes (14): AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LLMError, apiError, contextLengthExceeded, emptyResponse (+6 more)

### Community 67 - "LLMProvider"
Cohesion: 0.12
Nodes (15): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+7 more)

### Community 69 - ".body"
Cohesion: 0.17
Nodes (10): AppRootView, .body, RootTabView, .body, SelfwardApp, .body, DashboardTabView, .body (+2 more)

### Community 70 - "VoiceStatusBar"
Cohesion: 0.14
Nodes (11): CapturedBadgeRow, CrisisBanner, .body, MessageBubble, .body, .hasBadges, VoiceStatusBar, .body (+3 more)

### Community 72 - "Persona"
Cohesion: 0.21
Nodes (3): Persona, .displayName, TherapyService

### Community 73 - "test_notes.py"
Cohesion: 0.35
Nodes (11): test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes(), test_list_notes_empty_session(), test_note_types_defined() (+3 more)

### Community 74 - "env.py"
Cohesion: 0.17
Nodes (3): do_run_migrations(), run_migrations_online(), upgrade()

### Community 76 - "DashboardService"
Cohesion: 0.33
Nodes (3): DashboardService, GlobalDashboard, SessionDashboard

### Community 80 - "GraphUIService"
Cohesion: 0.24
Nodes (5): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), GraphUIService

### Community 83 - "LocalModelService.swift"
Cohesion: 0.17
Nodes (11): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3 (+3 more)

### Community 86 - "agents.py"
Cohesion: 0.27
Nodes (6): get_agent_service(), list_agents(), route_message(), AgentResponse, AgentRouteResponse, AgentService

### Community 89 - "CompanionPersonality"
Cohesion: 0.18
Nodes (11): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, machiavelli (+3 more)

### Community 92 - "test_auth.py"
Cohesion: 0.33
Nodes (6): api_key(), test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected(), test_wrong_key_rejected(), test_x_api_key_accepted()

### Community 94 - "SessionRow"
Cohesion: 0.29
Nodes (7): ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind

### Community 95 - "pytest"
Cohesion: 0.24
Nodes (4): test_health_endpoint(), test_boundary_response_is_filtered(), test_crisis_resource_message_consistent(), test_negation_is_not_crisis()

### Community 96 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (8): test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty(), test_visualization_with_data()

### Community 97 - "test_safety.py"
Cohesion: 0.36
Nodes (8): test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty(), test_safety_summary()

### Community 100 - "CompanionGender"
Cohesion: 0.22
Nodes (8): CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine, unspecified

### Community 102 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 104 - "EmbeddingService"
Cohesion: 0.28
Nodes (3): EmbeddingService, .isAvailable, NaturalLanguage

### Community 106 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 107 - "DashboardView"
Cohesion: 0.25
Nodes (9): DashboardView, .allDreams, .allEdges, .allMemories, .allNodes, .allNotes, .globalMemories, .recentNotes (+1 more)

### Community 109 - "test_dashboard.py"
Cohesion: 0.39
Nodes (7): test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 110 - "test_sessions.py"
Cohesion: 0.50
Nodes (6): test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 112 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 115 - "test_chat.py"
Cohesion: 0.54
Nodes (5): test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 117 - "MarkdownText"
Cohesion: 0.33
Nodes (3): MarkdownText, .attributed, .body

### Community 118 - "NewSessionView"
Cohesion: 0.33
Nodes (4): NewSessionView, .body, .defaultProviderLabel, .personaName

### Community 121 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **213 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+208 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 592 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **41 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `AutoBackupService`, `OpenRouterModel`, `ChatService`, `DashboardView.swift`, `Error`, `InsightCaptureServiceTests`, `.buildIncremental()`, `ChatView`, `.makeInMemoryContainer()`, `AggregatedGraph`, `String`, `GraphNodeModel`, `DreamModel`, `String`, `NoteModel`, `PersonaKind`, `.ephemeralDefaults()`, `GraphExportServiceTests`, `GraphServiceTests`, `DashboardService`, `MemoryService`, `.decrypt()`, `.configError()`, `SessionRow`, `VoiceService`, `.processMessage()`, `DashboardView`, `NewSessionView`?**
  _High betweenness centrality (0.092) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _213 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `cytoscape.min.js` be split into smaller, more focused modules?**
  _Cohesion score 0.051462904911180773 - nodes in this community are weakly interconnected._
- **Why does `Foundation` connect `Foundation` to `PINService`, `OpenRouterModel`, `BackupRestorePlan`, `SpeechService`, `SessionModel`, `AgentContext`, `LocalLLMEngine`, `InsightCaptureServiceTests`, `.buildIncremental()`, `String`, `AppleFoundationEngine`, `AggregatedGraph`, `Codable`, `String`, `GraphNodeModel`, `DreamModel`, `NoteModel`, `PersonaKind`, `Persona`, `DashboardService`, `LocalModelService.swift`, `Float`, `VoiceService`, `EmbeddingService`, `TTSKeyProvider`, `GlobalMemoryService`, `GraphExportServiceTests.swift`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Should `AutoBackupService` be split into smaller, more focused modules?**
  _Cohesion score 0.05798319327731093 - nodes in this community are weakly interconnected._