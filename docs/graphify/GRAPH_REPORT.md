# Graph Report - therAIpist  (2026-09-25)

## Corpus Check
- Large corpus: 233 files · ~982,529 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2731 nodes · 6761 edges · 130 communities (112 shown, 18 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 662 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- AggregatedGraph
- Foundation
- SpeechService
- AgentContext
- BackupRestorePlan
- sqlalchemy_ext_asyncio
- ChatMessage
- SessionModel
- vector_store.py
- DashboardView.swift
- LocalModelService
- ChatService
- ChatService
- OnboardingView.swift
- GraphService
- schemas.py
- test_safety.py
- dreams.py
- asyncio
- graphify_pipeline.py
- AgentContext
- View
- NarrativeView
- Float
- ChatView
- LocalLLMEngine
- insights.py
- Session
- Theme
- InsightCaptureServiceTests
- KeychainService
- .models()
- FastAPI
- notes.py
- AutoBackupService
- SelfwardDesktop
- ChatServiceStreamingTests
- asyncio
- database.py
- ConversationCompactorTests
- VoiceConversationController
- String
- Codable
- AppleFoundationEngine
- .makeInMemoryContainer()
- TTSCoordinator
- SafetyServiceTests
- SettingsView
- EmbeddingService
- VoiceTranscriptTests
- api/voice.py
- MemoryService
- SpiritualTradition
- asyncio
- GraphService
- .ephemeralDefaults()
- DashboardView
- test_dreams.py
- NoteModel
- FakeKeychain
- .trendSummary()
- PersonaKind
- graph_ui.py
- ConversationCompactor
- .classifyHTTPFailure()
- LLMProvider
- asyncio
- ModelService
- .buildIncremental()
- GraphServiceTests
- Error
- Persona
- ModelServiceTests
- test_notes.py
- dashboard.py
- SafetyService
- DownloadProgressDelegate
- DashboardService
- BackupFolderPicker
- test_insights.py
- env.py
- OpenRouterModel
- .decrypt()
- String
- ModelPickerView
- GlobalMemoryServiceTests
- MessageModel
- .processMessage()
- CompanionPersonality
- CodingKeys
- VoiceSettingsView
- EncryptedBackupDocument
- LLMError
- SpiritualPersonaTests
- VectorStore
- SessionRow
- XCTestCase
- test_graph_ui.py
- .body
- CompanionGender
- .sizeThatFits()
- CodingKeys
- .historyTokenBudget()
- .schedule()
- test_dashboard.py
- api/safety.py
- AutoBackupService.swift
- GlobalMemoryService
- String
- ProviderRoutingTests
- test_chat.py
- GlobalMemoryService
- cosine_similarity()
- .analyzeDream()
- .decode()
- Phase
- test_safety_enforcement.py
- KeychainStoring
- ModelSource
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
  tests/test_insights.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_memory.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_therapy.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (130 total, 18 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.05
Nodes (40): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+32 more)

### Community 2 - "AggregatedGraph"
Cohesion: 0.06
Nodes (37): Identifiable, AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL (+29 more)

### Community 3 - "Foundation"
Cohesion: 0.05
Nodes (21): AVAudioRecorder, BackupKit, Combine, Foundation, BadgeBackfillService, TTSKeyProvider, .displayName, elevenlabs (+13 more)

### Community 4 - "SpeechService"
Cohesion: 0.05
Nodes (36): AVFoundation, AVSpeechSynthesisVoiceQuality, AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, SpeechService, AVSpeechSynthesisVoice, Bool (+28 more)

### Community 5 - "AgentContext"
Cohesion: 0.11
Nodes (25): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+17 more)

### Community 6 - "BackupRestorePlan"
Cohesion: 0.10
Nodes (29): Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot (+21 more)

### Community 7 - "sqlalchemy_ext_asyncio"
Cohesion: 0.16
Nodes (19): Base, Message, GraphEdge, GraphNode, EpisodicMemory, ProceduralMemory, VoiceRecording, collections (+11 more)

### Community 8 - "ChatMessage"
Cohesion: 0.08
Nodes (27): Settings, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, get_provider(), get_stt_provider() (+19 more)

### Community 9 - "SessionModel"
Cohesion: 0.09
Nodes (18): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String (+10 more)

### Community 10 - "vector_store.py"
Cohesion: 0.07
Nodes (15): AsyncSession, get_vector_store(), InMemoryVectorStore, ABC, QdrantVectorStore, reset_vector_store(), SearchResult, VectorStore (+7 more)

### Community 11 - "DashboardView.swift"
Cohesion: 0.10
Nodes (34): Charts, DreamModel, GlobalMemoryModel, .body, DreamDetailView, .body, .feelings, .symbols (+26 more)

