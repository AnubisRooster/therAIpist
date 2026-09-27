# Graph Report - therAIpist  (2026-09-27)

## Corpus Check
- Large corpus: 233 files · ~982,811 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2733 nodes · 6769 edges · 141 communities (122 shown, 19 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 661 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- OpenRouterModel
- config.py
- AgentContext
- BackupRestorePlan
- sqlalchemy_ext_asyncio
- Base
- SessionModel
- ConversationCompactorTests
- OnboardingView.swift
- View
- asyncio
- schemas.py
- MemoryService
- graphify_pipeline.py
- AgentContext
- ChatMessage
- ChatService
- ChatView
- .processMessage()
- InMemoryVectorStore
- LocalLLMEngine
- dreams.py
- Float
- AutoBackupService
- ChatService
- LocalModelService
- insights.py
- Session
- SettingsView
- AggregatedGraph
- SafetyService
- SelfwardDesktop
- .buildIncremental()
- NarrativeView
- .makeInMemoryContainer()
- asyncio
- TherapyService
- GraphService
- .get()
- VoiceConversationController
- MockLLM
- TTSCoordinator
- api/graph.py
- notes.py
- Codable
- Coordinator
- SwiftData
- AppleFoundationEngine
- LocalModel
- VoicePickerView
- VoiceTranscriptTests
- SpeechService
- GraphNodeModel
- SpiritualTradition
- asyncio
- Foundation
- String
- String
- DashboardView
- test_dreams.py
- TagCapsule
- DreamModel
- NoteModel
- KeychainService
- String
- PersonaKind
- .ephemeralDefaults()
- String
- Error
- GraphExportServiceTests
- .classifyHTTPFailure()
- LLMProvider
- SafetyServiceTests
- asyncio
- LLMError
- FakeKeychain
- ChatServiceE2ETests
- GraphServiceTests
- Theme
- Persona
- test_notes.py
- graph_ui.py
- DownloadProgressDelegate
- DashboardService
- BackupFolderPicker
- env.py
- .trendSummary()
- ActiveImaginationTests
- GlobalMemoryServiceTests
- CompanionPersonality
- SpiritualPersonaTests
- .decrypt()
- test_auth.py
- .body
- EncryptedBackupDocument
- .streamAndSplitSentences()
- MemoryService
- VectorStore
- test_graph_ui.py
- test_safety.py
- GlobalMemoryService
- VoiceService
- CompanionGender
- .sizeThatFits()
- CodingKeys
- EmbeddingService
- .writePDF()
- .schedule()
- SessionRow
- NodeConnectionsSheet
- test_dashboard.py
- test_sessions.py
- SwiftUI
- TTSKeyProvider
- RoundedCorner
- GlobalMemoryService
- .stripMarkdown()
- String
- test_chat.py
- VoiceSettingsView
- OnDeviceModelsStep
- NarrativeTests
- TestModalityPrompts
- MarkdownText
- .narrativeFont()
- NewSessionView
- GraphExportServiceTests.swift
- Dream
- Phase
- NarrativeView.swift
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
  tests/test_graph.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_insights.py → app/models/base.py
- `db_session()` --uses--> `Base`  [INFERRED]
  tests/test_therapy.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (141 total, 19 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.05
Nodes (40): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+32 more)

### Community 2 - "OpenRouterModel"
Cohesion: 0.05
Nodes (38): CodingKey, Decoder, Hashable, CodingKeys, architecture, contextLength, id, inputModalities (+30 more)

### Community 3 - "config.py"
Cohesion: 0.06
Nodes (39): Settings, AsyncSession, cosine_similarity(), get_vector_store(), ABC, reset_vector_store(), SearchResult, VectorStore (+31 more)

### Community 4 - "AgentContext"
Cohesion: 0.10
Nodes (26): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+18 more)

### Community 5 - "BackupRestorePlan"
Cohesion: 0.10
Nodes (29): Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot, MoodSnapshot, SessionSnapshot (+21 more)

### Community 6 - "sqlalchemy_ext_asyncio"
Cohesion: 0.07
Nodes (37): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), get_mode(), get (+29 more)

