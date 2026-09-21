# Graph Report - therAIpist  (2026-09-21)

## Corpus Check
- Large corpus: 233 files · ~979,619 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2732 nodes · 6757 edges · 144 communities (126 shown, 18 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 662 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- vector_store.py
- BackupRestorePlan
- AgentContext
- sqlalchemy_ext_asyncio
- OnboardingView.swift
- SessionModel
- schemas.py
- View
- database.py
- ConversationCompactorTests
- GraphService
- ChatMessage
- dreams.py
- LocalModelService
- .makeInMemoryContainer()
- asyncio
- graphify_pipeline.py
- AgentContext
- ChatView
- .processMessage()
- ChatService
- XCTestCase
- AutoBackupService
- LocalLLMEngine
- insights.py
- OpenRouterModel
- .buildIncremental()
- AggregatedGraph
- SettingsView
- SelfwardDesktop
- asyncio
- MemoryService
- Session
- .get()
- TTSCoordinator
- notes.py
- ChatService
- SafetyServiceTests
- VoiceConversationController
- NarrativeView
- SwiftData
- AppleFoundationEngine
- SafetyService
- VoicePickerView
- Codable
- String
- GraphNodeModel
- String
- VoiceTranscriptTests
- SpeechService
- Identifiable
- Float
- SpiritualTradition
- Coordinator
- asyncio
- Components.swift
- String
- DashboardView
- MockLLM
- test_dreams.py
- NarrativeDocument
- KeychainService
- PersonaKind
- asyncio
- GraphExportServiceTests
- .classifyHTTPFailure()
- LLMProvider
- .ephemeralDefaults()
- String
- FakeKeychain
- test_graph.py
- Foundation
- LLMError
- Theme
- ModelPickerView
- Persona
- ModelServiceTests
- test_notes.py
- env.py
- graph_ui.py
- sessions.py
- DownloadProgressDelegate
- DashboardService
- BackupFolderPicker
- GlobalMemoryServiceTests
- api/voice.py
- MemoryService
- .historyTokenBudget()
- LocalModelService.swift
- .decrypt()
- ActiveImaginationTests
- agents.py
- SpiritualPersonaTests
- SafetyService
- test_auth.py
- .body
- VoiceService
- CodingKeys
- EncryptedBackupDocument
- CompanionPersonality
- SessionRow
- test_graph_ui.py
- test_safety.py
- chat.py
- GlobalMemoryService
- VoiceService
- CompanionGender
- CodingKeys
- EmbeddingService
- LocalModelServiceCatalogTests
- NoteService
- .schedule()
- test_dashboard.py
- test_sessions.py
- SwiftUI
- TTSKeyProvider
- RoundedCorner
- AutoBackupService.swift
- GlobalMemoryService
- .stripMarkdown()
- String
- NodeConnectionsSheet
- test_chat.py
- VoiceSettingsView
- .analyzeDream()
- ShareSheet
- TestModalityPrompts
- MarkdownText
- NewSessionView
- GraphExportServiceTests.swift
- .decode()
- Phase
- NarrativeView.swift
- PackageDescription
- therapist

## God Nodes (most connected - your core abstractions)
1. `SessionModel` - 145 edges
2. `ChatService` - 48 edges
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
  tests/test_graph.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_insights.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (144 total, 18 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.05
Nodes (40): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+32 more)

### Community 2 - "vector_store.py"
Cohesion: 0.06
Nodes (24): Settings, AsyncSession, cosine_similarity(), get_vector_store(), InMemoryVectorStore, ABC, QdrantVectorStore, reset_vector_store() (+16 more)

### Community 3 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (32): CommonCrypto, CryptoKit, Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot (+24 more)

### Community 4 - "AgentContext"
Cohesion: 0.10
Nodes (26): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+18 more)

### Community 5 - "sqlalchemy_ext_asyncio"
Cohesion: 0.18
Nodes (18): app_agents, Base, Message, GraphEdge, GraphNode, EpisodicMemory, Note, app_services_providers (+10 more)