### Community 12 - "LocalModelService"
Cohesion: 0.11
Nodes (25): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, Bool, Set, String (+17 more)

### Community 13 - "ChatService"
Cohesion: 0.09
Nodes (24): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+16 more)

### Community 14 - "ChatService"
Cohesion: 0.13
Nodes (11): ChatService, ChatServiceE2ETests, ModelContainer, ModelContext, String, ChatServiceCompactionTests, Int, ModelContainer (+3 more)

### Community 15 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 16 - "GraphService"
Cohesion: 0.10
Nodes (23): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+15 more)

### Community 17 - "schemas.py"
Cohesion: 0.12
Nodes (34): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+26 more)

### Community 18 - "test_safety.py"
Cohesion: 0.09
Nodes (28): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+20 more)

### Community 19 - "dreams.py"
Cohesion: 0.11
Nodes (22): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+14 more)

### Community 20 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 21 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 22 - "AgentContext"
Cohesion: 0.13
Nodes (19): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+11 more)

### Community 23 - "View"
Cohesion: 0.09
Nodes (30): Actions, AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body, PersonaAvatar (+22 more)

### Community 24 - "NarrativeView"
Cohesion: 0.10
Nodes (25): NarrativeDocument, NarrativeExportService, String, URL, NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud (+17 more)

### Community 25 - "Float"
Cohesion: 0.15
Nodes (18): GraphEdgeModel, GraphNodeModel, MemoryModel, MoodEntryModel, SafetyEventModel, Data, Date, Int (+10 more)

### Community 26 - "ChatView"
Cohesion: 0.09
Nodes (23): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, CrisisBanner, .body (+15 more)

### Community 27 - "LocalLLMEngine"
Cohesion: 0.12
Nodes (17): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, Bool (+9 more)

### Community 28 - "insights.py"
Cohesion: 0.14
Nodes (21): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+13 more)

### Community 29 - "Session"
Cohesion: 0.17
Nodes (22): get_mode(), get_mode_service(), AsyncSession, get, Session, ModeService, AsyncSession, asyncio (+14 more)

### Community 30 - "Theme"
Cohesion: 0.10
Nodes (17): AttributedString, Font, .body, MarkdownText, .attributed, .body, String, CGFloat (+9 more)

### Community 31 - "InsightCaptureServiceTests"
Cohesion: 0.14
Nodes (7): ModelContext, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 32 - "KeychainService"
Cohesion: 0.19
Nodes (7): APIKeyProvider, KeychainService, Bool, Data, String, .cloudProvidersWithKeys, .body

### Community 33 - ".models()"
Cohesion: 0.11
Nodes (15): HFModel, HFSibling, HuggingFaceModelService, LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML (+7 more)

### Community 34 - "FastAPI"
Cohesion: 0.12
Nodes (20): chat(), get_chat_history(), AsyncSession, get, post, health_check(), get, init_db() (+12 more)

### Community 35 - "notes.py"
Cohesion: 0.13
Nodes (16): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+8 more)

### Community 36 - "AutoBackupService"
Cohesion: 0.20
Nodes (14): AutoBackupConfig, AutoBackupService, .decoder, .encoder, .folderDisplayName, .isEnabled, .lastBackupDate, Bool (+6 more)

### Community 37 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 38 - "ChatServiceStreamingTests"
Cohesion: 0.13
Nodes (7): ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM, AsyncThrowingStream, String

### Community 39 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 40 - "database.py"
Cohesion: 0.13
Nodes (18): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), get_progress(), get_therapy_service() (+10 more)

### Community 42 - "VoiceConversationController"
Cohesion: 0.19
Nodes (9): Bool, TimeInterval, Timer, Void, VoiceConversationController, .silenceInterval, VoiceUtterance, SFSpeechAudioBufferRecognitionRequest (+1 more)

### Community 43 - "String"
Cohesion: 0.22
Nodes (8): BYOKLLMKit, LLMMessage, unsupportedProvider, LLMSending, LLMService, LLMStreaming, AsyncThrowingStream, String

### Community 44 - "Codable"
Cohesion: 0.24
Nodes (19): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+11 more)

### Community 45 - "AppleFoundationEngine"
Cohesion: 0.13
Nodes (15): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+7 more)

### Community 46 - ".makeInMemoryContainer()"
Cohesion: 0.15
Nodes (6): InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, StaticString, UInt

### Community 47 - "TTSCoordinator"
Cohesion: 0.18
Nodes (14): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+6 more)

### Community 48 - "SafetyServiceTests"
Cohesion: 0.13
Nodes (3): CrisisResources, Resource, SafetyServiceTests

### Community 49 - "SettingsView"
Cohesion: 0.15
Nodes (13): Binding, AboutYouSettingsView, .body, PrivacySettingsView, .body, SettingsView, .autoBackupEnabled, .body (+5 more)

