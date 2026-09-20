# Graph Report - therAIpist  (2026-09-20)

## Corpus Check
- Large corpus: 245 files · ~1,936,780 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2698 nodes · 6654 edges · 128 communities (110 shown, 18 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 645 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- cytoscape.min.js
- PINService
- GraphExportServiceTests
- config.py
- Float
- AutoBackupService
- BackupRestorePlan
- SafetyServiceTests
- AgentContext
- OpenRouterModel
- sqlalchemy_ext_asyncio
- database.py
- LocalModelService
- schemas.py
- OnboardingView.swift
- KeychainService
- dreams.py
- ChatMessage
- SessionModel
- ConversationCompactorTests
- asyncio
- graphify_pipeline.py
- ChatService
- ChatView
- .makeInMemoryContainer()
- ChatService
- String
- LocalLLMEngine
- View
- Error
- InsightCaptureServiceTests
- insights.py
- GraphService
- .buildIncremental()
- DashboardView.swift
- SelfwardDesktop
- asyncio
- TTSCoordinator
- Session
- NarrativeView
- notes.py
- Foundation
- VoiceConversationController
- InsightService
- api/memory.py
- MemoryService
- SafetyService
- VoicePickerView
- Codable
- VoiceTranscriptTests
- XCTest
- String
- SettingsView.swift
- SpiritualTradition
- asyncio
- test_dreams.py
- GraphNodeModel
- .models()
- PersonaKind
- asyncio
- SpeechService
- GlobalMemoryModel
- NoteModel
- LLMProvider
- .ephemeralDefaults()
- SettingsView
- .classifyHTTPFailure()
- String
- Persona
- test_notes.py
- env.py
- graph_ui.py
- sessions.py
- api/voice.py
- DownloadProgressDelegate
- Theme
- BackupFolderPicker
- GlobalMemoryServiceTests
- SwiftUI
- AppleFoundationEngine
- .configError()
- LocalModelService.swift
- ActiveImaginationTests
- VoiceService
- .classify()
- .processMessage()
- LLMError
- SpiritualPersonaTests
- test_auth.py
- EncryptedBackupDocument
- NarrativeDocument
- CompanionPersonality
- SessionRow
- test_graph_ui.py
- test_safety.py
- mode.py
- GlobalMemoryService
- CompanionGender
- .sizeThatFits()
- MemoryModel
- CodingKeys
- String
- test_dashboard.py
- test_sessions.py
- chat.py
- therapy.py
- VoiceService
- TTSKeyProvider
- RoundedCorner
- .stripMarkdown()
- test_chat.py
- MarkdownText
- NarrativeTests
- TestModalityPrompts
- NewSessionView
- NSObject
- .narrativeFont()
- Phase
- .speechSynthesizer()
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

## Communities (128 total, 18 thin omitted)

### Community 0 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 1 - "PINService"
Cohesion: 0.05
Nodes (40): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+32 more)

### Community 2 - "GraphExportServiceTests"
Cohesion: 0.05
Nodes (44): Identifiable, AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL (+36 more)

### Community 3 - "config.py"
Cohesion: 0.05
Nodes (34): Settings, AsyncSession, cosine_similarity(), get_vector_store(), InMemoryVectorStore, ABC, QdrantVectorStore, reset_vector_store() (+26 more)

### Community 4 - "Float"
Cohesion: 0.06
Nodes (38): ClosedRange, AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent (+30 more)

### Community 5 - "AutoBackupService"
Cohesion: 0.07
Nodes (37): App, AppRootView, .body, RootTabView, .body, SelfwardApp, .body, AutoBackupConfig (+29 more)

### Community 6 - "BackupRestorePlan"
Cohesion: 0.09
Nodes (32): CommonCrypto, CryptoKit, Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot (+24 more)

### Community 7 - "SafetyServiceTests"
Cohesion: 0.06
Nodes (22): MoodEntryModel, MoodStore, Date, Double, Int, ModelContext, BackupService, CrisisResources (+14 more)

