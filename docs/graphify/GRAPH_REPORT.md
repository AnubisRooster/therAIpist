# Graph Report - therAIpist  (2026-09-20)

## Corpus Check
- Large corpus: 233 files · ~979,595 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2718 nodes · 6716 edges · 132 communities (112 shown, 20 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 659 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- SafetyServiceTests
- BackupRestorePlan
- AgentContext
- test_memory.py
- sqlalchemy_ext_asyncio
- OpenRouterModel
- schemas.py
- ChatMessage
- SessionModel
- test_auth.py
- database.py
- AutoBackupService
- KeychainService
- DashboardView.swift
- ConversationCompactorTests
- ChatService
- LocalModelService
- OnboardingView.swift
- .processMessage()
- dreams.py
- asyncio
- graphify_pipeline.py
- ChatView
- AggregatedGraph
- LocalLLMEngine
- insights.py
- View
- .buildIncremental()
- InsightCaptureServiceTests
- GraphService
- SelfwardDesktop
- ChatService
- asyncio
- Session
- VoiceConversationController
- TTSCoordinator
- notes.py
- Codable
- .makeInMemoryContainer()
- Foundation
- AppleFoundationEngine
- NarrativeView
- XCTest
- VoicePickerView
- CompanionPersonality
- Error
- .ephemeralDefaults()
- XCTestCase
- VoiceTranscriptTests
- LLMError
- String
- GraphNodeModel
- Coordinator
- asyncio
- SwiftUI
- SpeechService
- String
- DreamModel
- ChatServiceStreamingTests
- test_dreams.py
- MemoryService
- NarrativeDocument
- asyncio
- graph_ui.py
- .classifyHTTPFailure()
- LLMProvider
- SettingsView
- .models()
- ChatServiceCompactionTests
- GraphServiceTests
- Theme
- test_notes.py
- env.py
- sessions.py
- api/voice.py
- SafetyService
- Identifiable
- DownloadProgressDelegate
- String
- SessionRow
- DashboardService
- BackupFolderPicker
- ActiveImaginationTests
- GlobalMemoryServiceTests
- MemoryService
- LocalModelService.swift
- PersonaKind
- agents.py
- Float
- ModelPickerView
- .body
- VoiceService
- EncryptedBackupDocument
- GraphVisualizationSheet
- test_safety.py
- chat.py
- .sizeThatFits()
- CodingKeys
- .historyTokenBudget()
- EmbeddingService
- NoteService
- DashboardSheet
- SpiritualPersonaTests
- api/safety.py
- VoiceService
- VoiceSettingsView
- LLMSending
- Persona
- .stripMarkdown()
- String
- conftest.py
- MarkdownText
- .narrativePage()
- GlobalMemoryService
- TherapyService
- NewSessionView
- TestModalityPrompts
- LocalModelServiceCatalogTests
- Phase
- test_safety_enforcement.py
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

## Communities (132 total, 20 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.06
Nodes (39): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+31 more)

### Community 2 - "SafetyServiceTests"
Cohesion: 0.05
Nodes (28): MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, BackupService, CrisisResources (+20 more)

### Community 3 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (30): Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot (+22 more)

### Community 4 - "AgentContext"
Cohesion: 0.11
Nodes (25): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+17 more)

### Community 5 - "test_memory.py"
Cohesion: 0.06
Nodes (20): AsyncSession, cosine_similarity(), get_vector_store(), InMemoryVectorStore, ABC, QdrantVectorStore, reset_vector_store(), SearchResult (+12 more)

### Community 6 - "sqlalchemy_ext_asyncio"
Cohesion: 0.15
Nodes (20): app_agents, Base, Message, GraphEdge, GraphNode, EpisodicMemory, ProceduralMemory, SemanticMemory (+12 more)

### Community 7 - "OpenRouterModel"
Cohesion: 0.06
Nodes (32): CodingKey, Decoder, Hashable, CodingKeys, architecture, contextLength, id, inputModalities (+24 more)

### Community 8 - "schemas.py"
Cohesion: 0.10
Nodes (47): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+39 more)

### Community 9 - "ChatMessage"
Cohesion: 0.09
Nodes (25): Settings, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, OllamaProvider, OpenRouterProvider (+17 more)

### Community 10 - "SessionModel"
Cohesion: 0.10
Nodes (18): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String (+10 more)

### Community 11 - "test_auth.py"
Cohesion: 0.07
Nodes (42): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+34 more)

### Community 12 - "database.py"
Cohesion: 0.07
Nodes (37): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), AsyncSession, get, health_check(), get, get_mode() (+29 more)

### Community 13 - "AutoBackupService"
Cohesion: 0.11
Nodes (23): AutoBackupConfig, AutoBackupService, .decoder, .encoder, .folderDisplayName, .isEnabled, .lastBackupDate, .passphrase (+15 more)

