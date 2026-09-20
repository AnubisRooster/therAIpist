# Graph Report - therAIpist  (2026-09-20)

## Corpus Check
- Large corpus: 245 files · ~1,938,085 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2708 nodes · 6689 edges · 142 communities (122 shown, 20 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 653 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- SafetyServiceTests
- AgentContext
- BackupRestorePlan
- AutoBackupService
- schemas.py
- SessionModel
- View
- database.py
- KeychainService
- Base
- ChatMessage
- ConversationCompactorTests
- OnboardingView.swift
- dreams.py
- ChatService
- asyncio
- graphify_pipeline.py
- ChatService
- Float
- .makeInMemoryContainer()
- AgentContext
- LocalLLMEngine
- LocalModelService
- Error
- InsightCaptureServiceTests
- DashboardView.swift
- insights.py
- GraphService
- .buildIncremental()
- vector_store.py
- SelfwardDesktop
- asyncio
- Session
- VoiceConversationController
- notes.py
- Codable
- DreamModel
- AggregatedGraph
- ChatView
- SwiftData
- Foundation
- AppleFoundationEngine
- VoicePickerView
- VoiceTranscriptTests
- LLMError
- EmbeddingService
- .ephemeralDefaults()
- SpiritualTradition
- pytest
- asyncio
- TTSCoordinator
- SwiftUI
- SpeechService
- DashboardView
- Coordinator
- test_dreams.py
- MemoryService
- NoteModel
- GraphService
- String
- PersonaKind
- asyncio
- graph_ui.py
- GraphExportServiceTests
- .classifyHTTPFailure()
- LLMProvider
- NarrativeView
- TestQdrantVectorStore
- SafetyService
- SettingsView
- OpenRouterModel
- String
- Persona
- Theme
- ModelService
- ModelServiceTests
- test_notes.py
- env.py
- sessions.py
- api/voice.py
- DownloadProgressDelegate
- String
- SessionRow
- DashboardService
- OnDeviceModelsStep
- BackupFolderPicker
- GlobalMemoryServiceTests
- LLMSending
- ActiveImaginationTests
- VoiceService
- .processMessage()
- ModelPickerView
- test_auth.py
- mode.py
- CodingKeys
- EncryptedBackupDocument
- CompanionPersonality
- test_graph_ui.py
- test_safety.py
- chat.py
- GlobalMemoryService
- VoiceService
- CompanionGender
- .sizeThatFits()
- CodingKeys
- LocalModelService.swift
- .writePDF()
- ShareSheet
- test_dashboard.py
- test_sessions.py
- therapy.py
- sqlalchemy_ext_asyncio
- QdrantVectorStore
- VoiceSettingsView
- GlobalMemoryService
- .stripMarkdown()
- String
- NodeConnectionsSheet
- XCTestCase
- test_chat.py
- cosine_similarity()
- .narrativeFont()
- NarrativeSettingsSheet
- TherapyService
- NewSessionView
- TestModalityPrompts
- NSObject
- .decode()
- httpx
- Phase
- BackupCrypto.swift
- PackageDescription
- therapist

## God Nodes (most connected - your core abstractions)
1. `SessionModel` - 143 edges
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
  tests/test_therapy.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (142 total, 20 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.06
Nodes (39): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+31 more)

### Community 2 - "SafetyServiceTests"
Cohesion: 0.05
Nodes (28): MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, BackupService, CrisisResources (+20 more)

### Community 3 - "AgentContext"
Cohesion: 0.11
Nodes (25): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+17 more)

### Community 4 - "BackupRestorePlan"
Cohesion: 0.10
Nodes (29): Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot (+21 more)

### Community 5 - "AutoBackupService"
Cohesion: 0.09
Nodes (30): App, AppRootView, .body, RootTabView, SelfwardApp, .body, AutoBackupConfig, AutoBackupService (+22 more)

### Community 6 - "schemas.py"
Cohesion: 0.10
Nodes (47): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+39 more)

### Community 7 - "SessionModel"
Cohesion: 0.10
Nodes (18): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String (+10 more)