### Community 6 - "OnboardingView.swift"
Cohesion: 0.07
Nodes (44): CGSize, AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body (+36 more)

### Community 7 - "SessionModel"
Cohesion: 0.10
Nodes (18): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String (+10 more)

### Community 8 - "schemas.py"
Cohesion: 0.09
Nodes (44): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+36 more)

### Community 9 - "View"
Cohesion: 0.09
Nodes (36): Charts, View, DreamModel, NoteModel, .body, DashboardTabView, .body, .body (+28 more)

### Community 10 - "database.py"
Cohesion: 0.08
Nodes (32): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), AsyncSession, get, health_check(), get, get_events() (+24 more)

### Community 11 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (8): ConversationCompactor, StoredState, Date, Int, String, ConversationCompactorTests, Int, String

### Community 12 - "GraphService"
Cohesion: 0.10
Nodes (23): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+15 more)

### Community 13 - "ChatMessage"
Cohesion: 0.11
Nodes (17): ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, OllamaProvider, OpenRouterProvider, pydantic (+9 more)

### Community 14 - "dreams.py"
Cohesion: 0.11
Nodes (22): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+14 more)

### Community 15 - "LocalModelService"
Cohesion: 0.13
Nodes (21): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, Bool, Set, .downloadedLocalModels (+13 more)

### Community 16 - ".makeInMemoryContainer()"
Cohesion: 0.08
Nodes (7): GraphServiceTests, InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, StaticString, UInt

### Community 17 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 18 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 19 - "AgentContext"
Cohesion: 0.13
Nodes (19): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+11 more)

### Community 20 - "ChatView"
Cohesion: 0.08
Nodes (25): CapturedBadgeRow, ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, CrisisBanner (+17 more)

### Community 21 - ".processMessage()"
Cohesion: 0.10
Nodes (10): BadgeBackfillService, ModelContext, ModelContext, Void, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests (+2 more)

### Community 22 - "ChatService"
Cohesion: 0.09
Nodes (14): get_chat_service(), AsyncSession, SessionCreate, ChatService, AsyncSession, DashboardService, AsyncSession, AsyncSession (+6 more)

### Community 23 - "XCTestCase"
Cohesion: 0.10
Nodes (13): ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM, AsyncThrowingStream, Int, String (+5 more)

### Community 24 - "AutoBackupService"
Cohesion: 0.17
Nodes (16): AutoBackupConfig, AutoBackupService, .decoder, .encoder, .folderDisplayName, .isEnabled, .lastBackupDate, AvailableAutoBackup (+8 more)

### Community 25 - "LocalLLMEngine"
Cohesion: 0.12
Nodes (17): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, Bool (+9 more)

### Community 26 - "insights.py"
Cohesion: 0.14
Nodes (21): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+13 more)

### Community 27 - "OpenRouterModel"
Cohesion: 0.14
Nodes (18): Decoder, Hashable, ModelPricing, ModelService, .freeModels, .paidModels, ModelsResponse, OpenRouterArchitecture (+10 more)

### Community 28 - ".buildIncremental()"
Cohesion: 0.19
Nodes (11): MessageModel, Bool, NarrativeService, Source, Bool, Date, ModelContext, String (+3 more)

### Community 29 - "AggregatedGraph"
Cohesion: 0.19
Nodes (10): AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL, GraphVisualizationSheet (+2 more)

### Community 30 - "SettingsView"
Cohesion: 0.13
Nodes (17): Binding, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+9 more)

### Community 31 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 32 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 33 - "MemoryService"
Cohesion: 0.15
Nodes (6): ProceduralMemory, SemanticMemory, MemoryService, db_session(), memory_service(), fixture

### Community 34 - "Session"
Cohesion: 0.23
Nodes (18): Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture, test_get_mode_default(), test_get_mode_not_found() (+10 more)

### Community 35 - ".get()"
Cohesion: 0.13
Nodes (6): APIKeyProvider, .byokProviders, .cloudProvidersWithKeys, .body, .openAISection, ProviderRoutingTests

### Community 36 - "TTSCoordinator"
Cohesion: 0.16
Nodes (14): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+6 more)

