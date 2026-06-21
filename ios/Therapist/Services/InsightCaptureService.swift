import Foundation
import SwiftData

// MARK: - Result types

struct DreamCandidate {
    let narrative: String
    let feelings: [String]
    let symbols: [String]
}

// MARK: - InsightCaptureService

/// Heuristic (no LLM cost) capture of dreams and per-session summary notes.
/// Dream detection reuses the same emotion-word and common-symbol lists already
/// used by GraphService and DreamService, so the vocabulary is consistent.
enum InsightCaptureService {

    // MARK: - Dream detection

    private static let dreamCues: [String] = [
        "i had a dream", "i dreamt", "i dreamed", "in my dream",
        "last night i dreamed", "last night i dreamt", "this dream",
        "a dream where", "dream where", "nightmare", "had a nightmare",
        "dreaming about", "i was dreaming",
    ]

    private static let emotionWords: [String] = [
        "angry", "anger", "sad", "sadness", "happy", "anxious", "anxiety",
        "fearful", "fear", "guilty", "guilt", "ashamed", "shame", "hopeful",
        "lonely", "loneliness", "frustrated", "frustration", "overwhelmed",
        "hopeless", "jealous", "jealousy", "grief", "hurt", "betrayed",
        "confused", "numb", "empty", "worthless", "helpless", "terrified",
        "panic", "dread", "peaceful", "joyful", "excited", "relieved",
    ]

    private static let symbolWords: [String] = [
        "water", "house", "forest", "animal", "flight", "falling", "chase",
        "death", "birth", "marriage", "child", "snake", "bird", "fire",
        "mountain", "ocean", "door", "window", "bridge", "shadow", "light",
        "car", "road", "monster", "darkness", "blood", "teeth", "train",
        "storm", "cave", "tower", "garden", "stairs", "school", "hospital",
    ]

    /// Returns a `DreamCandidate` when `text` contains dream-cue language,
    /// extracting feelings and symbols from the message body.
    /// Returns `nil` when no dream cue is found.
    static func detectDream(in text: String) -> DreamCandidate? {
        let lower = text.lowercased()
        guard dreamCues.contains(where: { lower.contains($0) }) else { return nil }
        let feelings = emotionWords.filter { lower.contains($0) }
        let symbols  = symbolWords.filter  { lower.contains($0) }
        return DreamCandidate(narrative: text, feelings: feelings, symbols: symbols)
    }

    // MARK: - Session summary note

    /// Builds a heuristic reflection note from a session's current graph nodes,
    /// suitable for upserting once per session without any LLM call.
    ///
    /// Returns `nil` when the session has fewer than 2 user messages (nothing
    /// meaningful to summarise yet).
    static func summaryNote(for session: SessionModel) -> (title: String, content: String)? {
        let userMessages = session.messages.filter { $0.role == "user" }
        guard userMessages.count >= 2 else { return nil }

        let nodes = session.graphNodes

        // Gather up to 3 of each interesting node type by strength.
        func top(_ type: String, limit: Int = 3) -> [String] {
            nodes.filter { $0.type == type }
                .sorted { $0.strength > $1.strength }
                .prefix(limit)
                .map(\.label)
        }

        let emotions = top("emotion")
        let persons  = top("person")
        let themes   = top("theme")
        let beliefs  = top("belief")

        var lines: [String] = []
        lines.append("Messages exchanged: \(userMessages.count)")
        if !emotions.isEmpty { lines.append("Emotions surfaced: \(emotions.joined(separator: ", "))") }
        if !persons.isEmpty  { lines.append("People mentioned: \(persons.joined(separator: ", "))") }
        if !themes.isEmpty   { lines.append("Themes: \(themes.joined(separator: ", "))") }
        if !beliefs.isEmpty  { lines.append("Beliefs explored: \(beliefs.joined(separator: ", "))") }

        let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        let title = "Session Summary · \(dateStr)"
        let content = lines.joined(separator: "\n")
        return (title: title, content: content)
    }

    // MARK: - Note upsert logic

    /// Key stored in `NoteModel.structuredData` to identify auto-generated
    /// session-summary notes so they can be detected and updated rather than
    /// duplicated.
    static let summaryNoteMarker = "{\"auto\":\"summary\"}"

    /// Returns the existing auto-summary `NoteModel` for `session`, if any.
    static func existingSummaryNote(for session: SessionModel) -> NoteModel? {
        session.notes.first { $0.structuredData == summaryNoteMarker }
    }
}
