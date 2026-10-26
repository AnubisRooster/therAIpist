# Graph Report - therAIpist  (2026-10-26)

## Corpus Check
- 221 files · ~339,899 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 10 file(s) not represented in the graph (top: (none) 2, .ini 1, .jsonl 1)

## Summary
- 2809 nodes · 6899 edges · 153 communities (109 shown, 44 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 709 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- NoteModel
- BackupRestorePlan
- AgentContext
- ChatMessage
- database.py
- sqlalchemy_ext_asyncio
- ConversationCompactorTests
- OnboardingView.swift
- MemoryService
- SessionModel
- asyncio
- schemas.py
- dreams.py
- LocalLLMEngine
- ChatView
- GraphService
- LocalModelService
- chat_service.py
- Session
- String
- Error
- AutoBackupService
- AggregatedGraph
- DashboardView.swift
- .buildIncremental()
- insights.py
- ChatService
- SwiftUI
- Coordinator
- .makeInMemoryContainer()
- InMemoryVectorStore
- SelfwardDesktop
- graphify_pipeline.py
- View
- ChatService
- asyncio
- TTSCoordinator
- TherapyService
- Codable
- .get()
- VoiceConversationController
- AppleFoundationEngine
- SafetyServiceTests
- NarrativeView
- notes.py
- api/voice.py
- GraphNodeModel
- InsightService
- SwiftData
- api/memory.py
- SettingsView
- .ephemeralDefaults()
- VoiceTranscriptTests
- String
- KeychainService
- SpiritualTradition
- asyncio
- QdrantVectorStore
- SpeechService
- DreamModel
- GraphService
- test_dreams.py
- .trendSummary()
- PersonaKind
- asyncio
- Foundation
- GraphExportServiceTests
- .classifyHTTPFailure()
- LLMProvider
- OpenRouterModel
- String
- FakeKeychain
- ChatServiceCompactionTests
- GraphServiceTests
- providers/__init__.py
- test_insights.py
- base
- TagCapsule
- Theme
- ModelService
- Persona
- ActiveImaginationTests
- ModelServiceTests
- test_notes.py
- env.py
- graph_ui.py
- DownloadProgressDelegate
- DashboardService
- OnDeviceModelsStep
- BackupFolderPicker
- MemoryService
- Float
- .writePDF()
- .decrypt()
- String
- GlobalMemoryServiceTests
- Selfward
- SelfwardTests
- CompanionPersonality
- ModelPickerView
- test_auth.py
- .body
- CodingKeys
- EncryptedBackupDocument
- test_graph_ui.py
- test_safety.py
- chat.py
- VoiceService
- CompanionGender
- .sizeThatFits()
- qdrant
- VoiceSettingsView
- properties
- CodingKeys
- EmbeddingService
- LocalModelService.swift
- DashboardSheet
- test_dashboard.py
- test_sessions.py
- TTSKeyProvider
- project.yml
- RoundedCorner
- GlobalMemoryService
- .schedule()
- .stripMarkdown()
- test_chat.py
- MarkdownText
- targets
- TherapyService
- NodeConnectionsSheet
- NarrativeTests
- TestModalityPrompts
- .narrativeFont()
- options
- AutoBackupService.swift
- ChatResult
- GraphExportServiceTests.swift
- .decode()
- Phase
- test_safety_enforcement.py
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

## Communities (153 total, 44 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.06
Nodes (27): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+19 more)

### Community 2 - "NoteModel"
Cohesion: 0.06
Nodes (26): NoteModel, AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent (+18 more)

### Community 3 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (17): CommonCrypto, CryptoKit, BackupCrypto, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot, BackupPlanner (+9 more)

### Community 4 - "AgentContext"
Cohesion: 0.11
Nodes (22): AgentContext, AgentResult, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent, IntegrativeAgent (+14 more)

### Community 5 - "ChatMessage"
Cohesion: 0.09
Nodes (11): Settings, ChatMessage, ChatResult, LLMProvider, OllamaProvider, OpenRouterProvider, test_health_endpoint(), provider() (+3 more)

### Community 6 - "database.py"
Cohesion: 0.08
Nodes (17): get_agent_service(), list_agents(), route_message(), health_check(), get_events(), get_safety_service(), get_summary(), get_progress() (+9 more)