### Community 37 - "notes.py"
Cohesion: 0.14
Nodes (15): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+7 more)

### Community 38 - "ChatService"
Cohesion: 0.18
Nodes (9): ChatResult, ChatService, Bool, Int, String, ChatServiceE2ETests, ModelContainer, ModelContext (+1 more)

### Community 39 - "SafetyServiceTests"
Cohesion: 0.14
Nodes (4): CrisisResources, Resource, String, SafetyServiceTests

### Community 40 - "VoiceConversationController"
Cohesion: 0.19
Nodes (9): Bool, TimeInterval, Timer, Void, VoiceConversationController, .silenceInterval, VoiceUtterance, SFSpeechAudioBufferRecognitionRequest (+1 more)

### Community 41 - "NarrativeView"
Cohesion: 0.13
Nodes (19): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+11 more)

### Community 42 - "SwiftData"
Cohesion: 0.21
Nodes (3): Selfward, SwiftData, XCTest

### Community 43 - "AppleFoundationEngine"
Cohesion: 0.14
Nodes (14): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+6 more)

### Community 44 - "SafetyService"
Cohesion: 0.15
Nodes (10): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService, re, asyncio, test_boundary_response_is_filtered() (+2 more)

### Community 45 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 46 - "Codable"
Cohesion: 0.27
Nodes (17): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+9 more)

### Community 47 - "String"
Cohesion: 0.21
Nodes (11): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+3 more)

### Community 48 - "GraphNodeModel"
Cohesion: 0.27
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 49 - "String"
Cohesion: 0.24
Nodes (9): LLMMessage, OpenRouterRequest, Bool, unsupportedProvider, LLMSending, LLMService, LLMStreaming, AsyncThrowingStream (+1 more)

### Community 51 - "SpeechService"
Cohesion: 0.17
Nodes (11): AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, SpeechService, AVSpeechSynthesisVoice, String, TimeInterval, Void (+3 more)

### Community 52 - "Identifiable"
Cohesion: 0.20
Nodes (13): Identifiable, MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, MoodCheckInCard (+5 more)

### Community 53 - "Float"
Cohesion: 0.19
Nodes (10): GlobalMemoryModel, Float, Int, String, VectorStore, GlobalMemoriesListView, .body, .filtered (+2 more)

### Community 54 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 55 - "Coordinator"
Cohesion: 0.16
Nodes (12): Coordinator, GraphVisualizationView, Coordinator, String, Void, UIViewRepresentable, WKNavigation, WKNavigationDelegate (+4 more)

### Community 56 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 57 - "Components.swift"
Cohesion: 0.15
Nodes (15): Actions, Font, AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body (+7 more)

### Community 58 - "String"
Cohesion: 0.19
Nodes (8): MemoryModel, SafetyEventModel, Data, Date, Int, String, TimeInterval, VoiceRecordingModel

### Community 59 - "DashboardView"
Cohesion: 0.12
Nodes (18): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+10 more)

### Community 60 - "MockLLM"
Cohesion: 0.27
Nodes (4): ChatServiceCompactionTests, ModelContainer, ModelContext, MockLLM

### Community 61 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 62 - "NarrativeDocument"
Cohesion: 0.19
Nodes (7): NarrativeDocument, NarrativeExportService, String, URL, NarrativeTests, ModelContainer, NSParagraphStyle

### Community 63 - "KeychainService"
Cohesion: 0.26
Nodes (6): .passphrase, KeychainService, KeychainStoring, Bool, Data, String

### Community 64 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 65 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 66 - "GraphExportServiceTests"
Cohesion: 0.29
Nodes (3): GraphExportServiceTests, Int, ModelContainer

### Community 67 - ".classifyHTTPFailure()"
Cohesion: 0.24
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 68 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 70 - "String"
Cohesion: 0.26
Nodes (7): HFModel, HFSibling, HuggingFaceModelService, Data, String, TimeInterval, HuggingFaceCatalogTests

### Community 71 - "FakeKeychain"
Cohesion: 0.27
Nodes (5): AutoBackupServiceTests, FakeKeychain, Bool, Data, String

