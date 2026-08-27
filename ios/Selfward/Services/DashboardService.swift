import Foundation
import SwiftData

class DashboardService {
    static let shared = DashboardService()

    func sessionDashboard(session: SessionModel) -> SessionDashboard {
        let messages = session.messages
        let userMessages = messages.filter { $0.role == "user" }
        let assistantMessages = messages.filter { $0.role == "assistant" }

        return SessionDashboard(
            messageCount: messages.count,
            userMessageCount: userMessages.count,
            assistantMessageCount: assistantMessages.count,
            graphNodeCount: session.graphNodes.count,
            emotionCount: session.graphNodes.filter { $0.type == "emotion" }.count,
            noteCount: session.notes.count,
            dreamCount: session.dreams.count,
            topEmotions: getTopEmotions(session: session),
            themes: getThemes(session: session),
            progressSummary: generateProgressSummary(session: session)
        )
    }

    func globalDashboard(sessions: [SessionModel]) -> GlobalDashboard {
        let totalMessages = sessions.reduce(0) { $0 + $1.messages.count }
        let modalityCounts = Dictionary(grouping: sessions, by: { $0.modality }).mapValues(\.count)
        let activeSessions = sessions.filter { $0.messages.count > 0 }

        var allEmotions: [(String, Float)] = []
        for session in sessions {
            for node in session.graphNodes where node.type == "emotion" {
                allEmotions.append((node.label, node.strength))
            }
        }
        let globalThemes = Set(sessions.flatMap { $0.graphNodes.filter { $0.type == "theme" }.map(\.label) })

        return GlobalDashboard(
            totalSessions: sessions.count,
            totalMessages: totalMessages,
            totalGraphNodes: sessions.reduce(0) { $0 + $1.graphNodes.count },
            totalNotes: sessions.reduce(0) { $0 + $1.notes.count },
            totalDreams: sessions.reduce(0) { $0 + $1.dreams.count },
            modalityDistribution: modalityCounts,
            activeSessions: activeSessions.count,
            globalThemes: Array(globalThemes),
            recentNotes: getRecentNotes(sessions: sessions)
        )
    }

    private func getTopEmotions(session: SessionModel) -> [(String, Float)] {
        session.graphNodes.filter { $0.type == "emotion" }
            .map { ($0.label, $0.strength) }
            .sorted { $0.1 > $1.1 }
    }

    private func getThemes(session: SessionModel) -> [String] {
        session.graphNodes.filter { $0.type == "theme" }.map(\.label)
    }

    private func generateProgressSummary(session: SessionModel) -> String {
        let messages = session.messages
        if messages.count < 4 {
            return "Therapy is in early stages. Continue building rapport and exploring the client's narrative."
        }

        let emotions = getTopEmotions(session: session)
        if emotions.isEmpty {
            return "\(messages.count) messages exchanged. Emotional themes are emerging."
        }

        return "\(messages.count) messages exchanged. Key emotions: \(emotions.map(\.0).joined(separator: ", ")). Progress is being made in identifying patterns."
    }

    private func getRecentNotes(sessions: [SessionModel]) -> [(String, String, Date)] {
        let allNotes = sessions.flatMap { session in
            session.notes.map { (session.title, $0.title, $0.createdAt) }
        }
        return allNotes.sorted { $0.2 > $1.2 }.prefix(5).map { ($0.0, $0.1, $0.2) }
    }
}

struct SessionDashboard {
    let messageCount: Int
    let userMessageCount: Int
    let assistantMessageCount: Int
    let graphNodeCount: Int
    let emotionCount: Int
    let noteCount: Int
    let dreamCount: Int
    let topEmotions: [(String, Float)]
    let themes: [String]
    let progressSummary: String
}

struct GlobalDashboard {
    let totalSessions: Int
    let totalMessages: Int
    let totalGraphNodes: Int
    let totalNotes: Int
    let totalDreams: Int
    let modalityDistribution: [String: Int]
    let activeSessions: Int
    let globalThemes: [String]
    let recentNotes: [(String, String, Date)]
}
