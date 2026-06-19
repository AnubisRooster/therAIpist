import Foundation
import NaturalLanguage

/// On-device sentence embeddings via Apple's NaturalLanguage framework.
/// No network call and no API key — everything runs locally on the device,
/// which keeps therapy conversations private.
final class EmbeddingService {
    static let shared = EmbeddingService()

    private let embedding: NLEmbedding? = NLEmbedding.sentenceEmbedding(for: .english)

    /// Whether an embedding model is available on this device/OS.
    var isAvailable: Bool { embedding != nil }

    // MARK: Embedding

    /// Returns a serialised `Float` vector for the given text, or `nil` when the
    /// embedding model is unavailable or the text yields no vector.
    func embed(_ text: String) -> Data? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let embedding,
              let vector = embedding.vector(for: trimmed) else { return nil }
        let floats = vector.map { Float($0) }
        return floats.withUnsafeBufferPointer { Data(buffer: $0) }
    }

    // MARK: Similarity

    /// Cosine similarity in [-1, 1]. Returns 0 when either vector is empty or the
    /// dimensions don't match.
    func similarity(between a: Data, and b: Data) -> Float {
        let va = floats(from: a)
        let vb = floats(from: b)
        guard va.count == vb.count, !va.isEmpty else { return 0 }

        let dot  = zip(va, vb).reduce(Float.zero) { $0 + $1.0 * $1.1 }
        let magA = sqrt(va.reduce(Float.zero) { $0 + $1 * $1 })
        let magB = sqrt(vb.reduce(Float.zero) { $0 + $1 * $1 })
        guard magA > 0, magB > 0 else { return 0 }
        return dot / (magA * magB)
    }

    // MARK: Private

    private func floats(from data: Data) -> [Float] {
        guard data.count >= MemoryLayout<Float>.size else { return [] }
        return data.withUnsafeBytes { raw in
            Array(raw.bindMemory(to: Float.self))
        }
    }
}
