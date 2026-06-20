import Foundation
import SwiftData

class GlobalMemoryService {
    static let shared = GlobalMemoryService()

    // MARK: - Storage

    func store(content: String, type: String = "semantic", importance: Float = 0.5,
               sessionID: String? = nil, keywords: String = "",
               context: ModelContext) -> GlobalMemoryModel {
        let memory = GlobalMemoryModel(sessionID: sessionID, type: type,
                                       content: content, keywords: keywords,
                                       importance: importance)
        context.insert(memory)
        return memory
    }

    // MARK: - Recall

    func recall(query: String, context: ModelContext, topK: Int = 5) -> [GlobalMemoryModel] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

        let fetch = FetchDescriptor<GlobalMemoryModel>(
            sortBy: [SortDescriptor(\.importance, order: .reverse)]
        )
        guard let all = try? context.fetch(fetch) else { return [] }

        let lowerQuery = query.lowercased()
        let queryWords = Set(lowerQuery.split(separator: " "))

        let scored = all.map { mem -> (GlobalMemoryModel, Float) in
            let wordCount = queryWords.filter {
                mem.content.lowercased().contains($0) ||
                mem.keywords.lowercased().contains($0)
            }.count
            let score = Float(wordCount) / Float(max(queryWords.count, 1)) +
                        mem.importance * 0.5
            return (mem, score)
        }

        return scored
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(topK)
            .map(\.0)
    }

    // MARK: - Promotion

    /// Promotes an exchange to a global memory when it contains signals of
    /// therapeutic significance.
    ///
    /// Previous behaviour required ~9 of 15 keywords to score ≥ 0.7, which
    /// essentially never fired. The new logic:
    ///
    /// - **tier-3** (high importance, 0.85): deeply significant words —
    ///   trauma, breakthrough, suicide, self-harm, abuse, childhood wounds.
    /// - **tier-2** (moderate importance, 0.65): personally meaningful words —
    ///   mother/father, always/never patterns, shame, grief, realisation.
    /// - **tier-1** (base importance, 0.45): mild signals — anxiety, fear,
    ///   loneliness, feeling stuck.
    ///
    /// Any single tier-3 hit is enough to create a global memory.
    /// Two or more tier-2 hits are enough. Three or more tier-1 hits create
    /// a lower-importance record.
    @discardableResult
    func promoteIfValuable(userMessage: String,
                           assistantResponse: String,
                           sessionID: String? = nil,
                           context: ModelContext) -> GlobalMemoryModel? {
        let combined = (userMessage + " " + assistantResponse).lowercased()

        // ── Tier-3: deeply significant ─────────────────────────────────────
        let tier3: [String] = [
            "trauma", "traumatic", "abuse", "abused", "assault",
            "suicidal", "suicide", "self-harm", "self harm", "harming myself",
            "since childhood", "as a child", "growing up", "my childhood",
            "breakthrough", "epiphany", "completely changed",
        ]

        // ── Tier-2: moderately significant ────────────────────────────────
        let tier2: [String] = [
            "my mother", "my father", "my mom", "my dad",
            "realized", "realised", "i discovered", "i learned", "i understand now",
            "for the first time", "i've never told",
            "always felt", "never felt", "always been", "never been",
            "ashamed", "shame", "guilt", "guilty",
            "grief", "grieving", "lost someone", "they died",
            "afraid", "terrified", "phobia",
            "abandoned", "rejection", "rejected", "neglected",
        ]

        // ── Tier-1: mild signal ────────────────────────────────────────────
        let tier1: [String] = [
            "anxious", "anxiety", "panic", "lonely", "loneliness",
            "hopeless", "worthless", "empty", "numb", "stuck",
            "hurt", "pain", "struggling", "overwhelmed",
            "relationship", "marriage", "divorce", "separation",
            "insight", "pattern", "repeated", "keeps happening",
        ]

        let t3hits = tier3.filter { combined.contains($0) }.count
        let t2hits = tier2.filter { combined.contains($0) }.count
        let t1hits = tier1.filter { combined.contains($0) }.count

        let importance: Float
        let type: String

        if t3hits >= 1 {
            // Deep therapeutic significance — always promote.
            importance = 0.85 + min(Float(t3hits - 1) * 0.05, 0.15)
            type = "insight"
        } else if t2hits >= 2 {
            importance = 0.65 + min(Float(t2hits - 2) * 0.05, 0.20)
            type = "semantic"
        } else if t2hits == 1 && t1hits >= 2 {
            importance = 0.55
            type = "semantic"
        } else if t1hits >= 3 {
            importance = 0.45 + min(Float(t1hits - 3) * 0.03, 0.15)
            type = "episodic"
        } else {
            return nil   // not significant enough
        }

        let content = "User: \(userMessage.prefix(400))\nTherapist: \(assistantResponse.prefix(400))"
        let keywords = MemoryService.shared.extractKeywords(
            from: userMessage + " " + assistantResponse
        )
        return store(content: String(content), type: type,
                     importance: min(importance, 1.0),
                     sessionID: sessionID,
                     keywords: keywords,
                     context: context)
    }
}