### Community 7 - "Base"
Cohesion: 0.16
Nodes (18): Base, Message, GraphEdge, GraphNode, EpisodicMemory, ProceduralMemory, SemanticMemory, Note (+10 more)

### Community 8 - "SessionModel"
Cohesion: 0.10
Nodes (18): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, InsightResult, InsightService, String (+10 more)

### Community 9 - "ConversationCompactorTests"
Cohesion: 0.12
Nodes (8): ConversationCompactor, StoredState, Date, Int, String, ConversationCompactorTests, Int, String

### Community 10 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 11 - "View"
Cohesion: 0.09
Nodes (33): Charts, Identifiable, View, GlobalMemoryModel, .body, CapturedBadgeRow, DashboardTabView, .body (+25 more)

### Community 12 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 13 - "schemas.py"
Cohesion: 0.10
Nodes (34): chat(), get_chat_history(), AsyncSession, get, post, patch, set_mode(), AgentResponse (+26 more)

### Community 14 - "MemoryService"
Cohesion: 0.11
Nodes (20): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+12 more)

### Community 15 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 16 - "AgentContext"
Cohesion: 0.13
Nodes (19): AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent, .name (+11 more)

### Community 17 - "ChatMessage"
Cohesion: 0.14
Nodes (11): health_check(), get, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, get_provider() (+3 more)

### Community 18 - "ChatService"
Cohesion: 0.11
Nodes (21): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+13 more)

### Community 19 - "ChatView"
Cohesion: 0.09
Nodes (24): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, CrisisBanner, .body (+16 more)

### Community 20 - ".processMessage()"
Cohesion: 0.11
Nodes (10): ModelContext, ModelContext, ModelContext, Void, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests (+2 more)

### Community 21 - "InMemoryVectorStore"
Cohesion: 0.10
Nodes (7): InMemoryVectorStore, QdrantVectorStore, Response, asyncio, fixture, TestInMemoryVectorStore, TestQdrantVectorStore

### Community 22 - "LocalLLMEngine"
Cohesion: 0.12
Nodes (17): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, Bool (+9 more)

### Community 23 - "dreams.py"
Cohesion: 0.15
Nodes (20): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+12 more)

### Community 24 - "Float"
Cohesion: 0.14
Nodes (14): ClosedRange, MemoryModel, MessageModel, MoodEntryModel, NarrativeDocument, SafetyEventModel, Bool, Data (+6 more)

### Community 25 - "AutoBackupService"
Cohesion: 0.18
Nodes (16): AutoBackupConfig, AutoBackupService, .decoder, .encoder, .folderDisplayName, .isEnabled, .lastBackupDate, AvailableAutoBackup (+8 more)

### Community 26 - "ChatService"
Cohesion: 0.12
Nodes (11): ChatResult, ChatService, LocalPromptOverflow, Bool, Int, String, LLMSending, ChatServiceStreamingTests (+3 more)

### Community 27 - "LocalModelService"
Cohesion: 0.15
Nodes (15): LocalModelService, .availableModels, .modelsDirectory, Bool, Set, .downloadedLocalModels, .localAvailable, .resolvedLocalModel (+7 more)

### Community 28 - "insights.py"
Cohesion: 0.16
Nodes (20): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+12 more)

### Community 29 - "Session"
Cohesion: 0.19
Nodes (20): get_mode_service(), AsyncSession, Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture (+12 more)

### Community 30 - "SettingsView"
Cohesion: 0.12
Nodes (19): Binding, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+11 more)

### Community 31 - "AggregatedGraph"
Cohesion: 0.19
Nodes (10): AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL, GraphVisualizationSheet (+2 more)

### Community 32 - "SafetyService"
Cohesion: 0.12
Nodes (15): get_events(), get_safety_service(), get_summary(), AsyncSession, get, SafetyEvent, _is_negated(), AsyncSession (+7 more)

### Community 33 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 34 - ".buildIncremental()"
Cohesion: 0.20
Nodes (9): NarrativeService, Source, Bool, Date, ModelContext, String, NarrativeServiceTests, ModelContainer (+1 more)