### Community 8 - "View"
Cohesion: 0.07
Nodes (39): Actions, AttributedString, AnimatedEmptyState, BadgePill, .body, GradientHeader, PersonaAvatar, RoundedCorner (+31 more)

### Community 9 - "database.py"
Cohesion: 0.07
Nodes (37): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), get_dashboard_service(), get_global_dashboard() (+29 more)

### Community 10 - "KeychainService"
Cohesion: 0.08
Nodes (18): Combine, APIKeyProvider, KeychainService, Bool, Data, String, TTSKeyProvider, .displayName (+10 more)

### Community 11 - "Base"
Cohesion: 0.18
Nodes (17): app_agents, Base, GraphEdge, EpisodicMemory, ProceduralMemory, SemanticMemory, Note, collections (+9 more)

### Community 12 - "ChatMessage"
Cohesion: 0.10
Nodes (20): Settings, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, OllamaProvider, OpenRouterProvider (+12 more)

### Community 13 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (8): ConversationCompactor, StoredState, Date, Int, String, ConversationCompactorTests, Int, String

### Community 14 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 15 - "dreams.py"
Cohesion: 0.11
Nodes (22): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+14 more)

### Community 16 - "ChatService"
Cohesion: 0.09
Nodes (15): get_chat_service(), AsyncSession, Message, SessionCreate, ChatService, AsyncSession, DashboardService, AsyncSession (+7 more)

### Community 17 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 18 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 19 - "ChatService"
Cohesion: 0.16
Nodes (9): ChatService, ChatServiceE2ETests, ModelContainer, ModelContext, String, ChatServiceCompactionTests, ModelContainer, ModelContext (+1 more)

### Community 20 - "Float"
Cohesion: 0.14
Nodes (16): GraphEdgeModel, GraphNodeModel, Float, Int, String, VectorStore, EdgesListView, .body (+8 more)

### Community 21 - ".makeInMemoryContainer()"
Cohesion: 0.09
Nodes (8): GraphServiceTests, InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, TestSupport, StaticString, UInt

### Community 22 - "AgentContext"
Cohesion: 0.15
Nodes (17): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+9 more)

### Community 23 - "LocalLLMEngine"
Cohesion: 0.11
Nodes (17): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, Bool (+9 more)

### Community 24 - "LocalModelService"
Cohesion: 0.16
Nodes (17): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, Bool, Set, .downloadedLocalModels (+9 more)

### Community 25 - "Error"
Cohesion: 0.10
Nodes (12): ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM, AsyncThrowingStream, Int, String (+4 more)

### Community 26 - "InsightCaptureServiceTests"
Cohesion: 0.12
Nodes (7): ModelContext, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 27 - "DashboardView.swift"
Cohesion: 0.14
Nodes (22): Charts, Identifiable, GlobalMemoryModel, MemoryModel, Data, .body, GlobalMemoriesListView, .body (+14 more)

### Community 28 - "insights.py"
Cohesion: 0.16
Nodes (20): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+12 more)

### Community 29 - "GraphService"
Cohesion: 0.13
Nodes (7): GraphNode, GraphService, AsyncSession, AsyncSession, db_session(), graph_service(), fixture

### Community 30 - ".buildIncremental()"
Cohesion: 0.19
Nodes (11): MessageModel, Bool, NarrativeService, Source, Bool, Date, ModelContext, String (+3 more)

### Community 31 - "vector_store.py"
Cohesion: 0.13
Nodes (9): AsyncSession, get_vector_store(), InMemoryVectorStore, ABC, reset_vector_store(), SearchResult, VectorStore, dataclasses (+1 more)

### Community 32 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 33 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 34 - "Session"
Cohesion: 0.23
Nodes (18): Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture, test_get_mode_default(), test_get_mode_not_found() (+10 more)

### Community 35 - "VoiceConversationController"
Cohesion: 0.19
Nodes (9): Bool, TimeInterval, Timer, Void, VoiceConversationController, .silenceInterval, VoiceUtterance, SFSpeechAudioBufferRecognitionRequest (+1 more)

### Community 36 - "notes.py"
Cohesion: 0.14
Nodes (15): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+7 more)

### Community 37 - "Codable"
Cohesion: 0.24
Nodes (19): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+11 more)