### Community 7 - "sqlalchemy_ext_asyncio"
Cohesion: 0.20
Nodes (7): Base, GraphEdge, GraphNode, Note, AgentService, db_session(), graph_service()

### Community 8 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (3): ConversationCompactor, StoredState, ConversationCompactorTests

### Community 9 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (31): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+23 more)

### Community 10 - "MemoryService"
Cohesion: 0.11
Nodes (8): EpisodicMemory, ProceduralMemory, SemanticMemory, MemoryService, get_vector_store(), VectorStore, db_session(), memory_service()

### Community 11 - "SessionModel"
Cohesion: 0.09
Nodes (22): SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, DashboardView, .allDreams, .allEdges, .allMemories (+14 more)

### Community 12 - "asyncio"
Cohesion: 0.09
Nodes (6): TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 13 - "schemas.py"
Cohesion: 0.13
Nodes (31): create_edge(), create_node(), extract(), AgentResponse, AgentRouteResponse, GlobalDashboardResponse, GraphConnectionResponse, GraphEdgeCreate (+23 more)

### Community 14 - "dreams.py"
Cohesion: 0.12
Nodes (16): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+8 more)

### Community 15 - "LocalLLMEngine"
Cohesion: 0.10
Nodes (12): exactVersion, url, LLM, LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed (+4 more)

### Community 16 - "ChatView"
Cohesion: 0.09
Nodes (17): CapturedBadgeRow, ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, CrisisBanner (+9 more)

### Community 17 - "GraphService"
Cohesion: 0.09
Nodes (8): get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph(), get_themes(), list_nodes(), GraphService

### Community 18 - "LocalModelService"
Cohesion: 0.15
Nodes (14): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, .downloadedLocalModels, .localAvailable, .resolvedLocalModel (+6 more)

### Community 19 - "chat_service.py"
Cohesion: 0.11
Nodes (7): Message, GlobalMemory, SafetyEvent, GlobalMemoryService, get_provider(), _is_negated(), SafetyService

### Community 20 - "Session"
Cohesion: 0.19
Nodes (17): get_mode(), get_mode_service(), set_mode(), Session, ModeService, test_get_mode_default(), test_get_mode_not_found(), test_resolve_provider_auto() (+9 more)

### Community 21 - "String"
Cohesion: 0.13
Nodes (14): BYOKLLMKit, LLMError, apiError, contextLengthExceeded, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded (+6 more)

### Community 22 - "Error"
Cohesion: 0.10
Nodes (6): ChatServiceStreamingTests, MockStreamingLLM, Error, keyDerivationFailed, malformed, sealFailed

### Community 23 - "AutoBackupService"
Cohesion: 0.17
Nodes (8): AutoBackupConfig, AutoBackupService, .decoder, .encoder, .folderDisplayName, .isEnabled, .lastBackupDate, AvailableAutoBackup

### Community 24 - "AggregatedGraph"
Cohesion: 0.17
Nodes (7): AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, GraphVisualizationSheet, .body, GraphVisualizationSheetTests

### Community 25 - "DashboardView.swift"
Cohesion: 0.13
Nodes (19): Charts, GlobalMemoryModel, .body, FlowTagView, .body, GlobalMemoriesListView, .body, .filtered (+11 more)

### Community 26 - ".buildIncremental()"
Cohesion: 0.18
Nodes (4): MessageModel, NarrativeService, Source, NarrativeServiceTests

### Community 27 - "insights.py"
Cohesion: 0.16
Nodes (17): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), refresh_insights() (+9 more)

### Community 28 - "ChatService"
Cohesion: 0.15
Nodes (11): create_session(), delete_session(), get_session(), list_sessions(), update_session(), get_chat_service(), SessionCreate, SessionResponse (+3 more)

### Community 29 - "SwiftUI"
Cohesion: 0.11
Nodes (11): AVFoundation, VoicePickerView, .body, .defaultVoices, .enhancedVoices, .premiumVoices, VoiceRow, .body (+3 more)

### Community 30 - "Coordinator"
Cohesion: 0.12
Nodes (4): Coordinator, GraphVisualizationView, ShareSheet, WebKit

### Community 31 - ".makeInMemoryContainer()"
Cohesion: 0.13
Nodes (4): InsightServiceTests, MemoryServiceTests, TestSupport, BackupPayloadTests

