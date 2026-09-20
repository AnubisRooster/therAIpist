# Graph Report - therAIpist  (2026-09-20)

## Corpus Check
- Large corpus: 245 files · ~1,941,110 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2712 nodes · 6703 edges · 130 communities (111 shown, 19 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 657 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- SafetyServiceTests
- AgentContext
- AutoBackupService
- BackupRestorePlan
- Base
- InMemoryVectorStore
- SessionModel
- sqlalchemy_ext_asyncio
- ChatMessage
- KeychainService
- ConversationCompactorTests
- OnboardingView.swift
- ChatService
- dreams.py
- asyncio
- MemoryService
- graphify_pipeline.py
- OpenRouterModel
- schemas.py
- GraphService
- ChatView
- AgentContext
- DashboardView.swift
- Float
- LocalLLMEngine
- LocalModelService
- View
- .buildIncremental()
- pytest
- InsightCaptureServiceTests
- NarrativeView
- Coordinator
- ChatService
- api/graph.py
- notes.py
- SelfwardDesktop
- ChatServiceStreamingTests
- asyncio
- TTSCoordinator
- TherapyService
- Codable
- DreamModel
- SwiftData
- VoiceConversationController
- VoicePickerView
- AggregatedGraph
- .makeInMemoryContainer()
- VoiceTranscriptTests
- insights.py
- Foundation
- SettingsView.swift
- String
- SpiritualTradition
- MockLLM
- asyncio
- SafetyService
- VoiceService
- GraphNodeModel
- DashboardView
- ChatServiceCompactionTests
- test_dreams.py
- Theme
- NarrativeDocument
- NoteModel
- String
- PersonaKind
- XCTestCase
- asyncio
- SwiftUI
- SpeechService
- String
- .classifyHTTPFailure()
- LLMProvider
- .ephemeralDefaults()
- SettingsView
- OnDeviceModelsStep
- ActiveImaginationTests
- ModelServiceTests
- test_notes.py
- env.py
- graph_ui.py
- AppleFoundationEngine
- DownloadProgressDelegate
- SessionRow
- DashboardService
- .graphML()
- Persona
- BackupFolderPicker
- GlobalMemoryServiceTests
- MemoryService
- Error
- LocalModelService.swift
- SpiritualPersonaTests
- test_auth.py
- mode.py
- CodingKeys
- EncryptedBackupDocument
- LLMError
- CompanionPersonality
- test_graph_ui.py
- test_safety.py
- GlobalMemoryService
- CompanionGender
- .sizeThatFits()
- CodingKeys
- .classify()
- EmbeddingService
- String
- InsightServiceTests
- test_dashboard.py
- test_sessions.py
- VoiceService
- .stripMarkdown()
- test_chat.py
- NewSessionView
- TestModalityPrompts
- .decode()
- Phase
- .speechSynthesizer()
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
- `provider()` --uses--> `Settings`  [INFERRED]
  tests/test_providers/test_ollama.py → app/core/config.py
- `provider()` --uses--> `Settings`  [INFERRED]
  tests/test_providers/test_openrouter.py → app/core/config.py
- `TestQdrantVectorStore` --uses--> `Settings`  [INFERRED]
  tests/test_vector_store.py → app/core/config.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/conftest.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_therapy.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (130 total, 19 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.05
Nodes (40): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+32 more)

### Community 2 - "SafetyServiceTests"
Cohesion: 0.05
Nodes (28): MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, BackupService, CrisisResources (+20 more)

### Community 3 - "AgentContext"
Cohesion: 0.10
Nodes (28): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+20 more)

### Community 4 - "AutoBackupService"
Cohesion: 0.07
Nodes (35): App, AppRootView, .body, RootTabView, SelfwardApp, .body, AutoBackupConfig, AutoBackupError (+27 more)

### Community 5 - "BackupRestorePlan"
Cohesion: 0.10
Nodes (29): Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot (+21 more)

### Community 6 - "Base"
Cohesion: 0.14
Nodes (24): app_agents, Base, Message, GraphEdge, GraphNode, EpisodicMemory, ProceduralMemory, SemanticMemory (+16 more)

### Community 7 - "InMemoryVectorStore"
Cohesion: 0.06
Nodes (13): AsyncSession, cosine_similarity(), InMemoryVectorStore, ABC, QdrantVectorStore, SearchResult, VectorStore, Response (+5 more)

### Community 8 - "SessionModel"
Cohesion: 0.10
Nodes (18): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String (+10 more)

### Community 9 - "sqlalchemy_ext_asyncio"
Cohesion: 0.10
Nodes (29): get_agent_service(), AsyncSession, post, route_message(), create_session(), delete_session(), get_session(), list_sessions() (+21 more)

