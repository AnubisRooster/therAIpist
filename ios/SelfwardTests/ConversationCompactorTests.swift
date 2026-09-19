import XCTest
import SwiftData
@testable import Selfward

// MARK: - ConversationCompactor unit tests

@MainActor
final class ConversationCompactorTests: XCTestCase {

    private func makeCompactor() -> ConversationCompactor {
        ConversationCompactor(defaults: TestSupport.ephemeralDefaults())
    }

    private func filledConversation(turnCount: Int, charsPerMessage: Int = 60) -> [(String, String)] {
        (0..<turnCount).map { index in
            let pad = String(repeating: "x", count: charsPerMessage)
            return (index % 2 == 0) ? ("user", "message \(index) \(pad)") : ("assistant", "reply \(index) \(pad)")
        }
    }

    // MARK: - Token estimation

    func testEstimatedTokensScalesWithCharacterCount() {
        XCTAssertEqual(ConversationCompactor.estimatedTokens(""), 0)
        XCTAssertEqual(ConversationCompactor.estimatedTokens("abcd"), 1)
        XCTAssertEqual(ConversationCompactor.estimatedTokens(String(repeating: "a", count: 400)), 100)
    }

    // MARK: - Budgeting

    func testCloudBudgetScalesWithKnownContextLength() {
        XCTAssertEqual(
            ConversationCompactor.historyTokenBudget(provider: "openrouter", knownContextLength: 32_000),
            Int(32_000 * ConversationCompactor.historyBudgetFraction)
        )
    }

    func testCloudBudgetCapsAtMaxHistoryTokens() {
        // A 128k model must not be sent an unbounded history.
        XCTAssertEqual(
            ConversationCompactor.historyTokenBudget(provider: "openrouter", knownContextLength: 128_000),
            ConversationCompactor.maxHistoryTokens
        )
    }

    func testCloudBudgetFallsBackToDefaultWhenContextUnknown() {
        XCTAssertEqual(
            ConversationCompactor.historyTokenBudget(provider: "openrouter", knownContextLength: nil),
            Int(Double(ConversationCompactor.defaultCloudContextLength) * ConversationCompactor.historyBudgetFraction)
        )
    }

    func testLocalBudgetUsesContextWindow() {
        let budget = ConversationCompactor.historyTokenBudget(provider: "local",
                                                              knownContextLength: nil,
                                                              localContextWindow: 2048)
        XCTAssertEqual(budget, max(Int(2048 * ConversationCompactor.historyBudgetFraction), 512))
    }

    func testLocalBudgetHasFloor() {
        let budget = ConversationCompactor.historyTokenBudget(provider: "local",
                                                              knownContextLength: nil,
                                                              localContextWindow: 100)
        XCTAssertGreaterThanOrEqual(budget, 512)
    }

    // MARK: - Retention

    func testRetainedHistoryKeepsNewestWithinBudget() {
        let history = filledConversation(turnCount: 10, charsPerMessage: 40)   // ~10 tokens each
        let kept = ConversationCompactor.retainedHistory(history, budget: 50)
        XCTAssertFalse(kept.isEmpty)
        XCTAssertEqual(kept.last?.0, history.last?.0)
        XCTAssertLessThanOrEqual(kept.count, 6)
    }

    func testRetainedHistoryAlwaysKeepsMostRecentTurnEvenWhenHuge() {
        let history = [
            ("user", "short"),
            ("assistant", String(repeating: "z", count: 10_000))
        ]
        let kept = ConversationCompactor.retainedHistory(history, budget: 100, minimumKeep: 1)
        XCTAssertEqual(kept.count, 1)
        XCTAssertEqual(kept.first?.1, history.last?.1)
    }

    func testRetainedHistoryForcesRecentTurnsUpToMinimumKeep() {
        let history = filledConversation(turnCount: 5, charsPerMessage: 4000)   // ~1000 tokens each
        let kept = ConversationCompactor.retainedHistory(history, budget: 50, minimumKeep: 3)
        XCTAssertEqual(kept.count, 3)
    }

    func testRetainedHistoryEmptyInput() {
        XCTAssertEqual(ConversationCompactor.retainedHistory([], budget: 100).count, 0)
    }

    // MARK: - Rolling summary

    func testCompactReturnsNilWhenEverythingFits() async throws {
        let compactor = makeCompactor()
        let history = filledConversation(turnCount: 20, charsPerMessage: 40)
        var summarizerCalls = 0
        let result = try await compactor.compact(
            messages: history,
            sessionID: UUID().uuidString,
            budget: 5_000,
            minimumRecentTurns: 4,
            summarizer: { _ in summarizerCalls += 1; return "SUMMARY" }
        )
        XCTAssertNil(result, "No summarization needed when the conversation fits the budget")
        XCTAssertEqual(summarizerCalls, 0)
    }

