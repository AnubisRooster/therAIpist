import Foundation
import XCTest
import SwiftData
@testable import Therapist

@MainActor
final class InsightCaptureServiceTests: XCTestCase {

    // MARK: - Dream detection – positive cases

    func test_detectDream_iHadADream() {
        let text = "Last night I had a dream where I was falling into darkness."
        let candidate = InsightCaptureService.detectDream(in: text)
        XCTAssertNotNil(candidate, "Should detect dream cue 'i had a dream'")
        XCTAssertEqual(candidate?.narrative, text)
        XCTAssertTrue(candidate?.symbols.contains("darkness") == true)
        XCTAssertTrue(candidate?.symbols.contains("falling") == true)
    }

    func test_detectDream_iDreamt() {
        let candidate = InsightCaptureService.detectDream(in: "I dreamt about my mother running away.")
        XCTAssertNotNil(candidate)
    }

    func test_detectDream_nightmare() {
        let candidate = InsightCaptureService.detectDream(in: "I keep having this nightmare about water.")
        XCTAssertNotNil(candidate)
        XCTAssertTrue(candidate?.symbols.contains("water") == true)
    }

    func test_detectDream_extractsFeelings() {
        let text = "In my dream I felt anxious and ashamed near a dark forest."
        let candidate = InsightCaptureService.detectDream(in: text)
        XCTAssertNotNil(candidate)
        XCTAssertTrue(candidate?.feelings.contains("anxious") == true)
        XCTAssertTrue(candidate?.feelings.contains("ashamed") == true)
    }

    func test_detectDream_mixedCase() {
        // Cue matching should be case-insensitive.
        let candidate = InsightCaptureService.detectDream(in: "Last night I DREAMED about a snake.")
        XCTAssertNotNil(candidate)
        XCTAssertTrue(candidate?.symbols.contains("snake") == true)
    }

    // MARK: - Dream detection – negative cases

    func test_detectDream_noCue_returnsNil() {
        let candidate = InsightCaptureService.detectDream(in: "I was feeling anxious all day.")
        XCTAssertNil(candidate, "No dream cue should return nil")
    }

    func test_detectDream_emptyString_returnsNil() {
        XCTAssertNil(InsightCaptureService.detectDream(in: ""))
    }

    func test_detectDream_relatedWordButNoCue() {
        // "dreamer" or "daydream" should not trigger unless the actual cue is present.
        XCTAssertNil(InsightCaptureService.detectDream(in: "She's such a dreamer."))
    }

    // MARK: - Summary note

    private func makeSession(messageCount: Int, container: ModelContainer) throws -> SessionModel {
        let ctx = container.mainContext
        let session = SessionModel(title: "Test Session")
        ctx.insert(session)
        for i in 0..<messageCount {
            let role = i % 2 == 0 ? "user" : "assistant"
            ctx.insert(MessageModel(session: session, role: role, content: "Message \(i)"))
        }
        try ctx.save()
        return session
    }

    func test_summaryNote_fewerThanTwoUserMessages_returnsNil() throws {
        let container = TestSupport.makeInMemoryContainer()
        let session = try makeSession(messageCount: 1, container: container) // 1 user message
        XCTAssertNil(InsightCaptureService.summaryNote(for: session))
    }

    func test_summaryNote_twoUserMessages_returnsValue() throws {
        let container = TestSupport.makeInMemoryContainer()
        let session = try makeSession(messageCount: 4, container: container) // 2 user + 2 assistant
        let summary = InsightCaptureService.summaryNote(for: session)
        XCTAssertNotNil(summary)
        XCTAssertFalse(summary!.title.isEmpty)
        XCTAssertTrue(summary!.content.contains("Messages exchanged: 2"))
    }

    func test_summaryNote_includesNodeLabels() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = try makeSession(messageCount: 4, container: container)
        let node = GraphNodeModel(session: session, type: "emotion", label: "Sadness")
        ctx.insert(node)
        try ctx.save()
        let summary = InsightCaptureService.summaryNote(for: session)
        XCTAssertTrue(summary?.content.contains("Sadness") == true)
    }

    // MARK: - Existing summary note detection

    func test_existingSummaryNote_foundByMarker() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = SessionModel(title: "Session")
        ctx.insert(session)
        let note = NoteModel(session: session, type: "reflection",
                             title: "Session Summary", content: "content")
        note.structuredData = InsightCaptureService.summaryNoteMarker
        ctx.insert(note)
        try ctx.save()
        XCTAssertNotNil(InsightCaptureService.existingSummaryNote(for: session))
    }

    func test_existingSummaryNote_notFoundWhenAbsent() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = SessionModel(title: "Session")
        ctx.insert(session)
        let note = NoteModel(session: session, type: "reflection", title: "Manual Note", content: "x")
        ctx.insert(note)
        try ctx.save()
        XCTAssertNil(InsightCaptureService.existingSummaryNote(for: session))
    }

    // MARK: - Note upsert idempotency (via ChatService E2E)

    func test_chatService_dreamMessageCreatesDreamModel() async throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let mock = MockLLM(response: "Tell me more about the dream.")
        let service = ChatService(llm: mock, localModelFileExists: { _ in false })

        let session = SessionModel(title: "Dream Session")
        ctx.insert(session)
        try ctx.save()

        let message = "I had a dream where I was falling into an ocean and felt anxious."
        _ = await service.processMessage(session: session, userMessage: message, context: ctx)

        XCTAssertFalse(session.dreams.isEmpty, "Dream should have been created")
        let dream = session.dreams.first!
        XCTAssertTrue(dream.narrative.contains("falling"))
    }

    func test_chatService_dreamBadgeSetOnAssistantMessage() async throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let mock = MockLLM(response: "Let's explore that dream.")
        let service = ChatService(llm: mock, localModelFileExists: { _ in false })

        let session = SessionModel(title: "Session")
        ctx.insert(session)
        try ctx.save()

        _ = await service.processMessage(
            session: session,
            userMessage: "I dreamt about my mother and felt afraid.",
            context: ctx
        )

        let assistantMessages = session.messages.filter { $0.role == "assistant" && !$0.content.starts(with: "I want to be honest") }
        let dreamBadged = assistantMessages.contains { $0.capturedDream }
        XCTAssertTrue(dreamBadged, "Assistant message should carry capturedDream = true")
    }

    func test_chatService_summaryNoteUpsertIsIdempotent() async throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let mock = MockLLM(response: "Good.")
        let service = ChatService(llm: mock, localModelFileExists: { _ in false })

        let session = SessionModel(title: "Session")
        ctx.insert(session)
        // Seed two prior user messages so summaryNote threshold is met.
        ctx.insert(MessageModel(session: session, role: "user", content: "Hello"))
        ctx.insert(MessageModel(session: session, role: "assistant", content: "Hi"))
        ctx.insert(MessageModel(session: session, role: "user", content: "How are you?"))
        ctx.insert(MessageModel(session: session, role: "assistant", content: "Fine"))
        try ctx.save()

        _ = await service.processMessage(session: session, userMessage: "Tell me more.",
                                          context: ctx)
        _ = await service.processMessage(session: session, userMessage: "And then?",
                                          context: ctx)

        let summaryNotes = session.notes.filter {
            $0.structuredData == InsightCaptureService.summaryNoteMarker
        }
        XCTAssertEqual(summaryNotes.count, 1, "Should upsert, not duplicate, the summary note")
    }
}
