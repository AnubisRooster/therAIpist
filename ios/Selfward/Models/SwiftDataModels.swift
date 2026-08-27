import Foundation
import SwiftData

@Model
final class SessionModel {
    var id: String
    var title: String
    var provider: String  // "openrouter" or "ollama"
    var model: String
    var systemPrompt: String
    var modality: String  // "integrated", "adlerian", "jungian", "dbt"
    var mode: String      // "auto", "local", "cloud", "hybrid"
    var localModel: String
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool = false
    // Which persona drives this session: "therapist" (default) or "companion".
    // Inline default is REQUIRED for SwiftData lightweight migration to open
    // stores created before this field existed.
    var persona: String = "therapist"

    @Relationship(deleteRule: .cascade) var messages: [MessageModel] = []
    @Relationship(deleteRule: .cascade) var memories: [MemoryModel] = []
    @Relationship(deleteRule: .cascade) var graphNodes: [GraphNodeModel] = []
    @Relationship(deleteRule: .cascade) var notes: [NoteModel] = []
    @Relationship(deleteRule: .cascade) var dreams: [DreamModel] = []
    @Relationship(deleteRule: .cascade) var voiceRecordings: [VoiceRecordingModel] = []
    @Relationship(deleteRule: .cascade) var safetyEvents: [SafetyEventModel] = []

