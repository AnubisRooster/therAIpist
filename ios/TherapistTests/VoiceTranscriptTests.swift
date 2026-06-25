import XCTest
@testable import Therapist

/// Unit tests for the pure transcript-stitching used to keep long monologues
/// intact across SFSpeechRecognizer's ~1-minute segment limit (fix #6).
@MainActor
final class VoiceTranscriptTests: XCTestCase {

    func testCombinesCommittedAndSegmentWithSpace() {
        let combined = VoiceConversationController.combinedTranscript(
            committed: "I have been feeling",
            segment: "really overwhelmed lately")
        XCTAssertEqual(combined, "I have been feeling really overwhelmed lately")
    }

    func testEmptyCommittedReturnsSegment() {
        XCTAssertEqual(
            VoiceConversationController.combinedTranscript(committed: "", segment: "hello"),
            "hello")
    }

    func testEmptySegmentReturnsCommitted() {
        XCTAssertEqual(
            VoiceConversationController.combinedTranscript(committed: "hello", segment: ""),
            "hello")
    }

    func testBothEmptyReturnsEmpty() {
        XCTAssertEqual(
            VoiceConversationController.combinedTranscript(committed: "", segment: ""),
            "")
    }

    func testMultiSegmentAccumulationStaysOrdered() {
        // Simulate three recognizer segments stitched together in order.
        var committed = ""
        for segment in ["first part", "second part", "third part"] {
            committed = VoiceConversationController.combinedTranscript(committed: committed, segment: segment)
        }
        XCTAssertEqual(committed, "first part second part third part")
    }

    // MARK: - utterance rollover detection

    func testRefinementGrowingIsContinuation() {
        XCTAssertTrue(VoiceConversationController.isContinuation(
            of: "I feel", by: "I feel anxious"))
    }

    func testSameLengthRefinementIsContinuation() {
        XCTAssertTrue(VoiceConversationController.isContinuation(
            of: "I am okay", by: "I am okey"))
    }

    func testShorterUnrelatedStringIsRollover() {
        // Recognizer threw away the prior sentence and started a new, shorter one.
        XCTAssertFalse(VoiceConversationController.isContinuation(
            of: "I have been feeling overwhelmed lately", by: "My job"))
    }

    func testShorterButSameOpeningIsContinuation() {
        // A transient shrink that keeps the opening is a refinement, not a rollover.
        XCTAssertTrue(VoiceConversationController.isContinuation(
            of: "I have been feeling", by: "I have"))
    }

    func testEmptyPreviousIsContinuation() {
        XCTAssertTrue(VoiceConversationController.isContinuation(of: "", by: "hello"))
    }

    func testRolloverCommitsPriorSentenceSoTranscriptKeepsBoth() {
        // Simulate the controller's stitching across a mid-request rollover:
        // segment goes "S1." then rolls over to "S2" — both must be kept.
        var committed = ""
        var lastSegment = ""
        let segments = ["I feel anxious.", "My work has been hard"]
        for seg in segments {
            if !lastSegment.isEmpty,
               !VoiceConversationController.isContinuation(of: lastSegment, by: seg) {
                committed = VoiceConversationController.combinedTranscript(committed: committed, segment: lastSegment)
            }
            lastSegment = seg
        }
        let full = VoiceConversationController.combinedTranscript(committed: committed, segment: lastSegment)
        XCTAssertEqual(full, "I feel anxious. My work has been hard")
    }

    // MARK: - "send" voice command

    func testDetectSendStripsTrailingCommand() {
        XCTAssertEqual(
            VoiceConversationController.detectSendCommand(in: "I feel anxious today send"),
            "I feel anxious today")
    }

    func testDetectSendHandlesTrailingPunctuationAndCasing() {
        XCTAssertEqual(
            VoiceConversationController.detectSendCommand(in: "I am doing better. Send."),
            "I am doing better")
    }

    func testDetectSendMultiWordVariants() {
        XCTAssertEqual(
            VoiceConversationController.detectSendCommand(in: "tell me more send the message"),
            "tell me more")
        XCTAssertEqual(
            VoiceConversationController.detectSendCommand(in: "okay send it now"),
            "okay")
    }

    func testDetectSendCommandOnlyReturnsEmpty() {
        XCTAssertEqual(VoiceConversationController.detectSendCommand(in: "send"), "")
        XCTAssertEqual(VoiceConversationController.detectSendCommand(in: "Send."), "")
    }

    func testDetectSendReturnsNilWhenNoCommand() {
        XCTAssertNil(VoiceConversationController.detectSendCommand(in: "I went to the store"))
        // "send" embedded mid-sentence is not a trailing command.
        XCTAssertNil(VoiceConversationController.detectSendCommand(in: "please send my regards to her"))
    }
}