### Community 8 - "AgentContext"
Cohesion: 0.10
Nodes (26): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentOrchestrator, AdlerianAgent, DBTAgent (+18 more)

### Community 9 - "OpenRouterModel"
Cohesion: 0.06
Nodes (32): CodingKey, Decoder, Hashable, CodingKeys, architecture, contextLength, id, inputModalities (+24 more)

### Community 10 - "sqlalchemy_ext_asyncio"
Cohesion: 0.18
Nodes (17): app_agents, Base, Message, GraphEdge, GraphNode, Note, app_services_providers, get_provider() (+9 more)

### Community 11 - "database.py"
Cohesion: 0.07
Nodes (34): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), get_dashboard_service(), get_global_dashboard() (+26 more)

### Community 12 - "LocalModelService"
Cohesion: 0.11
Nodes (25): LocalModel, LocalModelService, .availableModels, .huggingFaceModels, .modelsDirectory, Bool, Set, String (+17 more)

### Community 13 - "schemas.py"
Cohesion: 0.11
Nodes (38): create_edge(), create_node(), extract(), get_connections(), get_graph_service(), get_node(), get_patterns(), get_session_graph() (+30 more)

### Community 14 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 15 - "KeychainService"
Cohesion: 0.11
Nodes (11): APIKeyProvider, KeychainService, Bool, Data, String, .byokProviders, .cloudProvidersWithKeys, .body (+3 more)

### Community 16 - "dreams.py"
Cohesion: 0.11
Nodes (22): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+14 more)

### Community 17 - "ChatMessage"
Cohesion: 0.11
Nodes (16): ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, OllamaProvider, OpenRouterProvider, pydantic (+8 more)

### Community 18 - "SessionModel"
Cohesion: 0.09
Nodes (24): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, DashboardView, .allDreams, .allEdges (+16 more)

### Community 19 - "ConversationCompactorTests"
Cohesion: 0.13
Nodes (8): ConversationCompactor, StoredState, Date, Int, String, ConversationCompactorTests, Int, String

### Community 20 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 21 - "graphify_pipeline.py"
Cohesion: 0.08
Nodes (25): ABC, STTProvider, TranscriptResult, MockSTTProvider, graphify_analyze, graphify_build, graphify_cluster, graphify_detect (+17 more)

### Community 22 - "ChatService"
Cohesion: 0.15
Nodes (9): ChatService, ChatServiceE2ETests, ModelContainer, ModelContext, String, ChatServiceCompactionTests, ModelContainer, ModelContext (+1 more)

### Community 23 - "ChatView"
Cohesion: 0.09
Nodes (26): CapturedBadgeRow, .body, ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona (+18 more)

### Community 24 - ".makeInMemoryContainer()"
Cohesion: 0.09
Nodes (8): GraphServiceTests, InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, StaticString, UInt, XCTestCase

### Community 25 - "ChatService"
Cohesion: 0.09
Nodes (14): get_chat_service(), AsyncSession, SessionCreate, ChatService, AsyncSession, DashboardService, AsyncSession, AsyncSession (+6 more)

### Community 26 - "String"
Cohesion: 0.12
Nodes (21): GraphEdgeModel, .body, EdgesListView, .body, .filtered, FlowTagView, .body, NodeDetailView (+13 more)

### Community 27 - "LocalLLMEngine"
Cohesion: 0.12
Nodes (17): LocalLLMEngine, LocalLLMError, busy, .errorDescription, loadFailed, notLoaded, timeout, Bool (+9 more)

### Community 28 - "View"
Cohesion: 0.13
Nodes (21): Actions, AnimatedEmptyState, BadgePill, .body, GradientHeader, .body, PersonaAvatar, Bool (+13 more)

### Community 29 - "Error"
Cohesion: 0.11
Nodes (11): ChatServiceStreamingTests, ModelContainer, ModelContext, String, MockStreamingLLM, AsyncThrowingStream, String, Error (+3 more)

