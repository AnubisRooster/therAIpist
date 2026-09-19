# Graph Report - therAIpist  (2026-09-19)

## Corpus Check
- Large corpus: 245 files · ~1,936,014 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2696 nodes · 6647 edges · 139 communities (118 shown, 21 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 645 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- Float
- AgentContext
- BackupRestorePlan
- AutoBackupService
- OpenRouterModel
- sqlalchemy_ext_asyncio
- SessionModel
- database.py
- KeychainService
- LocalModelService
- schemas.py
- OnboardingView.swift
- Base
- ConversationCompactorTests
- dreams.py
- asyncio
- graphify_pipeline.py
- XCTestCase
- View
- DashboardView.swift
- insights.py
- ChatService
- ChatService
- VoiceConversationController
- SettingsView
- .buildIncremental()
- pytest
- GraphService
- MemoryService
- Session
- vector_store.py
- SelfwardDesktop
- InsightCaptureServiceTests
- LocalLLMEngine
- asyncio
- TTSCoordinator
- NarrativeView
- notes.py
- NoteModel
- AggregatedGraph
- .makeInMemoryContainer()
- AppleFoundationEngine
- ChatView
- api/memory.py
- VoicePickerView
- LLMProvider
- CompanionPersonality
- Codable
- SafetyServiceTests
- VoiceTranscriptTests
- XCTest
- Theme
- Foundation
- String
- .ephemeralDefaults()
- SpiritualTradition
- Coordinator
- asyncio
- GraphNodeModel
- DashboardView
- test_dreams.py
- TherapyService
- DreamModel
- .models()
- asyncio
- graph_ui.py
- SpeechService
- GraphExportServiceTests
- .classifyHTTPFailure()
- MockLLM
- TestQdrantVectorStore
- SafetyService
- MoodEntryModel
- String
- VoiceStatusBar
- Persona
- ActiveImaginationTests
- test_notes.py
- env.py
- api/voice.py
- DownloadProgressDelegate
- String
- SessionRow
- .decrypt()
- BackupFolderPicker
- ChatServiceCompactionTests
- GlobalMemoryServiceTests
- LocalModelService.swift
- PersonaKind
- String
- VoiceService
- LocalLLMError
- SpiritualPersonaTests
- test_auth.py
- EncryptedBackupDocument
- NarrativeDocument
- LLMError
- GraphServiceTests
- test_graph_ui.py
- test_safety.py
- chat.py
- GlobalMemoryService
- .sizeThatFits()
- CodingKeys
- ShareSheet
- test_dashboard.py
- test_sessions.py
- QdrantVectorStore
- VoiceService
- SafetyService.swift
- Identifiable
- RoundedCorner
- .schedule()
- .stripMarkdown()
- test_chat.py
- cosine_similarity()
- MarkdownText
- SwiftUI
- VoiceSettingsView
- GlobalMemoryService
- NewSessionView
- NarrativeTests
- TestModalityPrompts
- NSObject
- httpx
- Phase
- .speechSynthesizer()
- NarrativeView.swift
- PackageDescription
- therapist

## God Nodes (most connected - your core abstractions)
1. `SessionModel` - 143 edges
2. `GraphService` - 46 edges
3. `LocalModelService` - 46 edges
4. `AgentContext` - 44 edges
5. `ChatService` - 44 edges
6. `SwiftData` - 39 edges
7. `Base` - 37 edges
8. `ChatService` - 35 edges
9. `MemoryService` - 34 edges
10. `MockLLM` - 34 edges

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

## Communities (139 total, 21 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.06
Nodes (39): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+31 more)

### Community 2 - "Float"
Cohesion: 0.06
Nodes (38): ClosedRange, AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent (+30 more)

### Community 3 - "AgentContext"
Cohesion: 0.11
Nodes (25): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+17 more)

### Community 4 - "BackupRestorePlan"
Cohesion: 0.10
Nodes (29): Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot (+21 more)

### Community 5 - "AutoBackupService"
Cohesion: 0.09
Nodes (30): App, AppRootView, .body, RootTabView, SelfwardApp, .body, AutoBackupConfig, AutoBackupService (+22 more)