### Community 50 - "EmbeddingService"
Cohesion: 0.18
Nodes (10): ClosedRange, EmbeddingService, .isAvailable, Bool, Data, String, MemoryService, ModelContext (+2 more)

### Community 52 - "api/voice.py"
Cohesion: 0.18
Nodes (14): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+6 more)

### Community 53 - "MemoryService"
Cohesion: 0.16
Nodes (5): SemanticMemory, MemoryService, db_session(), memory_service(), fixture

### Community 54 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 55 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 56 - "GraphService"
Cohesion: 0.29
Nodes (6): EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 57 - ".ephemeralDefaults()"
Cohesion: 0.25
Nodes (3): UserDefaults, PersonaTests, TestSupport

### Community 58 - "DashboardView"
Cohesion: 0.12
Nodes (18): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+10 more)

### Community 59 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 60 - "NoteModel"
Cohesion: 0.24
Nodes (9): NoteModel, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView, .body (+1 more)

### Community 61 - "FakeKeychain"
Cohesion: 0.24
Nodes (5): AutoBackupServiceTests, FakeKeychain, Bool, Data, String

### Community 62 - ".trendSummary()"
Cohesion: 0.21
Nodes (11): MoodStore, Date, Double, Int, ModelContext, MoodCheckInCard, .body, .recentDaily (+3 more)

### Community 63 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 64 - "graph_ui.py"
Cohesion: 0.17
Nodes (11): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphStatsResponse, GraphTimelineResponse (+3 more)

### Community 65 - "ConversationCompactor"
Cohesion: 0.35
Nodes (5): ConversationCompactor, StoredState, Date, Int, String

### Community 66 - ".classifyHTTPFailure()"
Cohesion: 0.24
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 67 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 68 - "asyncio"
Cohesion: 0.22
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 69 - "ModelService"
Cohesion: 0.22
Nodes (9): ModelService, .freeModels, .paidModels, Int, String, TimeInterval, .body, KeysAndProvidersSettingsView (+1 more)

### Community 70 - ".buildIncremental()"
Cohesion: 0.30
Nodes (6): NarrativeService, Source, Bool, Date, ModelContext, String

### Community 72 - "Error"
Cohesion: 0.15
Nodes (11): CommonCrypto, CryptoKit, XMLParserRecorder, Int, NSObject, Error, keyDerivationFailed, malformed (+3 more)

### Community 73 - "Persona"
Cohesion: 0.21
Nodes (4): Persona, .displayName, String, TherapyService

### Community 75 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 76 - "dashboard.py"
Cohesion: 0.21
Nodes (9): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), AsyncSession, get, GlobalDashboardResponse, SessionDashboardResponse, DashboardService (+1 more)

### Community 77 - "SafetyService"
Cohesion: 0.23
Nodes (5): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService

### Community 78 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (10): Int64, DownloadProgressDelegate, Double, Result, URL, Void, URLSession, URLSessionDownloadDelegate (+2 more)

### Community 79 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 80 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 81 - "test_insights.py"
Cohesion: 0.21
Nodes (10): pytest_asyncio, cleanup_vector_store(), client(), db_session(), AsyncSession, fixture, db_session(), graph_service() (+2 more)

### Community 82 - "env.py"
Cohesion: 0.18
Nodes (7): alembic, asyncio, logging_config, do_run_migrations(), run_migrations_online(), sqlalchemy_engine, typing

### Community 83 - "OpenRouterModel"
Cohesion: 0.26
Nodes (10): Decoder, Hashable, ModelPricing, ModelsResponse, OpenRouterArchitecture, OpenRouterModel, .isFree, .isTextFirst (+2 more)

### Community 84 - ".decrypt()"
Cohesion: 0.35
Nodes (4): BackupService, Data, ModelContext, Payload

### Community 85 - "String"
Cohesion: 0.30
Nodes (5): SafetyService, StoreProtection, Bool, String, URL

### Community 86 - "ModelPickerView"
Cohesion: 0.24
Nodes (7): ModelPickerView, .byokProviders, .freeSorted, .paidSorted, Int, LLMProvider, String

### Community 87 - "GlobalMemoryServiceTests"
Cohesion: 0.27
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 88 - "MessageModel"
Cohesion: 0.35
Nodes (5): MessageModel, Bool, NarrativeServiceTests, ModelContainer, String

### Community 89 - ".processMessage()"
Cohesion: 0.22
Nodes (8): ChatResult, ChatResult, ModelContext, Bool, Int, ModelContext, String, Void

### Community 90 - "CompanionPersonality"
Cohesion: 0.18
Nodes (11): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, machiavelli (+3 more)