### Community 72 - "test_graph.py"
Cohesion: 0.17
Nodes (12): pytest, pytest_asyncio, db_session(), graph_service(), fixture, AsyncClient, asyncio, test_health_endpoint() (+4 more)

### Community 73 - "Foundation"
Cohesion: 0.18
Nodes (3): BackupKit, Foundation, UserNotifications

### Community 74 - "LLMError"
Cohesion: 0.15
Nodes (11): BYOKLLMKit, LLMError, apiError, contextLengthExceeded, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded (+3 more)

### Community 75 - "Theme"
Cohesion: 0.21
Nodes (9): .body, Color, LinearGradient, String, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament (+1 more)

### Community 76 - "ModelPickerView"
Cohesion: 0.19
Nodes (9): Bool, TagCapsule, .body, ModelPickerView, .freeSorted, .paidSorted, Int, LLMProvider (+1 more)

### Community 77 - "Persona"
Cohesion: 0.21
Nodes (4): Persona, .displayName, String, TherapyService

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

### Community 83 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (10): Int64, DownloadProgressDelegate, Double, Result, URL, Void, URLSession, URLSessionDownloadDelegate (+2 more)

### Community 84 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 85 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 86 - "GlobalMemoryServiceTests"
Cohesion: 0.24
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 87 - "api/voice.py"
Cohesion: 0.24
Nodes (11): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+3 more)

### Community 88 - "MemoryService"
Cohesion: 0.33
Nodes (5): ClosedRange, String, MemoryService, ModelContext, String

### Community 89 - ".historyTokenBudget()"
Cohesion: 0.20
Nodes (7): AsyncThrowingStream, Bool, ChatResult, Int, ModelContext, String, Void

### Community 90 - "LocalModelService.swift"
Cohesion: 0.17
Nodes (11): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3 (+3 more)

### Community 91 - ".decrypt()"
Cohesion: 0.35
Nodes (4): BackupService, Data, ModelContext, Payload

### Community 93 - "agents.py"
Cohesion: 0.25
Nodes (9): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), AgentResponse, AgentRouteResponse (+1 more)

### Community 95 - "SafetyService"
Cohesion: 0.29
Nodes (4): SafetyService, StoreProtection, Bool, URL

### Community 96 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 97 - ".body"
Cohesion: 0.29
Nodes (7): App, AppRootView, .body, RootTabView, SelfwardApp, .body, Scene

### Community 98 - "VoiceService"
Cohesion: 0.29
Nodes (5): VoiceRecording, get_stt_provider(), AsyncSession, VoiceService, settings

### Community 99 - "CodingKeys"
Cohesion: 0.20
Nodes (10): CodingKey, CodingKeys, architecture, contextLength, id, inputModalities, modality, name (+2 more)

### Community 100 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 101 - "CompanionPersonality"
Cohesion: 0.20
Nodes (10): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, playful (+2 more)

### Community 102 - "SessionRow"
Cohesion: 0.29
Nodes (7): ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind

### Community 103 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 104 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 105 - "chat.py"
Cohesion: 0.33
Nodes (8): chat(), get_chat_history(), AsyncSession, get, post, ChatRequest, ChatResponse, MessageResponse

### Community 106 - "GlobalMemoryService"
Cohesion: 0.36
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 107 - "VoiceService"
Cohesion: 0.33
Nodes (5): AVAudioRecorder, ModelContext, String, URL, VoiceService

### Community 108 - "CompanionGender"
Cohesion: 0.22
Nodes (9): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+1 more)

### Community 109 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 110 - "EmbeddingService"
Cohesion: 0.28
Nodes (6): EmbeddingService, .isAvailable, Bool, Data, NaturalLanguage, NLEmbedding

### Community 111 - "LocalModelServiceCatalogTests"
Cohesion: 0.25
Nodes (4): Int, .recommendedID, LocalModelServiceCatalogTests, .service

### Community 112 - "NoteService"
Cohesion: 0.50
Nodes (3): NoteService, ModelContext, String