    init(title: String, provider: String = "openrouter", model: String = "", modality: String = "integrated") {
        self.id = UUID().uuidString
        self.title = title
        self.provider = provider
        self.model = model
        self.systemPrompt = ""
        self.modality = modality
        self.mode = "auto"
        self.localModel = ""
        self.isArchived = false
        self.persona = "therapist"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

extension SessionModel {
    /// The provider actually used for inference.
    /// Falls back to the app-wide default, then "openrouter".
    var resolvedProvider: String {
        if !provider.isEmpty { return provider }
        let stored = UserDefaults.standard.string(forKey: "default_provider") ?? ""
        return stored.isEmpty ? "openrouter" : stored
    }

    /// The model ID actually used for inference.
    /// For local provider, returns the session's localModel (or the app default local model).
    /// For cloud provider, returns the session's chosen cloud model, the app default, or a free fallback.
    var resolvedModel: String {
        if resolvedProvider == "local" {
            if !localModel.isEmpty { return localModel }
            let stored = UserDefaults.standard.string(forKey: "default_local_model") ?? ""
            return stored.isEmpty ? "llama-3.2-3b" : stored
        }
        if !model.isEmpty { return model }
        let stored = UserDefaults.standard.string(forKey: "default_model") ?? ""
        if !stored.isEmpty { return stored }
        return "meta-llama/llama-3.2-1b-instruct:free"
    }

    /// Short display label for session lists and the chat nav bar.
    var modelLabel: String {
        if resolvedProvider == "local" {
            return resolvedModel.replacingOccurrences(of: "-", with: " ").capitalized
        }
        return resolvedModel.components(separatedBy: "/").last ?? resolvedModel
    }
}

@Model
final class MessageModel {
    var id: String
    var session: SessionModel?
    var role: String  // "user" or "assistant"
    var content: String
    var tokenCount: Int
    var createdAt: Date

    // Captured-insight badge counts — populated after extraction runs.
    // Inline defaults are REQUIRED for SwiftData lightweight migration to
    // open stores created before these fields existed.
    var capturedNodeCount: Int = 0
    var capturedEdgeCount: Int = 0
    var capturedMemoryCount: Int = 0
    var capturedGlobalMemory: Bool = false
    var capturedDream: Bool = false
    var capturedNote: Bool = false

    init(session: SessionModel, role: String, content: String, tokenCount: Int = 0) {
        self.id = UUID().uuidString
        self.session = session
        self.role = role
        self.content = content
        self.tokenCount = tokenCount
        self.capturedNodeCount = 0
        self.capturedEdgeCount = 0
        self.capturedMemoryCount = 0
        self.capturedGlobalMemory = false
        self.createdAt = Date()
    }
}

@Model
final class MemoryModel {
    var id: String
    var session: SessionModel?
    var type: String  // "episodic", "semantic", "procedural"
    var content: String
    var keywords: String
    var embeddingData: Data?
    var importance: Float
    var createdAt: Date

    init(session: SessionModel, type: String, content: String, keywords: String = "", importance: Float = 0.5) {
        self.id = UUID().uuidString
        self.session = session
        self.type = type
        self.content = content
        self.keywords = keywords
        self.importance = importance
        self.createdAt = Date()
    }
}

@Model
final class GraphNodeModel {
    var id: String
    var session: SessionModel?
    var type: String  // "person", "event", "emotion", "belief", "theme"
    var label: String
    var propertiesData: String  // JSON string
    var strength: Float
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var outgoingEdges: [GraphEdgeModel] = []

    init(session: SessionModel, type: String, label: String, properties: [String: String] = [:], strength: Float = 1.0) {
        self.id = UUID().uuidString
        self.session = session
        self.type = type
        self.label = label
        self.propertiesData = (try? JSONSerialization.data(withJSONObject: properties).base64EncodedString()) ?? ""
        self.strength = strength
        self.createdAt = Date()
    }
}

@Model
final class GraphEdgeModel {
    var id: String
    var session: SessionModel?
    var sourceNode: GraphNodeModel?
    var targetNodeID: String
    var type: String  // "CAUSES", "TRIGGERS", "SUPPRESSES", "COMPENSATES_FOR", "ASSOCIATED_WITH"
    var weight: Float
    var createdAt: Date

    init(session: SessionModel, sourceNode: GraphNodeModel, targetNodeID: String, type: String, weight: Float = 1.0) {
        self.id = UUID().uuidString
        self.session = session
        self.sourceNode = sourceNode
        self.targetNodeID = targetNodeID
        self.type = type
        self.weight = weight
        self.createdAt = Date()
    }
}

@Model
final class NoteModel {
    var id: String
    var session: SessionModel?
    var type: String  // "session_note", "journal", "reflection"
    var title: String
    var content: String
    var structuredData: String  // JSON string
    var createdAt: Date
    var updatedAt: Date

    init(session: SessionModel, type: String, title: String, content: String) {
        self.id = UUID().uuidString
        self.session = session
        self.type = type
        self.title = title
        self.content = content
        self.structuredData = "{}"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class DreamModel {
    var id: String
    var session: SessionModel?
    var narrative: String
    var feelings: String  // JSON array
    var symbolsData: String  // JSON array of strings
    var analysis: String
    var createdAt: Date

    init(session: SessionModel, narrative: String, feelings: [String] = [], symbols: [String] = []) {
        self.id = UUID().uuidString
        self.session = session
        self.narrative = narrative
        self.feelings = (try? JSONEncoder().encode(feelings).base64EncodedString()) ?? ""
        self.symbolsData = (try? JSONEncoder().encode(symbols).base64EncodedString()) ?? ""
        self.analysis = ""
        self.createdAt = Date()
    }
}

@Model
final class VoiceRecordingModel {
    var id: String
    var session: SessionModel?
    var fileURL: String
    var duration: TimeInterval
    var transcription: String
    var createdAt: Date

    init(session: SessionModel, fileURL: String, duration: TimeInterval = 0) {
        self.id = UUID().uuidString
        self.session = session
        self.fileURL = fileURL
        self.duration = duration
        self.transcription = ""
        self.createdAt = Date()
    }
}

@Model
final class GlobalMemoryModel {
    var id: String
    var sessionID: String?
    var type: String  // "episodic", "semantic", "insight", "theme"
    var content: String
    var keywords: String
    var importance: Float
    var createdAt: Date

    init(sessionID: String? = nil, type: String = "semantic", content: String, keywords: String = "", importance: Float = 0.5) {
        self.id = UUID().uuidString
        self.sessionID = sessionID
        self.type = type
        self.content = content
        self.keywords = keywords
        self.importance = importance
        self.createdAt = Date()
    }
}

// MARK: - NarrativeDocument

/// A single, evolving document that holds the user's entire life narrative.
///
/// There is always at most one `NarrativeDocument` in the store. The
/// `NarrativeService` fetches this record (creating it on first run) and
/// overwrites `content` with a freshly-revised comprehensive narrative on
/// every generation. `sourceWatermark` advances to the newest source event
/// incorporated, so incremental updates only re-read new material.
@Model
final class NarrativeDocument {
    var id: String
    /// The full narrative prose in Markdown, rewritten as one cohesive story.
    var content: String
    /// How many sessions have been included so far.
    var sessionCount: Int
    /// The creation time of the latest source event incorporated so far.
    var sourceWatermark: Date
    var createdAt: Date
    var updatedAt: Date

    init(content: String = "", sessionCount: Int = 0, sourceWatermark: Date = .distantPast) {
        self.id = UUID().uuidString
        self.content = content
        self.sessionCount = sessionCount
        self.sourceWatermark = sourceWatermark
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: -

@Model
final class SafetyEventModel {
    var id: String
    var session: SessionModel?
    var eventType: String  // "crisis_keyword", "boundary_violation", "referral_given"
    var level: String      // "info", "warning", "critical"
    var message: String
    var createdAt: Date

    init(session: SessionModel, eventType: String, level: String, message: String = "") {
        self.id = UUID().uuidString
        self.session = session
        self.eventType = eventType
        self.level = level
        self.message = message
        self.createdAt = Date()
    }
}