### Community 10 - "ChatMessage"
Cohesion: 0.10
Nodes (22): health_check(), get, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, get_provider() (+14 more)

### Community 11 - "KeychainService"
Cohesion: 0.09
Nodes (17): Combine, APIKeyProvider, KeychainService, Bool, Data, String, TTSKeyProvider, .displayName (+9 more)

### Community 12 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (8): ConversationCompactor, StoredState, Date, Int, String, ConversationCompactorTests, Int, String

### Community 13 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 14 - "ChatService"
Cohesion: 0.12
Nodes (24): get_chat_service(), AsyncSession, SessionCreate, Session, ChatService, AsyncSession, ModeService, AsyncSession (+16 more)

### Community 15 - "dreams.py"
Cohesion: 0.11
Nodes (22): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+14 more)

### Community 16 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 17 - "MemoryService"
Cohesion: 0.11
Nodes (20): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+12 more)

### Community 18 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 19 - "OpenRouterModel"
Cohesion: 0.11
Nodes (24): Decoder, Hashable, ModelPricing, ModelService, .freeModels, .paidModels, ModelsResponse, OpenRouterArchitecture (+16 more)

### Community 20 - "schemas.py"
Cohesion: 0.11
Nodes (33): chat(), get_chat_history(), AsyncSession, get, post, AgentResponse, AgentRouteResponse, ChatRequest (+25 more)

### Community 21 - "GraphService"
Cohesion: 0.09
Nodes (12): GraphService, AsyncSession, InsightService, dfs(), AsyncSession, graph_service(), insight_service(), fixture (+4 more)

### Community 22 - "ChatView"
Cohesion: 0.09
Nodes (26): CapturedBadgeRow, .body, ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona (+18 more)

### Community 23 - "AgentContext"
Cohesion: 0.15
Nodes (17): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+9 more)

### Community 24 - "DashboardView.swift"
Cohesion: 0.12
Nodes (23): Charts, GlobalMemoryModel, GlobalMemoryService, Int, ModelContext, String, .body, GlobalMemoriesListView (+15 more)

### Community 25 - "Float"
Cohesion: 0.12
Nodes (12): MemoryModel, SafetyEventModel, Data, Date, Int, String, TimeInterval, VoiceRecordingModel (+4 more)

### Community 26 - "LocalLLMEngine"
Cohesion: 0.12
Nodes (17): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, Bool (+9 more)

### Community 27 - "LocalModelService"
Cohesion: 0.16
Nodes (17): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, Bool, Set, .downloadedLocalModels (+9 more)

### Community 28 - "View"
Cohesion: 0.12
Nodes (22): Actions, AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, .body, PersonaAvatar (+14 more)

### Community 29 - ".buildIncremental()"
Cohesion: 0.17
Nodes (12): MessageModel, Bool, LLMSending, NarrativeService, Source, Bool, Date, ModelContext (+4 more)

### Community 30 - "pytest"
Cohesion: 0.12
Nodes (19): Settings, get_vector_store(), reset_vector_store(), BaseSettings, httpx, math, pytest, cleanup_vector_store() (+11 more)

### Community 31 - "InsightCaptureServiceTests"
Cohesion: 0.14
Nodes (7): ModelContext, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 32 - "NarrativeView"
Cohesion: 0.11
Nodes (21): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+13 more)

### Community 33 - "Coordinator"
Cohesion: 0.12
Nodes (17): Coordinator, GraphVisualizationView, ShareSheet, Any, Context, Coordinator, String, Void (+9 more)

### Community 34 - "ChatService"
Cohesion: 0.13
Nodes (14): ChatResult, ChatService, AsyncThrowingStream, Bool, ChatResult, Int, ModelContext, String (+6 more)

### Community 35 - "api/graph.py"
Cohesion: 0.14
Nodes (23): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+15 more)

### Community 36 - "notes.py"
Cohesion: 0.14
Nodes (14): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+6 more)

### Community 37 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 38 - "ChatServiceStreamingTests"
Cohesion: 0.13
Nodes (7): ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM, AsyncThrowingStream, String

### Community 39 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 40 - "TTSCoordinator"
Cohesion: 0.15
Nodes (14): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+6 more)

### Community 41 - "TherapyService"
Cohesion: 0.11
Nodes (14): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), AsyncSession, get, get_progress(), get_therapy_service(), AsyncSession (+6 more)

### Community 42 - "Codable"
Cohesion: 0.24
Nodes (20): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+12 more)

### Community 43 - "DreamModel"
Cohesion: 0.15
Nodes (14): DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings, .symbols (+6 more)

### Community 44 - "SwiftData"
Cohesion: 0.20
Nodes (3): Selfward, SwiftData, XCTest