### Community 14 - "KeychainService"
Cohesion: 0.08
Nodes (18): Combine, APIKeyProvider, KeychainService, Bool, Data, String, TTSKeyProvider, .displayName (+10 more)

### Community 15 - "DashboardView.swift"
Cohesion: 0.08
Nodes (37): Charts, GlobalMemoryModel, NoteModel, DashboardView, .allDreams, .allEdges, .allMemories, .allNodes (+29 more)

### Community 16 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (8): ConversationCompactor, StoredState, Date, Int, String, ConversationCompactorTests, Int, String

### Community 17 - "ChatService"
Cohesion: 0.08
Nodes (17): get_chat_service(), AsyncSession, GlobalMemory, SessionCreate, ChatService, AsyncSession, DashboardService, AsyncSession (+9 more)

### Community 18 - "LocalModelService"
Cohesion: 0.12
Nodes (23): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, Bool, Set, String (+15 more)

### Community 19 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 20 - ".processMessage()"
Cohesion: 0.12
Nodes (21): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+13 more)

### Community 21 - "dreams.py"
Cohesion: 0.11
Nodes (22): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+14 more)

### Community 22 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 23 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 24 - "ChatView"
Cohesion: 0.09
Nodes (25): CapturedBadgeRow, ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, CrisisBanner (+17 more)

### Community 25 - "AggregatedGraph"
Cohesion: 0.16
Nodes (8): AggregatedGraph, GraphExportService, String, URL, .body, GraphExportServiceTests, Int, ModelContainer

### Community 26 - "LocalLLMEngine"
Cohesion: 0.12
Nodes (17): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, Bool (+9 more)

### Community 27 - "insights.py"
Cohesion: 0.14
Nodes (21): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+13 more)

### Community 28 - "View"
Cohesion: 0.12
Nodes (22): Actions, AnimatedEmptyState, BadgePill, .body, GradientHeader, .body, PersonaAvatar, RoundedCorner (+14 more)

### Community 29 - ".buildIncremental()"
Cohesion: 0.19
Nodes (11): MessageModel, Bool, NarrativeService, Source, Bool, Date, ModelContext, String (+3 more)

### Community 30 - "InsightCaptureServiceTests"
Cohesion: 0.14
Nodes (7): ModelContext, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 31 - "GraphService"
Cohesion: 0.12
Nodes (9): GraphService, AsyncSession, db_session(), graph_service(), fixture, db_session(), graph_service(), insight_service() (+1 more)

### Community 32 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 33 - "ChatService"
Cohesion: 0.20
Nodes (6): ChatService, ChatServiceE2ETests, ModelContainer, ModelContext, String, MockLLM

### Community 34 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 35 - "Session"
Cohesion: 0.23
Nodes (18): Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture, test_get_mode_default(), test_get_mode_not_found() (+10 more)

### Community 36 - "VoiceConversationController"
Cohesion: 0.19
Nodes (9): Bool, TimeInterval, Timer, Void, VoiceConversationController, .silenceInterval, VoiceUtterance, SFSpeechAudioBufferRecognitionRequest (+1 more)

### Community 37 - "TTSCoordinator"
Cohesion: 0.16
Nodes (14): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+6 more)

### Community 38 - "notes.py"
Cohesion: 0.14
Nodes (15): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+7 more)

### Community 39 - "Codable"
Cohesion: 0.24
Nodes (19): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+11 more)

### Community 40 - ".makeInMemoryContainer()"
Cohesion: 0.15
Nodes (7): InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, TestSupport, StaticString, UInt

### Community 41 - "Foundation"
Cohesion: 0.17
Nodes (5): BackupKit, Foundation, BadgeBackfillService, SwiftData, UserNotifications

### Community 42 - "AppleFoundationEngine"
Cohesion: 0.14
Nodes (14): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+6 more)

### Community 43 - "NarrativeView"
Cohesion: 0.14
Nodes (19): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+11 more)

### Community 45 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 46 - "CompanionPersonality"
Cohesion: 0.11
Nodes (19): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+11 more)

### Community 47 - "Error"
Cohesion: 0.12
Nodes (13): CommonCrypto, CryptoKit, XMLParserRecorder, AsyncThrowingStream, Int, String, NSObject, Error (+5 more)

### Community 48 - ".ephemeralDefaults()"
Cohesion: 0.22
Nodes (3): PersonaService, UserDefaults, PersonaTests

### Community 49 - "XCTestCase"
Cohesion: 0.11
Nodes (15): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+7 more)

### Community 51 - "LLMError"
Cohesion: 0.11
Nodes (17): BYOKLLMKit, AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LLMError, apiError, contextLengthExceeded (+9 more)

### Community 52 - "String"
Cohesion: 0.22
Nodes (11): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+3 more)

