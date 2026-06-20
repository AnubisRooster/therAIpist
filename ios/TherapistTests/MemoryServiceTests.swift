import XCTest
import SwiftData
@testable import Therapist

@MainActor
final class MemoryServiceTests: XCTestCase {
    private let memory = MemoryService.shared

    // MARK: - Keyword extraction

    func testExtractKeywordsDropsStopwordsAndShortWords() {
        let keywords = memory.extractKeywords(from: "I have been feeling very anxious about my job interview")
        XCTAssertTrue(keywords.contains("anxious"))
        XCTAssertTrue(keywords.contains("interview"))
        XCTAssertFalse(keywords.contains("the"))
        XCTAssertFalse(keywords.contains("i,"))
    }

    func testExtractKeywordsEmptyForStopwordsOnly() {
        let keywords = memory.extractKeywords(from: "I am the a an it to of")
        XCTAssertTrue(keywords.isEmpty)
    }

    // MARK: - Recording exchanges

    func testRecordExchangeInsertsEpisodicMemory() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = SessionModel(title: "T")
        ctx.insert(session)

        memory.recordExchange(session: session,
                              userMessage: "I'm worried about work",
                              assistantResponse: "Tell me more about that.",
                              context: ctx)

        XCTAssertEqual(session.memories.count, 1)
        XCTAssertEqual(session.memories.first?.type, "episodic")
    }

    func testConsolidateRequiresThreeUserMessages() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = SessionModel(title: "T")
        ctx.insert(session)

        // Only two user messages → no semantic consolidation.
        ctx.insert(MessageModel(session: session, role: "user", content: "one"))
        ctx.insert(MessageModel(session: session, role: "user", content: "two"))
        memory.consolidateRecentMessages(session: session, context: ctx)
        XCTAssertEqual(session.memories.filter { $0.type == "semantic" }.count, 0)

        ctx.insert(MessageModel(session: session, role: "user", content: "three"))
        memory.consolidateRecentMessages(session: session, context: ctx)
        XCTAssertEqual(session.memories.filter { $0.type == "semantic" }.count, 1)
    }

    // MARK: - Recall (negative)

    func testRecallWithNoMemoriesReturnsEmpty() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = SessionModel(title: "T")
        ctx.insert(session)
        XCTAssertTrue(memory.recallRelevant(session: session, query: "anything", context: ctx).isEmpty)
    }
}