### Community 45 - "VoiceConversationController"
Cohesion: 0.20
Nodes (8): Bool, TimeInterval, Timer, Void, VoiceConversationController, .silenceInterval, SFSpeechAudioBufferRecognitionRequest, SFSpeechRecognitionTask

### Community 46 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 47 - "AggregatedGraph"
Cohesion: 0.20
Nodes (13): Identifiable, AggregatedEdge, AggregatedGraph, AggregatedNode, Int, Connection, GraphVisualizationSheet, .body (+5 more)

### Community 48 - ".makeInMemoryContainer()"
Cohesion: 0.25
Nodes (6): GraphExportServiceTests, Int, ModelContainer, ModelContainer, StaticString, UInt

### Community 50 - "insights.py"
Cohesion: 0.20
Nodes (18): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+10 more)

### Community 51 - "Foundation"
Cohesion: 0.12
Nodes (5): BackupKit, Foundation, BadgeBackfillService, BackupPayloadTests, UserNotifications

### Community 52 - "SettingsView.swift"
Cohesion: 0.12
Nodes (17): ElevenLabsTTSEngine, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+9 more)

### Community 53 - "String"
Cohesion: 0.22
Nodes (11): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+3 more)

### Community 54 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 55 - "MockLLM"
Cohesion: 0.21
Nodes (6): ChatServiceE2ETests, ModelContainer, ModelContext, String, MockLLM, Int

### Community 56 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 57 - "SafetyService"
Cohesion: 0.16
Nodes (10): get_events(), get_safety_service(), get_summary(), AsyncSession, get, SafetyEvent, _is_negated(), AsyncSession (+2 more)

### Community 58 - "VoiceService"
Cohesion: 0.16
Nodes (13): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+5 more)

### Community 59 - "GraphNodeModel"
Cohesion: 0.30
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 60 - "DashboardView"
Cohesion: 0.12
Nodes (18): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+10 more)

### Community 61 - "ChatServiceCompactionTests"
Cohesion: 0.20
Nodes (3): ChatServiceCompactionTests, ModelContainer, ModelContext

### Community 62 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 63 - "Theme"
Cohesion: 0.18
Nodes (11): Font, .body, CGFloat, Color, LinearGradient, String, Theme, .narrativeBackground (+3 more)

### Community 64 - "NarrativeDocument"
Cohesion: 0.19
Nodes (7): NarrativeDocument, NarrativeExportService, String, URL, NarrativeTests, ModelContainer, NSParagraphStyle

### Community 65 - "NoteModel"
Cohesion: 0.24
Nodes (9): NoteModel, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView, .body (+1 more)

### Community 66 - "String"
Cohesion: 0.24
Nodes (7): HFModel, HFSibling, HuggingFaceModelService, Data, String, TimeInterval, HuggingFaceCatalogTests

### Community 67 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 68 - "XCTestCase"
Cohesion: 0.12
Nodes (3): GraphServiceTests, MemoryServiceTests, XCTestCase

### Community 69 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 70 - "SwiftUI"
Cohesion: 0.15
Nodes (8): AttributedString, AVFoundation, MarkdownText, .attributed, .body, String, Speech, SwiftUI

### Community 71 - "SpeechService"
Cohesion: 0.22
Nodes (9): AVSpeechSynthesizerDelegate, SpeechService, AVSpeechSynthesisVoice, String, TimeInterval, Void, PersonasSettingsView, .body (+1 more)

### Community 72 - "String"
Cohesion: 0.28
Nodes (6): BYOKLLMKit, unsupportedProvider, LLMService, LLMStreaming, AsyncThrowingStream, String

### Community 73 - ".classifyHTTPFailure()"
Cohesion: 0.24
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 74 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 76 - "SettingsView"
Cohesion: 0.22
Nodes (8): Binding, SettingsView, .autoBackupEnabled, .body, Bool, Date, Int, Result

### Community 77 - "OnDeviceModelsStep"
Cohesion: 0.15
Nodes (8): Int, OnDeviceModelsStep, .ramGB, .recommendedID, .recommendedModel, Int, LocalModelServiceCatalogTests, .service

### Community 80 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 81 - "env.py"
Cohesion: 0.17
Nodes (8): alembic, app_models, asyncio, logging_config, do_run_migrations(), run_migrations_online(), sqlalchemy_engine, typing

### Community 82 - "graph_ui.py"
Cohesion: 0.23
Nodes (8): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphUIService, AsyncSession

### Community 83 - "AppleFoundationEngine"
Cohesion: 0.21
Nodes (11): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+3 more)

### Community 84 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (10): Int64, DownloadProgressDelegate, Double, Result, URL, Void, URLSession, URLSessionDownloadDelegate (+2 more)

### Community 85 - "SessionRow"
Cohesion: 0.21
Nodes (10): .body, ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind (+2 more)

