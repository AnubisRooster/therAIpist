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
