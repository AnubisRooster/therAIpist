import Foundation

/// The set of records a restore actually needs to insert.
///
/// Planning is a *pure* computation over the payload plus the ids already on
/// the device, so the idempotency rules are fully testable without SwiftData.
public struct BackupRestorePlan: Equatable, Sendable {
    public struct Session: Equatable, Sendable {
        public let id: String
        public let title: String
        public let modality: String
        public let createdAt: Date?
        public let updatedAt: Date?
        public let messages: [Message]

        public init(id: String, title: String, modality: String, createdAt: Date?, updatedAt: Date?, messages: [Message]) {
            self.id = id
            self.title = title
            self.modality = modality
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.messages = messages
        }
    }

    public struct Message: Equatable, Sendable {
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

    public struct Mood: Equatable, Sendable {
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

    public let sessions: [Session]
    public let moods: [Mood]

    public init(sessions: [Session], moods: [Mood]) {
        self.sessions = sessions
        self.moods = moods
    }

    public var sessionCount: Int { sessions.count }
    public var moodCount: Int { moods.count }

    public var allMessageIDs: [String?] {
        sessions.flatMap { $0.messages.map(\.id) }
    }
}

/// Decides which records a restore must insert, given a decrypted backup and
/// the ids that already exist on the device.
///
/// Idempotency contract (matches the historical on-device behaviour):
/// - A session is skipped when its id already exists. The whole session is
///   skipped wholesale, so any messages inside it are not restored either.
/// - A message is skipped when its id is present *and* already known. Messages
///   whose id is nil (legacy backups) are always planned.
/// - A mood is skipped when its id is present *and* already known. Moods whose
///   id is nil (legacy backups) are always planned.
/// - Deduplication also applies *within* one planning pass: a payload that
///   repeats an id plans it only once.
public enum BackupPlanner {
    public static func plan(
        payload: BackupPayload,
        existingSessionIDs: Set<String> = [],
        existingMessageIDs: Set<String> = [],
        existingMoodIDs: Set<String> = []
    ) -> BackupRestorePlan {
        var sessionIDs = existingSessionIDs
        var messageIDs = existingMessageIDs
        var moodIDs = existingMoodIDs
        var sessions: [BackupRestorePlan.Session] = []

        for snapshot in payload.sessions {
            guard !sessionIDs.contains(snapshot.id) else { continue }
            sessionIDs.insert(snapshot.id)

            var messages: [BackupRestorePlan.Message] = []
            for message in snapshot.messages {
                if let id = message.id, messageIDs.contains(id) { continue }
                messages.append(
                    BackupRestorePlan.Message(
                        id: message.id, role: message.role,
                        content: message.content, createdAt: message.createdAt
                    )
                )
                if let id = message.id { messageIDs.insert(id) }
            }

            sessions.append(
                BackupRestorePlan.Session(
                    id: snapshot.id, title: snapshot.title, modality: snapshot.modality,
                    createdAt: snapshot.createdAt, updatedAt: snapshot.updatedAt,
                    messages: messages
                )
            )
        }

        var moods: [BackupRestorePlan.Mood] = []
        for mood in payload.moods {
            if let id = mood.id, moodIDs.contains(id) { continue }
            if let id = mood.id { moodIDs.insert(id) }
            moods.append(
                BackupRestorePlan.Mood(id: mood.id, value: mood.value, note: mood.note, createdAt: mood.createdAt)
            )
        }

        return BackupRestorePlan(sessions: sessions, moods: moods)
    }
}