    func testCompactFoldsOverflowAndCachesSummary() async throws {
        let compactor = makeCompactor()
        let sessionID = UUID().uuidString
        let history = filledConversation(turnCount: 20, charsPerMessage: 200)   // ~50 tokens each → 1000 total
        var summarizerCalls = 0

        let first = try await compactor.compact(
            messages: history,
            sessionID: sessionID,
            budget: 500,
            minimumRecentTurns: 4,
            summarizer: { _ in summarizerCalls += 1; return "SUMMARY-1" }
        )

        let (summary, recent) = try XCTUnwrap(first)
        XCTAssertEqual(summary, "SUMMARY-1")
        XCTAssertEqual(summarizerCalls, 1)
        XCTAssertLessThanOrEqual(recent.count, 4, "Only the most recent turns stay verbatim")

        // Re-running with no new turns must reuse the cached summary.
        let second = try await compactor.compact(
            messages: history,
            sessionID: sessionID,
            budget: 500,
            minimumRecentTurns: 4,
            summarizer: { _ in summarizerCalls += 1; return "SHOULD-NOT-RUN" }
        )
        let (summary2, recent2) = try XCTUnwrap(second)
        XCTAssertEqual(summary2, "SUMMARY-1")
        XCTAssertEqual(recent2.count, recent.count)
        XCTAssertTrue(zip(recent2, recent).allSatisfy { $0.0 == $1.0 && $0.1 == $1.1 })
        XCTAssertEqual(summarizerCalls, 1, "Cached summary reused — no new summarization call")
    }

    func testCompactSummarizesNewTurnsWhenTheyAccumulate() async throws {
        let compactor = makeCompactor()
        let sessionID = UUID().uuidString
        var summarizerCalls = 0
        let history = filledConversation(turnCount: 20, charsPerMessage: 200)

        _ = try await compactor.compact(
            messages: history,
            sessionID: sessionID,
            budget: 500,
            minimumRecentTurns: 4,
            summarizer: { _ in summarizerCalls += 1; return "SUMMARY-1" }
        )

        let extended = history + [("user", "new turn \(String(repeating: "x", count: 200))"),
                                  ("assistant", "reply \(String(repeating: "y", count: 200))")]
        let result = try await compactor.compact(
            messages: extended,
            sessionID: sessionID,
            budget: 500,
            minimumRecentTurns: 4,
            summarizer: { _ in summarizerCalls += 1; return "SUMMARY-2" }
        )

        let (summary, _) = try XCTUnwrap(result)
        XCTAssertEqual(summary, "SUMMARY-2")
        XCTAssertEqual(summarizerCalls, 2, "New uncovered turns trigger one fresh summarization")
    }

    func testCompactPropagatesSummarizerFailure() async throws {
        struct SummarizerBoom: Error {}
        let compactor = makeCompactor()
        let history = filledConversation(turnCount: 20, charsPerMessage: 200)

        do {
            _ = try await compactor.compact(
                messages: history,
                sessionID: UUID().uuidString,
                budget: 500,
                minimumRecentTurns: 4,
                summarizer: { _ in throw SummarizerBoom() }
            )
            XCTFail("Expected summarizer failure to propagate")
        } catch is SummarizerBoom {
            // Expected.
        }
    }

    func testResetClearsStoredSummary() async throws {
        let compactor = makeCompactor()
        let sessionID = UUID().uuidString
        let history = filledConversation(turnCount: 20, charsPerMessage: 200)

        _ = try await compactor.compact(
            messages: history,
            sessionID: sessionID,
            budget: 500,
            minimumRecentTurns: 4,
            summarizer: { _ in "SUMMARY" }
        )

        compactor.reset(sessionID: sessionID)

        // After reset, the fold-in must run again rather than reuse anything.
        var summarizerCalls = 0
        _ = try await compactor.compact(
            messages: history,
            sessionID: sessionID,
            budget: 500,
            minimumRecentTurns: 4,
            summarizer: { _ in summarizerCalls += 1; return "SUMMARY-FRESH" }
        )
        XCTAssertEqual(summarizerCalls, 1)
    }
}

// MARK: - ChatService integration (budgeted history + compaction + error surfacing)

