# Graph Report - therAIpist  (2026-09-12)

## Corpus Check
- Large corpus: 238 files · ~1,878,108 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2533 nodes · 6128 edges · 122 communities (104 shown, 10 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 607 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- ChatService
- cytoscape.min.js
- LocalModelService
- PINService
- Float
- AgentContext
- InMemoryVectorStore
- MoodSnapshot
- OpenRouterModel
- SessionModel
- ChatMessage
- DashboardView.swift
- OnboardingView.swift
- Base
- SpeechService
- DreamService
- asyncio
- schemas.py
- String
- VoiceConversationController
- InsightService
- Codable
- ChatService
- notes.py
- String
- .get()
- Coordinator
- View
- NarrativeView
- Session
- Identifiable
- InsightCaptureServiceTests
- LocalLLMEngine
- ChatView
- .body
- asyncio
- database.py
- providers/__init__.py
- GraphService
- DreamModel
- Theme
- TherapyService
- api/memory.py
- InsightService
- SafetyServiceTests
- TTSCoordinator
- Foundation
- CompanionPersonality
- SelfwardDesktop
- NoteModel
- .resolve()
- VoiceTranscriptTests
- SpiritualTradition
- .makeInMemoryContainer()
- asyncio
- MemoryService
- XCTest
- test_dreams.py
- SwiftUI
- .sizeThatFits()
- NarrativeDocument
- AutoBackupService
- GraphService
- asyncio
- graph_ui.py
- MarkdownText
- GraphExportServiceTests
- LLMProvider
- api/voice.py
- SafetyService
- Persona
- String
- XCTestCase
- test_notes.py
- BackupFolderPicker
- ActiveImaginationTests
- GlobalMemoryServiceTests
- AppleFoundationEngine
- MemoryModel
- PersonaKind
- get_db()
- LocalLLMError
- SpiritualPersonaTests
- .decrypt()
- test_auth.py
- mode.py
- EncryptedBackupDocument
- test_graph_ui.py
- test_safety.py
- test_voice.py
- chat.py
- therapy.py
- GlobalMemoryService
- .schedule()
- DashboardSheet
- test_dashboard.py
- test_sessions.py
- TTSKeyProvider
- VoiceSettingsView
- test_chat.py
- GlobalMemoryService
- NodeConnectionsSheet
- NewSessionView
- TestModalityPrompts
- VoiceStatusBar
- Phase
- test_safety_enforcement.py
- env.py
- test_health_endpoint()
- get_dashboard_service()
- get_graph_service()
- graphify_pipeline.py
- PackageDescription
- therapist

## God Nodes (most connected - your core abstractions)
1. `SessionModel` - 143 edges
2. `GraphService` - 46 edges
3. `LocalModelService` - 46 edges
4. `AgentContext` - 44 edges
5. `Base` - 37 edges
6. `SwiftData` - 36 edges
7. `ChatService` - 35 edges
8. `MemoryService` - 34 edges
9. `VoiceConversationController` - 34 edges
10. `ChatService` - 33 edges

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
  tests/test_therapy.py → app/models/base.py

## Import Cycles
- None detected.

## Communities (122 total, 10 thin omitted)

### Community 0 - "ChatService"
Cohesion: 0.05
Nodes (39): MessageModel, Bool, ChatResult, ChatService, AsyncThrowingStream, Bool, Int, ModelContext (+31 more)

### Community 1 - "cytoscape.min.js"
Cohesion: 0.05
Nodes (58): a(), Ao(), b(), Ba(), cs(), d(), dc(), ds() (+50 more)

### Community 2 - "LocalModelService"
Cohesion: 0.06
Nodes (52): Int64, DownloadProgressDelegate, HFModel, HFSibling, HuggingFaceModelService, LocalModel, LocalModelKind, appleFoundation (+44 more)

### Community 3 - "PINService"
Cohesion: 0.06
Nodes (39): KeychainLockoutStore, PINAttemptResult, incorrect, lockedOut, success, PINLockout, .isLockedOut, PINLockoutStore (+31 more)

### Community 4 - "Float"
Cohesion: 0.07
Nodes (34): ClosedRange, AdlerianAgent, .name, AgentContext, AgentOrchestrator, .agentNames, AgentResult, CrisisAgent (+26 more)

### Community 5 - "AgentContext"
Cohesion: 0.10
Nodes (29): AgentContext, AgentResult, ABC, TherapyAgent, CrisisAgent, AgentResult, AgentOrchestrator, AdlerianAgent (+21 more)

### Community 6 - "InMemoryVectorStore"
Cohesion: 0.06
Nodes (22): Settings, AsyncSession, cosine_similarity(), get_vector_store(), InMemoryVectorStore, ABC, QdrantVectorStore, reset_vector_store() (+14 more)

### Community 7 - "MoodSnapshot"
Cohesion: 0.09
Nodes (31): CommonCrypto, CryptoKit, Equatable, BackupCrypto, Data, String, BackupPayload, MessageSnapshot (+23 more)

### Community 8 - "OpenRouterModel"
Cohesion: 0.06
Nodes (37): App, CodingKey, Decoder, Hashable, AppRootView, .body, RootTabView, SelfwardApp (+29 more)

### Community 9 - "SessionModel"
Cohesion: 0.07
Nodes (33): IndexSet, SessionModel, .modelLabel, .resolvedModel, .resolvedProvider, .body, ArchivedSessionsView, .body (+25 more)

### Community 10 - "ChatMessage"
Cohesion: 0.09
Nodes (19): Message, ChatMessage, ChatResult, LLMProvider, ABC, BaseModel, get_provider(), OllamaProvider (+11 more)

### Community 11 - "DashboardView.swift"
Cohesion: 0.10
Nodes (31): Charts, GlobalMemoryModel, GraphEdgeModel, GraphNodeModel, .body, EdgesListView, .body, .filtered (+23 more)

### Community 12 - "OnboardingView.swift"
Cohesion: 0.09
Nodes (37): AboutYouStep, .body, APIKeyStep, .body, BulletRow, BulletRow2, .body, .body (+29 more)

### Community 13 - "Base"
Cohesion: 0.15
Nodes (14): Base, Message, GraphEdge, GraphNode, EpisodicMemory, SemanticMemory, AgentService, DeclarativeBase (+6 more)

### Community 14 - "SpeechService"
Cohesion: 0.10
Nodes (25): AVSpeechSynthesisVoiceQuality, AVSpeechSynthesizer, AVSpeechSynthesizerDelegate, AVSpeechUtterance, SpeechService, AVSpeechSynthesisVoice, Bool, String (+17 more)

### Community 15 - "DreamService"
Cohesion: 0.11
Nodes (23): analyze_dream(), create_dream(), delete_dream(), extract_symbols(), get_dream(), get_dream_service(), json_loads(), list_dreams() (+15 more)

### Community 16 - "asyncio"
Cohesion: 0.09
Nodes (7): asyncio, TestExtraction, TestGraphChatIntegration, TestGraphEdgeOperations, TestGraphNodeOperations, TestSessionGraph, TestThemesAndPatterns

### Community 17 - "schemas.py"
Cohesion: 0.15
Nodes (30): create_edge(), create_node(), extract(), get_connections(), get_node(), get_patterns(), get_session_graph(), get_themes() (+22 more)

### Community 18 - "String"
Cohesion: 0.12
Nodes (18): MoodEntryModel, SafetyEventModel, Date, Int, String, TimeInterval, VoiceRecordingModel, MoodStore (+10 more)

### Community 19 - "VoiceConversationController"
Cohesion: 0.18
Nodes (12): Bool, Never, String, Task, TimeInterval, Timer, Void, VoiceConversationController (+4 more)

### Community 20 - "InsightService"
Cohesion: 0.14
Nodes (22): _build_summary(), get_adlerian_insights(), get_all_insights(), get_cycles(), get_dbt_recommendations(), get_insight_service(), get_shadow_observations(), AsyncSession (+14 more)

### Community 21 - "Codable"
Cohesion: 0.16
Nodes (27): Codable, AnthropicContentBlock, AnthropicMessage, AnthropicRequest, AnthropicResponse, AnthropicUsage, CodingKeys, completionTokens (+19 more)

### Community 22 - "ChatService"
Cohesion: 0.13
Nodes (20): create_session(), delete_session(), get_session(), list_sessions(), AsyncSession, delete, get, patch (+12 more)

### Community 23 - "notes.py"
Cohesion: 0.13
Nodes (17): create_note(), delete_note(), get_note_service(), list_notes(), AsyncSession, delete, get, patch (+9 more)

### Community 24 - "String"
Cohesion: 0.18
Nodes (16): BYOKLLMKit, LLMMessage, LLMError, apiError, emptyResponse, .errorDescription, localModelLoadFailed, localModelNotDownloaded (+8 more)

### Community 25 - ".get()"
Cohesion: 0.15
Nodes (8): .passphrase, APIKeyProvider, KeychainService, Bool, String, .byokProviders, .body, ProviderRoutingTests

### Community 26 - "Coordinator"
Cohesion: 0.11
Nodes (17): Coordinator, GraphVisualizationView, ShareSheet, Any, Context, Coordinator, Void, UIActivityViewController (+9 more)

### Community 27 - "View"
Cohesion: 0.14
Nodes (20): BadgePill, .body, GradientHeader, .body, PersonaAvatar, Bool, Color, LinearGradient (+12 more)

### Community 28 - "NarrativeView"
Cohesion: 0.12
Nodes (21): NarrativeSettingsSheet, .body, .cloudModelPlaceholder, .usesCloud, NarrativeView, .body, .cloudProvidersWithKeys, .document (+13 more)

### Community 29 - "Session"
Cohesion: 0.21
Nodes (18): Session, ModeService, AsyncSession, asyncio, AsyncSession, fixture, test_get_mode_default(), test_get_mode_not_found() (+10 more)

### Community 30 - "Identifiable"
Cohesion: 0.20
Nodes (11): Identifiable, AggregatedEdge, AggregatedGraph, AggregatedNode, GraphExportService, Int, String, URL (+3 more)

### Community 31 - "InsightCaptureServiceTests"
Cohesion: 0.15
Nodes (8): BadgeBackfillService, ModelContext, DreamCandidate, InsightCaptureService, String, InsightCaptureServiceTests, Int, ModelContainer

### Community 32 - "LocalLLMEngine"
Cohesion: 0.15
Nodes (11): LocalLLMEngine, Int, Never, String, Task, URL, Void, LocalLLMEngineTests (+3 more)

### Community 33 - "ChatView"
Cohesion: 0.15
Nodes (15): ChatView, .body, .hasActiveCrisis, .isBusy, .modelLabel, .persona, Bool, ChatService (+7 more)

### Community 34 - ".body"
Cohesion: 0.14
Nodes (16): AboutYouSettingsView, .body, KeysAndProvidersSettingsView, .body, PrivacySettingsView, .body, ProviderKeySection, SettingsTabView (+8 more)

### Community 35 - "asyncio"
Cohesion: 0.13
Nodes (6): asyncio, TestBuildContext, TestCycleDetection, TestGenerateInsights, TestInsightsAPI, TestParseInsights

### Community 36 - "database.py"
Cohesion: 0.13
Nodes (17): get_agent_service(), list_agents(), AsyncSession, get, post, route_message(), health_check(), get (+9 more)

### Community 37 - "providers/__init__.py"
Cohesion: 0.16
Nodes (9): VoiceRecording, get_stt_provider(), ABC, STTProvider, TranscriptResult, MockSTTProvider, AsyncSession, VoiceService (+1 more)

### Community 38 - "GraphService"
Cohesion: 0.15
Nodes (6): GraphService, AsyncSession, db_session(), graph_service(), insight_service(), fixture

### Community 39 - "DreamModel"
Cohesion: 0.15
Nodes (14): DreamModel, DreamService, ModelContext, String, DreamDetailView, .body, .feelings, .symbols (+6 more)

### Community 40 - "Theme"
Cohesion: 0.15
Nodes (15): Actions, Font, AnimatedEmptyState, .body, .body, CGFloat, Color, LinearGradient (+7 more)

### Community 41 - "TherapyService"
Cohesion: 0.13
Nodes (11): get_global_dashboard(), get_session_dashboard(), get, DashboardService, AsyncSession, AsyncSession, TherapyService, db_session() (+3 more)

### Community 42 - "api/memory.py"
Cohesion: 0.17
Nodes (20): consolidate(), get_memory_service(), list_episodic(), list_procedural(), list_semantic(), AsyncSession, get, post (+12 more)

### Community 43 - "InsightService"
Cohesion: 0.26
Nodes (3): InsightResult, InsightService, String

### Community 44 - "SafetyServiceTests"
Cohesion: 0.13
Nodes (3): CrisisResources, Resource, SafetyServiceTests

### Community 45 - "TTSCoordinator"
Cohesion: 0.23
Nodes (11): AnyCancellable, CheckedContinuation, PrefetchedSentence, text, Bool, Never, Task, Void (+3 more)

### Community 46 - "Foundation"
Cohesion: 0.17
Nodes (5): BackupKit, Foundation, BackupPayloadTests, Security, SwiftData

### Community 47 - "CompanionPersonality"
Cohesion: 0.11
Nodes (19): CaseIterable, CompanionGender, feminine, .id, .label, masculine, nonbinary, .promptLine (+11 more)

### Community 48 - "SelfwardDesktop"
Cohesion: 0.19
Nodes (7): Selfward Desktop Client (Windows/Linux/macOS) A simple desktop client using…, SelfwardDesktop, run(), run(), run(), create(), run()

### Community 49 - "NoteModel"
Cohesion: 0.21
Nodes (9): NoteModel, NoteService, ModelContext, String, NoteDetailView, .body, NotesListView, .body (+1 more)

### Community 50 - ".resolve()"
Cohesion: 0.23
Nodes (4): PersonaService, UserDefaults, PersonaTests, TestSupport

### Community 52 - "SpiritualTradition"
Cohesion: 0.11
Nodes (14): SpiritualTradition, buddhist, christian, hindu, .id, interfaith, islamic, jewish (+6 more)

### Community 53 - ".makeInMemoryContainer()"
Cohesion: 0.18
Nodes (6): InsightServiceTests, ModelContainer, MemoryServiceTests, ModelContainer, StaticString, UInt

### Community 54 - "asyncio"
Cohesion: 0.16
Nodes (5): asyncio, TestConsolidation, TestEpisodicMemory, TestProceduralMemory, TestSemanticMemory

### Community 57 - "test_dreams.py"
Cohesion: 0.21
Nodes (17): asyncio, test_analyze_dream(), test_analyze_dream_not_found(), test_analyze_dream_provider_error(), test_create_dream(), test_delete_dream(), test_delete_dream_not_found(), test_dream_custom_date() (+9 more)

### Community 58 - "SwiftUI"
Cohesion: 0.18
Nodes (8): AVAudioRecorder, AVFoundation, ModelContext, String, URL, VoiceService, Speech, SwiftUI

### Community 59 - ".sizeThatFits()"
Cohesion: 0.16
Nodes (13): CGSize, RoundedCorner, CGFloat, CGRect, FlowLayout, CGFloat, CGRect, Layout (+5 more)

### Community 60 - "NarrativeDocument"
Cohesion: 0.20
Nodes (7): NarrativeDocument, NarrativeExportService, String, URL, NarrativeTests, ModelContainer, NSParagraphStyle

### Community 61 - "AutoBackupService"
Cohesion: 0.23
Nodes (10): AutoBackupService, .folderDisplayName, .isEnabled, .lastBackupDate, Bool, Date, Int, ModelContext (+2 more)

### Community 62 - "GraphService"
Cohesion: 0.31
Nodes (6): EdgeSpec, Extraction, GraphService, NodeSpec, ModelContext, String

### Community 63 - "asyncio"
Cohesion: 0.20
Nodes (3): asyncio, TestInterventionSuggestion, TestTherapyAPI

### Community 64 - "graph_ui.py"
Cohesion: 0.17
Nodes (11): get_graph_ui_service(), get_stats(), get_timeline(), get_visualization(), AsyncSession, get, GraphStatsResponse, GraphTimelineResponse (+3 more)

### Community 65 - "MarkdownText"
Cohesion: 0.15
Nodes (13): AttributedString, MarkdownText, .attributed, .body, String, CapturedBadgeRow, .body, CrisisBanner (+5 more)

### Community 66 - "GraphExportServiceTests"
Cohesion: 0.29
Nodes (3): GraphExportServiceTests, Int, ModelContainer

### Community 67 - "LLMProvider"
Cohesion: 0.12
Nodes (16): LLMProvider, anthropic, .baseURL, deepseek, .displayName, .exampleModelID, groq, .id (+8 more)

### Community 68 - "api/voice.py"
Cohesion: 0.21
Nodes (13): delete_recording(), get_voice_service(), list_recordings(), AsyncSession, delete, get, post, upload_audio() (+5 more)

### Community 69 - "SafetyService"
Cohesion: 0.23
Nodes (5): SafetyEvent, _is_negated(), AsyncSession, Return True when a negation cue immediately precedes ``start``., SafetyService

### Community 70 - "Persona"
Cohesion: 0.22
Nodes (4): Persona, .displayName, String, TherapyService

### Community 71 - "String"
Cohesion: 0.27
Nodes (6): SafetyService, StoreProtection, Bool, String, URL, UserNotifications

### Community 72 - "XCTestCase"
Cohesion: 0.14
Nodes (3): GraphServiceTests, HuggingFaceCatalogTests, XCTestCase

### Community 73 - "test_notes.py"
Cohesion: 0.35
Nodes (13): AsyncClient, asyncio, test_create_journal_entry(), test_create_note_invalid_type(), test_create_session_note(), test_delete_note(), test_delete_note_not_found(), test_list_notes() (+5 more)

### Community 74 - "BackupFolderPicker"
Cohesion: 0.27
Nodes (8): BackupFolderPicker, Coordinator, Context, Coordinator, URL, Void, UIDocumentPickerDelegate, UIDocumentPickerViewController

### Community 76 - "GlobalMemoryServiceTests"
Cohesion: 0.27
Nodes (3): GlobalMemoryServiceTests, ModelContainer, ModelContext

### Community 77 - "AppleFoundationEngine"
Cohesion: 0.23
Nodes (10): FoundationModels, AppleFoundationEngine, .isAvailable, .statusLabel, AppleFoundationError, .errorDescription, unavailable, appleFoundationModelAvailable() (+2 more)

### Community 78 - "MemoryModel"
Cohesion: 0.39
Nodes (6): MemoryModel, Data, String, MemoryService, ModelContext, String

### Community 79 - "PersonaKind"
Cohesion: 0.17
Nodes (12): PersonaKind, .avatarAssetName, .blurb, companion, .defaultName, .fallbackLabel, .icon, .id (+4 more)

### Community 80 - "get_db()"
Cohesion: 0.22
Nodes (10): get_events(), get_safety_service(), get_summary(), AsyncSession, get, get_db(), AsyncSession, SafetyEventResponse (+2 more)

### Community 81 - "LocalLLMError"
Cohesion: 0.18
Nodes (11): AutoBackupError, .errorDescription, noAutoBackupsFound, noFolderChosen, LocalLLMError, busy, .errorDescription, loadFailed (+3 more)

### Community 83 - ".decrypt()"
Cohesion: 0.42
Nodes (4): BackupService, Data, ModelContext, Payload

### Community 84 - "test_auth.py"
Cohesion: 0.33
Nodes (10): api_key(), AsyncClient, asyncio, fixture, Enable API-key auth for the duration of a test, then restore., test_auth_disabled_allows_request(), test_bearer_key_accepted(), test_missing_key_is_rejected() (+2 more)

### Community 85 - "mode.py"
Cohesion: 0.24
Nodes (9): get_mode(), get_mode_service(), AsyncSession, get, patch, set_mode(), ModeResponse, ModeSetRequest (+1 more)

### Community 86 - "EncryptedBackupDocument"
Cohesion: 0.22
Nodes (8): FileDocument, FileWrapper, EncryptedBackupDocument, .readableContentTypes, Data, ReadConfiguration, UTType, WriteConfiguration

### Community 87 - "test_graph_ui.py"
Cohesion: 0.36
Nodes (9): asyncio, test_stats_degree_distribution(), test_stats_empty(), test_stats_with_data(), test_timeline_empty(), test_timeline_with_data(), test_visualization_colors_and_shapes(), test_visualization_empty() (+1 more)

### Community 88 - "test_safety.py"
Cohesion: 0.36
Nodes (9): asyncio, test_boundary_detection(), test_crisis_detection_in_chat(), test_crisis_detection_multiple_patterns(), test_normal_chat_still_works_with_safety(), test_normal_message_no_crisis(), test_referral_logged(), test_safety_events_empty() (+1 more)

### Community 89 - "test_voice.py"
Cohesion: 0.36
Nodes (9): asyncio, test_delete_recording(), test_delete_recording_not_found(), test_list_recordings(), test_list_recordings_empty(), test_upload_audio(), test_upload_cleans_up_file(), test_voice_chat() (+1 more)

### Community 90 - "chat.py"
Cohesion: 0.33
Nodes (8): chat(), get_chat_history(), AsyncSession, get, post, ChatRequest, ChatResponse, MessageResponse

### Community 91 - "therapy.py"
Cohesion: 0.31
Nodes (8): get_progress(), get_therapy_service(), AsyncSession, get, suggest_intervention(), InterventionSuggestionResponse, ProgressResponse, TherapyService

### Community 92 - "GlobalMemoryService"
Cohesion: 0.36
Nodes (3): GlobalMemory, GlobalMemoryService, AsyncSession

### Community 93 - ".schedule()"
Cohesion: 0.39
Nodes (4): ReminderScheduler, Int, UNNotificationRequest, UNUserNotificationCenter

### Community 94 - "DashboardSheet"
Cohesion: 0.22
Nodes (9): DashboardSheet, dreams, edges, globalMemories, graphMap, .id, memories, nodes (+1 more)

### Community 95 - "test_dashboard.py"
Cohesion: 0.39
Nodes (8): asyncio, test_global_dashboard_empty(), test_global_dashboard_recent_notes(), test_global_dashboard_tracks_graph_data(), test_global_dashboard_with_data(), test_session_dashboard_empty(), test_session_dashboard_summary_fields(), test_session_dashboard_with_data()

### Community 96 - "test_sessions.py"
Cohesion: 0.50
Nodes (8): AsyncClient, asyncio, test_create_session(), test_delete_session(), test_get_session(), test_get_session_not_found(), test_list_sessions(), test_update_session()

### Community 97 - "TTSKeyProvider"
Cohesion: 0.25
Nodes (7): Combine, TTSKeyProvider, .displayName, elevenlabs, .keychainKey, .keyHint, VoiceLoopKit

### Community 98 - "VoiceSettingsView"
Cohesion: 0.29
Nodes (7): ElevenLabsTTSEngine, Double, String, VoiceSettingsView, .body, .elevenLabsSection, .openAISection

### Community 99 - "test_chat.py"
Cohesion: 0.54
Nodes (7): AsyncClient, asyncio, test_chat_consolidates_memories(), test_chat_recalls_memories(), test_chat_session_not_found(), test_chat_with_history(), test_get_chat_history()

### Community 100 - "GlobalMemoryService"
Cohesion: 0.57
Nodes (4): GlobalMemoryService, Int, ModelContext, String

### Community 101 - "NodeConnectionsSheet"
Cohesion: 0.43
Nodes (6): Connection, NodeConnectionsSheet, .body, .connections, Int, String

### Community 102 - "NewSessionView"
Cohesion: 0.33
Nodes (5): NewSessionView, .body, .defaultProviderLabel, .personaName, String

### Community 104 - "VoiceStatusBar"
Cohesion: 0.33
Nodes (6): Color, VoiceStatusBar, .body, .icon, .label, .tint

### Community 105 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, idle, listening, speaking, thinking

### Community 106 - "test_safety_enforcement.py"
Cohesion: 0.60
Nodes (4): asyncio, test_boundary_response_is_filtered(), test_crisis_resource_message_consistent(), test_negation_is_not_crisis()

### Community 108 - "test_health_endpoint()"
Cohesion: 0.50
Nodes (3): AsyncClient, asyncio, test_health_endpoint()

### Community 109 - "get_dashboard_service()"
Cohesion: 0.67
Nodes (3): get_dashboard_service(), AsyncSession, DashboardService

### Community 110 - "get_graph_service()"
Cohesion: 0.67
Nodes (3): get_graph_service(), AsyncSession, GraphService

## Knowledge Gaps
- **202 isolated node(s):** `PackageDescription`, `CryptoKit`, `CommonCrypto`, `sealFailed`, `malformed` (+197 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 557 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SessionModel` connect `SessionModel` to `ChatService`, `Float`, `DashboardView.swift`, `String`, `View`, `Identifiable`, `InsightCaptureServiceTests`, `ChatView`, `DreamModel`, `InsightService`, `NoteModel`, `.resolve()`, `.makeInMemoryContainer()`, `SwiftUI`, `GraphService`, `GraphExportServiceTests`, `XCTestCase`, `MemoryModel`, `SpiritualPersonaTests`, `.decrypt()`, `NewSessionView`?**
  _High betweenness centrality (0.090) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `LocalModelService`, `PINService`, `OpenRouterModel`, `SessionModel`, `DashboardView.swift`, `OnboardingView.swift`, `SpeechService`, `String`, `NarrativeView`, `Identifiable`, `ChatView`, `.body`, `DreamModel`, `Theme`, `NoteModel`, `.sizeThatFits()`, `MarkdownText`, `VoiceSettingsView`, `NodeConnectionsSheet`, `NewSessionView`, `VoiceStatusBar`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `LocalModelService`, `Float`, `MoodSnapshot`, `OpenRouterModel`, `String`, `Codable`, `String`, `Identifiable`, `InsightCaptureServiceTests`, `LocalLLMEngine`, `DreamModel`, `InsightService`, `CompanionPersonality`, `NoteModel`, `SwiftUI`, `GraphService`, `Persona`, `String`, `AppleFoundationEngine`, `TTSKeyProvider`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Are the 40 inferred relationships involving `SessionModel` (e.g. with `.buildIncremental()` and `.restore()`) actually correct?**
  _`SessionModel` has 40 INFERRED edges - model-reasoned connections that need verification._
- **Are the 18 inferred relationships involving `GraphService` (e.g. with `create_edge()` and `create_node()`) actually correct?**
  _`GraphService` has 18 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `LocalModelService` (e.g. with `.downloadedLocalModels` and `.localAvailable`) actually correct?**
  _`LocalModelService` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `CryptoKit`, `CommonCrypto` to the rest of the system?**
  _202 weakly-connected nodes found - possible documentation gaps or missing edges._