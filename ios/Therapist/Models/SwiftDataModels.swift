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
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

extension SessionModel {
    /// The model actually used for inference: the session's chosen model, then
    /// the app-wide default, then a sensible free fallback.
    var resolvedModel: String {
        if !model.isEmpty { return model }
        let stored = UserDefaults.standard.string(forKey: "default_model") ?? ""
        if !stored.isEmpty { return stored }
        return "meta-llama/llama-3.2-1b-instruct:free"
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

    init(session: SessionModel, role: String, content: String, tokenCount: Int = 0) {
        self.id = UUID().uuidString
        self.session = session
        self.role = role
        self.content = content
        self.tokenCount = tokenCount
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
