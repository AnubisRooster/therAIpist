import Foundation
import Security

/// Stores and verifies a numeric PIN in the device Keychain.
///
/// The PIN never touches `UserDefaults` or iCloud; it lives only in the local
/// Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
final class PINService {
    static let shared = PINService()

    private let service = (Bundle.main.bundleIdentifier ?? "com.therAIpist") + ".pin"
    private let account = "user_pin"

    // MARK: Public API

    var isPINSetup: Bool { load() != nil }

    @discardableResult
    func save(_ pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        delete()
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