### Community 32 - "InMemoryVectorStore"
Cohesion: 0.13
Nodes (3): InMemoryVectorStore, TestInMemoryVectorStore, TestQdrantVectorStore

### Community 33 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (6): SelfwardDesktop, run(), run(), run(), create(), run()

### Community 34 - "graphify_pipeline.py"
Cohesion: 0.11
Nodes (8): test_delete_recording(), test_delete_recording_not_found(), test_list_recordings(), test_list_recordings_empty(), test_upload_audio(), test_upload_cleans_up_file(), test_voice_chat(), test_voice_chat_session_not_found()

### Community 35 - "View"
Cohesion: 0.12
Nodes (18): PersonaAvatar, View, .body, ArchivedSessionsView, .body, ContentView, .body, SessionRow (+10 more)

### Community 36 - "ChatService"
Cohesion: 0.20
Nodes (3): ChatService, ChatServiceE2ETests, MockLLM

### Community 37 - "asyncio"
Cohesion: 0.13
Nodes (5): TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 38 - "TTSCoordinator"
Cohesion: 0.15
Nodes (5): PrefetchedSentence, text, TTSCoordinator, .isSpeaking, .provider

### Community 39 - "TherapyService"
Cohesion: 0.11
Nodes (8): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), DashboardService, TherapyService, db_session(), graph_service(), therapy_service()

### Community 40 - "Codable"
Cohesion: 0.24
Nodes (15): AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData, EmbeddingRequest (+7 more)

### Community 41 - ".get()"
Cohesion: 0.13
Nodes (6): APIKeyProvider, .byokProviders, .cloudProvidersWithKeys, .body, .openAISection, ProviderRoutingTests

### Community 42 - "VoiceConversationController"
Cohesion: 0.19
Nodes (3): VoiceConversationController, .silenceInterval, VoiceUtterance

### Community 43 - "AppleFoundationEngine"
Cohesion: 0.13
Nodes (9): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+1 more)

### Community 44 - "SafetyServiceTests"
Cohesion: 0.12
Nodes (3): CrisisResources, Resource, SafetyServiceTests

### Community 45 - "NarrativeView"
Cohesion: 0.13
Nodes (13): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+5 more)

### Community 46 - "notes.py"
Cohesion: 0.15
Nodes (9): create_note(), delete_note(), get_note_service(), list_notes(), update_note(), NoteCreate, NoteResponse, NoteUpdate (+1 more)

### Community 47 - "api/voice.py"
Cohesion: 0.17
Nodes (9): delete_recording(), get_voice_service(), list_recordings(), upload_audio(), voice_chat(), VoiceChatResponse, VoiceRecordingResponse, VoiceRecording (+1 more)

### Community 48 - "GraphNodeModel"
Cohesion: 0.22
Nodes (11): GraphEdgeModel, GraphNodeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties (+3 more)

### Community 50 - "SwiftData"
Cohesion: 0.22
Nodes (3): Selfward, SwiftData, XCTest

### Community 51 - "api/memory.py"
Cohesion: 0.18
Nodes (16): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), search_memories(), store_procedural(), store_semantic() (+8 more)

### Community 52 - "SettingsView"
Cohesion: 0.15
Nodes (8): AboutYouSettingsView, .body, PrivacySettingsView, .body, SettingsView, .autoBackupEnabled, .body, UniformTypeIdentifiers

### Community 55 - "String"
Cohesion: 0.22
Nodes (5): MemoryModel, MoodEntryModel, NarrativeDocument, SafetyEventModel, VoiceRecordingModel

### Community 56 - "KeychainService"
Cohesion: 0.28
Nodes (3): .passphrase, KeychainService, KeychainStoring

### Community 57 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 58 - "asyncio"
Cohesion: 0.16
Nodes (4): TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 59 - "QdrantVectorStore"
Cohesion: 0.16
Nodes (4): cosine_similarity(), QdrantVectorStore, SearchResult, TestCosineSimilarity

### Community 60 - "SpeechService"
Cohesion: 0.18
Nodes (3): SpeechService, PersonasSettingsView, .body

### Community 61 - "DreamModel"
Cohesion: 0.20
Nodes (9): DreamModel, DreamService, DreamDetailView, .body, .feelings, .symbols, DreamsListView, .body (+1 more)

