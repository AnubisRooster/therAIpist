import XCTest
import Foundation
@testable import BackupKit

final class BackupCryptoTests: XCTestCase {
    private func makePayload() -> BackupPayload {
        BackupPayload(
            sessions: [
                SessionSnapshot(
                    id: "s1", title: "First", modality: "integrated",
                    createdAt: Date(timeIntervalSince1970: 1_700_000_000),
                    updatedAt: nil,
                    messages: [
                        MessageSnapshot(id: "m1", role: "user", content: "hello", createdAt: Date(timeIntervalSince1970: 1_700_000_100)),
                        MessageSnapshot(id: "m2", role: "assistant", content: "world", createdAt: Date(timeIntervalSince1970: 1_700_000_200)),
                    ]
                )
            ],
            moods: [MoodSnapshot(id: "mo1", value: 4, note: "good", createdAt: Date(timeIntervalSince1970: 1_700_000_300))],
            exportedAt: Date(timeIntervalSince1970: 1_700_000_400)
        )
    }

    func testEncryptThenDecryptRoundTripsExactly() throws {
        let payload = makePayload()
        let sealed = try BackupCrypto.encrypt(payload, passphrase: "correct horse battery staple")
        let reopened = try BackupCrypto.decrypt(sealed, passphrase: "correct horse battery staple")
        XCTAssertEqual(reopened, payload)
    }

    func testWrongPassphraseThrows() throws {
        let sealed = try BackupCrypto.encrypt(makePayload(), passphrase: "right passphrase")
        XCTAssertThrowsError(try BackupCrypto.decrypt(sealed, passphrase: "wrong passphrase"))
    }

    func testMalformedDataThrows() {
        XCTAssertThrowsError(try BackupCrypto.decrypt(Data(), passphrase: "any passphrase")) { error in
            guard case BackupCrypto.Error.malformed = error else {
                return XCTFail("expected malformed, got \(error)")
            }
        }
    }

    func testEveryExportIsUniqueEvenForIdenticalPayloads() throws {
        let payload = makePayload()
        let first = try BackupCrypto.encrypt(payload, passphrase: "same passphrase")
        let second = try BackupCrypto.encrypt(payload, passphrase: "same passphrase")
        XCTAssertNotEqual(first, second, "random salt must produce different ciphertext")
        XCTAssertEqual(try BackupCrypto.decrypt(first, passphrase: "same passphrase"),
                       try BackupCrypto.decrypt(second, passphrase: "same passphrase"))
    }
}