### Community 38 - "DreamModel"
Cohesion: 0.15
Nodes (14): DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings, .symbols (+6 more)

### Community 39 - "AggregatedGraph"
Cohesion: 0.22
Nodes (9): AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL, GraphVisualizationSheet (+1 more)

### Community 40 - "ChatView"
Cohesion: 0.14
Nodes (14): ChatView, .hasActiveCrisis, .isBusy, .modelLabel, .persona, Bool, ChatService, Date (+6 more)

### Community 41 - "SwiftData"
Cohesion: 0.21
Nodes (3): Selfward, SwiftData, XCTest

### Community 42 - "Foundation"
Cohesion: 0.11
Nodes (6): BackupKit, Foundation, BadgeBackfillService, NaturalLanguage, BackupPayloadTests, UserNotifications

### Community 43 - "AppleFoundationEngine"
Cohesion: 0.14
Nodes (14): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+6 more)

### Community 44 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 46 - "LLMError"
Cohesion: 0.11
Nodes (17): BYOKLLMKit, AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LLMError, apiError, contextLengthExceeded (+9 more)

### Community 47 - "EmbeddingService"
Cohesion: 0.19
Nodes (10): ClosedRange, EmbeddingService, .isAvailable, Bool, Data, String, MemoryService, ModelContext (+2 more)

### Community 49 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 50 - "pytest"
Cohesion: 0.15
Nodes (15): pytest, pytest_asyncio, cleanup_vector_store(), client(), db_session(), AsyncSession, fixture, db_session() (+7 more)

### Community 51 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 52 - "TTSCoordinator"
Cohesion: 0.19
Nodes (11): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+3 more)

### Community 53 - "SwiftUI"
Cohesion: 0.13
Nodes (14): AVFoundation, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+6 more)

### Community 54 - "SpeechService"
Cohesion: 0.18
Nodes (10): AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, SpeechService, AVSpeechSynthesisVoice, String, TimeInterval, Void (+2 more)

### Community 55 - "DashboardView"
Cohesion: 0.12
Nodes (18): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+10 more)

### Community 56 - "Coordinator"
Cohesion: 0.17
Nodes (12): Coordinator, GraphVisualizationView, Coordinator, String, Void, UIViewRepresentable, WKNavigation, WKNavigationDelegate (+4 more)

### Community 57 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 58 - "MemoryService"
Cohesion: 0.17
Nodes (3): get_memory_service(), AsyncSession, MemoryService

### Community 59 - "NoteModel"
Cohesion: 0.24
Nodes (9): NoteModel, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView, .body (+1 more)

### Community 60 - "GraphService"
Cohesion: 0.30
Nodes (6): EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 61 - "String"
Cohesion: 0.24
Nodes (7): HFModel, HFSibling, HuggingFaceModelService, Data, String, TimeInterval, HuggingFaceCatalogTests

### Community 62 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 63 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 64 - "graph_ui.py"
Cohesion: 0.17
Nodes (11): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphStatsResponse, GraphTimelineResponse (+3 more)

### Community 65 - "GraphExportServiceTests"
Cohesion: 0.29
Nodes (3): GraphExportServiceTests, Int, ModelContainer

### Community 66 - ".classifyHTTPFailure()"
Cohesion: 0.24
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 67 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 68 - "NarrativeView"
Cohesion: 0.17
Nodes (14): NarrativeView, .document, .emptyDescription, .needsRefresh, .preferredCloudProvider, .resolvedLabel, .resolvedTarget, .toolbarItems (+6 more)

### Community 69 - "TestQdrantVectorStore"
Cohesion: 0.19
Nodes (4): asyncio, fixture, TestInMemoryVectorStore, TestQdrantVectorStore

### Community 70 - "SafetyService"
Cohesion: 0.21
Nodes (6): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService, re

### Community 71 - "SettingsView"
Cohesion: 0.22
Nodes (8): Binding, SettingsView, .autoBackupEnabled, .body, Bool, Date, Int, Result

### Community 72 - "OpenRouterModel"
Cohesion: 0.19
Nodes (13): Decoder, Hashable, ModelSource, curated, huggingFace, ModelPricing, ModelsResponse, OpenRouterArchitecture (+5 more)

