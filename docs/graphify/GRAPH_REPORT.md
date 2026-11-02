# Graph Report - therAIpist  (2026-11-02)

## Corpus Check
- 221 files · ~344,404 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 10 file(s) not represented in the graph (top: (none) 2, .ini 1, .jsonl 1)

## Summary
- 2809 nodes · 7092 edges · 137 communities (96 shown, 41 thin omitted)
- Extraction: 87% EXTRACTED · 13% INFERRED · 0% AMBIGUOUS · INFERRED: 905 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- AutoBackupService
- cytoscape.min.js
- PINService
- schemas.py
- BackupRestorePlan
- AgentContext
- config.py
- sqlalchemy_ext_asyncio
- insights.py
- ChatMessage
- MemoryService
- .add_node()
- LocalModelService
- ConversationCompactorTests
- OnboardingView.swift
- dreams.py
- SessionModel
- AgentContext
- LocalLLMEngine
- String
- OpenRouterModel
- Float
- ChatService
- GraphService
- String
- DashboardView.swift
- String
- Error
- Session
- .chat()
- .buildIncremental()
- AggregatedGraph
- ChatService
- Coordinator
- SpeechService
- notes.py
- SelfwardDesktop
- graphify_pipeline.py
- NarrativeView
- Codable
- View
- VoiceConversationController
- pytest
- AppleFoundationEngine
- .makeInMemoryContainer()
- ChatView
- Foundation
- InsightCaptureServiceTests
- InsightService
- SafetyServiceTests
- XCTest
- SwiftUI
- VoicePickerView
- GraphNodeModel
- .ephemeralDefaults()
- VoiceTranscriptTests
- TTSCoordinator
- api/voice.py
- SpiritualTradition
- asyncio
- DreamModel
- test_dreams.py
- SettingsView.swift
- .trendSummary()
- .models()
- PersonaKind
- MockLLM
- test_chat.py
- .classifyHTTPFailure()
- LLMProvider
- VoiceStatusBar
- GraphServiceTests
- SettingsView
- base
- Theme
- Persona
- ModelServiceTests
- test_notes.py
- env.py
- VoiceService
- DownloadProgressDelegate
- DashboardService
- BackupFolderPicker
- ActiveImaginationTests
- GlobalMemoryServiceTests
- GraphUIService
- .decrypt()
- String
- dashboard.py
- TherapyService
- Selfward
- SelfwardTests
- CompanionPersonality
- ModelPickerView
- test_auth.py
- .body
- CodingKeys
- EncryptedBackupDocument
- SessionRow
- test_graph_ui.py
- test_safety.py
- CompanionGender
- .sizeThatFits()
- qdrant
- properties
- CodingKeys
- LocalModelService.swift
- .writePDF()
- .schedule()
- DashboardSheet
- InsightServiceTests
- XCTestCase
- test_dashboard.py
- .get_modality_prompt()
- TTSKeyProvider
- project.yml
- RoundedCorner
- targets
- GlobalMemoryService
- TherapyService
- NodeConnectionsSheet
- NarrativeTests
- options
- .decode()
- Phase
- memory_service()
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
- `provider()` --uses--> `Settings`  [INFERRED]
  tests/test_providers/test_ollama.py → app/core/config.py
- `provider()` --uses--> `Settings`  [INFERRED]
  tests/test_providers/test_openrouter.py → app/core/config.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/conftest.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_insights.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_memory.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (137 total, 41 thin omitted)

### Community 0 - "AutoBackupService"
Cohesion: 0.05
Nodes (24): AutoBackupConfig, AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, AutoBackupService, .decoder, .encoder (+16 more)

### Community 1 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 2 - "PINService"
Cohesion: 0.06
Nodes (27): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+19 more)

### Community 3 - "schemas.py"
Cohesion: 0.06
Nodes (49): get_agent_service(), list_agents(), route_message(), chat(), health_check(), get_safety_service(), get_progress(), suggest_intervention() (+41 more)

