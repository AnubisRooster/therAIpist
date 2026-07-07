import Foundation
import SwiftData
import XCTest
@testable import Therapist

/// Shared helpers for the test suite.
enum TestSupport {
    /// A fresh in-memory SwiftData container holding the full app schema.
    /// Each call is isolated, so tests never see each other's data.
    static func makeInMemoryContainer(file: StaticString = #filePath, line: UInt = #line) -> ModelContainer {
        let schema = Schema([
            SessionModel.self,
            MessageModel.self,
            MemoryModel.self,
            GraphNodeModel.self,
            GraphEdgeModel.self,
            NoteModel.self,
            DreamModel.self,
            VoiceRecordingModel.self,
            GlobalMemoryModel.self,
            SafetyEventModel.self,
            NarrativeDocument.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Force-unwrap is acceptable in tests; a failure here is a setup bug.
        // swiftlint:disable:next force_try
        return try! ModelContainer(for: schema, configurations: [config])
    }

    /// A UserDefaults backed by an ephemeral suite that is cleared on creation.
    static func ephemeralDefaults(_ name: String = UUID().uuidString) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}

/// Deterministic in-memory stand-in for the real LLM backend so ChatService can
/// be exercised end-to-end without the network or an on-device model.
final class MockLLM: LLMSending, @unchecked Sendable {
    var response: String
    var error: Error?

    private(set) var callCount = 0
    private(set) var lastProvider: String?
    private(set) var lastModel: String?
    private(set) var lastMessages: [LLMMessage] = []

    init(response: String = "Thanks for sharing that with me.", error: Error? = nil) {
        self.response = response
        self.error = error
    }

    func sendMessage(provider: String, model: String, messages: [LLMMessage]) async throws -> String {
        callCount += 1
        lastProvider = provider
        lastModel = model
        lastMessages = messages
        if let error { throw error }
        return response
    }
}

/// A mock that also conforms to `LLMStreaming`, so `ChatService` exercises its
/// sentence-splitting/`onSentence` pipeline instead of the plain `sendMessage`
/// fallback. Delivers `chunks` as successive stream deltas one at a time.
final class MockStreamingLLM: LLMSending, LLMStreaming, @unchecked Sendable {
    private let chunks: [String]
    var error: Error?
    private(set) var callCount = 0

    /// - Parameter chunks: raw deltas yielded in order; join them to get the
    ///   full reply. Doesn't need to align with sentence boundaries — the
    ///   splitter is expected to buffer across delta boundaries.
    init(chunks: [String], error: Error? = nil) {
        self.chunks = chunks
        self.error = error
    }

    func sendMessage(provider: String, model: String, messages: [LLMMessage]) async throws -> String {
        callCount += 1
        if let error { throw error }
        return chunks.joined()
    }

    func streamMessage(provider: String, model: String, messages: [LLMMessage]) -> AsyncThrowingStream<String, Error> {
        callCount += 1
        return AsyncThrowingStream { continuation in
            if let error {
                continuation.finish(throwing: error)
                return
            }
            for chunk in chunks { continuation.yield(chunk) }
            continuation.finish()
        }
    }
}