### Community 73 - "String"
Cohesion: 0.26
Nodes (7): NarrativeDocument, SafetyEventModel, Date, Int, String, TimeInterval, VoiceRecordingModel

### Community 74 - "Persona"
Cohesion: 0.14
Nodes (3): Persona, .displayName, SpiritualPersonaTests

### Community 75 - "Theme"
Cohesion: 0.21
Nodes (9): .body, Color, LinearGradient, String, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament (+1 more)

### Community 76 - "ModelService"
Cohesion: 0.23
Nodes (8): ModelService, .freeModels, .paidModels, Int, String, TimeInterval, .body, ObservableObject

### Community 78 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 79 - "env.py"
Cohesion: 0.17
Nodes (8): alembic, app_models, asyncio, logging_config, do_run_migrations(), run_migrations_online(), sqlalchemy_engine, typing

### Community 80 - "sessions.py"
Cohesion: 0.28
Nodes (12): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+4 more)

### Community 81 - "api/voice.py"
Cohesion: 0.23
Nodes (12): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+4 more)

### Community 82 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (10): Int64, DownloadProgressDelegate, Double, Result, URL, Void, URLSession, URLSessionDownloadDelegate (+2 more)

### Community 83 - "String"
Cohesion: 0.40
Nodes (5): LLMMessage, unsupportedProvider, LLMService, AsyncThrowingStream, String

### Community 84 - "SessionRow"
Cohesion: 0.21
Nodes (10): .body, ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind (+2 more)

### Community 85 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 86 - "OnDeviceModelsStep"
Cohesion: 0.17
Nodes (8): Int, OnDeviceModelsStep, .ramGB, .recommendedID, .recommendedModel, Int, LocalModelServiceCatalogTests, .service

### Community 87 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 88 - "GlobalMemoryServiceTests"
Cohesion: 0.24
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 89 - "LLMSending"
Cohesion: 0.20
Nodes (6): AsyncThrowingStream, Bool, Int, String, Void, LLMSending

### Community 91 - "VoiceService"
Cohesion: 0.29
Nodes (5): VoiceRecording, get_stt_provider(), AsyncSession, VoiceService, settings

### Community 92 - ".processMessage()"
Cohesion: 0.22
Nodes (8): ChatResult, ChatResult, ModelContext, Bool, Int, ModelContext, String, Void

### Community 93 - "ModelPickerView"
Cohesion: 0.27
Nodes (6): ModelPickerView, .freeSorted, .paidSorted, Int, LLMProvider, String

### Community 94 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 95 - "mode.py"
Cohesion: 0.24
Nodes (9): get_mode(), get_mode_service(), AsyncSession, get, patch, set_mode(), ModeResponse, ModeSetRequest (+1 more)

### Community 96 - "CodingKeys"
Cohesion: 0.20
Nodes (10): CodingKey, CodingKeys, architecture, contextLength, id, inputModalities, modality, name (+2 more)

### Community 97 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 98 - "CompanionPersonality"
Cohesion: 0.20
Nodes (10): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, playful (+2 more)

### Community 99 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 100 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 101 - "chat.py"
Cohesion: 0.33
Nodes (8): chat(), get_chat_history(), AsyncSession, get, post, ChatRequest, ChatResponse, MessageResponse

### Community 102 - "GlobalMemoryService"
Cohesion: 0.36
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 103 - "VoiceService"
Cohesion: 0.33
Nodes (5): AVAudioRecorder, ModelContext, String, URL, VoiceService

### Community 104 - "CompanionGender"
Cohesion: 0.22
Nodes (9): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+1 more)

### Community 105 - ".sizeThatFits()"
Cohesion: 0.31
Nodes (7): CGSize, FlowLayout, CGFloat, CGRect, Layout, ProposedViewSize, Subviews

### Community 106 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 107 - "LocalModelService.swift"
Cohesion: 0.22
Nodes (8): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3

### Community 108 - ".writePDF()"
Cohesion: 0.36
Nodes (4): NarrativeExportService, String, URL, NSParagraphStyle