### Community 86 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 87 - ".graphML()"
Cohesion: 0.28
Nodes (3): GraphExportService, String, URL

### Community 88 - "Persona"
Cohesion: 0.23
Nodes (4): Persona, .displayName, String, TherapyService

### Community 89 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 90 - "GlobalMemoryServiceTests"
Cohesion: 0.24
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 91 - "MemoryService"
Cohesion: 0.33
Nodes (5): ClosedRange, String, MemoryService, ModelContext, String

### Community 92 - "Error"
Cohesion: 0.18
Nodes (10): CommonCrypto, CryptoKit, XMLParserRecorder, NSObject, Error, keyDerivationFailed, malformed, sealFailed (+2 more)

### Community 93 - "LocalModelService.swift"
Cohesion: 0.17
Nodes (11): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3 (+3 more)

### Community 95 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 96 - "mode.py"
Cohesion: 0.24
Nodes (9): get_mode(), get_mode_service(), AsyncSession, get, patch, set_mode(), ModeResponse, ModeSetRequest (+1 more)

### Community 97 - "CodingKeys"
Cohesion: 0.20
Nodes (10): CodingKey, CodingKeys, architecture, contextLength, id, inputModalities, modality, name (+2 more)

### Community 98 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 99 - "LLMError"
Cohesion: 0.20
Nodes (10): LLMError, apiError, contextLengthExceeded, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded, noAPIKey (+2 more)

### Community 100 - "CompanionPersonality"
Cohesion: 0.20
Nodes (10): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, playful (+2 more)

### Community 101 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 102 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 103 - "GlobalMemoryService"
Cohesion: 0.36
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 104 - "CompanionGender"
Cohesion: 0.22
Nodes (9): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+1 more)

### Community 105 - ".sizeThatFits()"
Cohesion: 0.31
Nodes (7): CGSize, FlowLayout, CGFloat, CGRect, Layout, ProposedViewSize, Subviews

### Community 106 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 107 - ".classify()"
Cohesion: 0.36
Nodes (4): LanguageModelSession, AppleFoundationErrorMappingTests, LanguageModelSession, String

### Community 108 - "EmbeddingService"
Cohesion: 0.28
Nodes (6): EmbeddingService, .isAvailable, Bool, Data, NaturalLanguage, NLEmbedding

### Community 109 - "String"
Cohesion: 0.36
Nodes (4): Never, String, Task, VoiceUtterance

### Community 111 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 112 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 113 - "VoiceService"
Cohesion: 0.39
Nodes (5): AVAudioRecorder, ModelContext, String, URL, VoiceService

### Community 115 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 116 - "NewSessionView"
Cohesion: 0.33
Nodes (5): NewSessionView, .body, .defaultProviderLabel, .personaName, String

### Community 119 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **208 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+203 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 601 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **19 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `SafetyServiceTests`, `AutoBackupService`, `OpenRouterModel`, `ChatView`, `DashboardView.swift`, `Float`, `.buildIncremental()`, `InsightCaptureServiceTests`, `ChatService`, `ChatServiceStreamingTests`, `DreamModel`, `AggregatedGraph`, `.makeInMemoryContainer()`, `String`, `MockLLM`, `GraphNodeModel`, `DashboardView`, `ChatServiceCompactionTests`, `NoteModel`, `PersonaKind`, `XCTestCase`, `.ephemeralDefaults()`, `SessionRow`, `DashboardService`, `MemoryService`, `InsightServiceTests`, `VoiceService`, `NewSessionView`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `PINService`, `SafetyServiceTests`, `AutoBackupService`, `SessionModel`, `OnboardingView.swift`, `OpenRouterModel`, `ChatView`, `DashboardView.swift`, `LocalModelService`, `NarrativeView`, `DreamModel`, `VoicePickerView`, `AggregatedGraph`, `SettingsView.swift`, `String`, `DashboardView`, `NoteModel`, `SwiftUI`, `SpeechService`, `SettingsView`, `OnDeviceModelsStep`, `SessionRow`, `NewSessionView`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `PINService`, `AutoBackupService`, `BackupRestorePlan`, `SessionModel`, `KeychainService`, `OpenRouterModel`, `AgentContext`, `DashboardView.swift`, `Float`, `LocalLLMEngine`, `InsightCaptureServiceTests`, `Codable`, `DreamModel`, `SwiftData`, `AggregatedGraph`, `GraphNodeModel`, `NoteModel`, `PersonaKind`, `SwiftUI`, `String`, `AppleFoundationEngine`, `DashboardService`, `Persona`, `Error`, `LocalModelService.swift`, `EmbeddingService`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 43 INFERRED edges - model-reasoned connections that need verification._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _208 weakly-connected nodes found - possible documentation gaps or missing edges._