### Community 4 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (17): CommonCrypto, CryptoKit, BackupCrypto, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot, BackupPlanner (+9 more)

### Community 5 - "AgentContext"
Cohesion: 0.12
Nodes (22): AgentContext, AgentResult, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent, IntegrativeAgent (+14 more)

### Community 6 - "config.py"
Cohesion: 0.06
Nodes (11): Settings, cosine_similarity(), get_vector_store(), InMemoryVectorStore, QdrantVectorStore, reset_vector_store(), SearchResult, VectorStore (+3 more)

### Community 7 - "sqlalchemy_ext_asyncio"
Cohesion: 0.18
Nodes (11): Base, Message, GraphEdge, GraphNode, EpisodicMemory, ProceduralMemory, SemanticMemory, VoiceRecording (+3 more)

### Community 8 - "insights.py"
Cohesion: 0.09
Nodes (22): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), refresh_insights() (+14 more)

### Community 9 - "ChatMessage"
Cohesion: 0.08
Nodes (13): ChatMessage, ChatResult, LLMProvider, get_stt_provider(), OllamaProvider, OpenRouterProvider, STTProvider, TranscriptResult (+5 more)

### Community 10 - "MemoryService"
Cohesion: 0.09
Nodes (15): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), search_memories(), store_procedural(), store_semantic() (+7 more)

### Community 11 - ".add_node()"
Cohesion: 0.10
Nodes (6): TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 12 - "LocalModelService"
Cohesion: 0.11
Nodes (20): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, .downloadedLocalModels, .localAvailable, .resolvedLocalModel (+12 more)

### Community 13 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (3): ConversationCompactor, StoredState, ConversationCompactorTests

### Community 14 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (31): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+23 more)

### Community 15 - "dreams.py"
Cohesion: 0.13
Nodes (16): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+8 more)

### Community 16 - "SessionModel"
Cohesion: 0.09
Nodes (22): SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, DashboardView, .allDreams, .allEdges, .allMemories (+14 more)

### Community 17 - "AgentContext"
Cohesion: 0.14
Nodes (16): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+8 more)

### Community 18 - "LocalLLMEngine"
Cohesion: 0.10
Nodes (12): exactVersion, url, LLM, LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed (+4 more)

### Community 19 - "String"
Cohesion: 0.13
Nodes (16): GlobalMemoryModel, MemoryModel, MoodEntryModel, NarrativeDocument, SafetyEventModel, VoiceRecordingModel, GlobalMemoriesListView, .body (+8 more)

### Community 20 - "OpenRouterModel"
Cohesion: 0.11
Nodes (16): ModelSource, curated, huggingFace, ModelPricing, ModelService, .freeModels, .paidModels, ModelsResponse (+8 more)

### Community 21 - "Float"
Cohesion: 0.12
Nodes (5): EmbeddingService, .isAvailable, Float, MemoryService, VectorStore

### Community 22 - "ChatService"
Cohesion: 0.14
Nodes (11): get_chat_history(), create_session(), delete_session(), get_session(), list_sessions(), update_session(), SessionCreate, SessionResponse (+3 more)

### Community 23 - "GraphService"
Cohesion: 0.14
Nodes (16): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+8 more)

### Community 24 - "String"
Cohesion: 0.13
Nodes (14): BYOKLLMKit, LLMError, apiError, contextLengthExceeded, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded (+6 more)

### Community 25 - "DashboardView.swift"
Cohesion: 0.12
Nodes (11): Charts, NoteModel, .body, NoteService, DashboardTabView, .body, NoteDetailView, .body (+3 more)

### Community 26 - "String"
Cohesion: 0.13
Nodes (17): GraphEdgeModel, .body, EdgesListView, .body, .filtered, FlowTagView, .body, NodeDetailView (+9 more)

### Community 27 - "Error"
Cohesion: 0.10
Nodes (6): ChatServiceStreamingTests, MockStreamingLLM, Error, keyDerivationFailed, malformed, sealFailed