### Community 53 - "GraphNodeModel"
Cohesion: 0.29
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 54 - "Coordinator"
Cohesion: 0.16
Nodes (12): Coordinator, GraphVisualizationView, Coordinator, String, Void, UIViewRepresentable, WKNavigation, WKNavigationDelegate (+4 more)

### Community 55 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 56 - "SwiftUI"
Cohesion: 0.13
Nodes (14): AVFoundation, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+6 more)

### Community 57 - "SpeechService"
Cohesion: 0.18
Nodes (10): AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, SpeechService, AVSpeechSynthesisVoice, String, TimeInterval, Void (+2 more)

### Community 58 - "String"
Cohesion: 0.19
Nodes (8): MemoryModel, SafetyEventModel, Data, Date, Int, String, TimeInterval, VoiceRecordingModel

### Community 59 - "DreamModel"
Cohesion: 0.19
Nodes (11): DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings, .symbols (+3 more)

### Community 60 - "ChatServiceStreamingTests"
Cohesion: 0.18
Nodes (5): ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM

### Community 61 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 62 - "MemoryService"
Cohesion: 0.17
Nodes (3): get_memory_service(), AsyncSession, MemoryService

### Community 63 - "NarrativeDocument"
Cohesion: 0.19
Nodes (7): NarrativeDocument, NarrativeExportService, String, URL, NarrativeTests, ModelContainer, NSParagraphStyle

### Community 64 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 65 - "graph_ui.py"
Cohesion: 0.17
Nodes (11): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphStatsResponse, GraphTimelineResponse (+3 more)

### Community 66 - ".classifyHTTPFailure()"
Cohesion: 0.24
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 67 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 68 - "SettingsView"
Cohesion: 0.22
Nodes (8): Binding, SettingsView, .autoBackupEnabled, .body, Bool, Date, Int, Result

### Community 69 - ".models()"
Cohesion: 0.20
Nodes (7): HFModel, HFSibling, HuggingFaceModelService, Data, Int, TimeInterval, HuggingFaceCatalogTests

### Community 70 - "ChatServiceCompactionTests"
Cohesion: 0.27
Nodes (3): ChatServiceCompactionTests, ModelContainer, ModelContext

### Community 72 - "Theme"
Cohesion: 0.21
Nodes (9): .body, Color, LinearGradient, String, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament (+1 more)

### Community 73 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 74 - "env.py"
Cohesion: 0.17
Nodes (8): alembic, app_models, asyncio, logging_config, do_run_migrations(), run_migrations_online(), sqlalchemy_engine, typing

### Community 75 - "sessions.py"
Cohesion: 0.28
Nodes (12): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+4 more)

### Community 76 - "api/voice.py"
Cohesion: 0.23
Nodes (12): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+4 more)

### Community 77 - "SafetyService"
Cohesion: 0.23
Nodes (5): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService

### Community 78 - "Identifiable"
Cohesion: 0.22
Nodes (9): Identifiable, AggregatedEdge, AggregatedNode, Int, Connection, NodeConnectionsSheet, .connections, Int (+1 more)

### Community 79 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (10): Int64, DownloadProgressDelegate, Double, Result, URL, Void, URLSession, URLSessionDownloadDelegate (+2 more)

### Community 80 - "String"
Cohesion: 0.40
Nodes (5): LLMMessage, unsupportedProvider, LLMService, AsyncThrowingStream, String

### Community 81 - "SessionRow"
Cohesion: 0.21
Nodes (10): .body, ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind (+2 more)

### Community 82 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 83 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 85 - "GlobalMemoryServiceTests"
Cohesion: 0.24
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 86 - "MemoryService"
Cohesion: 0.33
Nodes (5): ClosedRange, String, MemoryService, ModelContext, String

### Community 87 - "LocalModelService.swift"
Cohesion: 0.17
Nodes (11): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3 (+3 more)

### Community 88 - "PersonaKind"
Cohesion: 0.17
Nodes (12): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+4 more)

### Community 89 - "agents.py"
Cohesion: 0.25
Nodes (9): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), AgentResponse, AgentRouteResponse (+1 more)

### Community 90 - "Float"
Cohesion: 0.35
Nodes (4): Float, Int, String, VectorStore

### Community 91 - "ModelPickerView"
Cohesion: 0.27
Nodes (6): ModelPickerView, .freeSorted, .paidSorted, Int, LLMProvider, String

### Community 92 - ".body"
Cohesion: 0.29
Nodes (7): App, AppRootView, .body, RootTabView, SelfwardApp, .body, Scene

### Community 93 - "VoiceService"
Cohesion: 0.29
Nodes (5): VoiceRecording, get_stt_provider(), AsyncSession, VoiceService, settings

