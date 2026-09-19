import Foundation
import SwiftData
import XCTest
@testable import Selfward

/// In-memory stand-in for the Keychain so tests never touch the simulator's
/// real Keychain (which persists across test runs and would leak state).
private final class FakeKeychain: KeychainStoring {
    private var storage: [String: Data] = [:]

    func keychainData(account: String) -> Data? {
        storage[account]
    }

    func setKeychainData(_ value: Data?, account: String) -> Bool {
        if let value {
            storage[account] = value
        } else {
            storage.removeValue(forKey: account)
        }
        return true
    }

    func autoBackupPassphrase() -> String? {
        storage["passphrase"].flatMap { String(data: $0, encoding: .utf8) }
    }

    func setAutoBackupPassphrase(_ value: String) -> Bool {
        storage["passphrase"] = Data(value.utf8)
        return true
    }
}

final class AutoBackupServiceTests: XCTestCase {
    /// A service wired to ephemeral storage: a fresh UserDefaults suite plus a
    /// fresh FakeKeychain, so every test starts from the same clean state.
    private func makeService() -> (AutoBackupService, FakeKeychain) {
        let keychain = FakeKeychain()
        return (AutoBackupService(defaults: TestSupport.ephemeralDefaults(), keychain: keychain), keychain)
    }

    // MARK: - Config persistence (survives a reinstall)

    func testConfigRoundTripPersistsInKeychain() {
        let (service, keychain) = makeService()
        XCTAssertFalse(service.isEnabled)

        service.isEnabled = true
        XCTAssertTrue(service.isEnabled)
        // A fresh service reading the *same* Keychain still sees it — this is
        // exactly what a reinstall sees, since UserDefaults were wiped.
        let reinstalled = AutoBackupService(defaults: TestSupport.ephemeralDefaults(), keychain: keychain)
        XCTAssertTrue(reinstalled.isEnabled)
        XCTAssertNotNil(keychain.keychainData(account: KeychainService.autoBackupConfigAccount))
    }

    func testConfigDefaultIsDisabled() {
        let (service, _) = makeService()
        XCTAssertFalse(service.isEnabled)
        XCTAssertEqual(service.folderDisplayName, "Not chosen yet")
        XCTAssertNil(service.lastBackupDate)
    }

    // MARK: - Migration from legacy UserDefaults

    func testMigratesLegacyDefaultsIntoKeychainAndClearsLegacy() {
        let defaults = TestSupport.ephemeralDefaults()
        defaults.set(true, forKey: "autoBackup.enabled")
        defaults.set("My Backups", forKey: "autoBackup.folderDisplayName")
        defaults.set(Date(timeIntervalSince1970: 1_700_000_000), forKey: "autoBackup.lastAt")
        let bookmark = Data("legacy-bookmark".utf8)
        defaults.set(bookmark, forKey: "autoBackup.folderBookmark")

        let keychain = FakeKeychain()
        let service = AutoBackupService(defaults: defaults, keychain: keychain)

        XCTAssertTrue(service.isEnabled)
        XCTAssertEqual(service.folderDisplayName, "My Backups")
        XCTAssertEqual(service.lastBackupDate, Date(timeIntervalSince1970: 1_700_000_000))
        XCTAssertEqual(keychain.keychainData(account: KeychainService.autoBackupBookmarkAccount), bookmark)

        // Legacy keys are cleared so the migration is one-time.
        XCTAssertNil(defaults.object(forKey: "autoBackup.enabled"))
        XCTAssertNil(defaults.object(forKey: "autoBackup.folderBookmark"))
        XCTAssertNil(defaults.object(forKey: "autoBackup.folderDisplayName"))
        XCTAssertNil(defaults.object(forKey: "autoBackup.lastAt"))
    }

    // MARK: - Write → detect → recover round-trip

    @MainActor
    func testWriteDetectRecoverRoundTrip() async throws {
        let (service, _) = makeService()
        service.isEnabled = true

        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }

        // The folder bookmark survives in the (fake) Keychain, like a reinstall.
        XCTAssertTrue(service.setFolder(folder))

        // Source store: one session with one message, plus one mood entry.
        let container = TestSupport.makeInMemoryContainer()
        let context = container.mainContext
        let session = SessionModel(title: "First talk")
        context.insert(session)
        context.insert(MessageModel(session: session, role: "user", content: "hello"))
        context.insert(MoodEntryModel(value: 4, note: "ok"))
        try context.save()

        let url = try await service.writeBackup(context: context, to: folder)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertNotNil(service.lastBackupDate)

        // Detection finds the newest backup.
        let offer = service.newestAvailableBackup()
        XCTAssertEqual(offer?.folderName, folder.lastPathComponent)
        XCTAssertNotNil(offer?.newestAt)

        // A fresh store — exactly what a reinstall provides. The Keychain (and
        // the passphrase inside it) survived, so recovery decrypts automatically.
        let freshContainer = TestSupport.makeInMemoryContainer()
        let inserted = try await service.recoverLatest(context: freshContainer.mainContext)
        XCTAssertEqual(inserted.sessions, 1)
        XCTAssertEqual(inserted.moods, 1)

        let sessions = try freshContainer.mainContext.fetch(FetchDescriptor<SessionModel>())
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.title, "First talk")
        XCTAssertEqual(sessions.first?.messages.count, 1)
        let moods = try freshContainer.mainContext.fetch(FetchDescriptor<MoodEntryModel>())
        XCTAssertEqual(moods.count, 1)
    }

    @MainActor
    func testDetectionSkipsWhenDisabled() async throws {
        let (service, _) = makeService()
        // Backups exist on disk, but the user disabled auto-backup before the
        // reinstall — honoring that choice means no restore prompt.
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        XCTAssertTrue(service.setFolder(folder))

        let container = TestSupport.makeInMemoryContainer()
        try await service.writeBackup(context: container.mainContext, to: folder)

        XCTAssertNil(service.newestAvailableBackup())
    }

    // MARK: - Reinstall means empty defaults can't block Keychain config

    @MainActor
    func testReinstallReadsConfigEvenWithEmptyDefaults() throws {
        // A "returning user" install: UserDefaults wiped, Keychain intact.
        let keychain = FakeKeychain()
        let original = AutoBackupService(defaults: TestSupport.ephemeralDefaults(), keychain: keychain)
        original.isEnabled = true
        original.setFolder(FileManager.default.temporaryDirectory)

        let wipedDefaults = TestSupport.ephemeralDefaults()
        let reinstalled = AutoBackupService(defaults: wipedDefaults, keychain: keychain)
        XCTAssertTrue(reinstalled.isEnabled)
    }
}
