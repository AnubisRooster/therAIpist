import XCTest
@testable import Therapist

final class PINLockoutTests: XCTestCase {

    private func makeLockout(maxAttempts: Int = 5) -> PINLockout {
        PINLockout(defaults: TestSupport.ephemeralDefaults(), maxAttempts: maxAttempts)
    }

    // MARK: - Positive: normal failure accounting

    func testFailuresBelowThresholdReportRemainingAttempts() {
        var lockout = makeLockout(maxAttempts: 5)
        XCTAssertEqual(lockout.registerFailure(), .incorrect(attemptsRemaining: 4))
        XCTAssertEqual(lockout.registerFailure(), .incorrect(attemptsRemaining: 3))
        XCTAssertEqual(lockout.registerFailure(), .incorrect(attemptsRemaining: 2))
        XCTAssertEqual(lockout.registerFailure(), .incorrect(attemptsRemaining: 1))
        XCTAssertFalse(lockout.isLockedOut)
    }

    func testReachingThresholdLocksOut() {
        var lockout = makeLockout(maxAttempts: 5)
        for _ in 0..<4 { _ = lockout.registerFailure() }
        let result = lockout.registerFailure()
        XCTAssertEqual(result, .lockedOut(secondsRemaining: 30))
        XCTAssertTrue(lockout.isLockedOut)
    }

    func testLockoutEscalatesOnRepeatedRounds() {
        var lockout = makeLockout(maxAttempts: 2)
        let now = Date()

        // Round 1 → 30s lockout.
        _ = lockout.registerFailure(now: now)
        XCTAssertEqual(lockout.registerFailure(now: now), .lockedOut(secondsRemaining: 30))

        // After it expires, the next round escalates to 60s.
        let afterFirst = now.addingTimeInterval(31)
        _ = lockout.registerFailure(now: afterFirst)
        XCTAssertEqual(lockout.registerFailure(now: afterFirst), .lockedOut(secondsRemaining: 60))
    }

    // MARK: - Negative / boundary

    func testAttemptsDuringLockoutAreRejectedWithoutCounting() {
        var lockout = makeLockout(maxAttempts: 2)
        let now = Date()
        _ = lockout.registerFailure(now: now)
        _ = lockout.registerFailure(now: now)   // now locked for 30s

        let during = now.addingTimeInterval(10)
        if case .lockedOut(let remaining) = lockout.registerFailure(now: during) {
            XCTAssertEqual(remaining, 20)        // 30 - 10
        } else {
            XCTFail("Expected lockedOut while inside the lockout window")
        }
    }

    func testRegisterSuccessClearsAllState() {
        var lockout = makeLockout(maxAttempts: 2)
        _ = lockout.registerFailure()
        _ = lockout.registerFailure()           // locked
        XCTAssertTrue(lockout.isLockedOut)

        lockout.registerSuccess()
        XCTAssertFalse(lockout.isLockedOut)
        XCTAssertEqual(lockout.lockoutRemaining(), 0)
        // And the next failure starts the counter fresh.
        XCTAssertEqual(lockout.registerFailure(), .incorrect(attemptsRemaining: 1))
    }

    func testLockoutRemainingIsZeroAfterExpiry() {
        var lockout = makeLockout(maxAttempts: 1)
        let now = Date()
        _ = lockout.registerFailure(now: now)   // immediately locked (30s)
        XCTAssertEqual(lockout.lockoutRemaining(now: now.addingTimeInterval(31)), 0)
    }

    // MARK: - PINService.attempt integration (no Keychain write needed)

    func testServiceAttemptWithWrongPinEventuallyLocksOut() {
        let service = PINService(defaults: TestSupport.ephemeralDefaults())
        // No PIN stored → verify always false → these are all "incorrect".
        var lastResult: PINAttemptResult = .success
        for _ in 0..<5 { lastResult = service.attempt("000000") }
        XCTAssertEqual(lastResult, .lockedOut(secondsRemaining: 30))
        XCTAssertTrue(service.isLockedOut)
    }
}
