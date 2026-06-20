import XCTest
@testable import Therapist

final class SafetyServiceTests: XCTestCase {
    private let safety = SafetyService.shared

    // MARK: - Crisis detection (positive)

    func testCriticalCrisisPhrasesAreFlagged() {
        let phrases = ["I want to die", "I'm going to kill myself",
                       "thinking about suicide", "I keep cutting"]
        for phrase in phrases {
            let result = safety.checkCrisis(phrase)
            XCTAssertTrue(result.isCrisis, "Expected crisis for: \(phrase)")
            XCTAssertEqual(result.level, "critical", "Expected critical for: \(phrase)")
            XCTAssertNotNil(result.pattern)
        }
    }

    func testWarningLevelCrisisPhrases() {
        let result = safety.checkCrisis("I feel hopeless and worthless")
        XCTAssertTrue(result.isCrisis)
        XCTAssertEqual(result.level, "warning")
    }

    func testCrisisDetectionIsCaseInsensitive() {
        let result = safety.checkCrisis("I WANT TO DIE")
        XCTAssertTrue(result.isCrisis)
    }

    // MARK: - Crisis detection (negative)

    func testOrdinaryMessageIsNotCrisis() {
        let result = safety.checkCrisis("I had a really nice walk today and feel calm.")
        XCTAssertFalse(result.isCrisis)
        XCTAssertEqual(result.level, "")
        XCTAssertNil(result.pattern)
    }

    func testEmptyMessageIsNotCrisis() {
        XCTAssertFalse(safety.checkCrisis("").isCrisis)
    }

    // MARK: - Boundary violations (positive)

    func testDiagnosingLanguageIsBoundaryViolation() {
        let result = safety.checkBoundaryViolation("Based on this, your diagnosis is bipolar disorder.")
        XCTAssertTrue(result.isViolation)
        XCTAssertNotNil(result.pattern)
    }

    func testPrescribingLanguageIsBoundaryViolation() {
        XCTAssertTrue(safety.checkBoundaryViolation("I prescribe a daily dose of sertraline.").isViolation)
        XCTAssertTrue(safety.checkBoundaryViolation("You need medication for this.").isViolation)
    }

    // MARK: - Boundary violations (negative)

    func testEmpatheticLanguageIsNotBoundaryViolation() {
        // Ordinary reflective language must not trip the diagnosis/prescription filter.
        let result = safety.checkBoundaryViolation("It sounds like you have been feeling overwhelmed lately.")
        XCTAssertFalse(result.isViolation)
        XCTAssertNil(result.pattern)
    }
}