### Community 30 - "InsightCaptureServiceTests"
Cohesion: 0.13
Nodes (8): BadgeBackfillService, ModelContext, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 31 - "insights.py"
Cohesion: 0.16
Nodes (20): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+12 more)

### Community 32 - "GraphService"
Cohesion: 0.12
Nodes (9): GraphService, AsyncSession, AsyncSession, graph_service(), fixture, db_session(), graph_service(), insight_service() (+1 more)

### Community 33 - ".buildIncremental()"
Cohesion: 0.20
Nodes (11): MessageModel, Bool, NarrativeService, Source, Bool, Date, ModelContext, String (+3 more)

### Community 34 - "DashboardView.swift"
Cohesion: 0.14
Nodes (18): Charts, DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings (+10 more)

### Community 35 - "SelfwardDesktop"
Cohesion: 0.15
Nodes (11): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run(), threading (+3 more)

### Community 36 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 37 - "TTSCoordinator"
Cohesion: 0.15
Nodes (14): AnyCancellable, PrefetchedSentence, text, Bool, Never, Task, TimeInterval, Void (+6 more)

### Community 38 - "Session"
Cohesion: 0.23
Nodes (18): Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture, test_get_mode_default(), test_get_mode_not_found() (+10 more)

### Community 39 - "NarrativeView"
Cohesion: 0.13
Nodes (20): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .document, .emptyDescription (+12 more)

### Community 40 - "notes.py"
Cohesion: 0.14
Nodes (15): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+7 more)

### Community 41 - "Foundation"
Cohesion: 0.16
Nodes (4): BackupKit, Foundation, SwiftData, UserNotifications

### Community 42 - "VoiceConversationController"
Cohesion: 0.20
Nodes (8): Bool, TimeInterval, Timer, Void, VoiceConversationController, .silenceInterval, SFSpeechAudioBufferRecognitionRequest, SFSpeechRecognitionTask

### Community 43 - "InsightService"
Cohesion: 0.25
Nodes (3): InsightResult, InsightService, String

### Community 44 - "api/memory.py"
Cohesion: 0.18
Nodes (19): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+11 more)

### Community 45 - "MemoryService"
Cohesion: 0.18
Nodes (4): EpisodicMemory, ProceduralMemory, SemanticMemory, MemoryService

### Community 46 - "SafetyService"
Cohesion: 0.15
Nodes (10): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService, re, asyncio, test_boundary_response_is_filtered() (+2 more)

### Community 47 - "VoicePickerView"
Cohesion: 0.15
Nodes (15): AVSpeechSynthesisVoiceQuality, Bool, AVSpeechSynthesisVoice, Bool, Color, Double, String, VoicePickerView (+7 more)

### Community 48 - "Codable"
Cohesion: 0.27
Nodes (18): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CrisisPattern, EmbeddingData (+10 more)

### Community 51 - "String"
Cohesion: 0.25
Nodes (8): BYOKLLMKit, LLMMessage, unsupportedProvider, LLMService, LLMStreaming, AsyncThrowingStream, Data, String

### Community 52 - "SettingsView.swift"
Cohesion: 0.12
Nodes (17): ElevenLabsTTSEngine, AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection (+9 more)

### Community 53 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 54 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 55 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 56 - "GraphNodeModel"
Cohesion: 0.33
Nodes (7): GraphNodeModel, EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 57 - ".models()"
Cohesion: 0.19
Nodes (7): HFModel, HFSibling, HuggingFaceModelService, Data, Int, TimeInterval, HuggingFaceCatalogTests

### Community 58 - "PersonaKind"
Cohesion: 0.12
Nodes (13): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+5 more)

### Community 59 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 60 - "SpeechService"
Cohesion: 0.22
Nodes (9): AVSpeechSynthesizerDelegate, SpeechService, AVSpeechSynthesisVoice, String, TimeInterval, Void, PersonasSettingsView, .body (+1 more)

### Community 61 - "GlobalMemoryModel"
Cohesion: 0.23
Nodes (11): GlobalMemoryModel, GlobalMemoryService, Int, ModelContext, String, GlobalMemoriesListView, .body, .filtered (+3 more)