@MainActor
final class ChatServiceCompactionTests: XCTestCase {

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
        let session = SessionModel(title: "Test", provider: provider,
                                   model: provider == "local" ? "llama-3.2-3b" : "test/model")
        ctx.insert(session)
        return session
    }

    private func seedPriorTurns(session: SessionModel, count: Int, charsPerMessage: Int = 60) {
        let now = Date()
        for index in 0..<count {
            let role = index % 2 == 0 ? "user" : "assistant"
            let message = MessageModel(session: session, role: role,
                                       content: "prior\(index) " + String(repeating: "x", count: charsPerMessage))
            message.createdAt = now.addingTimeInterval(TimeInterval(index - count))
            ctx.insert(message)
        }
    }

    // MARK: - Cloud: budget-based history, no more "last 10" trim

    func testCloudProviderSendsEntireBudgetedHistory() async {
        let mock = MockLLM(response: "sure")
        let chat = ChatService(llm: mock)
        let session = newSession()

        // 30 prior turns are comfortably inside the default cloud budget — the
        // old behavior would have sent at most the last 10.
        seedPriorTurns(session: session, count: 30)
        _ = await chat.processMessage(session: session, userMessage: "latest", context: ctx)

        // Summary/compaction is a local-only feature — cloud must be a single call.
        XCTAssertEqual(mock.callCount, 1)

        let convo = mock.lastMessages.filter { $0.role == "user" || $0.role == "assistant" }
        XCTAssertEqual(convo.count, 31, "All 30 prior turns plus the new message are sent")
        XCTAssertEqual(convo.last?.content, "latest")
        XCTAssertEqual(convo.first?.content, "prior0 " + String(repeating: "x", count: 60))
    }

    // MARK: - Local: overflowing conversations get a rolling summary

    func testLocalProviderCompactsOverflowingConversation() async {
        let mock = MockLLM(response: "here is a reply")
        let chat = ChatService(llm: mock, localModelFileExists: { _ in true })
        let session = newSession(provider: "local")

        // 40 prior turns at ~150 tokens each comfortably exceed the local
        // context window's budget even on the largest RAM tier.
        seedPriorTurns(session: session, count: 40, charsPerMessage: 600)
        _ = await chat.processMessage(session: session, userMessage: "latest local turn", context: ctx)

        // One call for the summary, a second for the real reply.
        XCTAssertEqual(mock.callCount, 2)

        let hasRecap = mock.lastMessages.contains {
            $0.role == "system" && $0.content.hasPrefix("Ongoing conversation recap")
        }
        XCTAssertTrue(hasRecap, "The rolling summary must be injected as a system message")
        XCTAssertEqual(mock.lastMessages.last?.content, "latest local turn")
    }

    func testLocalProviderWithShortConversationDoesNotSummarize() async {
        let mock = MockLLM(response: "here is a reply")
        let chat = ChatService(llm: mock, localModelFileExists: { _ in true })
        let session = newSession(provider: "local")

        seedPriorTurns(session: session, count: 2)
        _ = await chat.processMessage(session: session, userMessage: "hi", context: ctx)

        // Nothing overflows → single call, no synthesized recap.
        XCTAssertEqual(mock.callCount, 1)
        XCTAssertFalse(mock.lastMessages.contains {
            $0.role == "system" && $0.content.hasPrefix("Ongoing conversation recap")
        })
    }

    // MARK: - Error surfacing replaces the generic swallow

    func testRateLimitedSurfacesInsteadOfGenericFallback() async {
        let chat = ChatService(llm: MockLLM(error: LLMError.rateLimited(retryAfter: 5)))
        let session = newSession()
        let result = await chat.processMessage(session: session, userMessage: "hello", context: ctx)
        let isSurfaced = result.response.lowercased().contains("overloaded")
            || result.response.lowercased().contains("rate-limit")
        XCTAssertTrue(isSurfaced)
    }

    func testContextLengthExceededSurfacesGuidance() async {
        let chat = ChatService(llm: MockLLM(error: LLMError.contextLengthExceeded))
        let session = newSession()
        let result = await chat.processMessage(session: session, userMessage: "hello", context: ctx)
        XCTAssertTrue(result.response.lowercased().contains("context window"))
    }

    func testProviderApiErrorSurfacesReason() async {
        let chat = ChatService(llm: MockLLM(error: LLMError.apiError("HTTP 500: upstream exploded")))
        let session = newSession()
        let result = await chat.processMessage(session: session, userMessage: "hello", context: ctx)
        XCTAssertTrue(result.response.lowercased().contains("provider"))
        XCTAssertTrue(result.response.contains("upstream exploded"))
    }
}
