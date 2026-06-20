import XCTest
import SwiftData
@testable import Therapist

/// True end-to-end tests of the chat pipeline using an in-memory SwiftData store
/// and a mock LLM, so a single `processMessage` call exercises safety checks,
/// memory, the knowledge graph, badges, and error handling together.
@MainActor
final class ChatServiceE2ETests: XCTestCase {

    private var container: ModelContainer!
    private var ctx: ModelContext!

    override func setUp() {
        super.setUp()
        container = TestSupport.makeInMemoryContainer()
        ctx = container.mainContext
    }

    override func tearDown() {
        container = nil
        ctx = nil
        super.tearDown()
    }

    private func newSession(provider: String = "openrouter") -> SessionModel {
        let s = SessionModel(title: "Test", provider: provider, model: "test/model")
        ctx.insert(s)
        return s
    }

    // MARK: - Happy path

    func testNormalMessageProducesAssistantBubbleAndMemory() async {
        let mock = MockLLM(response: "I hear you. What feels heaviest right now?")
        let chat = ChatService(llm: mock)
        let session = newSession()

        let result = await chat.processMessage(session: session,
                                               userMessage: "I am angry at my mother",
                                               context: ctx)

        XCTAssertFalse(result.isCrisis)
        XCTAssertEqual(result.response, "I hear you. What feels heaviest right now?")
        XCTAssertEqual(mock.callCount, 1)

        // User + assistant bubbles both persisted.
        let roles = session.messages.sorted { $0.createdAt < $1.createdAt }.map(\.role)
        XCTAssertEqual(roles, ["user", "assistant"])

        // Episodic memory recorded and graph populated.
        XCTAssertGreaterThanOrEqual(session.memories.count, 1)
        XCTAssertEqual(session.graphNodes.count, 2)   // Angry + Mother
    }

    func testAssistantBubbleIsBadgedWithCapturedInsights() async {
        let chat = ChatService(llm: MockLLM())
        let session = newSession()

        _ = await chat.processMessage(session: session,
                                      userMessage: "I am angry at my mother",
                                      context: ctx)

        let assistant = session.messages.first { $0.role == "assistant" }
        XCTAssertNotNil(assistant)
        XCTAssertEqual(assistant?.capturedNodeCount, 2)
        XCTAssertEqual(assistant?.capturedEdgeCount, 1)   // Mother TRIGGERS Angry
        XCTAssertGreaterThanOrEqual(assistant?.capturedMemoryCount ?? 0, 1)
    }

    // MARK: - Crisis path

    func testCrisisMessageReturnsResourcesAndLogsEvent() async {
        let mock = MockLLM(response: "should not be used")
        let chat = ChatService(llm: mock)
        let session = newSession()

        let result = await chat.processMessage(session: session,
                                               userMessage: "I want to die",
                                               context: ctx)

        XCTAssertTrue(result.isCrisis)
        XCTAssertEqual(result.response, resourceMessage)
        XCTAssertEqual(mock.callCount, 0, "LLM must not be called on a crisis turn")

        // Crisis exchange is visible in the conversation.
        let roles = session.messages.map(\.role).sorted()
        XCTAssertEqual(roles, ["assistant", "user"])
        XCTAssertTrue(session.messages.contains { $0.content == resourceMessage })

        // A critical safety event is recorded.
        XCTAssertTrue(session.safetyEvents.contains { $0.level == "critical" })
    }

    // MARK: - Configuration errors (negative)

    func testNoAPIKeySurfacesGuidanceBubble() async {
        let mock = MockLLM(error: LLMError.noAPIKey)
        let chat = ChatService(llm: mock)
        let session = newSession()

        let result = await chat.processMessage(session: session,
                                               userMessage: "hello",
                                               context: ctx)

        XCTAssertFalse(result.isCrisis)
        XCTAssertTrue(result.response.contains("API key"))
        // Guidance is visible as an assistant bubble.
        XCTAssertTrue(session.messages.contains { $0.role == "assistant" && $0.content.contains("API key") })
    }

    func testLocalProviderWithNoModelGivesGuidanceWithoutCallingLLM() async {
        let mock = MockLLM(response: "unused")
        // Inject a "no model on disk" check so we don't touch the filesystem.
        let chat = ChatService(llm: mock, localModelFileExists: { _ in false })
        let session = newSession(provider: "local")
        session.localModel = "llama-3.2-3b"

        let result = await chat.processMessage(session: session,
                                               userMessage: "hi",
                                               context: ctx)

        XCTAssertEqual(mock.callCount, 0, "Should not attempt inference with no model present")
        XCTAssertTrue(result.response.lowercased().contains("on-device model"))
        XCTAssertTrue(session.messages.contains { $0.role == "assistant" })
    }

    func testGenericLLMErrorFallsBackGracefully() async {
        struct Boom: Error {}
        let chat = ChatService(llm: MockLLM(error: Boom()))
        let session = newSession()

        let result = await chat.processMessage(session: session,
                                               userMessage: "hello",
                                               context: ctx)
        XCTAssertFalse(result.isCrisis)
        XCTAssertFalse(result.response.isEmpty)
        // Falls back but still records the assistant turn.
        XCTAssertTrue(session.messages.contains { $0.role == "assistant" })
    }

    // MARK: - History ordering

    func testHistoryIsSentToLLMInChronologicalOrder() async {
        let mock = MockLLM()
        let chat = ChatService(llm: mock)
        let session = newSession()

        // Insert prior turns with deliberately out-of-order createdAt values.
        let now = Date()
        let m1 = MessageModel(session: session, role: "user", content: "first")
        m1.createdAt = now.addingTimeInterval(-300)
        let a1 = MessageModel(session: session, role: "assistant", content: "reply-one")
        a1.createdAt = now.addingTimeInterval(-200)
        let m2 = MessageModel(session: session, role: "user", content: "second")
        m2.createdAt = now.addingTimeInterval(-100)
        // Insert in scrambled order on purpose.
        ctx.insert(a1); ctx.insert(m2); ctx.insert(m1)

        _ = await chat.processMessage(session: session, userMessage: "third", context: ctx)

        // Extract just the conversational turns (skip system primer messages).
        let convo = mock.lastMessages.filter { $0.role == "user" || $0.role == "assistant" }
        let contents = convo.map(\.content)
        XCTAssertEqual(contents, ["first", "reply-one", "second", "third"])
    }

    // MARK: - Boundary violation in the model's reply

    func testBoundaryViolationInReplyIsReplacedAndLogged() async {
        let mock = MockLLM(response: "Your diagnosis is generalized anxiety disorder.")
        let chat = ChatService(llm: mock)
        let session = newSession()

        let result = await chat.processMessage(session: session,
                                               userMessage: "what's wrong with me?",
                                               context: ctx)

        XCTAssertFalse(result.response.contains("diagnosis is"))
        XCTAssertTrue(session.safetyEvents.contains { $0.eventType == "boundary_violation" })
    }
}
