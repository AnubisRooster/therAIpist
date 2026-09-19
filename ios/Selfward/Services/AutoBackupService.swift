import Foundation
import SwiftData
import Security
import BackupKit

/// The durable auto-backup configuration. Stored (JSON-encoded) in the Keychain
/// — not `UserDefaults` — so it survives an app uninstall and a reinstall can
/// still find the folder the user picked and offer to restore.
struct AutoBackupConfig: Codable, Equatable {
    var enabled = false
    var displayName = ""
    var lastAt: Date?
}

/// Describes a recoverable automatic backup found on disk, for the first-launch
/// restore prompt.
struct AvailableAutoBackup: Equatable {
    let folderName: String
    let newestAt: Date?
}

/// Writes encrypted backups of the on-device store into a folder the user picks
/// once in the Files app. The folder lives outside the app sandbox, so backups
/// survive app updates and even uninstalls.
///
/// The passphrase is generated on-device and kept in the Keychain, which also
/// survives an app uninstall — so after a reinstall the user only needs to
/// re-pick the same folder in Files and recovery decrypts automatically with no
/// passphrase to remember. Since the config (enabled flag, folder bookmark,
/// folder name) is also stored in the Keychain, a reinstall *remembers* the
/// folder too and the app can offer to restore on first launch instead of
/// silently starting over as a brand-new user.
///
/// This service never deletes anything: not the store, and not old backups.
/// Retention is entirely the user's call in the Files app.
final class AutoBackupService {
    static let shared = AutoBackupService()

    private let defaults: UserDefaults
    private let keychain: KeychainStoring

    /// Legacy `UserDefaults` keys — the config lived here before it moved to
    /// the Keychain. On first access we migrate and clear them, so an update
    /// over an install that still has them keeps working.
    private let legacyEnabledKey = "autoBackup.enabled"
    private let legacyBookmarkKey = "autoBackup.folderBookmark"
    private let legacyDisplayNameKey = "autoBackup.folderDisplayName"
    private let legacyLastBackupKey = "autoBackup.lastAt"

    /// Test seam: inject an ephemeral `UserDefaults` suite and an in-memory
    /// `KeychainStoring` stand-in.
    init(defaults: UserDefaults = .standard, keychain: KeychainStoring = KeychainService.shared) {
        self.defaults = defaults
        self.keychain = keychain
    }

    /// Whether automatic backups are on. Persisted in the Keychain so the
    /// choice survives an uninstall and a reinstall can offer recovery.
    var isEnabled: Bool {
        get { migrateLegacyConfigIfNeeded(); return loadConfig()?.enabled ?? false }
        set {
            var config = loadConfig() ?? AutoBackupConfig()
            config.enabled = newValue
            store(config)
        }
    }

    /// Display name of the folder the user chose (for the settings summary row).
    var folderDisplayName: String {
        migrateLegacyConfigIfNeeded()
        let name = loadConfig()?.displayName ?? ""
        return name.isEmpty ? "Not chosen yet" : name
    }

    /// When the last automatic backup was written, if ever.
    var lastBackupDate: Date? {
        migrateLegacyConfigIfNeeded()
        return loadConfig()?.lastAt
    }

    /// The folder the user picked, re-resolved from its security-scoped bookmark.
    @MainActor
    func folderURL() -> URL? {
        migrateLegacyConfigIfNeeded()
        guard let bookmark = keychain.keychainData(account: KeychainService.autoBackupBookmarkAccount)
        else { return nil }
        var stale = false
        guard let url = try? URL(resolvingBookmarkData: bookmark,
                                 options: [],
                                 relativeTo: nil,
                                 bookmarkDataIsStale: &stale) else { return nil }
        return url
    }

    /// Remembers the folder the user picked in Files by storing a security-scoped
    /// bookmark. Returns `false` if the bookmark couldn't be created.
    @discardableResult
    @MainActor
    func setFolder(_ url: URL) -> Bool {
        guard let bookmark = try? url.bookmarkData(options: [],
                                                   includingResourceValuesForKeys: nil,
                                                   relativeTo: nil) else { return false }
        guard keychain.setKeychainData(bookmark,
                                       account: KeychainService.autoBackupBookmarkAccount)
        else { return false }
        migrateLegacyConfigIfNeeded()
        var config = loadConfig() ?? AutoBackupConfig()
        config.displayName = url.lastPathComponent
        store(config)
        return true
    }

    /// The passphrase used for automatic backups. Generated once, stored in the
    /// Keychain so a future reinstall can decrypt old auto-backups.
    private var passphrase: String {
        if let existing = keychain.autoBackupPassphrase() { return existing }
        var bytes = [UInt8](repeating: 0, count: 32)
        let phrase = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess
            ? Data(bytes).base64EncodedString()
            : UUID().uuidString
        _ = keychain.setAutoBackupPassphrase(phrase)
        return phrase
    }

    /// Encrypts the current store and writes it into the saved folder. Returns
    /// `nil` when auto-backup is off or no folder is chosen (callers treat that
    /// as a no-op, not an error). Never deletes anything.
    @discardableResult
    @MainActor
    func backupNow(context: ModelContext) async throws -> URL? {
        guard isEnabled, let folder = folderURL() else { return nil }
        return try await writeBackup(context: context, to: folder)
    }