### Community 35 - "NarrativeView"
Cohesion: 0.12
Nodes (22): ShareSheet, Any, NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body (+14 more)

### Community 36 - ".makeInMemoryContainer()"
Cohesion: 0.13
Nodes (9): InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, TestSupport, BackupPayloadTests, StaticString, UInt (+1 more)

### Community 37 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 38 - "TherapyService"
Cohesion: 0.11
Nodes (14): get_dashboard_service(), get_global_dashboard(), get_session_dashboard(), AsyncSession, get, get_progress(), get_therapy_service(), AsyncSession (+6 more)

### Community 39 - "GraphService"
Cohesion: 0.13
Nodes (6): get_graph_service(), AsyncSession, AsyncSession, GraphService, AsyncSession, AsyncSession

### Community 40 - ".get()"
Cohesion: 0.13
Nodes (6): APIKeyProvider, .byokProviders, .cloudProvidersWithKeys, .body, .openAISection, ProviderRoutingTests

### Community 41 - "VoiceConversationController"
Cohesion: 0.19
Nodes (9): Bool, TimeInterval, Timer, Void, VoiceConversationController, .silenceInterval, VoiceUtterance, SFSpeechAudioBufferRecognitionRequest (+1 more)

### Community 42 - "MockLLM"
Cohesion: 0.18
Nodes (4): ChatServiceCompactionTests, ModelContainer, ModelContext, MockLLM

### Community 43 - "TTSCoordinator"
Cohesion: 0.16
Nodes (14): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+6 more)

### Community 44 - "api/graph.py"
Cohesion: 0.16
Nodes (21): create_edge(), create_node(), extract(), get_connections(), get_node(), get_patterns(), get_session_graph(), get_themes() (+13 more)

### Community 45 - "notes.py"
Cohesion: 0.14
Nodes (15): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+7 more)

### Community 46 - "Codable"
Cohesion: 0.24
Nodes (19): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+11 more)

### Community 47 - "Coordinator"
Cohesion: 0.14
Nodes (13): Coordinator, GraphVisualizationView, Context, Coordinator, Void, UIActivityViewController, UIViewRepresentable, WKNavigation (+5 more)

### Community 48 - "SwiftData"
Cohesion: 0.21
Nodes (3): Selfward, SwiftData, XCTest

### Community 49 - "AppleFoundationEngine"
Cohesion: 0.14
Nodes (14): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+6 more)

### Community 50 - "LocalModel"
Cohesion: 0.12
Nodes (15): LocalModel, LocalModelKind, appleFoundation, gguf, .huggingFaceModels, LocalModelTemplate, chatML, gemma (+7 more)

### Community 51 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 53 - "SpeechService"
Cohesion: 0.17
Nodes (11): AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, SpeechService, AVSpeechSynthesisVoice, String, TimeInterval, Void (+3 more)

### Community 54 - "GraphNodeModel"
Cohesion: 0.29
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 55 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 56 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 57 - "Foundation"
Cohesion: 0.14
Nodes (4): BackupKit, Foundation, BadgeBackfillService, UserNotifications

### Community 58 - "String"
Cohesion: 0.27
Nodes (7): BYOKLLMKit, LLMMessage, unsupportedProvider, LLMService, LLMStreaming, AsyncThrowingStream, String

### Community 59 - "String"
Cohesion: 0.24
Nodes (11): GraphEdgeModel, EdgesListView, .body, .filtered, NodeDetailView, .body, .properties, NodesListView (+3 more)

### Community 60 - "DashboardView"
Cohesion: 0.12
Nodes (18): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+10 more)

### Community 61 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 62 - "TagCapsule"
Cohesion: 0.15
Nodes (15): Actions, AnimatedEmptyState, BadgePill, .body, GradientHeader, .body, PersonaAvatar, Bool (+7 more)

### Community 63 - "DreamModel"
Cohesion: 0.21
Nodes (11): DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings, .symbols (+3 more)

### Community 64 - "NoteModel"
Cohesion: 0.24
Nodes (9): NoteModel, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView, .body (+1 more)

### Community 65 - "KeychainService"
Cohesion: 0.26
Nodes (6): .passphrase, KeychainService, KeychainStoring, Bool, Data, String