### Community 113 - ".schedule()"
Cohesion: 0.36
Nodes (4): ReminderScheduler, Int, UNNotificationRequest, UNUserNotificationCenter

### Community 114 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 115 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 116 - "SwiftUI"
Cohesion: 0.32
Nodes (3): AVFoundation, Speech, SwiftUI

### Community 117 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 118 - "RoundedCorner"
Cohesion: 0.32
Nodes (6): RoundedCorner, CGFloat, CGRect, Path, Shape, UIRectCorner

### Community 119 - "AutoBackupService.swift"
Cohesion: 0.25
Nodes (6): AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LocalizedError, Security

### Community 120 - "GlobalMemoryService"
Cohesion: 0.43
Nodes (4): GlobalMemoryService, Int, ModelContext, String

### Community 122 - "String"
Cohesion: 0.43
Nodes (3): Never, String, Task

### Community 123 - "NodeConnectionsSheet"
Cohesion: 0.32
Nodes (6): Connection, NodeConnectionsSheet, .body, .connections, Int, WebKit

### Community 124 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 125 - "VoiceSettingsView"
Cohesion: 0.33
Nodes (6): ElevenLabsTTSEngine, Double, String, VoiceSettingsView, .body, .elevenLabsSection

### Community 126 - ".analyzeDream()"
Cohesion: 0.43
Nodes (3): DreamService, ModelContext, String

### Community 127 - "ShareSheet"
Cohesion: 0.38
Nodes (5): ShareSheet, Any, Context, UIActivityViewController, UIViewControllerRepresentable

### Community 129 - "MarkdownText"
Cohesion: 0.40
Nodes (5): AttributedString, MarkdownText, .attributed, .body, String

### Community 130 - "NewSessionView"
Cohesion: 0.40
Nodes (5): NewSessionView, .body, .defaultProviderLabel, .personaName, String

### Community 131 - "GraphExportServiceTests.swift"
Cohesion: 0.33
Nodes (4): XMLParserRecorder, NSObject, XMLParser, XMLParserDelegate

### Community 133 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **208 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+203 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 604 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `NewSessionView`, `View`, `.makeInMemoryContainer()`, `ChatView`, `.processMessage()`, `XCTestCase`, `AutoBackupService`, `.buildIncremental()`, `AggregatedGraph`, `ChatService`, `String`, `GraphNodeModel`, `String`, `DashboardView`, `MockLLM`, `PersonaKind`, `GraphExportServiceTests`, `.ephemeralDefaults()`, `ModelPickerView`, `DashboardService`, `MemoryService`, `.historyTokenBudget()`, `.decrypt()`, `SessionRow`, `VoiceService`, `NoteService`, `.analyzeDream()`?**
  _High betweenness centrality (0.101) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `MarkdownText`, `NewSessionView`, `PINService`, `OnboardingView.swift`, `SessionModel`, `LocalModelService`, `ChatView`, `OpenRouterModel`, `AggregatedGraph`, `SettingsView`, `NarrativeView`, `VoicePickerView`, `String`, `SpeechService`, `Identifiable`, `Float`, `Components.swift`, `DashboardView`, `ModelPickerView`, `.body`, `SessionRow`, `RoundedCorner`, `NodeConnectionsSheet`, `VoiceSettingsView`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `PINService`, `GraphExportServiceTests.swift`, `BackupRestorePlan`, `SessionModel`, `AgentContext`, `.processMessage()`, `LocalLLMEngine`, `OpenRouterModel`, `.buildIncremental()`, `AggregatedGraph`, `AppleFoundationEngine`, `Codable`, `GraphNodeModel`, `Float`, `String`, `PersonaKind`, `LLMError`, `Persona`, `DashboardService`, `LocalModelService.swift`, `VoiceService`, `EmbeddingService`, `NoteService`, `SwiftUI`, `TTSKeyProvider`, `AutoBackupService.swift`, `GlobalMemoryService`, `.analyzeDream()`?**
  _High betweenness centrality (0.038) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _208 weakly-connected nodes found - possible documentation gaps or missing edges._