### Community 28 - "Session"
Cohesion: 0.19
Nodes (17): get_mode(), get_mode_service(), set_mode(), Session, ModeService, test_get_mode_default(), test_get_mode_not_found(), test_resolve_provider_auto() (+9 more)

### Community 29 - ".chat()"
Cohesion: 0.13
Nodes (8): get_events(), get_summary(), GlobalMemory, SafetyEvent, AgentService, GlobalMemoryService, _is_negated(), SafetyService

### Community 30 - ".buildIncremental()"
Cohesion: 0.17
Nodes (4): MessageModel, NarrativeService, Source, NarrativeServiceTests

### Community 31 - "AggregatedGraph"
Cohesion: 0.18
Nodes (7): AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, GraphVisualizationSheet, .body, GraphVisualizationSheetTests

### Community 32 - "ChatService"
Cohesion: 0.16
Nodes (4): ChatResult, ChatService, LocalPromptOverflow, ChatServiceCompactionTests

### Community 33 - "Coordinator"
Cohesion: 0.11
Nodes (4): Coordinator, GraphVisualizationView, ShareSheet, WebKit

### Community 34 - "SpeechService"
Cohesion: 0.13
Nodes (4): SpeechService, PersonasSettingsView, .body, SpeechServiceTests

### Community 35 - "notes.py"
Cohesion: 0.15
Nodes (10): create_note(), delete_note(), get_note_service(), list_notes(), update_note(), Note, NoteCreate, NoteResponse (+2 more)

### Community 36 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (6): SelfwardDesktop, run(), run(), run(), create(), run()

### Community 37 - "graphify_pipeline.py"
Cohesion: 0.11
Nodes (8): test_delete_recording(), test_delete_recording_not_found(), test_list_recordings(), test_list_recordings_empty(), test_upload_audio(), test_upload_cleans_up_file(), test_voice_chat(), test_voice_chat_session_not_found()

### Community 38 - "NarrativeView"
Cohesion: 0.12
Nodes (14): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+6 more)

### Community 39 - "Codable"
Cohesion: 0.24
Nodes (15): AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData, EmbeddingRequest (+7 more)

### Community 40 - "View"
Cohesion: 0.15
Nodes (12): AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body, PersonaAvatar, TagCapsule (+4 more)

### Community 41 - "VoiceConversationController"
Cohesion: 0.19
Nodes (3): VoiceConversationController, .silenceInterval, VoiceUtterance

### Community 42 - "pytest"
Cohesion: 0.11
Nodes (10): cleanup_vector_store(), client(), db_session(), test_health_endpoint(), db_session(), graph_service(), insight_service(), test_boundary_response_is_filtered() (+2 more)

### Community 43 - "AppleFoundationEngine"
Cohesion: 0.13
Nodes (9): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+1 more)

### Community 45 - "ChatView"
Cohesion: 0.15
Nodes (6): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona

### Community 46 - "Foundation"
Cohesion: 0.15
Nodes (6): BackupKit, Foundation, BadgeBackfillService, NaturalLanguage, SwiftData, UserNotifications

### Community 47 - "InsightCaptureServiceTests"
Cohesion: 0.18
Nodes (3): DreamCandidate, InsightCaptureService, InsightCaptureServiceTests

### Community 49 - "SafetyServiceTests"
Cohesion: 0.13
Nodes (3): CrisisResources, Resource, SafetyServiceTests

### Community 51 - "SwiftUI"
Cohesion: 0.12
Nodes (10): AVFoundation, MarkdownText, .attributed, .body, NewSessionView, .body, .defaultProviderLabel, .personaName (+2 more)

### Community 52 - "VoicePickerView"
Cohesion: 0.15
Nodes (8): VoicePickerView, .body, .defaultVoices, .enhancedVoices, .premiumVoices, VoiceRow, .body, .isSelected

### Community 53 - "GraphNodeModel"
Cohesion: 0.27
Nodes (5): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec

### Community 56 - "TTSCoordinator"
Cohesion: 0.17
Nodes (5): PrefetchedSentence, text, TTSCoordinator, .isSpeaking, .provider

### Community 57 - "api/voice.py"
Cohesion: 0.19
Nodes (7): delete_recording(), get_voice_service(), list_recordings(), upload_audio(), voice_chat(), VoiceRecordingResponse, VoiceService

### Community 58 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 60 - "DreamModel"
Cohesion: 0.20
Nodes (9): DreamModel, DreamService, DreamDetailView, .body, .feelings, .symbols, DreamsListView, .body (+1 more)

### Community 61 - "test_dreams.py"
Cohesion: 0.21
Nodes (16): test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date(), test_dream_date_default() (+8 more)

### Community 62 - "SettingsView.swift"
Cohesion: 0.13
Nodes (12): AboutYouSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection, SettingsTabView, .body, VoiceSettingsView (+4 more)

### Community 63 - ".trendSummary()"
Cohesion: 0.21
Nodes (5): MoodStore, MoodCheckInCard, .body, .recentDaily, MoodDayAverage

### Community 64 - ".models()"
Cohesion: 0.19
Nodes (4): HFModel, HFSibling, HuggingFaceModelService, HuggingFaceCatalogTests

### Community 65 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 67 - "test_chat.py"
Cohesion: 0.24
Nodes (11): test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history(), test_create_session(), test_delete_session(), test_get_session() (+3 more)

### Community 69 - "LLMProvider"
Cohesion: 0.12
Nodes (15): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+7 more)

### Community 70 - "VoiceStatusBar"
Cohesion: 0.14
Nodes (11): CapturedBadgeRow, CrisisBanner, .body, MessageBubble, .body, .hasBadges, VoiceStatusBar, .body (+3 more)

### Community 72 - "SettingsView"
Cohesion: 0.23
Nodes (3): SettingsView, .autoBackupEnabled, .body

### Community 73 - "base"
Cohesion: 0.14
Nodes (14): ASSETCATALOG_COMPILER_APPICON_NAME, BUNDLE_LOADER, CODE_SIGN_STYLE, CURRENT_PROJECT_VERSION, DEVELOPMENT_TEAM, ENABLE_PREVIEWS, GENERATE_INFOPLIST_FILE, INFOPLIST_FILE (+6 more)

### Community 74 - "Theme"
Cohesion: 0.21
Nodes (6): .body, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament, .line

### Community 75 - "Persona"
Cohesion: 0.15
Nodes (3): Persona, .displayName, SpiritualPersonaTests

### Community 77 - "test_notes.py"
Cohesion: 0.35
Nodes (11): test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes(), test_list_notes_empty_session(), test_note_types_defined() (+3 more)

### Community 78 - "env.py"
Cohesion: 0.17
Nodes (3): do_run_migrations(), run_migrations_online(), upgrade()

### Community 81 - "DashboardService"
Cohesion: 0.33
Nodes (3): DashboardService, GlobalDashboard, SessionDashboard

### Community 85 - "GraphUIService"
Cohesion: 0.24
Nodes (5): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), GraphUIService

### Community 88 - "dashboard.py"
Cohesion: 0.29
Nodes (4): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), DashboardService

### Community 89 - "TherapyService"
Cohesion: 0.24
Nodes (5): get_therapy_service(), TherapyService, db_session(), graph_service(), therapy_service()

### Community 90 - "Selfward"
Cohesion: 0.18
Nodes (11): package, product, buildPhase, path, dependencies, deploymentTarget, platform, resources (+3 more)

### Community 91 - "SelfwardTests"
Cohesion: 0.18
Nodes (11): target, sources, dependencies, deploymentTarget, platform, settings, sources, type (+3 more)

### Community 93 - "CompanionPersonality"
Cohesion: 0.18
Nodes (11): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, machiavelli (+3 more)