### Community 109 - "ShareSheet"
Cohesion: 0.28
Nodes (6): ShareSheet, Any, Context, .body, UIActivityViewController, UIViewControllerRepresentable

### Community 110 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 111 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 112 - "therapy.py"
Cohesion: 0.36
Nodes (7): get_progress(), get_therapy_service(), AsyncSession, get, suggest_intervention(), InterventionSuggestionResponse, ProgressResponse

### Community 113 - "sqlalchemy_ext_asyncio"
Cohesion: 0.68
Nodes (3): app_services_providers, get_provider(), sqlalchemy_ext_asyncio

### Community 115 - "VoiceSettingsView"
Cohesion: 0.29
Nodes (7): ElevenLabsTTSEngine, Double, String, VoiceSettingsView, .body, .elevenLabsSection, .onDeviceSection

### Community 116 - "GlobalMemoryService"
Cohesion: 0.43
Nodes (4): GlobalMemoryService, Int, ModelContext, String

### Community 118 - "String"
Cohesion: 0.43
Nodes (3): Never, String, Task

### Community 119 - "NodeConnectionsSheet"
Cohesion: 0.32
Nodes (6): Connection, NodeConnectionsSheet, .body, .connections, Int, WebKit

### Community 120 - "XCTestCase"
Cohesion: 0.25
Nodes (3): NarrativeTests, ModelContainer, XCTestCase

### Community 121 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 123 - ".narrativeFont()"
Cohesion: 0.33
Nodes (5): Font, .body, .body, CGFloat, .emptyState

### Community 124 - "NarrativeSettingsSheet"
Cohesion: 0.29
Nodes (5): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, UIKit

### Community 126 - "NewSessionView"
Cohesion: 0.33
Nodes (5): NewSessionView, .body, .defaultProviderLabel, .personaName, String

### Community 128 - "NSObject"
Cohesion: 0.33
Nodes (4): XMLParserRecorder, NSObject, XMLParser, XMLParserDelegate

### Community 130 - "httpx"
Cohesion: 0.40
Nodes (4): httpx, AsyncClient, asyncio, test_health_endpoint()

### Community 131 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **208 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+203 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 601 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **20 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `SafetyServiceTests`, `AutoBackupService`, `ChatService`, `Float`, `.makeInMemoryContainer()`, `Error`, `InsightCaptureServiceTests`, `DashboardView.swift`, `.buildIncremental()`, `DreamModel`, `AggregatedGraph`, `ChatView`, `EmbeddingService`, `.ephemeralDefaults()`, `DashboardView`, `NoteModel`, `GraphService`, `PersonaKind`, `GraphExportServiceTests`, `String`, `SessionRow`, `DashboardService`, `.processMessage()`, `ModelPickerView`, `VoiceService`, `NewSessionView`?**
  _High betweenness centrality (0.086) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `PINService`, `SafetyServiceTests`, `AutoBackupService`, `SessionModel`, `OnboardingView.swift`, `Float`, `LocalModelService`, `DashboardView.swift`, `DreamModel`, `AggregatedGraph`, `ChatView`, `VoicePickerView`, `SwiftUI`, `SpeechService`, `DashboardView`, `NoteModel`, `NarrativeView`, `SettingsView`, `SessionRow`, `OnDeviceModelsStep`, `ModelPickerView`, `VoiceSettingsView`, `NodeConnectionsSheet`, `NarrativeSettingsSheet`, `NewSessionView`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `NSObject`, `PINService`, `BackupCrypto.swift`, `BackupRestorePlan`, `SessionModel`, `KeychainService`, `Float`, `AgentContext`, `LocalLLMEngine`, `InsightCaptureServiceTests`, `.buildIncremental()`, `Codable`, `DreamModel`, `AggregatedGraph`, `AppleFoundationEngine`, `LLMError`, `SwiftUI`, `NoteModel`, `GraphService`, `PersonaKind`, `OpenRouterModel`, `String`, `DashboardService`, `VoiceService`, `LocalModelService.swift`, `GlobalMemoryService`, `TherapyService`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 43 INFERRED edges - model-reasoned connections that need verification._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _208 weakly-connected nodes found - possible documentation gaps or missing edges._