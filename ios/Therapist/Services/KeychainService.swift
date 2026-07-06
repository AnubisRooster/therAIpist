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

/// Wraps the Security framework Keychain API to store per-provider API keys.
/// Keys are stored under the generic-password class with the app's bundle ID
/// as the service and the provider's `keychainKey` as the account.
final class KeychainService: @unchecked Sendable {
    static let shared = KeychainService()

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
        SecItemDelete(query as CFDictionary)

        guard !value.isEmpty else { return true } // Intentional clear.

        var addAttrs = query
        addAttrs[kSecValueData] = data
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

    // MARK: - OpenRouter legacy migration

    private static let legacyOpenRouterDefaultsKey = "openrouter_key"

    /// The effective OpenRouter key. Prefers the Keychain, and transparently
    /// migrates (then clears) any legacy plaintext value stored in
    /// `UserDefaults` under `openrouter_key`. Returns "" when none is set.
    ///
    /// This is the single source of truth for the OpenRouter key — callers
    /// should use it instead of reading `@AppStorage("openrouter_key")`.
    @discardableResult
    func openRouterKey() -> String {
        if let stored = get(for: .openrouter) { return stored }

        let legacy = (UserDefaults.standard.string(forKey: Self.legacyOpenRouterDefaultsKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !legacy.isEmpty {
            set(legacy, for: .openrouter)
            // Remove the plaintext copy now that it lives securely in Keychain.
            UserDefaults.standard.removeObject(forKey: Self.legacyOpenRouterDefaultsKey)
            return legacy
        }
        return ""
    }
}