### Community 66 - "String"
Cohesion: 0.24
Nodes (7): HFModel, HFSibling, HuggingFaceModelService, Data, String, TimeInterval, HuggingFaceCatalogTests

### Community 67 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 69 - "String"
Cohesion: 0.23
Nodes (5): CrisisResources, Resource, SafetyService, Bool, String

### Community 70 - "Error"
Cohesion: 0.17
Nodes (10): CommonCrypto, CryptoKit, MockStreamingLLM, AsyncThrowingStream, Int, String, Error, keyDerivationFailed (+2 more)

### Community 71 - "GraphExportServiceTests"
Cohesion: 0.29
Nodes (3): GraphExportServiceTests, Int, ModelContainer

### Community 72 - ".classifyHTTPFailure()"
Cohesion: 0.24
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 73 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 74 - "SafetyServiceTests"
Cohesion: 0.12
Nodes (3): StoreProtection, URL, SafetyServiceTests

### Community 75 - "asyncio"
Cohesion: 0.22
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 76 - "LLMError"
Cohesion: 0.13
Nodes (15): AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LLMError, apiError, contextLengthExceeded, emptyResponse (+7 more)

### Community 77 - "FakeKeychain"
Cohesion: 0.27
Nodes (5): AutoBackupServiceTests, FakeKeychain, Bool, Data, String

### Community 78 - "ChatServiceE2ETests"
Cohesion: 0.22
Nodes (4): ChatServiceE2ETests, ModelContainer, ModelContext, String

### Community 80 - "Theme"
Cohesion: 0.21
Nodes (9): .body, Color, LinearGradient, String, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament (+1 more)

### Community 81 - "Persona"
Cohesion: 0.21
Nodes (4): Persona, .displayName, String, TherapyService

### Community 82 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 83 - "graph_ui.py"
Cohesion: 0.23
Nodes (8): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphUIService, AsyncSession

### Community 84 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (10): Int64, DownloadProgressDelegate, Double, Result, URL, Void, URLSession, URLSessionDownloadDelegate (+2 more)

### Community 85 - "DashboardService"
Cohesion: 0.33
Nodes (6): DashboardService, GlobalDashboard, SessionDashboard, Date, Int, String

### Community 86 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 87 - "env.py"
Cohesion: 0.18
Nodes (7): alembic, asyncio, logging_config, do_run_migrations(), run_migrations_online(), sqlalchemy_engine, typing

### Community 88 - ".trendSummary()"
Cohesion: 0.32
Nodes (6): MoodStore, Date, Double, Int, ModelContext, .body

### Community 90 - "GlobalMemoryServiceTests"
Cohesion: 0.27
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 91 - "CompanionPersonality"
Cohesion: 0.18
Nodes (11): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, machiavelli (+3 more)

### Community 93 - ".decrypt()"
Cohesion: 0.38
Nodes (4): BackupService, Data, ModelContext, Payload

### Community 94 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 95 - ".body"
Cohesion: 0.29
Nodes (7): App, AppRootView, .body, RootTabView, SelfwardApp, .body, Scene

### Community 96 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 97 - ".streamAndSplitSentences()"
Cohesion: 0.24
Nodes (6): AsyncThrowingStream, Bool, ChatResult, Int, String, Void

### Community 98 - "MemoryService"
Cohesion: 0.44
Nodes (4): String, MemoryService, ModelContext, String

### Community 99 - "VectorStore"
Cohesion: 0.33
Nodes (3): Int, String, VectorStore

### Community 100 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 101 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

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

### Community 107 - "EmbeddingService"
Cohesion: 0.28
Nodes (6): EmbeddingService, .isAvailable, Bool, Data, NaturalLanguage, NLEmbedding

### Community 108 - ".writePDF()"
Cohesion: 0.36
Nodes (4): NarrativeExportService, String, URL, NSParagraphStyle

### Community 109 - ".schedule()"
Cohesion: 0.36
Nodes (4): ReminderScheduler, Int, UNNotificationRequest, UNUserNotificationCenter

