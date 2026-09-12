import Foundation

/// Passphrase-protected, encrypted full-data export/restore domain.
///
/// Everything in `BackupKit` is a pure value type — no SwiftData, no UIKit —
/// so the logic is fully testable on any platform via `swift test`.

// MARK: - Payload

/// A point-in-time snapshot of all the data a backup carries.
///
/// `Sendable`: crosses into a background task for the CPU-heavy encrypt and
/// decrypt steps, so every case stays a pure value type.
public struct BackupPayload: Codable, Equatable, Sendable {
    public let sessions: [SessionSnapshot]
    public let moods: [MoodSnapshot]
    public let exportedAt: Date

    public init(sessions: [SessionSnapshot], moods: [MoodSnapshot], exportedAt: Date) {
        self.sessions = sessions
        self.moods = moods
        self.exportedAt = exportedAt
    }
}

public struct SessionSnapshot: Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let modality: String
    public let createdAt: Date?
    public let updatedAt: Date?
    public let messages: [MessageSnapshot]

    public init(id: String, title: String, modality: String, createdAt: Date?, updatedAt: Date?, messages: [MessageSnapshot]) {
        self.id = id
        self.title = title
        self.modality = modality
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = messages
    }
}

public struct MessageSnapshot: Codable, Equatable, Sendable {
    /// Optional (nil for backups exported before ids were embedded):
    /// `decodeIfPresent` keeps those files readable.
    public let id: String?
    public let role: String
    public let content: String
    public let createdAt: Date

    public init(id: String?, role: String, content: String, createdAt: Date) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
}

public struct MoodSnapshot: Codable, Equatable, Sendable {
    /// Optional (nil for backups exported before ids were embedded).
    public let id: String?
    public let value: Int
    public let note: String
    public let createdAt: Date

    public init(id: String?, value: Int, note: String, createdAt: Date) {
        self.id = id
        self.value = value
        self.note = note
        self.createdAt = createdAt
    }
}