import Foundation
import Security

/// Result of a PIN entry attempt.
enum PINAttemptResult: Equatable {
    case success
    case incorrect(attemptsRemaining: Int)
    case lockedOut(secondsRemaining: Int)
}

/// Minimal key-value store `PINLockout` persists its counters through.
/// `UserDefaults` conforms natively (used by tests, for isolation); in
/// production `PINService` instead injects a Keychain-backed store, so
/// lockout state survives app deletion just like the PIN itself — see
/// `KeychainLockoutStore` below. Without this, deleting and reinstalling the
/// app would silently reset a brute-force lockout back to zero.
protocol PINLockoutStore {
    func integer(forKey key: String) -> Int
    func double(forKey key: String) -> Double
    func set(_ value: Int, forKey key: String)
    func set(_ value: Double, forKey key: String)
    func removeObject(forKey key: String)
}

extension UserDefaults: PINLockoutStore {}

/// Brute-force lockout state machine, kept separate from Keychain reads so
/// it is fully unit-testable with an injected store and clock.
struct PINLockout {
    let defaults: PINLockoutStore
    let maxAttempts: Int

    private let failKey  = "pin_fail_count"
    private let levelKey = "pin_lock_level"
    // Stores the deadline as a monotonic uptime value, not a wall-clock
    // timestamp — see `lockoutRemaining` for why.
    private let untilUptimeKey = "pin_lock_until_uptime"

    init(defaults: PINLockoutStore = UserDefaults.standard, maxAttempts: Int = 5) {
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
    ///
    /// `uptime` is monotonic time since boot (default:
    /// `ProcessInfo.processInfo.systemUptime`), not wall-clock `Date()` —
    /// advancing the device's date/time in Settings can't rewind it, so it
    /// can't be used to bypass a lockout the way a `Date()`-based deadline
    /// could. The tradeoff is that a device reboot resets uptime to ~0; a
    /// stored deadline would then look astronomically far in the future
    /// rather than expired, so any remaining value beyond the longest
    /// possible lockout duration is treated as stale (post-reboot) rather
    /// than "still locked out".
    func lockoutRemaining(uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) -> Int {
        let until = defaults.double(forKey: untilUptimeKey)
        guard until > 0 else { return 0 }
        let remaining = until - uptime
        guard remaining > 0, remaining <= lockoutDuration(level: .max) else { return 0 }
        // The deadline loses sub-microsecond precision round-tripping through
        // storage as a Double. Shave a tiny epsilon before rounding up so an
        // exact value like 20.0 doesn't intermittently round to 21 due to
        // that floating-point noise.
        return Int((remaining - 0.0001).rounded(.up))
    }

    var isLockedOut: Bool { lockoutRemaining() > 0 }

    /// Records a failed attempt and returns the resulting state.
    mutating func registerFailure(uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) -> PINAttemptResult {
        if lockoutRemaining(uptime: uptime) > 0 {
            return .lockedOut(secondsRemaining: lockoutRemaining(uptime: uptime))
        }
        let fails = defaults.integer(forKey: failKey) + 1
        if fails >= maxAttempts {
            let level = defaults.integer(forKey: levelKey) + 1
            let duration = lockoutDuration(level: level)
            defaults.set(level, forKey: levelKey)
            defaults.set(uptime + duration, forKey: untilUptimeKey)
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
        defaults.removeObject(forKey: untilUptimeKey)
    }
}

/// Persists `PINLockout`'s counters to the Keychain instead of
/// `UserDefaults`. `UserDefaults` is wiped when the app is deleted, but a
/// Keychain item with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
/// survives app deletion/reinstallation — so without this, an attacker
/// locked out after 5 wrong guesses could just delete and reinstall the app
/// to get unlimited fresh attempt rounds against the (still-present) PIN.
final class KeychainLockoutStore: PINLockoutStore {
    private let service: String
    private let account: String

    init(service: String, account: String = "pin_lockout_state") {
        self.service = service
        self.account = account
    }

    private struct State: Codable {
        var ints: [String: Int] = [:]
        var doubles: [String: Double] = [:]
    }

    private func load() -> State {
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
              let state = try? JSONDecoder().decode(State.self, from: data) else {
            return State()
        }
        return state
    }

    private func persist(_ state: State) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]
        let update: [CFString: Any] = [kSecValueData: data]
        if SecItemUpdate(query as CFDictionary, update as CFDictionary) == errSecItemNotFound {
            var attrs = query
            attrs[kSecValueData] = data
            attrs[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            SecItemAdd(attrs as CFDictionary, nil)
        }
    }

    func integer(forKey key: String) -> Int { load().ints[key] ?? 0 }
    func double(forKey key: String) -> Double { load().doubles[key] ?? 0 }

    func set(_ value: Int, forKey key: String) {
        var state = load()
        state.ints[key] = value
        persist(state)
    }

    func set(_ value: Double, forKey key: String) {
        var state = load()
        state.doubles[key] = value
        persist(state)
    }

    func removeObject(forKey key: String) {
        var state = load()
        state.ints.removeValue(forKey: key)
        state.doubles.removeValue(forKey: key)
        persist(state)
    }
}

/// Stores and verifies a numeric PIN in the device Keychain.
///
/// The PIN never touches `UserDefaults` or iCloud; it lives only in the local
/// Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
final class PINService {
    static let shared = PINService()