### Community 6 - "OpenRouterModel"
Cohesion: 0.06
Nodes (30): CodingKey, Decoder, Hashable, CodingKeys, architecture, contextLength, id, inputModalities (+22 more)

### Community 7 - "sqlalchemy_ext_asyncio"
Cohesion: 0.11
Nodes (22): Settings, app_services_providers, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, get_provider() (+14 more)

### Community 8 - "SessionModel"
Cohesion: 0.10
Nodes (18): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String (+10 more)

### Community 9 - "database.py"
Cohesion: 0.07
Nodes (37): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), get_dashboard_service(), get_global_dashboard() (+29 more)

### Community 10 - "KeychainService"
Cohesion: 0.09
Nodes (17): Combine, APIKeyProvider, KeychainService, Bool, Data, String, TTSKeyProvider, .displayName (+9 more)

### Community 11 - "LocalModelService"
Cohesion: 0.11
Nodes (25): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, Bool, Set, String (+17 more)

### Community 12 - "schemas.py"
Cohesion: 0.11
Nodes (39): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+31 more)

### Community 13 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 14 - "Base"
Cohesion: 0.18
Nodes (14): app_agents, Base, Message, GraphEdge, Note, DashboardService, AsyncSession, collections (+6 more)

### Community 15 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (8): ConversationCompactor, StoredState, Date, Int, String, ConversationCompactorTests, Int, String

### Community 16 - "dreams.py"
Cohesion: 0.11
Nodes (22): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+14 more)

### Community 17 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 18 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 19 - "XCTestCase"
Cohesion: 0.09
Nodes (14): CommonCrypto, CryptoKit, ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM, AsyncThrowingStream (+6 more)

### Community 20 - "View"
Cohesion: 0.12
Nodes (23): Actions, AnimatedEmptyState, .body, BadgePill, .body, GradientHeader, PersonaAvatar, Bool (+15 more)

### Community 21 - "DashboardView.swift"
Cohesion: 0.12
Nodes (24): Charts, GlobalMemoryModel, MemoryModel, Data, .body, FlowTagView, .body, GlobalMemoriesListView (+16 more)

### Community 22 - "insights.py"
Cohesion: 0.14
Nodes (21): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+13 more)

### Community 23 - "ChatService"
Cohesion: 0.14
Nodes (18): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+10 more)

### Community 24 - "ChatService"
Cohesion: 0.13
Nodes (15): ChatResult, ChatService, AsyncThrowingStream, Bool, ChatResult, Int, ModelContext, String (+7 more)

### Community 25 - "VoiceConversationController"
Cohesion: 0.17
Nodes (12): Bool, Never, String, Task, TimeInterval, Timer, Void, VoiceConversationController (+4 more)

### Community 26 - "SettingsView"
Cohesion: 0.12
Nodes (19): Binding, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+11 more)

### Community 27 - ".buildIncremental()"
Cohesion: 0.20
Nodes (11): MessageModel, Bool, NarrativeService, Source, Bool, Date, ModelContext, String (+3 more)

### Community 28 - "pytest"
Cohesion: 0.12
Nodes (20): pytest, pytest_asyncio, cleanup_vector_store(), client(), db_session(), AsyncSession, fixture, db_session() (+12 more)

### Community 29 - "GraphService"
Cohesion: 0.14
Nodes (6): GraphNode, GraphService, AsyncSession, db_session(), graph_service(), fixture

### Community 30 - "MemoryService"
Cohesion: 0.16
Nodes (7): EpisodicMemory, ProceduralMemory, SemanticMemory, MemoryService, db_session(), memory_service(), fixture

### Community 31 - "Session"
Cohesion: 0.21
Nodes (18): Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture, test_get_mode_default(), test_get_mode_not_found() (+10 more)

### Community 32 - "vector_store.py"
Cohesion: 0.13
Nodes (9): AsyncSession, get_vector_store(), InMemoryVectorStore, ABC, reset_vector_store(), SearchResult, VectorStore, dataclasses (+1 more)