### Community 94 - "ModelPickerView"
Cohesion: 0.27
Nodes (3): ModelPickerView, .freeSorted, .paidSorted

### Community 95 - "test_auth.py"
Cohesion: 0.33
Nodes (6): api_key(), test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected(), test_wrong_key_rejected(), test_x_api_key_accepted()

### Community 96 - ".body"
Cohesion: 0.29
Nodes (5): AppRootView, .body, RootTabView, SelfwardApp, .body

### Community 97 - "CodingKeys"
Cohesion: 0.20
Nodes (9): CodingKeys, architecture, contextLength, id, inputModalities, modality, name, outputModalities (+1 more)

### Community 99 - "SessionRow"
Cohesion: 0.29
Nodes (7): ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind

### Community 100 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (8): test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty(), test_visualization_with_data()

### Community 101 - "test_safety.py"
Cohesion: 0.36
Nodes (8): test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty(), test_safety_summary()

### Community 102 - "CompanionGender"
Cohesion: 0.22
Nodes (8): CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine, unspecified

### Community 104 - "qdrant"
Cohesion: 0.22
Nodes (8): image, ports, volumes, services, qdrant, version, volumes, qdrant_data

### Community 105 - "properties"
Cohesion: 0.22
Nodes (9): path, properties, NSMicrophoneUsageDescription, NSSpeechRecognitionUsageDescription, UILaunchScreen, UISupportedInterfaceOrientations, UISupportedInterfaceOrientations~ipad, info (+1 more)

### Community 106 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 107 - "LocalModelService.swift"
Cohesion: 0.22
Nodes (8): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3

### Community 110 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 113 - "test_dashboard.py"
Cohesion: 0.39
Nodes (7): test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 115 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 116 - "project.yml"
Cohesion: 0.25
Nodes (7): name, from, url, packages, OnDeviceKit, settings, targets

### Community 119 - "targets"
Cohesion: 0.29
Nodes (7): targets, schemes, Selfward, build, test, gatherCoverageData, targets

### Community 122 - "NodeConnectionsSheet"
Cohesion: 0.43
Nodes (4): Connection, NodeConnectionsSheet, .body, .connections

### Community 124 - "options"
Cohesion: 0.33
Nodes (6): iOS, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, xcodeVersion

### Community 126 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **213 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+208 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 625 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **41 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `AutoBackupService`, `String`, `Float`, `DashboardView.swift`, `String`, `Error`, `.buildIncremental()`, `AggregatedGraph`, `ChatService`, `.makeInMemoryContainer()`, `ChatView`, `InsightCaptureServiceTests`, `InsightService`, `SwiftUI`, `GraphNodeModel`, `.ephemeralDefaults()`, `DreamModel`, `PersonaKind`, `MockLLM`, `GraphServiceTests`, `VoiceService`, `DashboardService`, `.decrypt()`, `.configError()`, `ModelPickerView`, `SessionRow`, `InsightServiceTests`, `XCTestCase`?**
  _High betweenness centrality (0.077) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _213 weakly-connected nodes found - possible missing edges._
- **Should `AutoBackupService` be split into smaller, more focused modules?**
  _Cohesion score 0.05255613951266125 - nodes in this community are weakly interconnected._
- **Why does `View` connect `View` to `PINService`, `LocalModelService`, `OnboardingView.swift`, `SessionModel`, `String`, `OpenRouterModel`, `DashboardView.swift`, `String`, `AggregatedGraph`, `SpeechService`, `NarrativeView`, `ChatView`, `SwiftUI`, `VoicePickerView`, `DreamModel`, `SettingsView.swift`, `.trendSummary()`, `VoiceStatusBar`, `SettingsView`, `ModelPickerView`, `.body`, `SessionRow`, `RoundedCorner`, `NodeConnectionsSheet`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Should `cytoscape.min.js` be split into smaller, more focused modules?**
  _Cohesion score 0.05067920585161965 - nodes in this community are weakly interconnected._