    private let service = (Bundle.main.bundleIdentifier ?? "com.intelligentdesignsllc.selfward") + ".pin"
    private let account = "user_pin"
    private var lockout: PINLockout

    /// `lockoutStore` persists brute-force lockout counters. Production uses
    /// a Keychain-backed store by default (see `KeychainLockoutStore`) so
    /// lockout survives app deletion; tests inject an ephemeral
    /// `UserDefaults` instance for isolation.
    init(defaults: PINLockoutStore? = nil) {
        let service = (Bundle.main.bundleIdentifier ?? "com.intelligentdesignsllc.selfward") + ".pin"
        self.lockout = PINLockout(defaults: defaults ?? KeychainLockoutStore(service: service))
    }

    // MARK: Public API

    /// True when a PIN is stored. A transient Keychain read error is treated
    /// as "PIN exists" (fail closed) rather than "no PIN", so a temporary
    /// glitch can't route into setup-a-new-PIN mode and bypass the real one.
    var isPINSetup: Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status != errSecItemNotFound
    }

    var isLockedOut: Bool { lockout.isLockedOut }
    var lockoutRemaining: Int { lockout.lockoutRemaining() }

    /// Verifies a PIN while enforcing brute-force lockout. Prefer this over
    /// `verify(_:)` at the UI layer.
    func attempt(_ pin: String, uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) -> PINAttemptResult {
        let remaining = lockout.lockoutRemaining(uptime: uptime)
        if remaining > 0 { return .lockedOut(secondsRemaining: remaining) }
        if verify(pin) {
            lockout.registerSuccess()
            return .success
        }
        return lockout.registerFailure(uptime: uptime)
    }

    /// Stores a new PIN, replacing any existing one. Only clears lockout
    /// state after the Keychain write is confirmed to have succeeded, and
    /// replaces an existing PIN in place (update, not delete-then-add) so a
    /// failed write can never leave the Keychain with no PIN at all.
    @discardableResult
    func save(_ pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]
        var addAttrs = query
        addAttrs[kSecValueData] = data
        addAttrs[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        var status = SecItemAdd(addAttrs as CFDictionary, nil)
        if status == errSecDuplicateItem {
            status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
        }
        guard status == errSecSuccess else { return false }
        lockout.registerSuccess()
        return true
    }

    func verify(_ pin: String) -> Bool {
        guard let stored = load() else { return false }
        return Self.constantTimeEqual(stored, pin)
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

    /// Constant-time equality check, so comparing the entered PIN against the
    /// stored one doesn't leak a timing signal from an early-exit `==` (the
    /// brute-force lockout above already limits attempt volume; this is
    /// defense-in-depth on top of it).
    private static func constantTimeEqual(_ a: String, _ b: String) -> Bool {
        let aBytes = Array(a.utf8)
        let bBytes = Array(b.utf8)
        guard aBytes.count == bBytes.count else { return false }
        var diff: UInt8 = 0
        for i in 0..<aBytes.count {
            diff |= aBytes[i] ^ bBytes[i]
        }
        return diff == 0
    }
}