### Community 33 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 34 - "InsightCaptureServiceTests"
Cohesion: 0.14
Nodes (6): DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 35 - "LocalLLMEngine"
Cohesion: 0.14
Nodes (11): LocalLLMEngine, Int, Never, String, Task, URL, Void, LocalLLMEngineTests (+3 more)

### Community 36 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 37 - "TTSCoordinator"
Cohesion: 0.15
Nodes (14): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+6 more)

### Community 38 - "NarrativeView"
Cohesion: 0.13
Nodes (20): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+12 more)

### Community 39 - "notes.py"
Cohesion: 0.14
Nodes (15): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+7 more)

### Community 40 - "NoteModel"
Cohesion: 0.18
Nodes (11): NoteModel, BadgeBackfillService, ModelContext, NoteService, ModelContext, String, NoteDetailView, .body (+3 more)

### Community 41 - "AggregatedGraph"
Cohesion: 0.22
Nodes (9): AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL, GraphVisualizationSheet (+1 more)

### Community 42 - ".makeInMemoryContainer()"
Cohesion: 0.15
Nodes (7): InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, TestSupport, StaticString, UInt

### Community 43 - "AppleFoundationEngine"
Cohesion: 0.14
Nodes (14): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+6 more)

### Community 44 - "ChatView"
Cohesion: 0.15
Nodes (11): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, Bool, Date (+3 more)

### Community 45 - "api/memory.py"
Cohesion: 0.18
Nodes (19): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+11 more)

### Community 46 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 47 - "LLMProvider"
Cohesion: 0.10
Nodes (18): BYOKLLMKit, LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq (+10 more)

### Community 48 - "CompanionPersonality"
Cohesion: 0.11
Nodes (19): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+11 more)

### Community 49 - "Codable"
Cohesion: 0.27
Nodes (18): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+10 more)

### Community 50 - "SafetyServiceTests"
Cohesion: 0.12
Nodes (3): CrisisResources, Resource, SafetyServiceTests

### Community 53 - "Theme"
Cohesion: 0.15
Nodes (12): Font, .body, .body, CGFloat, Color, LinearGradient, String, Theme (+4 more)

### Community 54 - "Foundation"
Cohesion: 0.19
Nodes (3): Foundation, Security, SwiftData

### Community 55 - "String"
Cohesion: 0.22
Nodes (11): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+3 more)

### Community 56 - ".ephemeralDefaults()"
Cohesion: 0.24
Nodes (3): PersonaService, UserDefaults, PersonaTests

### Community 57 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 58 - "Coordinator"
Cohesion: 0.16
Nodes (12): Coordinator, GraphVisualizationView, Coordinator, String, Void, UIViewRepresentable, WKNavigation, WKNavigationDelegate (+4 more)

### Community 59 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 60 - "GraphNodeModel"
Cohesion: 0.30
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 61 - "DashboardView"
Cohesion: 0.12
Nodes (18): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+10 more)

### Community 62 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 63 - "TherapyService"
Cohesion: 0.18
Nodes (9): get_progress(), get_therapy_service(), AsyncSession, get, suggest_intervention(), InterventionSuggestionResponse, ProgressResponse, AsyncSession (+1 more)

### Community 64 - "DreamModel"
Cohesion: 0.21
Nodes (11): DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings, .symbols (+3 more)

### Community 65 - ".models()"
Cohesion: 0.19
Nodes (7): HFModel, HFSibling, HuggingFaceModelService, Data, Int, TimeInterval, HuggingFaceCatalogTests

### Community 66 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 67 - "graph_ui.py"
Cohesion: 0.17
Nodes (11): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphStatsResponse, GraphTimelineResponse (+3 more)

### Community 68 - "SpeechService"
Cohesion: 0.22
Nodes (9): AVSpeechSynthesizerDelegate, SpeechService, AVSpeechSynthesisVoice, String, TimeInterval, Void, PersonasSettingsView, .body (+1 more)

