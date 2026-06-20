import Foundation
import Security

/// Result of a PIN entry attempt.
enum PINAttemptResult: Equatable {
    case success
    case incorrect(attemptsRemaining: Int)
    case lockedOut(secondsRemaining: Int)
}

/// Brute-force lockout state machine, kept separate from Keychain so it is
/// fully unit-testable with an injected `UserDefaults` and clock.
struct PINLockout {
    let defaults: UserDefaults
    let maxAttempts: Int

    private let failKey  = "pin_fail_count"
    private let levelKey = "pin_lock_level"
    private let untilKey = "pin_lock_until"

    init(defaults: UserDefaults = .standard, maxAttempts: Int = 5) {
        self.defaults = defaults
        self.maxAttempts = maxAttempts
    }

    /// Lockout duration for the Nth lockout (1-based), escalating then capped.
    func lockoutDuration(level: Int) -> TimeInterval {
        switch level {
        case ..<1:  return 0
        case 1:     return 30
        case 2:     return 60
        case 3:     return 300
        default:    return 900
        }
    }

    /// Seconds remaining in the current lockout, or 0 if not locked out.
    func lockoutRemaining(now: Date = Date()) -> Int {
        let until = Date(timeIntervalSince1970: defaults.double(forKey: untilKey))
        let remaining = until.timeIntervalSince(now)
        return remaining > 0 ? Int(remaining.rounded(.up)) : 0
    }

    var isLockedOut: Bool { lockoutRemaining() > 0 }

    /// Records a failed attempt and returns the resulting state.
    mutating func registerFailure(now: Date = Date()) -> PINAttemptResult {
        if lockoutRemaining(now: now) > 0 {
            return .lockedOut(secondsRemaining: lockoutRemaining(now: now))
        }
        let fails = defaults.integer(forKey: failKey) + 1
        if fails >= maxAttempts {
            let level = defaults.integer(forKey: levelKey) + 1
            let duration = lockoutDuration(level: level)
            defaults.set(level, forKey: levelKey)
            defaults.set(now.addingTimeInterval(duration).timeIntervalSince1970, forKey: untilKey)
            defaults.set(0, forKey: failKey)
            return .lockedOut(secondsRemaining: Int(duration.rounded(.up)))
        }
        defaults.set(fails, forKey: failKey)
        return .incorrect(attemptsRemaining: maxAttempts - fails)
    }

    /// Clears all failure/lockout state after a correct PIN.
    mutating func registerSuccess() {
        defaults.removeObject(forKey: failKey)
        defaults.removeObject(forKey: levelKey)
        defaults.removeObject(forKey: untilKey)
    }
}

/// Stores and verifies a numeric PIN in the device Keychain.
///
/// The PIN never touches `UserDefaults` or iCloud; it lives only in the local
/// Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
final class PINService {
    static let shared = PINService()

    private let service = (Bundle.main.bundleIdentifier ?? "com.therAIpist") + ".pin"
    private let account = "user_pin"
    private var lockout: PINLockout

    init(defaults: UserDefaults = .standard) {
        self.lockout = PINLockout(defaults: defaults)
    }

    // MARK: Public API

    var isPINSetup: Bool { load() != nil }

    var isLockedOut: Bool { lockout.isLockedOut }
    var lockoutRemaining: Int { lockout.lockoutRemaining() }

    /// Verifies a PIN while enforcing brute-force lockout. Prefer this over
    /// `verify(_:)` at the UI layer.
    func attempt(_ pin: String, now: Date = Date()) -> PINAttemptResult {
        let remaining = lockout.lockoutRemaining(now: now)
        if remaining > 0 { return .lockedOut(secondsRemaining: remaining) }
        if verify(pin) {
            lockout.registerSuccess()
            return .success
        }
        return lockout.registerFailure(now: now)
    }

    @discardableResult
    func save(_ pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        delete()
        lockout.registerSuccess()
        let attrs: [CFString: Any] = [
            kSecClass:          kSecClassGenericPassword,
            kSecAttrService:    service,
            kSecAttrAccount:    account,
            kSecValueData:      data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        return SecItemAdd(attrs as CFDictionary, nil) == errSecSuccess
    }

    func verify(_ pin: String) -> Bool {
        guard let stored = load() else { return false }
        return stored == pin
    }

    func delete() {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: Private

    private func load() -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let pin  = String(data: data, encoding: .utf8) else { return nil }
        return pin
    }
}
