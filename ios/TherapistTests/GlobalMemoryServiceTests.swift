import XCTest
import SwiftData
@testable import Therapist

@MainActor
final class GlobalMemoryServiceTests: XCTestCase {
    private let global = GlobalMemoryService.shared

    // Retain the container for the lifetime of each test; a context whose
    // container is deallocated crashes on insert/fetch.
    private var container: ModelContainer!

    override func setUp() {
        super.setUp()
        container = TestSupport.makeInMemoryContainer()
    }

    override func tearDown() {
        container = nil
        super.tearDown()
    }

    private func makeContext() -> ModelContext {
        container.mainContext
    }

    // MARK: - Promotion (positive)

    func testTier3KeywordAlwaysPromotes() {
        let ctx = makeContext()
        let promoted = global.promoteIfValuable(
            userMessage: "I think this all goes back to the trauma from my childhood",
            assistantResponse: "That sounds significant.",
            sessionID: "s1", context: ctx)
        XCTAssertNotNil(promoted)
        XCTAssertEqual(promoted?.type, "insight")
        XCTAssertGreaterThanOrEqual(promoted?.importance ?? 0, 0.85)
    }

    func testTwoTier2KeywordsPromote() {
        let ctx = makeContext()
        let promoted = global.promoteIfValuable(
            userMessage: "I feel so much shame about my father",
            assistantResponse: "Thank you for trusting me with that.",
            sessionID: "s1", context: ctx)
        XCTAssertNotNil(promoted)
        XCTAssertEqual(promoted?.type, "semantic")
    }

    func testThreeTier1KeywordsPromoteEpisodic() {
        let ctx = makeContext()
        let promoted = global.promoteIfValuable(
            userMessage: "I'm anxious and lonely and feel stuck",
            assistantResponse: "Let's slow down together.",
            sessionID: "s1", context: ctx)
        XCTAssertNotNil(promoted)
        XCTAssertEqual(promoted?.type, "episodic")
    }

    // MARK: - Promotion (negative)

    func testSmallTalkDoesNotPromote() {
        let ctx = makeContext()
        let promoted = global.promoteIfValuable(
            userMessage: "I watched a good movie last night",
            assistantResponse: "Nice, what was it about?",
            sessionID: "s1", context: ctx)
        XCTAssertNil(promoted)
    }

    func testSingleTier1KeywordDoesNotPromote() {
        let ctx = makeContext()
        let promoted = global.promoteIfValuable(
            userMessage: "I was a little anxious before the meeting",
            assistantResponse: "How did the meeting go?",
            sessionID: "s1", context: ctx)
        XCTAssertNil(promoted)
    }

    // MARK: - Recall

    func testRecallMatchesStoredMemoryByKeyword() {
        let ctx = makeContext()
        _ = global.store(content: "User feels grief over losing their mother",
                         type: "insight", importance: 0.9, sessionID: "s1",
                         keywords: "grief, mother, loss", context: ctx)
        let results = global.recall(query: "tell me about grief", context: ctx)
        XCTAssertFalse(results.isEmpty)
    }

    func testRecallEmptyQueryReturnsNothing() {
        let ctx = makeContext()
        _ = global.store(content: "something", context: ctx)
        XCTAssertTrue(global.recall(query: "   ", context: ctx).isEmpty)
    }
}