### Community 69 - "GraphExportServiceTests"
Cohesion: 0.29
Nodes (3): GraphExportServiceTests, Int, ModelContainer

### Community 70 - ".classifyHTTPFailure()"
Cohesion: 0.24
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 71 - "MockLLM"
Cohesion: 0.27
Nodes (5): ChatServiceE2ETests, ModelContainer, ModelContext, String, MockLLM

### Community 72 - "TestQdrantVectorStore"
Cohesion: 0.19
Nodes (4): asyncio, fixture, TestInMemoryVectorStore, TestQdrantVectorStore

### Community 73 - "SafetyService"
Cohesion: 0.21
Nodes (6): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService, re

### Community 74 - "MoodEntryModel"
Cohesion: 0.29
Nodes (9): MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, MoodCheckInCard, .body (+1 more)

### Community 75 - "String"
Cohesion: 0.34
Nodes (6): LLMMessage, unsupportedProvider, LLMService, AsyncThrowingStream, Data, String

### Community 76 - "VoiceStatusBar"
Cohesion: 0.14
Nodes (14): CapturedBadgeRow, CrisisBanner, .body, MessageBubble, .body, .hasBadges, Color, String (+6 more)

### Community 77 - "Persona"
Cohesion: 0.21
Nodes (4): Persona, .displayName, String, TherapyService

### Community 79 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 80 - "env.py"
Cohesion: 0.17
Nodes (8): alembic, app_models, asyncio, logging_config, do_run_migrations(), run_migrations_online(), sqlalchemy_engine, typing

### Community 81 - "api/voice.py"
Cohesion: 0.23
Nodes (12): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+4 more)

### Community 82 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (10): Int64, DownloadProgressDelegate, Double, Result, URL, Void, URLSession, URLSessionDownloadDelegate (+2 more)

### Community 83 - "String"
Cohesion: 0.26
Nodes (6): SafetyEventModel, Date, Int, String, TimeInterval, VoiceRecordingModel

### Community 84 - "SessionRow"
Cohesion: 0.21
Nodes (10): .body, ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind (+2 more)

### Community 85 - ".decrypt()"
Cohesion: 0.32
Nodes (4): BackupService, Data, ModelContext, Payload

### Community 86 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 87 - "ChatServiceCompactionTests"
Cohesion: 0.27
Nodes (3): ChatServiceCompactionTests, ModelContainer, ModelContext

### Community 88 - "GlobalMemoryServiceTests"
Cohesion: 0.24
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 89 - "LocalModelService.swift"
Cohesion: 0.17
Nodes (11): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3 (+3 more)

### Community 90 - "PersonaKind"
Cohesion: 0.17
Nodes (12): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+4 more)

### Community 91 - "String"
Cohesion: 0.30
Nodes (5): SafetyService, StoreProtection, Bool, String, URL

### Community 92 - "VoiceService"
Cohesion: 0.29
Nodes (5): VoiceRecording, get_stt_provider(), AsyncSession, VoiceService, settings

### Community 93 - "LocalLLMError"
Cohesion: 0.18
Nodes (11): AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LocalLLMError, busy, .errorDescription, loadFailed (+3 more)

### Community 95 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 96 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 97 - "NarrativeDocument"
Cohesion: 0.38
Nodes (5): NarrativeDocument, NarrativeExportService, String, URL, NSParagraphStyle

### Community 98 - "LLMError"
Cohesion: 0.20
Nodes (10): LLMError, apiError, contextLengthExceeded, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded, noAPIKey (+2 more)

### Community 100 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 101 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 102 - "chat.py"
Cohesion: 0.33
Nodes (8): chat(), get_chat_history(), AsyncSession, get, post, ChatRequest, ChatResponse, MessageResponse

### Community 103 - "GlobalMemoryService"
Cohesion: 0.36
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 104 - ".sizeThatFits()"
Cohesion: 0.31
Nodes (7): CGSize, FlowLayout, CGFloat, CGRect, Layout, ProposedViewSize, Subviews

