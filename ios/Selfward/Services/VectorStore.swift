import Foundation

class VectorStore {
    static let shared = VectorStore()

    private var entries: [(id: String, embedding: [Float], text: String)] = []

    func store(id: String, embedding: [Float], text: String) {
        entries.append((id, embedding, text))
    }

    func search(embedding: [Float], topK: Int = 5) -> [(id: String, score: Float, text: String)] {
        let scored = entries.map { entry in
            (entry.id, cosineSimilarity(embedding, entry.embedding), entry.text)
        }
        return scored.sorted { $0.1 > $1.1 }.prefix(topK).map { ($0.0, $0.1, $0.2) }
    }

    func keywordSearch(query: String, topK: Int = 5) -> [(id: String, text: String)] {
        let lowerQuery = query.lowercased()
        let queryWords = Set(lowerQuery.split(separator: " "))

        let scored = entries.map { entry in
            let wordCount = queryWords.filter { entry.text.lowercased().contains($0) }.count
            return (entry.id, wordCount, entry.text)
        }
        return scored.filter { $0.1 > 0 }.sorted { $0.1 > $1.1 }.prefix(topK).map { ($0.0, $0.2) }
    }

    func remove(id: String) {
        entries.removeAll { $0.id == id }
    }

    func clear() {
        entries.removeAll()
    }

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        let dot = zip(a, b).reduce(0) { $0 + $1.0 * $1.1 }
        let normA = sqrt(a.reduce(0) { $0 + $1 * $1 })
        let normB = sqrt(b.reduce(0) { $0 + $1 * $1 })
        guard normA > 0, normB > 0 else { return 0 }
        return dot / (normA * normB)
    }
}
