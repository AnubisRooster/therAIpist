import XCTest
import SwiftData
@testable import Therapist

/// Covers the sentence-level TTS pipelining added to `ChatService`: the pure
/// `splitFirstSentence` splitter, and `processMessage`'s `onSentence` callback
/// when the injected LLM backend supports streaming.
@MainActor
final class ChatServiceStreamingTests: XCTestCase {

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

    // MARK: - splitFirstSentence

    func testSplitFirstSentenceReturnsNilWithoutTerminalPunctuation() {
        XCTAssertNil(ChatService.splitFirstSentence(from: "still generating"))
    }

    func testSplitFirstSentenceSplitsOnPeriod() {
        let result = ChatService.splitFirstSentence(from: "Hello there. How are you")
        XCTAssertEqual(result?.sentence, "Hello there.")
        XCTAssertEqual(result?.rest, " How are you")
    }

    func testSplitFirstSentenceHandlesQuestionAndExclamation() {
        XCTAssertEqual(ChatService.splitFirstSentence(from: "Really?! Yes")?.sentence, "Really?")
        XCTAssertEqual(ChatService.splitFirstSentence(from: "Wow! Ok")?.sentence, "Wow!")
    }

    func testSplitFirstSentenceSkipsStrayBoundaryOnlyFragment() {
        // A lone leading period (e.g. from a stray delta boundary) shouldn't
        // produce an empty "sentence" — it should recurse to the next one.
        let result = ChatService.splitFirstSentence(from: "  . Actually that's fine.")
        XCTAssertEqual(result?.sentence, "Actually that's fine.")
    }

    // MARK: - processMessage(onSentence:) with a streaming backend

    func testOnSentenceFiresPerSentenceAsStreamArrives() async {
        // Deltas are split mid-word/mid-sentence on purpose, so this also
        // covers buffering across delta boundaries.
        let mock = MockStreamingLLM(chunks: [
            "I hear ", "that this ", "is hard for you. ",
            "What feels ", "heaviest right now?",
        ])
        let chat = ChatService(llm: mock)
        let session = newSession()

        var sentences: [String] = []
        let result = await chat.processMessage(session: session, userMessage: "I'm struggling", context: ctx,
                                               onSentence: { sentences.append($0) })

        XCTAssertEqual(result.response, "I hear that this is hard for you. What feels heaviest right now?")
        XCTAssertFalse(result.wasReplacedForSafety)
        XCTAssertEqual(sentences, [
            "I hear that this is hard for you.",
            "What feels heaviest right now?",
        ])
    }

    func testOnSentenceMergesShortSentencesBelowMinimumLength() async {
        let mock = MockStreamingLLM(chunks: ["Ok. ", "Right. ", "Let's talk about your week and how it went."])
        let chat = ChatService(llm: mock)
        let session = newSession()

        var sentences: [String] = []
        _ = await chat.processMessage(session: session, userMessage: "hi", context: ctx,
                                      onSentence: { sentences.append($0) })

        // "Ok." and "Right." are each under the merge threshold, so they fold
        // into the next sentence instead of firing as their own tiny clips.
        XCTAssertEqual(sentences, ["Ok. Right. Let's talk about your week and how it went."])
    }

    func testOnSentenceFlushesTrailingTextWithoutTerminalPunctuation() async {
        let mock = MockStreamingLLM(chunks: ["No terminal punctuation on this one though it is long enough"])
        let chat = ChatService(llm: mock)
        let session = newSession()

        var sentences: [String] = []
        _ = await chat.processMessage(session: session, userMessage: "hi", context: ctx,
                                      onSentence: { sentences.append($0) })

        XCTAssertEqual(sentences, ["No terminal punctuation on this one though it is long enough"])
    }

    func testNonStreamingBackendStillReportsFullReplyThroughOnSentence() async {
        // MockLLM only conforms to LLMSending, so ChatService must fall back
        // to the non-streaming path and still call onSentence once.
        let mock = MockLLM(response: "A single non-streamed reply.")
        let chat = ChatService(llm: mock)
        let session = newSession()

        var sentences: [String] = []
        let result = await chat.processMessage(session: session, userMessage: "hi", context: ctx,
                                               onSentence: { sentences.append($0) })

        XCTAssertEqual(result.response, "A single non-streamed reply.")
        XCTAssertEqual(sentences, ["A single non-streamed reply."])
    }

    func testBoundaryViolationMarksResultAsReplacedForSafety() async {
        // Streamed sentences arrive before the boundary check runs on the
        // full text — `wasReplacedForSafety` is how a caller that already
        // started synthesizing them learns to discard that audio.
        let mock = MockStreamingLLM(chunks: ["I hear you. ", "Your diagnosis is generalized anxiety disorder."])
        let chat = ChatService(llm: mock)
        let session = newSession()

        var sentences: [String] = []
        let result = await chat.processMessage(session: session, userMessage: "what's wrong with me?", context: ctx,
                                               onSentence: { sentences.append($0) })

        XCTAssertTrue(result.wasReplacedForSafety)
        XCTAssertFalse(result.response.contains("diagnosis is"))
        // The (now-discarded) prefetch queue would still have been built from
        // the original streamed text. "I hear you." is under the merge
        // threshold, so it folds into the next sentence as one chunk.
        XCTAssertEqual(sentences, ["I hear you. Your diagnosis is generalized anxiety disorder."])
    }

    func testCrisisPathNeverStreamsAndMarksReplacedForSafety() async {
        let mock = MockStreamingLLM(chunks: ["should not be used"])
        let chat = ChatService(llm: mock)
        let session = newSession()

        var sentences: [String] = []
        let result = await chat.processMessage(session: session, userMessage: "I want to die", context: ctx,
                                               onSentence: { sentences.append($0) })

        XCTAssertTrue(result.isCrisis)
        XCTAssertTrue(result.wasReplacedForSafety)
        XCTAssertEqual(mock.callCount, 0)
        XCTAssertTrue(sentences.isEmpty)
    }
}