### Community 105 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 106 - "ShareSheet"
Cohesion: 0.28
Nodes (6): ShareSheet, Any, Context, UIActivityViewController, UIViewControllerRepresentable, WebKit

### Community 107 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 108 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 110 - "VoiceService"
Cohesion: 0.39
Nodes (5): AVAudioRecorder, ModelContext, String, URL, VoiceService

### Community 111 - "SafetyService.swift"
Cohesion: 0.25
Nodes (3): BackupKit, BackupPayloadTests, UserNotifications

### Community 112 - "Identifiable"
Cohesion: 0.29
Nodes (8): Identifiable, MoodDayAverage, Date, Double, Connection, NodeConnectionsSheet, .connections, Int

### Community 113 - "RoundedCorner"
Cohesion: 0.32
Nodes (6): RoundedCorner, CGFloat, CGRect, Path, Shape, UIRectCorner

### Community 114 - ".schedule()"
Cohesion: 0.43
Nodes (4): ReminderScheduler, Int, UNNotificationRequest, UNUserNotificationCenter

### Community 116 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 118 - "MarkdownText"
Cohesion: 0.33
Nodes (5): AttributedString, MarkdownText, .attributed, .body, String

### Community 119 - "SwiftUI"
Cohesion: 0.38
Nodes (3): AVFoundation, Speech, SwiftUI

### Community 120 - "VoiceSettingsView"
Cohesion: 0.33
Nodes (6): ElevenLabsTTSEngine, Double, String, VoiceSettingsView, .body, .elevenLabsSection

### Community 121 - "GlobalMemoryService"
Cohesion: 0.52
Nodes (4): GlobalMemoryService, Int, ModelContext, String

### Community 122 - "NewSessionView"
Cohesion: 0.33
Nodes (5): NewSessionView, .body, .defaultProviderLabel, .personaName, String

### Community 125 - "NSObject"
Cohesion: 0.33
Nodes (4): XMLParserRecorder, NSObject, XMLParser, XMLParserDelegate

### Community 126 - "httpx"
Cohesion: 0.40
Nodes (4): httpx, AsyncClient, asyncio, test_health_endpoint()

### Community 127 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **208 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+203 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 600 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **21 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `Float`, `AutoBackupService`, `XCTestCase`, `View`, `DashboardView.swift`, `ChatService`, `.buildIncremental()`, `InsightCaptureServiceTests`, `NoteModel`, `AggregatedGraph`, `.makeInMemoryContainer()`, `ChatView`, `Foundation`, `String`, `.ephemeralDefaults()`, `GraphNodeModel`, `DashboardView`, `DreamModel`, `GraphExportServiceTests`, `MockLLM`, `String`, `SessionRow`, `.decrypt()`, `ChatServiceCompactionTests`, `SpiritualPersonaTests`, `GraphServiceTests`, `VoiceService`, `NewSessionView`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `PINService`, `Float`, `BackupRestorePlan`, `OpenRouterModel`, `SessionModel`, `KeychainService`, `ConversationCompactorTests`, `XCTestCase`, `InsightCaptureServiceTests`, `LocalLLMEngine`, `AggregatedGraph`, `AppleFoundationEngine`, `LLMProvider`, `CompanionPersonality`, `Codable`, `Persona`, `LocalModelService.swift`, `SafetyService.swift`, `SwiftUI`, `NSObject`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `PINService`, `AutoBackupService`, `SessionModel`, `LocalModelService`, `OnboardingView.swift`, `DashboardView.swift`, `SettingsView`, `NarrativeView`, `NoteModel`, `AggregatedGraph`, `ChatView`, `VoicePickerView`, `String`, `DashboardView`, `DreamModel`, `SpeechService`, `MoodEntryModel`, `VoiceStatusBar`, `SessionRow`, `Identifiable`, `RoundedCorner`, `MarkdownText`, `VoiceSettingsView`, `NewSessionView`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 43 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `LocalModelService` (e.g. with `.downloadedLocalModels` and `.localAvailable`) actually correct?**
  _`LocalModelService` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _208 weakly-connected nodes found - possible documentation gaps or missing edges._