### Community 62 - "NoteModel"
Cohesion: 0.27
Nodes (9): NoteModel, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView, .body (+1 more)

### Community 63 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 65 - "SettingsView"
Cohesion: 0.22
Nodes (8): Binding, SettingsView, .autoBackupEnabled, .body, Bool, Date, Int, Result

### Community 66 - ".classifyHTTPFailure()"
Cohesion: 0.26
Nodes (6): LLMErrorTriage, Bool, Data, Int, String, LLMRetryClassificationTests

### Community 67 - "String"
Cohesion: 0.23
Nodes (6): SafetyEventModel, Date, Int, String, TimeInterval, VoiceRecordingModel

### Community 68 - "Persona"
Cohesion: 0.21
Nodes (4): Persona, .displayName, String, TherapyService

### Community 69 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 70 - "env.py"
Cohesion: 0.17
Nodes (8): alembic, app_models, asyncio, logging_config, do_run_migrations(), run_migrations_online(), sqlalchemy_engine, typing

### Community 71 - "graph_ui.py"
Cohesion: 0.23
Nodes (8): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphUIService, AsyncSession

### Community 72 - "sessions.py"
Cohesion: 0.28
Nodes (12): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+4 more)

### Community 73 - "api/voice.py"
Cohesion: 0.23
Nodes (12): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+4 more)

### Community 74 - "DownloadProgressDelegate"
Cohesion: 0.23
Nodes (10): Int64, DownloadProgressDelegate, Double, Result, URL, Void, URLSession, URLSessionDownloadDelegate (+2 more)

### Community 75 - "Theme"
Cohesion: 0.23
Nodes (9): .body, Color, LinearGradient, String, Theme, .narrativeBackground, .narrativeBackgroundDark, .chapterOrnament (+1 more)

### Community 76 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 77 - "GlobalMemoryServiceTests"
Cohesion: 0.24
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 78 - "SwiftUI"
Cohesion: 0.20
Nodes (4): AVFoundation, Speech, SwiftUI, UIKit

### Community 79 - "AppleFoundationEngine"
Cohesion: 0.23
Nodes (10): AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable(), Bool (+2 more)

### Community 80 - ".configError()"
Cohesion: 0.20
Nodes (7): AsyncThrowingStream, Bool, ChatResult, Int, ModelContext, String, Void

### Community 81 - "LocalModelService.swift"
Cohesion: 0.17
Nodes (11): LocalModelKind, appleFoundation, gguf, LocalModelTemplate, chatML, gemma, llama3, phi3 (+3 more)

### Community 83 - "VoiceService"
Cohesion: 0.29
Nodes (5): VoiceRecording, get_stt_provider(), AsyncSession, VoiceService, settings

### Community 84 - ".classify()"
Cohesion: 0.27
Nodes (5): FoundationModels, LanguageModelSession, AppleFoundationErrorMappingTests, LanguageModelSession, String

### Community 85 - ".processMessage()"
Cohesion: 0.24
Nodes (7): ChatResult, Bool, Int, ModelContext, String, Void, LLMSending

### Community 86 - "LLMError"
Cohesion: 0.18
Nodes (10): LLMError, apiError, contextLengthExceeded, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded, noAPIKey (+2 more)

### Community 88 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 89 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 90 - "NarrativeDocument"
Cohesion: 0.38
Nodes (5): NarrativeDocument, NarrativeExportService, String, URL, NSParagraphStyle

### Community 91 - "CompanionPersonality"
Cohesion: 0.20
Nodes (10): CompanionPersonality, bold, calm, cheerful, deep, .id, .label, playful (+2 more)

### Community 92 - "SessionRow"
Cohesion: 0.29
Nodes (7): ArchivedSessionsView, .body, ContentView, .body, SessionRow, .body, .personaKind

### Community 93 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 94 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 95 - "mode.py"
Cohesion: 0.28
Nodes (8): get_mode(), get_mode_service(), AsyncSession, get, patch, set_mode(), ModeSetRequest, ModeUpdateResponse

