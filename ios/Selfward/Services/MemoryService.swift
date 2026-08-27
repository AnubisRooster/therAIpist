import Foundation
import SwiftData

class MemoryService {
    static let shared = MemoryService()

    private let embedder = EmbeddingService.shared

    func createMemory(session: SessionModel, type: String, content: String, keywords: String = "", context: ModelContext) {
        let memory = MemoryModel(session: session, type: type, content: content, keywords: keywords)
        memory.embeddingData = embedder.embed(content)
        context.insert(memory)
    }

    /// Persist a single chat exchange as an embedded episodic memory so the
    /// conversation is stored and searchable locally.
    func recordExchange(session: SessionModel, userMessage: String, assistantResponse: String, context: ModelContext) {
        let combined = "User: \(userMessage)\nTherapist: \(assistantResponse)"
        let content = String(combined.prefix(800))
        let memory = MemoryModel(
            session: session,
            type: "episodic",
            content: content,
            keywords: extractKeywords(from: userMessage),
            importance: 0.5
        )
        memory.embeddingData = embedder.embed(userMessage)
        context.insert(memory)
    }

    func consolidateRecentMessages(session: SessionModel, context: ModelContext) {
        let recentMessages = session.messages.suffix(6).filter { $0.role == "user" }
        guard recentMessages.count >= 3 else { return }

        let combined = recentMessages.map(\.content).joined(separator: "\n")
        let summary = String(combined.prefix(500))

        if let existing = session.memories.first(where: { $0.type == "semantic" && $0.content.contains(summary.prefix(50)) }) {
            existing.importance = min(existing.importance + 0.1, 1.0)
        } else {
            let keywords = extractKeywords(from: summary)
            let memory = MemoryModel(session: session, type: "semantic", content: summary, keywords: keywords, importance: 0.6)
            memory.embeddingData = embedder.embed(summary)
            context.insert(memory)
        }
    }

    func recallRelevant(session: SessionModel, query: String, context: ModelContext? = nil) -> [MemoryModel] {
        let memories = session.memories.filter { $0.type == "episodic" || $0.type == "semantic" }

        // Prefer on-device semantic similarity when embeddings are available.
        if let queryVec = embedder.embed(query) {
            let scored = memories.compactMap { mem -> (MemoryModel, Float)? in
                guard let data = mem.embeddingData else { return nil }
                return (mem, embedder.similarity(between: queryVec, and: data))
            }
            if !scored.isEmpty {
                return scored.sorted { $0.1 > $1.1 }.prefix(5).map(\.0)
            }
        }

        // Fallback: keyword overlap + importance + recency.
        let lowerQuery = query.lowercased()
        let queryWords = Set(lowerQuery.split(separator: " "))

        var scored = memories.map { mem -> (MemoryModel, Float) in
            let wordCount = queryWords.filter { mem.content.lowercased().contains($0) || mem.keywords.lowercased().contains($0) }.count
            let recencyBoost = Float(mem.createdAt.timeIntervalSinceNow * -1 / 86400).clamped(to: 0...1) * 0.2
            let score = Float(wordCount) / Float(max(queryWords.count, 1)) + mem.importance * 0.5 + recencyBoost
            return (mem, score)
        }

        // Cross-session recall: search all other sessions' memories too
        if let ctx = context {
            let fetch = FetchDescriptor<SessionModel>()
            if let allSessions = try? ctx.fetch(fetch) {
                for otherSession in allSessions where otherSession.id != session.id {
                    for mem in otherSession.memories where mem.type == "episodic" || mem.type == "semantic" {
                        let wordCount = queryWords.filter { mem.content.lowercased().contains($0) || mem.keywords.lowercased().contains($0) }.count
                        if wordCount > 0 {
                            let score = Float(wordCount) / Float(max(queryWords.count, 1)) + mem.importance * 0.3
                            scored.append((mem, score + 0.1))  // slight bonus for cross-session
                        }
                    }
                }
            }
        }

        return scored.sorted { $0.1 > $1.1 }.prefix(5).map(\.0)
    }

    func extractKeywords(from text: String) -> String {
        let stopWords: Set<String> = ["the", "a", "an", "is", "was", "were", "be", "been", "being",
                                       "have", "has", "had", "do", "does", "did", "will", "would",
                                       "can", "could", "shall", "should", "may", "might", "to", "of",
                                       "in", "for", "on", "with", "at", "by", "from", "as", "into",
                                       "through", "during", "before", "after", "above", "below",
                                       "between", "and", "but", "or", "nor", "not", "so", "yet",
                                       "i", "me", "my", "we", "our", "you", "your", "he", "she",
                                       "it", "they", "them", "this", "that", "these", "those"]

        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { $0.count > 3 && !stopWords.contains($0) }

        let counts = Dictionary(grouping: words, by: { $0 }).mapValues(\.count)
        return counts.sorted { $0.value > $1.value }.prefix(10).map(\.key).joined(separator: ", ")
    }
}

extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