### Community 91 - "CodingKeys"
Cohesion: 0.20
Nodes (10): CodingKey, CodingKeys, architecture, contextLength, id, inputModalities, modality, name (+2 more)

### Community 92 - "VoiceSettingsView"
Cohesion: 0.22
Nodes (9): ElevenLabsTTSEngine, ProviderKeySection, Double, String, VoiceSettingsView, .body, .elevenLabsSection, .openAISection (+1 more)

### Community 93 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 94 - "LLMError"
Cohesion: 0.20
Nodes (10): LLMError, apiError, contextLengthExceeded, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded, noAPIKey (+2 more)

### Community 96 - "VectorStore"
Cohesion: 0.33
Nodes (3): Int, String, VectorStore

### Community 97 - "SessionRow"
Cohesion: 0.29
Nodes (7): ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind

### Community 98 - "XCTestCase"
Cohesion: 0.20
Nodes (4): NarrativeTests, ModelContainer, BackupPayloadTests, XCTestCase

### Community 99 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 100 - ".body"
Cohesion: 0.31
Nodes (6): App, AppRootView, .body, SelfwardApp, .body, Scene

### Community 101 - "CompanionGender"
Cohesion: 0.22
Nodes (9): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+1 more)

### Community 102 - ".sizeThatFits()"
Cohesion: 0.31
Nodes (7): CGSize, FlowLayout, CGFloat, CGRect, Layout, ProposedViewSize, Subviews

### Community 103 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 104 - ".historyTokenBudget()"
Cohesion: 0.28
Nodes (5): AsyncThrowingStream, Bool, Int, String, Void

### Community 105 - ".schedule()"
Cohesion: 0.36
Nodes (4): ReminderScheduler, Int, UNNotificationRequest, UNUserNotificationCenter

### Community 106 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 107 - "api/safety.py"
Cohesion: 0.32
Nodes (7): get_events(), get_safety_service(), get_summary(), AsyncSession, get, SafetyEventResponse, SafetySummaryResponse

### Community 108 - "AutoBackupService.swift"
Cohesion: 0.29
Nodes (6): AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, AvailableAutoBackup, String

### Community 109 - "GlobalMemoryService"
Cohesion: 0.43
Nodes (4): GlobalMemoryService, Int, ModelContext, String

### Community 110 - "String"
Cohesion: 0.43
Nodes (3): Never, String, Task

### Community 112 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 113 - "GlobalMemoryService"
Cohesion: 0.48
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 115 - ".analyzeDream()"
Cohesion: 0.43
Nodes (3): DreamService, ModelContext, String

### Community 117 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

### Community 118 - "test_safety_enforcement.py"
Cohesion: 0.60
Nodes (4): asyncio, test_boundary_response_is_filtered(), test_crisis_resource_message_consistent(), test_negation_is_not_crisis()

### Community 120 - "ModelSource"
Cohesion: 0.67
Nodes (3): ModelSource, curated, huggingFace

## Knowledge Gaps
- **209 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+204 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 603 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `AggregatedGraph`, `Foundation`, `SpeechService`, `DashboardView.swift`, `ChatService`, `Float`, `ChatView`, `InsightCaptureServiceTests`, `ChatServiceStreamingTests`, `.makeInMemoryContainer()`, `EmbeddingService`, `GraphService`, `.ephemeralDefaults()`, `DashboardView`, `NoteModel`, `FakeKeychain`, `PersonaKind`, `.buildIncremental()`, `GraphServiceTests`, `DashboardService`, `.decrypt()`, `ModelPickerView`, `MessageModel`, `.processMessage()`, `SessionRow`, `.analyzeDream()`?**
  _High betweenness centrality (0.095) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `PINService`, `AggregatedGraph`, `SpeechService`, `SessionModel`, `DashboardView.swift`, `LocalModelService`, `OnboardingView.swift`, `NarrativeView`, `Float`, `ChatView`, `Theme`, `SettingsView`, `DashboardView`, `NoteModel`, `.trendSummary()`, `ModelService`, `ModelPickerView`, `VoiceSettingsView`, `SessionRow`, `.body`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `PINService`, `AggregatedGraph`, `SpeechService`, `BackupRestorePlan`, `SessionModel`, `AgentContext`, `Float`, `LocalLLMEngine`, `InsightCaptureServiceTests`, `.models()`, `String`, `Codable`, `AppleFoundationEngine`, `EmbeddingService`, `GraphService`, `NoteModel`, `PersonaKind`, `.buildIncremental()`, `Error`, `Persona`, `DashboardService`, `OpenRouterModel`, `VectorStore`, `AutoBackupService.swift`, `GlobalMemoryService`, `.analyzeDream()`?**
  _High betweenness centrality (0.039) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _209 weakly-connected nodes found - possible documentation gaps or missing edges._