### Community 96 - "GlobalMemoryService"
Cohesion: 0.36
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 97 - "CompanionGender"
Cohesion: 0.22
Nodes (9): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+1 more)

### Community 98 - ".sizeThatFits()"
Cohesion: 0.31
Nodes (7): CGSize, FlowLayout, CGFloat, CGRect, Layout, ProposedViewSize, Subviews

### Community 99 - "MemoryModel"
Cohesion: 0.33
Nodes (6): MemoryModel, Data, MemoriesListView, .body, MemoryDetailView, .body

### Community 100 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, completionTokens, inputTokens, maxTokens, messages, model, outputTokens, promptTokens (+1 more)

### Community 101 - "String"
Cohesion: 0.36
Nodes (4): Never, String, Task, VoiceUtterance

### Community 102 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 103 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 104 - "chat.py"
Cohesion: 0.36
Nodes (7): chat(), get_chat_history(), AsyncSession, get, post, ChatRequest, ChatResponse

### Community 105 - "therapy.py"
Cohesion: 0.36
Nodes (7): get_progress(), get_therapy_service(), AsyncSession, get, suggest_intervention(), InterventionSuggestionResponse, ProgressResponse

### Community 106 - "VoiceService"
Cohesion: 0.39
Nodes (5): AVAudioRecorder, ModelContext, String, URL, VoiceService

### Community 107 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 108 - "RoundedCorner"
Cohesion: 0.32
Nodes (6): RoundedCorner, CGFloat, CGRect, Path, Shape, UIRectCorner

### Community 110 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 111 - "MarkdownText"
Cohesion: 0.33
Nodes (5): AttributedString, MarkdownText, .attributed, .body, String

### Community 114 - "NewSessionView"
Cohesion: 0.40
Nodes (5): NewSessionView, .body, .defaultProviderLabel, .personaName, String

### Community 115 - "NSObject"
Cohesion: 0.33
Nodes (4): XMLParserRecorder, NSObject, XMLParser, XMLParserDelegate

### Community 116 - ".narrativeFont()"
Cohesion: 0.50
Nodes (3): Font, .body, CGFloat

### Community 117 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

## Knowledge Gaps
- **208 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+203 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 601 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `GraphExportServiceTests`, `Float`, `AutoBackupService`, `SafetyServiceTests`, `ChatService`, `ChatView`, `.makeInMemoryContainer()`, `String`, `View`, `Error`, `InsightCaptureServiceTests`, `.buildIncremental()`, `DashboardView.swift`, `Foundation`, `InsightService`, `GraphNodeModel`, `PersonaKind`, `NoteModel`, `.ephemeralDefaults()`, `String`, `.configError()`, `.processMessage()`, `SessionRow`, `MemoryModel`, `VoiceService`, `NewSessionView`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `PINService`, `GraphExportServiceTests`, `AutoBackupService`, `LocalModelService`, `OnboardingView.swift`, `SessionModel`, `ChatView`, `String`, `DashboardView.swift`, `NarrativeView`, `VoicePickerView`, `SettingsView.swift`, `SpeechService`, `GlobalMemoryModel`, `NoteModel`, `SettingsView`, `SessionRow`, `MemoryModel`, `RoundedCorner`, `MarkdownText`, `NewSessionView`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `PINService`, `GraphExportServiceTests`, `Float`, `AutoBackupService`, `BackupRestorePlan`, `OpenRouterModel`, `KeychainService`, `ConversationCompactorTests`, `LocalLLMEngine`, `InsightCaptureServiceTests`, `InsightService`, `Codable`, `String`, `PersonaKind`, `Persona`, `SwiftUI`, `AppleFoundationEngine`, `LocalModelService.swift`, `TTSKeyProvider`, `NSObject`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 43 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `LocalModelService` (e.g. with `.downloadedLocalModels` and `.localAvailable`) actually correct?**
  _`LocalModelService` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _208 weakly-connected nodes found - possible documentation gaps or missing edges._