import XCTest
@testable import Selfward

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
        let now: TimeInterval = 1_000

        // Round 1 → 30s lockout.
        _ = lockout.registerFailure(uptime: now)
        XCTAssertEqual(lockout.registerFailure(uptime: now), .lockedOut(secondsRemaining: 30))

        // After it expires, the next round escalates to 60s.
        let afterFirst = now + 31
        _ = lockout.registerFailure(uptime: afterFirst)
        XCTAssertEqual(lockout.registerFailure(uptime: afterFirst), .lockedOut(secondsRemaining: 60))
    }

    // MARK: - Negative / boundary

    func testAttemptsDuringLockoutAreRejectedWithoutCounting() {
        var lockout = makeLockout(maxAttempts: 2)
        let now: TimeInterval = 1_000
        _ = lockout.registerFailure(uptime: now)
        _ = lockout.registerFailure(uptime: now)   // now locked for 30s

        let during = now + 10
        if case .lockedOut(let remaining) = lockout.registerFailure(uptime: during) {
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
        let now: TimeInterval = 1_000
        _ = lockout.registerFailure(uptime: now)   // immediately locked (30s)
        XCTAssertEqual(lockout.lockoutRemaining(uptime: now + 31), 0)
    }

    func testLockoutRemainingIsZeroWhenStaleDeadlineFollowsRebootLikeUptimeReset() {
        // A device reboot resets systemUptime to ~0; a stale stored deadline
        // (from before reboot) would otherwise look astronomically far in
        // the future rather than expired. Simulate that: lock out at a large
        // uptime, then query with a much smaller "post reboot" uptime.
        var lockout = makeLockout(maxAttempts: 1)
        _ = lockout.registerFailure(uptime: 50_000)   // locked until ~50_030
        XCTAssertEqual(lockout.lockoutRemaining(uptime: 5), 0)
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

    // MARK: - KeychainLockoutStore (Keychain-backed persistence)

    private func makeKeychainStore(account: String = "test_\(UUID().uuidString)") -> KeychainLockoutStore {
        KeychainLockoutStore(service: "test.selfward.lockout", account: account)
    }

    func testKeychainLockoutStoreRoundTripsIntAndDouble() {
        let store = makeKeychainStore()
        defer { store.removeObject(forKey: "fails"); store.removeObject(forKey: "until") }

        XCTAssertEqual(store.integer(forKey: "fails"), 0)
        store.set(3, forKey: "fails")
        XCTAssertEqual(store.integer(forKey: "fails"), 3)

        XCTAssertEqual(store.double(forKey: "until"), 0)
        store.set(12345.5, forKey: "until")
        XCTAssertEqual(store.double(forKey: "until"), 12345.5)
    }

    func testKeychainLockoutStoreRemoveObjectClearsValue() {
        let store = makeKeychainStore()
        store.set(5, forKey: "fails")
        store.removeObject(forKey: "fails")
        XCTAssertEqual(store.integer(forKey: "fails"), 0)
    }

    func testKeychainLockoutStoreSurvivesAcrossFreshInstances() {
        // A fresh instance targeting the same account (as if the app process
        // relaunched) still sees state written by a prior instance — this is
        // the property that makes it usable as a reinstall-resistant store.
        let account = "test_\(UUID().uuidString)"
        let first = makeKeychainStore(account: account)
        first.set(2, forKey: "level")
        first.set(99_999.0, forKey: "untilUptime")

        let second = makeKeychainStore(account: account)
        XCTAssertEqual(second.integer(forKey: "level"), 2)
        XCTAssertEqual(second.double(forKey: "untilUptime"), 99_999.0)

        second.removeObject(forKey: "level")
        second.removeObject(forKey: "untilUptime")
    }

    func testPINLockoutBackedByKeychainStoreSurvivesFreshUserDefaultsLikeReinstall() {
        // Reproduces the fixed vulnerability: lockout state now survives even
        // when the surrounding UserDefaults is fresh (simulating an app
        // reinstall), because it's backed by the Keychain instead.
        let account = "test_\(UUID().uuidString)"
        var first = PINLockout(defaults: makeKeychainStore(account: account), maxAttempts: 1)
        XCTAssertEqual(first.registerFailure(uptime: 1_000), .lockedOut(secondsRemaining: 30))

        var second = PINLockout(defaults: makeKeychainStore(account: account), maxAttempts: 1)
        XCTAssertGreaterThan(second.lockoutRemaining(uptime: 1_010), 0)

        second.registerSuccess()
    }
}