    /// Encrypts the current store and writes a new `SelfwardAutoBackup-*.selfwardbackup`
    /// file into `folder`, then records the write time so settings can show it.
    @discardableResult
    @MainActor
    func writeBackup(context: ModelContext, to folder: URL) async throws -> URL {
        let payload = try BackupService.buildPayload(context: context)
        let pass = passphrase
        let data = try await Task.detached(priority: .utility) {
            try BackupService.encrypt(payload, passphrase: pass)
        }.value

        let accessing = folder.startAccessingSecurityScopedResource()
        defer { if accessing { folder.stopAccessingSecurityScopedResource() } }

        let url = folder.appendingPathComponent("SelfwardAutoBackup-\(Self.stamp()).selfwardbackup")
        try data.write(to: url, options: .atomic)
        var config = loadConfig() ?? AutoBackupConfig()
        config.lastAt = Date()
        store(config)
        return url
    }

    /// Best-effort scan of the saved folder for the newest automatic backup.
    /// Returns `nil` when backups aren't configured (or were disabled), the
    /// bookmark no longer resolves, or no backup files exist — callers treat
    /// that as "nothing to restore" and proceed silently.
    @MainActor
    func newestAvailableBackup() -> AvailableAutoBackup? {
        migrateLegacyConfigIfNeeded()
        guard isEnabled else { return nil }
        guard let folder = folderURL() else { return nil }

        let accessing = folder.startAccessingSecurityScopedResource()
        defer { if accessing { folder.stopAccessingSecurityScopedResource() } }

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return nil }
        let candidates = contents.filter { $0.lastPathComponent.hasPrefix("SelfwardAutoBackup-") }
        guard let newest = candidates.max(by: {
            modificationDate(of: $0) < modificationDate(of: $1)
        }) else { return nil }
        return AvailableAutoBackup(folderName: folderDisplayName, newestAt: modificationDate(of: newest))
    }

    /// Decrypts the most recent automatic backup in the saved folder and merges
    /// it into the store (same idempotent merge as a manual restore). Returns
    /// how many sessions and moods were inserted. Requires the folder to have
    /// been re-selected if this is a fresh install.
    @discardableResult
    @MainActor
    func recoverLatest(context: ModelContext) async throws -> (sessions: Int, moods: Int) {
        migrateLegacyConfigIfNeeded()
        guard let folder = folderURL() else { throw AutoBackupError.noFolderChosen }

        let accessing = folder.startAccessingSecurityScopedResource()
        defer { if accessing { folder.stopAccessingSecurityScopedResource() } }

        let contents = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        let candidates = contents.filter { $0.lastPathComponent.hasPrefix("SelfwardAutoBackup-") }
        guard let newest = candidates.max(by: { modificationDate(of: $0) < modificationDate(of: $1) }) else {
            throw AutoBackupError.noAutoBackupsFound
        }

        let data = try Data(contentsOf: newest)
        let pass = passphrase
        let payload = try await Task.detached(priority: .userInitiated) {
            try BackupService.decrypt(data, passphrase: pass)
        }.value

        let inserted = try BackupService.restore(payload, into: context)
        try context.save()
        try? StoreProtection.applyToDefaultStore()
        return inserted
    }

    // MARK: - Keychain-backed config

    private func loadConfig() -> AutoBackupConfig? {
        guard let data = keychain.keychainData(account: KeychainService.autoBackupConfigAccount) else { return nil }
        return try? Self.decoder.decode(AutoBackupConfig.self, from: data)
    }

    private func store(_ config: AutoBackupConfig) {
        guard let data = try? Self.encoder.encode(config) else { return }
        _ = keychain.setKeychainData(data, account: KeychainService.autoBackupConfigAccount)
    }

    /// One-time transfer of the legacy `UserDefaults`-resident config into the
    /// Keychain, so an update over an install that still has the old keys keeps
    /// the user's choice (and folder) intact going forward.
    private func migrateLegacyConfigIfNeeded() {
        if keychain.keychainData(account: KeychainService.autoBackupConfigAccount) == nil {
            var config = AutoBackupConfig()
            config.enabled = defaults.bool(forKey: legacyEnabledKey)
            config.displayName = defaults.string(forKey: legacyDisplayNameKey) ?? ""
            config.lastAt = defaults.object(forKey: legacyLastBackupKey) as? Date
            store(config)
        }
        if keychain.keychainData(account: KeychainService.autoBackupBookmarkAccount) == nil,
           let bookmark = defaults.data(forKey: legacyBookmarkKey) {
            _ = keychain.setKeychainData(bookmark, account: KeychainService.autoBackupBookmarkAccount)
        }
        defaults.removeObject(forKey: legacyEnabledKey)
        defaults.removeObject(forKey: legacyBookmarkKey)
        defaults.removeObject(forKey: legacyDisplayNameKey)
        defaults.removeObject(forKey: legacyLastBackupKey)
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func modificationDate(of url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
    }

    private static func stamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: Date())
    }
}

/// User-facing errors for the automatic backup flow.
enum AutoBackupError: LocalizedError {
    case noFolderChosen
    case noAutoBackupsFound

    var errorDescription: String? {
        switch self {
        case .noFolderChosen:
            return "No backup folder has been chosen. Pick one in Settings → Automatic backup first."
        case .noAutoBackupsFound:
            return "No automatic backups were found in the chosen folder."
        }
    }
}
