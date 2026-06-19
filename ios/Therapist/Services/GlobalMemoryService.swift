import Foundation
import SwiftData

class GlobalMemoryService {
    static let shared = GlobalMemoryService()

    func store(content: String, type: String = "semantic", importance: Float = 0.5, sessionID: String? = nil, keywords: String = "", context: ModelContext) -> GlobalMemoryModel {
        let memory = GlobalMemoryModel(sessionID: sessionID, type: type, content: content, keywords: keywords, importance: importance)
        context.insert(memory)
        return memory
    }

    func recall(query: String, context: ModelContext, topK: Int = 5) -> [GlobalMemoryModel] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

        let fetch = FetchDescriptor<GlobalMemoryModel>(
            sortBy: [SortDescriptor(\.importance, order: .reverse)]
        )
        guard let all = try? context.fetch(fetch) else { return [] }

        let lowerQuery = query.lowercased()
        let queryWords = Set(lowerQuery.split(separator: " "))

        let scored = all.map { mem -> (GlobalMemoryModel, Float) in
            let wordCount = queryWords.filter { mem.content.lowercased().contains($0) || mem.keywords.lowercased().contains($0) }.count
            let score = Float(wordCount) / Float(max(queryWords.count, 1)) + mem.importance * 0.5
            return (mem, score)
        }

        return scored.filter { $0.1 > 0 }.sorted { $0.1 > $1.1 }.prefix(topK).map(\.0)
    }

    func promoteIfValuable(userMessage: String, assistantResponse: String, sessionID: String? = nil, context: ModelContext) -> GlobalMemoryModel? {
        let importanceKeywords = [
            "realized", "insight", "breakthrough", "always", "never", "since childhood",
            "my mother", "my father", "trauma", "afraid", "ashamed", "guilty",
            "i learned", "i discovered", "for the first time",
        ]
        let combined = (userMessage + " " + assistantResponse).lowercased()
        let hits = importanceKeywords.filter { combined.contains($0) }.count
        let importance = 0.3 + (Float(hits) / Float(importanceKeywords.count)) * 0.7

        guard importance >= 0.7 else { return nil }

        let content = "User: \(userMessage.prefix(300))\nTherapist: \(assistantResponse.prefix(300))"
        let keywords = MemoryService.shared.extractKeywords(from: userMessage + " " + assistantResponse)
        return store(content: String(content), importance: importance, sessionID: sessionID, keywords: keywords, context: context)
    }
}