### Community 110 - "SessionRow"
Cohesion: 0.33
Nodes (6): ArchivedSessionsView, .body, ContentView, .body, SessionRow, .personaKind

### Community 111 - "NodeConnectionsSheet"
Cohesion: 0.31
Nodes (7): Connection, NodeConnectionsSheet, .body, .connections, Int, String, WebKit

### Community 112 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 113 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 114 - "SwiftUI"
Cohesion: 0.32
Nodes (3): AVFoundation, Speech, SwiftUI

### Community 115 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 116 - "RoundedCorner"
Cohesion: 0.32
Nodes (6): RoundedCorner, CGFloat, CGRect, Path, Shape, UIRectCorner

### Community 117 - "GlobalMemoryService"
Cohesion: 0.43
Nodes (4): GlobalMemoryService, Int, ModelContext, String

### Community 119 - "String"
Cohesion: 0.43
Nodes (3): Never, String, Task

### Community 120 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 121 - "VoiceSettingsView"
Cohesion: 0.33
Nodes (6): ElevenLabsTTSEngine, Double, String, VoiceSettingsView, .body, .elevenLabsSection

### Community 122 - "OnDeviceModelsStep"
Cohesion: 0.29
Nodes (6): Int, OnDeviceModelsStep, .ramGB, .recommendedID, .recommendedModel, Int

### Community 125 - "MarkdownText"
Cohesion: 0.40
Nodes (5): AttributedString, MarkdownText, .attributed, .body, String

### Community 126 - ".narrativeFont()"
Cohesion: 0.40
Nodes (4): Font, .body, CGFloat, .emptyState

### Community 127 - "NewSessionView"
Cohesion: 0.40
Nodes (5): NewSessionView, .body, .defaultProviderLabel, .personaName, String

### Community 128 - "GraphExportServiceTests.swift"
Cohesion: 0.33
Nodes (4): XMLParserRecorder, NSObject, XMLParser, XMLParserDelegate

### Community 130 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **209 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+204 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 602 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **19 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `OpenRouterModel`, `View`, `ChatView`, `.processMessage()`, `Float`, `ChatService`, `AggregatedGraph`, `.buildIncremental()`, `.makeInMemoryContainer()`, `MockLLM`, `GraphNodeModel`, `String`, `DashboardView`, `DreamModel`, `NoteModel`, `PersonaKind`, `.ephemeralDefaults()`, `GraphExportServiceTests`, `ChatServiceE2ETests`, `GraphServiceTests`, `DashboardService`, `.decrypt()`, `MemoryService`, `VoiceService`, `SessionRow`, `NewSessionView`?**
  _High betweenness centrality (0.092) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `GraphExportServiceTests.swift`, `PINService`, `OpenRouterModel`, `BackupRestorePlan`, `SessionModel`, `AgentContext`, `.processMessage()`, `LocalLLMEngine`, `Float`, `AggregatedGraph`, `.buildIncremental()`, `Codable`, `AppleFoundationEngine`, `LocalModel`, `GraphNodeModel`, `String`, `NoteModel`, `PersonaKind`, `Error`, `Persona`, `DashboardService`, `VectorStore`, `VoiceService`, `EmbeddingService`, `SwiftUI`, `TTSKeyProvider`, `GlobalMemoryService`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `PINService`, `OpenRouterModel`, `SessionModel`, `OnboardingView.swift`, `ChatView`, `LocalModelService`, `SettingsView`, `AggregatedGraph`, `NarrativeView`, `VoicePickerView`, `SpeechService`, `String`, `DashboardView`, `TagCapsule`, `DreamModel`, `NoteModel`, `.body`, `SessionRow`, `NodeConnectionsSheet`, `RoundedCorner`, `VoiceSettingsView`, `OnDeviceModelsStep`, `MarkdownText`, `NewSessionView`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 45 INFERRED edges - model-reasoned connections that need verification._
- **Are the 31 inferred relationships involving `ChatService` (e.g. with `AgentOrchestrator` and `.testAssistantBubbleIsBadgedWithCapturedInsights()`) actually correct?**
  _`ChatService` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _209 weakly-connected nodes found - possible documentation gaps or missing edges._