### Community 62 - "GraphService"
Cohesion: 0.29
Nodes (4): EdgeSpec, Extraction, GraphService, NodeSpec

### Community 63 - "test_dreams.py"
Cohesion: 0.21
Nodes (16): test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date(), test_dream_date_default() (+8 more)

### Community 64 - ".trendSummary()"
Cohesion: 0.21
Nodes (5): MoodStore, MoodCheckInCard, .body, .recentDaily, MoodDayAverage

### Community 65 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 67 - "Foundation"
Cohesion: 0.15
Nodes (4): BackupKit, Foundation, BadgeBackfillService, UserNotifications

### Community 70 - "LLMProvider"
Cohesion: 0.12
Nodes (15): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+7 more)

### Community 71 - "OpenRouterModel"
Cohesion: 0.19
Nodes (10): ModelSource, curated, huggingFace, ModelPricing, ModelsResponse, OpenRouterArchitecture, OpenRouterModel, .isFree (+2 more)

### Community 72 - "String"
Cohesion: 0.26
Nodes (4): HFModel, HFSibling, HuggingFaceModelService, HuggingFaceCatalogTests

### Community 76 - "providers/__init__.py"
Cohesion: 0.29
Nodes (4): get_stt_provider(), STTProvider, TranscriptResult, MockSTTProvider

### Community 77 - "test_insights.py"
Cohesion: 0.20
Nodes (7): reset_vector_store(), cleanup_vector_store(), client(), db_session(), db_session(), graph_service(), insight_service()

### Community 78 - "base"
Cohesion: 0.14
Nodes (14): ASSETCATALOG_COMPILER_APPICON_NAME, BUNDLE_LOADER, CODE_SIGN_STYLE, CURRENT_PROJECT_VERSION, DEVELOPMENT_TEAM, ENABLE_PREVIEWS, GENERATE_INFOPLIST_FILE, INFOPLIST_FILE (+6 more)

### Community 79 - "TagCapsule"
Cohesion: 0.20
Nodes (8): AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, TagCapsule, .body, .body

### Community 80 - "Theme"
Cohesion: 0.21
Nodes (6): .body, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament, .line

### Community 82 - "ModelService"
Cohesion: 0.23
Nodes (6): ModelService, .freeModels, .paidModels, .body, KeysAndProvidersSettingsView, .body

### Community 83 - "Persona"
Cohesion: 0.15
Nodes (3): Persona, .displayName, SpiritualPersonaTests

### Community 86 - "test_notes.py"
Cohesion: 0.35
Nodes (11): test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes(), test_list_notes_empty_session(), test_note_types_defined() (+3 more)

### Community 87 - "env.py"
Cohesion: 0.17
Nodes (3): do_run_migrations(), run_migrations_online(), upgrade()

### Community 88 - "graph_ui.py"
Cohesion: 0.27
Nodes (5): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), GraphUIService

### Community 90 - "DashboardService"
Cohesion: 0.33
Nodes (3): DashboardService, GlobalDashboard, SessionDashboard

### Community 91 - "OnDeviceModelsStep"
Cohesion: 0.17
Nodes (6): OnDeviceModelsStep, .ramGB, .recommendedID, .recommendedModel, LocalModelServiceCatalogTests, .service

### Community 99 - "Selfward"
Cohesion: 0.18
Nodes (11): package, product, buildPhase, path, dependencies, deploymentTarget, platform, resources (+3 more)

### Community 100 - "SelfwardTests"
Cohesion: 0.18
Nodes (11): target, sources, dependencies, deploymentTarget, platform, settings, sources, type (+3 more)

### Community 101 - "CompanionPersonality"
Cohesion: 0.18
Nodes (11): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, machiavelli (+3 more)

### Community 102 - "ModelPickerView"
Cohesion: 0.27
Nodes (3): ModelPickerView, .freeSorted, .paidSorted

### Community 103 - "test_auth.py"
Cohesion: 0.33
Nodes (6): api_key(), test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected(), test_wrong_key_rejected(), test_x_api_key_accepted()

### Community 104 - ".body"
Cohesion: 0.29
Nodes (5): AppRootView, .body, RootTabView, SelfwardApp, .body

### Community 105 - "CodingKeys"
Cohesion: 0.20
Nodes (9): CodingKeys, architecture, contextLength, id, inputModalities, modality, name, outputModalities (+1 more)