### Community 94 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 95 - "GraphVisualizationSheet"
Cohesion: 0.27
Nodes (7): GraphVisualizationSheet, ShareSheet, Any, Context, UIActivityViewController, UIViewControllerRepresentable, WebKit

### Community 96 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 97 - "chat.py"
Cohesion: 0.33
Nodes (8): chat(), get_chat_history(), AsyncSession, get, post, ChatRequest, ChatResponse, MessageResponse

### Community 98 - ".sizeThatFits()"
Cohesion: 0.31
Nodes (7): CGSize, FlowLayout, CGFloat, CGRect, Layout, ProposedViewSize, Subviews

### Community 99 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 100 - ".historyTokenBudget()"
Cohesion: 0.28
Nodes (5): AsyncThrowingStream, Bool, Int, String, Void

### Community 101 - "EmbeddingService"
Cohesion: 0.28
Nodes (6): EmbeddingService, .isAvailable, Bool, Data, NaturalLanguage, NLEmbedding

### Community 102 - "NoteService"
Cohesion: 0.50
Nodes (3): NoteService, ModelContext, String

### Community 103 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 105 - "api/safety.py"
Cohesion: 0.32
Nodes (7): get_events(), get_safety_service(), get_summary(), AsyncSession, get, SafetyEventResponse, SafetySummaryResponse

### Community 106 - "VoiceService"
Cohesion: 0.39
Nodes (5): AVAudioRecorder, ModelContext, String, URL, VoiceService

### Community 107 - "VoiceSettingsView"
Cohesion: 0.29
Nodes (7): ElevenLabsTTSEngine, Double, String, VoiceSettingsView, .body, .elevenLabsSection, .onDeviceSection

### Community 108 - "LLMSending"
Cohesion: 0.29
Nodes (5): ChatResult, Bool, Int, String, LLMSending

### Community 111 - "String"
Cohesion: 0.43
Nodes (3): Never, String, Task

### Community 112 - "conftest.py"
Cohesion: 0.32
Nodes (6): pytest_asyncio, cleanup_vector_store(), client(), db_session(), AsyncSession, fixture

### Community 113 - "MarkdownText"
Cohesion: 0.33
Nodes (5): AttributedString, MarkdownText, .attributed, .body, String

### Community 114 - ".narrativePage()"
Cohesion: 0.33
Nodes (4): Font, .body, CGFloat, .emptyState

### Community 115 - "GlobalMemoryService"
Cohesion: 0.52
Nodes (4): GlobalMemoryService, Int, ModelContext, String

### Community 117 - "NewSessionView"
Cohesion: 0.33
Nodes (5): NewSessionView, .body, .defaultProviderLabel, .personaName, String

### Community 120 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

### Community 121 - "test_safety_enforcement.py"
Cohesion: 0.60
Nodes (4): asyncio, test_boundary_response_is_filtered(), test_crisis_resource_message_consistent(), test_negation_is_not_crisis()

## Knowledge Gaps
- **208 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+203 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 604 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **20 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `SafetyServiceTests`, `AutoBackupService`, `DashboardView.swift`, `.processMessage()`, `ChatView`, `AggregatedGraph`, `.buildIncremental()`, `InsightCaptureServiceTests`, `ChatService`, `.makeInMemoryContainer()`, `.ephemeralDefaults()`, `String`, `GraphNodeModel`, `String`, `DreamModel`, `ChatServiceStreamingTests`, `ChatServiceCompactionTests`, `GraphServiceTests`, `SessionRow`, `DashboardService`, `MemoryService`, `ModelPickerView`, `GraphVisualizationSheet`, `NoteService`, `VoiceService`, `NewSessionView`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `PINService`, `BackupRestorePlan`, `OpenRouterModel`, `SessionModel`, `KeychainService`, `.processMessage()`, `LocalLLMEngine`, `.buildIncremental()`, `InsightCaptureServiceTests`, `Codable`, `AppleFoundationEngine`, `CompanionPersonality`, `Error`, `LLMError`, `GraphNodeModel`, `SwiftUI`, `String`, `DreamModel`, `Identifiable`, `DashboardService`, `LocalModelService.swift`, `Float`, `EmbeddingService`, `NoteService`, `TherapyService`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `PINService`, `SafetyServiceTests`, `SessionModel`, `DashboardView.swift`, `LocalModelService`, `OnboardingView.swift`, `ChatView`, `NarrativeView`, `VoicePickerView`, `String`, `SwiftUI`, `SpeechService`, `DreamModel`, `SettingsView`, `Identifiable`, `SessionRow`, `ModelPickerView`, `.body`, `GraphVisualizationSheet`, `VoiceSettingsView`, `MarkdownText`, `.narrativePage()`, `NewSessionView`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _208 weakly-connected nodes found - possible documentation gaps or missing edges._