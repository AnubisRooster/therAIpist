import XCTest
import SwiftData
@testable import Selfward

@MainActor
final class InsightServiceTests: XCTestCase {
    private let insight = InsightService.shared
    private let graph = GraphService.shared

    // MARK: - Helpers

    private func makeSession(_ container: ModelContainer) -> SessionModel {
        let ctx = container.mainContext
        let session = SessionModel(title: "T")
        ctx.insert(session)
        return session
    }

    // MARK: - Plain-language highlights (positive)

    func testHighlightPersonTriggersEmotion() throws {
        let container = TestSupport.makeInMemoryContainer()
        let session = makeSession(container)
        let ctx = container.mainContext

        graph.extractEntitiesFromMessage(session: session,
                                         message: "I am so angry at my mother",
                                         context: ctx)

        let highlights = insight.plainLanguageHighlights(session: session)
        XCTAssertTrue(
            highlights.contains { $0 == "You often feel angry when Mother comes up." },
            "Expected a person->emotion sentence, got: \(highlights)"
        )
    }

    func testHighlightsAreReadableSentencesNotRawTypes() throws {
        let container = TestSupport.makeInMemoryContainer()
        let session = makeSession(container)
        let ctx = container.mainContext

        graph.extractEntitiesFromMessage(session: session,
                                         message: "I am anxious about my father",
                                         context: ctx)

        let highlights = insight.plainLanguageHighlights(session: session)
        XCTAssertFalse(highlights.isEmpty)
        for line in highlights {
            XCTAssertFalse(line.contains("TRIGGERS"))
            XCTAssertFalse(line.contains("ASSOCIATED_WITH"))
            XCTAssertFalse(line.contains("_"))
        }
    }

    func testHighlightsNeverResolveToRawNodeID() throws {
        let container = TestSupport.makeInMemoryContainer()
        let session = makeSession(container)
        let ctx = container.mainContext

        graph.extractEntitiesFromMessage(session: session,
                                         message: "I feel anxious and lonely about my partner",
                                         context: ctx)

        // Node IDs are UUID strings; none should leak into the user-facing text.
        let ids = Set(session.graphNodes.map(\.id))
        let highlights = insight.plainLanguageHighlights(session: session)
        for line in highlights {
            for id in ids {
                XCTAssertFalse(line.contains(id), "Raw node id leaked into highlight: \(line)")
            }
        }
    }

    func testHighlightsCappedAtFour() throws {
        let container = TestSupport.makeInMemoryContainer()
        let session = makeSession(container)
        let ctx = container.mainContext

        // A dense message that produces many emotions + people + beliefs.
        graph.extractEntitiesFromMessage(
            session: session,
            message: "I feel angry, anxious, sad, and lonely at my mother and my father, and I always fail",
            context: ctx
        )

        let highlights = insight.plainLanguageHighlights(session: session)
        XCTAssertLessThanOrEqual(highlights.count, 4)
    }

    // MARK: - Fallback (negative / sparse)

    func testHighlightsFallBackToEmotionsWhenNoEdges() throws {
        let container = TestSupport.makeInMemoryContainer()
        let session = makeSession(container)
        let ctx = container.mainContext

        // Single emotion, no co-occurrence -> no edges, should fall back.
        graph.extractEntitiesFromMessage(session: session, message: "I feel sad", context: ctx)

        let highlights = insight.plainLanguageHighlights(session: session)
        XCTAssertEqual(highlights.count, 1)
        XCTAssertTrue(highlights.first?.contains("Feelings that have come up") == true)
    }

    func testHighlightsEmptyForNeutralSession() throws {
        let container = TestSupport.makeInMemoryContainer()
        let session = makeSession(container)
        let ctx = container.mainContext

        graph.extractEntitiesFromMessage(session: session,
                                         message: "The weather was fine today.",
                                         context: ctx)

        XCTAssertTrue(insight.plainLanguageHighlights(session: session).isEmpty)
    }

    // MARK: - Mood tracking

    func testMoodIsLoggedAndClamped() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext

        MoodStore.log(value: 6, context: ctx)   // out of range -> clamped to 5
        MoodStore.log(value: 3, context: ctx)
        MoodStore.log(value: 0, context: ctx)   // out of range -> clamped to 1

        let recent = MoodStore.recent(context: ctx)
        XCTAssertEqual(recent.count, 3)
        XCTAssertEqual(recent.map(\.value).sorted(), [1, 3, 5])
    }

    func testMoodTrendSummaryAggregatesDaily() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        MoodStore.log(value: 4, context: ctx)
        MoodStore.log(value: 2, context: ctx)
        ctx.insert(MoodEntryModel(value: 5, createdAt: yesterday))

        let summary = MoodStore.trendSummary(context: ctx)
        XCTAssertEqual(summary.count, 3)
        XCTAssertEqual(summary.daily.count, 2)   // two distinct days
        // Yesterday's single entry averages to 5.
        XCTAssertTrue(summary.daily.contains { cal.isDate($0.0, inSameDayAs: yesterday) && $0.1 == 5 })
    }
}
