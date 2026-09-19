import XCTest
@testable import Selfward

final class SpeechServiceTests: XCTestCase {
    func testStripMarkdownLeavesProseIntact() {
        XCTAssertEqual(SpeechService.stripMarkdown("Hello."), "Hello.")
    }

    func testStripMarkdownCollapsesNewlinesIntoShortPause() {
        XCTAssertEqual(SpeechService.stripMarkdown("One.\nTwo."), "One., Two.")
    }

    func testStripMarkdownRemovesBoldAndHeaders() {
        XCTAssertEqual(SpeechService.stripMarkdown("**Bold** and *italic*"), "Bold and italic")
        XCTAssertEqual(SpeechService.stripMarkdown("# Header\nText"), "Header, Text")
    }

    func testStripMarkdownBullets() {
        XCTAssertEqual(SpeechService.stripMarkdown("- Item 1\n- Item 2"), "Item 1, Item 2")
    }

    func testStripMarkdownCollapsesRepeatedPeriods() {
        XCTAssertEqual(SpeechService.stripMarkdown("Hello.. World"), "Hello. World")
        XCTAssertEqual(SpeechService.stripMarkdown("End... Here"), "End.. Here")
    }

    func testStripMarkdownComplex() {
        let input = "**Summary:**\n- Point one\n- Point two\n\nThat's all."
        let expected = "Summary:, Point one, Point two, , That's all."
        XCTAssertEqual(SpeechService.stripMarkdown(input), expected)
    }
}