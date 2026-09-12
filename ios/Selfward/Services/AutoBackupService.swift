import Foundation
import SwiftData
import Security
import BackupKit

/// Writes encrypted backups of the on-device store into a folder the user picks
/// once in the Files app. The folder lives outside the app sandbox, so backups
/// survive app updates and even uninstalls.
///
/// The passphrase is generated on-device and kept in the Keychain, which also
/// survives an app uninstall — so after a reinstall the user only needs to
/// re-pick the same folder in Files and recovery decrypts automatically with no
/// passphrase to remember.
///
/// This service never deletes anything: not the store, and not old backups.
/// Retention is entirely the user's call in the Files app.
final class AutoBackupService {
    static let shared = AutoBackupService()

    private let defaults = UserDefaults.standard

    private let enabledKey = "autoBackup.enabled"
    private let bookmarkKey = "autoBackup.folderBookmark"
    private let displayNameKey = "autoBackup.folderDisplayName"
    private let lastBackupKey = "autoBackup.lastAt"

    /// Whether automatic backups are on. Pristine installs and CI runs start
    /// with this off, so nothing tries to write anywhere until the user opts in.
    var isEnabled: Bool {
        get { defaults.bool(forKey: enabledKey) }
        set { defaults.set(newValue, forKey: enabledKey) }
    }

    /// Display name of the folder the user chose (for the settings summary row).
    var folderDisplayName: String {
        defaults.string(forKey: displayNameKey) ?? "Not chosen yet"
    }

    /// When the last automatic backup was written, if ever.
    var lastBackupDate: Date? {
        defaults.object(forKey: lastBackupKey) as? Date
    }

    /// The folder the user picked, re-resolved from its security-scoped bookmark.
    @MainActor
    func folderURL() -> URL? {
        guard let data = defaults.data(forKey: bookmarkKey) else { return nil }
        var stale = false
        guard let url = try? URL(resolvingBookmarkData: data,
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
        defaults.set(bookmark, forKey: bookmarkKey)
        defaults.set(url.lastPathComponent, forKey: displayNameKey)
        return true
    }

    /// The passphrase used for automatic backups. Generated once, stored in the
    /// Keychain so a future reinstall can decrypt old auto-backups.
    private var passphrase: String {
        if let existing = KeychainService.shared.autoBackupPassphrase() { return existing }
        var bytes = [UInt8](repeating: 0, count: 32)
        let phrase = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess
            ? Data(bytes).base64EncodedString()
            : UUID().uuidString
        _ = KeychainService.shared.setAutoBackupPassphrase(phrase)
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
        defaults.set(Date(), forKey: lastBackupKey)
        return url
    }

    /// Decrypts the most recent automatic backup in the saved folder and merges
    /// it into the store (same idempotent merge as a manual restore). Returns
    /// how many sessions and moods were inserted. Requires the folder to have
    /// been re-selected if this is a fresh install.
    @discardableResult
    @MainActor
    func recoverLatest(context: ModelContext) async throws -> (sessions: Int, moods: Int) {
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