### Community 107 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (8): test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty(), test_visualization_with_data()

### Community 108 - "test_safety.py"
Cohesion: 0.36
Nodes (8): test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty(), test_safety_summary()

### Community 109 - "chat.py"
Cohesion: 0.33
Nodes (5): chat(), get_chat_history(), ChatRequest, ChatResponse, MessageResponse

### Community 111 - "CompanionGender"
Cohesion: 0.22
Nodes (8): CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine, unspecified

### Community 113 - "qdrant"
Cohesion: 0.22
Nodes (8): image, ports, volumes, services, qdrant, version, volumes, qdrant_data

### Community 114 - "VoiceSettingsView"
Cohesion: 0.25
Nodes (5): ProviderKeySection, VoiceSettingsView, .body, .elevenLabsSection, .onDeviceSection

### Community 115 - "properties"
Cohesion: 0.22
Nodes (9): path, properties, NSMicrophoneUsageDescription, NSSpeechRecognitionUsageDescription, UILaunchScreen, UISupportedInterfaceOrientations, UISupportedInterfaceOrientations~ipad, info (+1 more)

### Community 116 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 117 - "EmbeddingService"
Cohesion: 0.28
Nodes (3): EmbeddingService, .isAvailable, NaturalLanguage

### Community 118 - "LocalModelService.swift"
Cohesion: 0.22
Nodes (8): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3

### Community 119 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 120 - "test_dashboard.py"
Cohesion: 0.39
Nodes (7): test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 121 - "test_sessions.py"
Cohesion: 0.50
Nodes (6): test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 122 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 123 - "project.yml"
Cohesion: 0.25
Nodes (7): name, from, url, packages, OnDeviceKit, settings, targets

### Community 129 - "test_chat.py"
Cohesion: 0.54
Nodes (5): test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 130 - "MarkdownText"
Cohesion: 0.33
Nodes (3): MarkdownText, .attributed, .body

### Community 131 - "targets"
Cohesion: 0.29
Nodes (7): targets, schemes, Selfward, build, test, gatherCoverageData, targets

### Community 133 - "NodeConnectionsSheet"
Cohesion: 0.43
Nodes (4): Connection, NodeConnectionsSheet, .body, .connections

### Community 137 - "options"
Cohesion: 0.33
Nodes (6): iOS, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, xcodeVersion

### Community 138 - "AutoBackupService.swift"
Cohesion: 0.33
Nodes (5): AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, Security

### Community 142 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

### Community 143 - "test_safety_enforcement.py"
Cohesion: 0.60
Nodes (3): test_boundary_response_is_filtered(), test_crisis_resource_message_consistent(), test_negation_is_not_crisis()

## Knowledge Gaps
- **213 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+208 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 636 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **44 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `NoteModel`, `ChatView`, `Error`, `AutoBackupService`, `AggregatedGraph`, `DashboardView.swift`, `.buildIncremental()`, `.makeInMemoryContainer()`, `View`, `ChatService`, `GraphNodeModel`, `InsightService`, `.ephemeralDefaults()`, `String`, `DreamModel`, `GraphService`, `PersonaKind`, `GraphExportServiceTests`, `ChatServiceCompactionTests`, `GraphServiceTests`, `.historyTokenBudget()`, `DashboardService`, `MemoryService`, `.decrypt()`, `ModelPickerView`, `VoiceService`?**
  _High betweenness centrality (0.077) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _213 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `cytoscape.min.js` be split into smaller, more focused modules?**
  _Cohesion score 0.051462904911180773 - nodes in this community are weakly interconnected._
- **Why does `View` connect `View` to `PINService`, `MarkdownText`, `NoteModel`, `NodeConnectionsSheet`, `OnboardingView.swift`, `SessionModel`, `ChatView`, `LocalModelService`, `AggregatedGraph`, `DashboardView.swift`, `SwiftUI`, `NarrativeView`, `GraphNodeModel`, `SettingsView`, `SpeechService`, `DreamModel`, `.trendSummary()`, `TagCapsule`, `ModelService`, `OnDeviceModelsStep`, `ModelPickerView`, `.body`, `VoiceSettingsView`, `RoundedCorner`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Should `PINService` be split into smaller, more focused modules?**
  _Cohesion score 0.05583308845136644 - nodes in this community are weakly interconnected._