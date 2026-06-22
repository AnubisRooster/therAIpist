import Foundation
import Security

/// Wraps the Security framework Keychain API to store per-provider API keys.
/// Keys are stored under the generic-password class with the app's bundle ID
/// as the service and the provider's `keychainKey` as the account.
final class KeychainService: @unchecked Sendable {
    static let shared = KeychainService()

    private let service: String = Bundle.main.bundleIdentifier ?? "com.theraipist.app"

    // MARK: - Public API

    /// Saves `value` for `provider`. Overwrites any existing value.
    @discardableResult
    func set(_ value: String, for provider: LLMProvider) -> Bool {
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
    func get(for provider: LLMProvider) -> String? {
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
    func delete(for provider: LLMProvider) -> Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.keychainKey,
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Returns `true` if a non-empty key exists for `provider`.
    func hasKey(for provider: LLMProvider) -> Bool {
        get(for: provider) != nil
    }
}
