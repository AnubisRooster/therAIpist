import Foundation
import CryptoKit
import CommonCrypto

/// Seals and opens `BackupPayload` as self-contained, encrypted backup bytes.
///
/// Wire format: `[salt (16)] + [AES-GCM combined sealed box]`. The key is a
/// PBKDF2-HMAC-SHA256 (100k iterations) derivation of the passphrase + salt,
/// so every export is unique even for identical data.
public enum BackupCrypto {
    private static let saltLength = 16
    private static let iterations = 100_000

    public enum Error: Swift.Error, Equatable {
        case sealFailed
        case malformed
        case keyDerivationFailed
    }

    /// Encrypts a payload: JSON encode + PBKDF2 + AES-GCM. Pure CPU work with
    /// no I/O, safe to run off the main actor.
    public static func encrypt(_ payload: BackupPayload, passphrase: String) throws -> Data {
        let json = try JSONEncoder().encode(payload)

        let salt = Data((0..<saltLength).map { _ in UInt8.random(in: 0...255) })
        let key = try deriveKey(passphrase: passphrase, salt: salt)
        let sealed = try AES.GCM.seal(json, using: key)
        guard let combined = sealed.combined else { throw Error.sealFailed }
        return salt + combined
    }

    /// Decrypts backup bytes produced by `encrypt`.
    public static func decrypt(_ data: Data, passphrase: String) throws -> BackupPayload {
        guard data.count > saltLength else { throw Error.malformed }
        let salt = data.prefix(saltLength)
        let sealedData = data.dropFirst(saltLength)
        let key = try deriveKey(passphrase: passphrase, salt: Data(salt))
        let sealed = try AES.GCM.SealedBox(combined: Data(sealedData))
        let json = try AES.GCM.open(sealed, using: key)
        return try JSONDecoder().decode(BackupPayload.self, from: json)
    }

    private static func deriveKey(passphrase: String, salt: Data) throws -> SymmetricKey {
        var derived = [UInt8](repeating: 0, count: 32)
        let count = derived.count
        let status = passphrase.withCString { pw in
            salt.withUnsafeBytes { saltBuf in
                derived.withUnsafeMutableBytes { derivBuf in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        pw,
                        strlen(pw),
                        saltBuf.bindMemory(to: UInt8.self).baseAddress!,
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        derivBuf.bindMemory(to: UInt8.self).baseAddress!,
                        count
                    )
                }
            }
        }
        guard status == kCCSuccess else { throw Error.keyDerivationFailed }
        return SymmetricKey(data: Data(derived))
    }
}