import XCTest
import SwiftData
@testable import Selfward

@MainActor
final class NarrativeServiceTests: XCTestCase {

    private func makeSession(_ container: ModelContainer, provider: String = "openrouter") -> SessionModel {
        let ctx = container.mainContext
        let session = SessionModel(title: "Test", provider: provider)
        ctx.insert(session)
        return session
    }

    // MARK: - Crisis content is withheld from cloud generation

    func testCrisisFlaggedSourceWithheldFromCloudGeneration() async throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = makeSession(container, provider: "openrouter")
        ctx.insert(MessageModel(session: session, role: "user", content: "I want to kill myself"))
        ctx.insert(MessageModel(session: session, role: "user", content: "Work has been stressful lately"))

        let mock = MockLLM(response: "A calm reflection on their week.")
        let service = NarrativeService(llm: mock)

        let updated = try await service.buildIncremental(context: ctx, provider: "openrouter", model: "gpt-4o-mini")

        XCTAssertTrue(updated)
        XCTAssertEqual(mock.callCount, 1)
        let sentText = mock.lastMessages.map(\.content).joined()
        XCTAssertFalse(sentText.contains("kill myself"), "Crisis-flagged content must not reach a cloud provider")
        XCTAssertTrue(sentText.contains("Work has been stressful"), "Non-flagged content should still be sent")

        let events = try ctx.fetch(FetchDescriptor<SafetyEventModel>())
        XCTAssertTrue(events.contains { $0.eventType == "narrative_source_withheld" })
    }

    func testCrisisFlaggedSourceIncludedForLocalProvider() async throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = makeSession(container, provider: "local")
        ctx.insert(MessageModel(session: session, role: "user", content: "I want to kill myself"))

        let mock = MockLLM(response: "A reflection.")
        let service = NarrativeService(llm: mock)

        let updated = try await service.buildIncremental(context: ctx, provider: "local", model: "llama-3.2-3b")

        XCTAssertTrue(updated)
        let sentText = mock.lastMessages.map(\.content).joined()
        XCTAssertTrue(sentText.contains("kill myself"), "On-device generation never leaves the device, so nothing needs withholding")

        let events = try ctx.fetch(FetchDescriptor<SafetyEventModel>())
        XCTAssertFalse(events.contains { $0.eventType == "narrative_source_withheld" })
    }

    func testAllSourcesFlaggedReturnsFalseWithoutCallingLLM() async throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = makeSession(container, provider: "openrouter")
        ctx.insert(MessageModel(session: session, role: "user", content: "I want to kill myself"))

        let mock = MockLLM(response: "unused")
        let service = NarrativeService(llm: mock)

        let updated = try await service.buildIncremental(context: ctx, provider: "openrouter", model: "gpt-4o-mini")

        XCTAssertFalse(updated)
        XCTAssertEqual(mock.callCount, 0)
    }

    // MARK: - Boundary violation on the returned narrative

    func testBoundaryViolationInResponseReplacesStoredContent() async throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = makeSession(container, provider: "openrouter")
        ctx.insert(MessageModel(session: session, role: "user", content: "Reflecting on a hard week at work"))

        let mock = MockLLM(response: "Given everything, I diagnose you with generalized anxiety disorder.")
        let service = NarrativeService(llm: mock)

        let updated = try await service.buildIncremental(context: ctx, provider: "openrouter", model: "gpt-4o-mini")
        XCTAssertTrue(updated)

        let documents = try ctx.fetch(FetchDescriptor<NarrativeDocument>())
        let document = try XCTUnwrap(documents.first)
        XCTAssertFalse(document.content.contains("diagnose"))
        XCTAssertTrue(document.content.contains("beyond what I can safely help with"))

        let events = try ctx.fetch(FetchDescriptor<SafetyEventModel>())
        XCTAssertTrue(events.contains { $0.eventType == "boundary_violation" })
    }

    // MARK: - Normal path

    func testOrdinaryNarrativeGenerationSucceeds() async throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = makeSession(container, provider: "openrouter")
        ctx.insert(MessageModel(session: session, role: "user", content: "Had a good walk today"))

        let mock = MockLLM(response: "They took a walk and felt at ease.")
        let service = NarrativeService(llm: mock)

        let updated = try await service.buildIncremental(context: ctx, provider: "openrouter", model: "gpt-4o-mini")
        XCTAssertTrue(updated)

        let documents = try ctx.fetch(FetchDescriptor<NarrativeDocument>())
        let document = try XCTUnwrap(documents.first)
        XCTAssertEqual(document.content, "They took a walk and felt at ease.")

        let events = try ctx.fetch(FetchDescriptor<SafetyEventModel>())
        XCTAssertTrue(events.isEmpty)
    }
}
