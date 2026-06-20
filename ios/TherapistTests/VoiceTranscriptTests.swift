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
}
