import Foundation
import Security

/// Any type whose values each map to a distinct Keychain-stored API key, with
/// UI metadata for the settings key-entry row. `LLMProvider` conforms below;
/// `TTSKeyProvider` (in TTSCoordinator.swift) is the other conformer, for
/// cloud TTS services that aren't LLM providers.
protocol APIKeyProvider {
    var keychainKey: String { get }
    var displayName: String { get }
    var keyHint: String { get }
}

/// The minimal Keychain storage surface `AutoBackupService` depends on. It is a
/// protocol so tests can inject an in-memory stand-in instead of reading/writing
/// the simulator's real Keychain.
protocol KeychainStoring {
    /// Returns the raw Data stored under `account`, or `nil` if unset.
    func keychainData(account: String) -> Data?
    /// Stores raw Data under `account` (pass `nil` to clear). Returns success.
    @discardableResult
    func setKeychainData(_ value: Data?, account: String) -> Bool
    /// The automatic-backup passphrase (Keychain, survives a reinstall).
    func autoBackupPassphrase() -> String?
    @discardableResult
    func setAutoBackupPassphrase(_ value: String) -> Bool
}

/// Wraps the Security framework Keychain API to store per-provider API keys.
/// Keys are stored under the generic-password class with the app's bundle ID
/// as the service and the provider's `keychainKey` as the account.
final class KeychainService: KeychainStoring, @unchecked Sendable {
    static let shared = KeychainService()

    // MARK: - Automatic-backup account names

    /// Keychain account for the JSON-encoded `AutoBackupConfig` blob.
    static let autoBackupConfigAccount = "autobackup.config"
    /// Keychain account for the security-scoped bookmark of the backup folder.
    static let autoBackupBookmarkAccount = "autobackup.folderbookmark"

    private let service: String = Bundle.main.bundleIdentifier ?? "com.theraipist.app"

    // MARK: - Public API

    /// Saves `value` for `provider`. Overwrites any existing value.
    @discardableResult
    func set(_ value: String, for provider: some APIKeyProvider) -> Bool {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.keychainKey,
        ]

        // Delete old item first so SecItemAdd always succeeds.
        let deleteStatus = SecItemDelete(query as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else { return false }

        guard !value.isEmpty else { return true } // Intentional clear.

        var addAttrs = query
        addAttrs[kSecValueData] = data
        // Keep keys on this device only (excluded from iCloud/iTunes backups) and
        // available only while the device is unlocked.
        addAttrs[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(addAttrs as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieves the stored value for `provider`, or `nil` if not set.
    func get(for provider: some APIKeyProvider) -> String? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrService:      service,
            kSecAttrAccount:      provider.keychainKey,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8),
              !string.isEmpty
        else { return nil }
        return string
    }

    /// Removes the stored key for `provider`.
    @discardableResult
    func delete(for provider: some APIKeyProvider) -> Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.keychainKey,
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Returns `true` if a non-empty key exists for `provider`.
    func hasKey(for provider: some APIKeyProvider) -> Bool {
        get(for: provider) != nil
    }

    // MARK: - OpenRouter key

    /// The effective OpenRouter key, read from the Keychain only. No plaintext
    /// `UserDefaults` fallback is used — the key is never stored in the clear.
    /// Returns "" when none is set. This is the single source of truth for the
    /// OpenRouter key; callers should not read `@AppStorage("openrouter_key")`.
    @discardableResult
    func openRouterKey() -> String {
        get(for: LLMProvider.openrouter) ?? ""
    }

    // MARK: - Automatic backup passphrase

    /// The account name under which the automatic-backup passphrase is stored.
    /// Unlike API keys this is not tied to a provider, so it gets its own
    /// account and load/store helpers.
    private static let autoBackupAccount = "autobackup.passphrase"

    /// Stores the passphrase used for automatic backups. The Keychain survives
    /// an app uninstall, so this lets a reinstall decrypt backups made before
    /// it without the user having to remember another passphrase.
    @discardableResult
    func setAutoBackupPassphrase(_ value: String) -> Bool {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: Self.autoBackupAccount,
        ]
        let deleteStatus = SecItemDelete(query as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else { return false }
        guard !value.isEmpty else { return true }
        var addAttrs = query
        addAttrs[kSecValueData] = data
        addAttrs[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(addAttrs as CFDictionary, nil) == errSecSuccess
    }

    /// Returns the stored automatic-backup passphrase, or `nil` if never set.
    func autoBackupPassphrase() -> String? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrService:      service,
            kSecAttrAccount:      Self.autoBackupAccount,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8),
              !string.isEmpty
        else { return nil }
        return string
    }

    // MARK: - Raw account storage (KeychainStoring)

    /// Returns the raw Data stored under `account`, or `nil` if unset.
    func keychainData(account: String) -> Data? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrService:      service,
            kSecAttrAccount:      account,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    /// Stores raw Data under `account`. Passing `nil` (or empty Data) clears the
    /// item. Data stays on this device only and is available while unlocked,
    /// matching the API-key behavior above.
    @discardableResult
    func setKeychainData(_ value: Data?, account: String) -> Bool {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrService:      service,
            kSecAttrAccount:      account,
        ]
        let deleteStatus = SecItemDelete(query as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else { return false }

        guard let value, !value.isEmpty else { return true } // Intentional clear.

        var addAttrs = query
        addAttrs[kSecValueData] = value
        addAttrs[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let addStatus = SecItemAdd(addAttrs as CFDictionary, nil)
        return addStatus == errSecSuccess
    }

    // MARK: - Automatic backup config (survives a reinstall)

    /// The JSON-encoded `AutoBackupConfig` blob, or `nil` if never stored.
    func autoBackupConfigData() -> Data? {
        keychainData(account: Self.autoBackupConfigAccount)
    }

    @discardableResult
    func setAutoBackupConfigData(_ value: Data?) -> Bool {
        setKeychainData(value, account: Self.autoBackupConfigAccount)
    }

    /// The security-scoped bookmark of the folder the user picked in Files.
    func autoBackupBookmarkData() -> Data? {
        keychainData(account: Self.autoBackupBookmarkAccount)
    }

    @discardableResult
    func setAutoBackupBookmarkData(_ value: Data?) -> Bool {
        setKeychainData(value, account: Self.autoBackupBookmarkAccount)
    }
}
