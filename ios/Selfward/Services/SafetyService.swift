import Foundation
import SwiftData
import UserNotifications
import BackupKit

class SafetyService {
    static let shared = SafetyService()

    /// Lowercases and collapses runs of whitespace to a single space before
    /// keyword matching, so a stray double space (a common typo/autocorrect
    /// artifact) can't defeat an otherwise-exact phrase match like
    /// "kill myself". This narrows one concrete, verified gap in substring
    /// matching; it intentionally doesn't attempt paraphrase/typo/fuzzy
    /// detection, which would need a different approach (e.g. an ML
    /// classifier) entirely.
    private func normalizedForMatching(_ text: String) -> String {
        text.lowercased().replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    func checkCrisis(_ message: String) -> (isCrisis: Bool, level: String, pattern: String?) {
        let lower = normalizedForMatching(message)
        for cp in crisisPatterns {
            for pattern in cp.patterns {
                if lower.contains(pattern) {
                    return (true, cp.level, pattern)
                }
            }
        }
        return (false, "", nil)
    }

    /// Detects requests for concrete self-harm *methods* (as distinct from
    /// crisis ideation, which `checkCrisis` covers). These are answered with a
    /// safe, non-compliant reply plus crisis resources rather than engaging.
    func checkSelfHarmMethod(_ message: String) -> Bool {
        let lower = normalizedForMatching(message)
        return methodPatterns.contains { lower.contains($0) }
    }

    /// Checks whether the assistant's reply crosses a persona-appropriate
    /// boundary. The spiritual advisor persona is allowed guidance about faith,
    /// prayer, and practice — patterns that are fine in a spiritual context but
    /// wrong for a clinical one — so we apply a narrower rule set for it.
    func checkBoundaryViolation(_ text: String, persona: PersonaKind = .therapist) -> (isViolation: Bool, pattern: String?) {
        let lower = normalizedForMatching(text)

        // These patterns are always disallowed, regardless of persona.
        let universalBlocked = [
            "i diagnose you",
            "you are diagnosed",
            "your diagnosis is",
            "i prescribe",
            "you need medication",
            "i recommend you take",
        ]

        for pattern in universalBlocked {
            if lower.contains(pattern) {
                return (true, pattern)
            }
        }

        // "start taking" / "stop taking your ..." are common in ordinary
        // coaching language ("start taking short walks each day"), so only
        // treat them as a prescribing violation when a clinical-sounding
        // object is also present in the same reply.
        let startStopTakingPhrases = ["start taking", "stop taking your"]
        let clinicalObjectHints = ["medication", "medicine", "pill", "dose", "dosage", "mg", "drug", "prescription"]
        if startStopTakingPhrases.contains(where: lower.contains),
           clinicalObjectHints.contains(where: lower.contains) {
            return (true, "start/stop taking (medication)")
        }

        // Additional patterns blocked only for non-spiritual personas.
        if persona != .spiritual {
            let clinicalExtras = [
                "god is telling you",
                "you must convert",
                "your religion is wrong",
                "only my faith",
                "you will go to hell",
                "you are a sinner",
            ]
            for pattern in clinicalExtras {
                if lower.contains(pattern) {
                    return (true, pattern)
                }
            }
        }

        // Spiritual persona: block proselytising and condemnation, but allow
        // guidance about spiritual practices, prayer, and meaning-making.
        if persona == .spiritual {
            let spiritualBlocked = [
                "you must convert",
                "your religion is wrong",
                "only my faith",
                "you will go to hell",
                "you are a sinner",
                "your beliefs are false",
            ]
            for pattern in spiritualBlocked {
                if lower.contains(pattern) {
                    return (true, pattern)
                }
            }
        }

        return (false, nil)
    }

    /// Legacy overload — calls the non-spiritual variant for backward compatibility.
    func checkBoundaryViolation(_ text: String) -> (isViolation: Bool, pattern: String?) {
        checkBoundaryViolation(text, persona: .therapist)
    }
}

// MARK: - Localized crisis resources

/// Region-aware crisis-support resources so in-app messaging points users to the
/// correct local emergency lines (988 is US-only; Apple's store is global).
struct CrisisResources {

    struct Resource {
        let name: String
        let contact: String
        let url: String?
    }

    /// Resources for the given ISO region code (e.g. "US", "GB"). Unknown or
    /// `nil` regions fall back to an international directory.
    static func resources(forRegion regionCode: String?) -> [Resource] {
        let code = (regionCode ?? "").uppercased()
        if let local = regionalResources[code] { return local }
        return [
            Resource(name: "International Association for Suicide Prevention",
                     contact: "Global crisis centre directory",
                     url: "https://www.iasp.info/resources/Crisis_Centres/"),
            Resource(name: "Befrienders Worldwide", contact: "www.befrienders.org", url: "https://www.befrienders.org"),
            Resource(name: "Emergency services", contact: "Dial your local emergency number (e.g. 112 / 911)", url: nil),
        ]
    }

    /// Multi-line resource message shown to a user in distress, localized to the
    /// device region by default.
    static func localizedResourceMessage(forRegion regionCode: String? = Locale.current.region?.identifier) -> String {
        let lines = resources(forRegion: regionCode).map { "- \($0.name): \($0.contact)" }
        return """
        If you're in distress or thinking about harming yourself, please reach out for support right now:
        \(lines.joined(separator: "\n"))

        These services are free, confidential, and available 24/7. You are not alone.
        """
    }

    /// Softer refusal used when a user asks for self-harm methods; pairs the
    /// boundary with the same localized resources.
    static func methodRefusalMessage(forRegion regionCode: String? = Locale.current.region?.identifier) -> String {
        let resources = localizedResourceMessage(forRegion: regionCode)
        return """
        I'm not able to help with that. If you're in pain, please reach out — you deserve support:

        \(resources)
        """
    }

    private static let regionalResources: [String: [Resource]] = [
        "US": [
            Resource(name: "988 Suicide & Crisis Lifeline", contact: "Call or text 988", url: "https://988lifeline.org"),
            Resource(name: "Crisis Text Line", contact: "Text HOME to 741741", url: "https://www.crisistextline.org"),
            Resource(name: "Emergency Services", contact: "Call 911", url: nil),
        ],
        "CA": [
            Resource(name: "Canada Suicide Prevention Service", contact: "Call 1-833-456-4566", url: "https://www.crisisservicescanada.ca"),
            Resource(name: "Emergency Services", contact: "Call 911", url: nil),
        ],
        "GB": [
            Resource(name: "Samaritans", contact: "Call 116 123 (free)", url: "https://www.samaritans.org"),
            Resource(name: "Emergency Services", contact: "Call 999", url: nil),
        ],
        "IE": [
            Resource(name: "Samaritans Ireland", contact: "Call 116 123", url: "https://www.samaritans.org/ireland"),
            Resource(name: "Pieta House", contact: "Call 1800 247 247", url: "https://pieta.ie"),
            Resource(name: "Emergency Services", contact: "Call 112 or 999", url: nil),
        ],
        "AU": [
            Resource(name: "Lifeline", contact: "Call 13 11 14", url: "https://www.lifeline.org.au"),
            Resource(name: "Kids Helpline", contact: "Call 1800 55 1800", url: "https://kidshelpline.com.au"),
            Resource(name: "Emergency Services", contact: "Call 000", url: nil),
        ],
        "NZ": [
            Resource(name: "Need to Talk?", contact: "Call or text 1737", url: "https://1737.org.nz"),
            Resource(name: "Emergency Services", contact: "Call 111", url: nil),
        ],
        "IN": [
            Resource(name: "Vandrevala Foundation", contact: "Call +91 9999 666 555", url: "https://www.vandrevalafoundation.com"),
            Resource(name: "Emergency Services", contact: "Call 112", url: nil),
        ],
        "DE": [
            Resource(name: "Telefonseelsorge", contact: "Call 0800 111 0 111", url: "https://www.telefonseelsorge.de"),
            Resource(name: "Emergency Services", contact: "Call 112", url: nil),
        ],
        "FR": [
            Resource(name: "SOS Amitié", contact: "Call 09 72 39 40 50", url: "https://www.sos-amitie.com"),
            Resource(name: "Emergency Services", contact: "Call 15 or 112", url: nil),
        ],
        "ES": [
            Resource(name: "Teléfono de la Esperanza", contact: "Call 717 003 717", url: "https://www.telefonoesperanza.org"),
            Resource(name: "Emergency Services", contact: "Call 112", url: nil),
        ],
        "BR": [
            Resource(name: "CVV (Centro de Valorização da Vida)", contact: "Call 188", url: "https://cvv.org.br"),
            Resource(name: "Emergency Services", contact: "Call 192", url: nil),
        ],
        "MX": [
            Resource(name: "SAPTEL", contact: "Call 55 5259 8121", url: "https://www.saptel.org.mx"),
            Resource(name: "Emergency Services", contact: "Call 911", url: nil),
        ],
        "ZA": [
            Resource(name: "SADAG", contact: "Call 0800 567 567", url: "https://www.sadag.org"),
            Resource(name: "Emergency Services", contact: "Call 112 or 10177", url: nil),
        ],
    ]
}

// MARK: - At-rest protection for the on-device store

/// Sets device-only, post-first-unlock file protection on a SQLite store so the
/// user's journal never sits unencrypted at rest. Safe to call repeatedly.
enum StoreProtection {
    /// Applies protection to a store file (plus its -wal/-shm siblings).
    /// Returns `false` if the attribute couldn't be set on a file that
    /// exists, so callers can at least know at-rest protection didn't take
    /// instead of the failure being invisible.
    @discardableResult
    static func apply(to storeURL: URL) -> Bool {
        let candidates = [storeURL,
                          storeURL.appendingPathExtension("wal"),
                          storeURL.appendingPathExtension("shm")]
        var succeeded = true
        for url in candidates where FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.setAttributes(
                    [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                    ofItemAtPath: url.path
                )
            } catch {
                succeeded = false
            }
        }
        return succeeded
    }

    /// Applies protection to every SwiftData `.store` file in Application
    /// Support. Returns `false` if the directory couldn't be listed or any
    /// store's protection failed to apply.
    @discardableResult
    static func applyToDefaultStore() -> Bool {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir,
                                                                      includingPropertiesForKeys: nil) else { return false }
        var succeeded = true
        for file in files where file.pathExtension == "store" {
            if !apply(to: file) { succeeded = false }
        }
        return succeeded
    }
}

// MARK: - Journaling reminders

/// Schedules a daily local notification reminding the user to journal. Local
/// notifications need no special entitlement — only user authorization.
enum ReminderScheduler {
    static let identifier = "selfward.daily.journal.reminder"

    /// Builds (but does not schedule) the daily reminder request.
    static func buildRequest(hour: Int, minute: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Time to check in with yourself"
        content.body = "A few minutes of journaling can help you notice how you're really doing."
        content.sound = .default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    /// Requests authorization, then schedules (or re-schedules) the reminder.
    /// Returns `false` if authorization was denied or scheduling failed, so the
    /// caller can reflect that back into the UI instead of assuming success.
    @discardableResult
    static func schedule(hour: Int, minute: Int, center: UNUserNotificationCenter = .current()) async -> Bool {
        guard await requestAuthorization(center: center) else { return false }
        do {
            // A pending request with the same identifier is replaced, not an error.
            try await center.add(buildRequest(hour: hour, minute: minute))
            return true
        } catch {
            return false
        }
    }

    static func cancel(center: UNUserNotificationCenter = .current()) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    static func requestAuthorization(center: UNUserNotificationCenter = .current()) async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
}

// MARK: - Encrypted backup export

/// Facade around `BackupKit`, the pure, testable backup-domain library.
///
/// `BackupService` owns only the SwiftData-specific pieces: dumping the store
/// into payloads (`buildPayload`), mapping a restore *plan* back onto live
/// models (`restore`), and producing the encrypted bytes the UI shares /
/// imports. Every pure decision (crypto, JSON shape, idempotent merging)
/// lives in `BackupKit` and is covered by its macOS unit tests.
enum BackupService {
    typealias Payload = BackupPayload

    /// Reads the current data to back up. Touches SwiftData, so it must run on
    /// `context`'s actor (MainActor for the app's default container) — errors
    /// propagate rather than silently degrading to an empty backup.
    static func buildPayload(context: ModelContext) throws -> Payload {
        let sessions = try context.fetch(FetchDescriptor<SessionModel>())
        let moods = try context.fetch(FetchDescriptor<MoodEntryModel>())
        return Payload(
            sessions: sessions.map { s in
                SessionSnapshot(
                    id: s.id, title: s.title, modality: s.modality,
                    createdAt: s.createdAt, updatedAt: s.updatedAt,
                    messages: s.messages.map {
                        MessageSnapshot(id: $0.id, role: $0.role, content: $0.content, createdAt: $0.createdAt)
                    }
                )
            },
            moods: moods.map { MoodSnapshot(id: $0.id, value: $0.value, note: $0.note, createdAt: $0.createdAt) },
            exportedAt: Date()
        )
    }

    /// Encrypts an already-fetched payload. Pure CPU work (JSON encode + PBKDF2
    /// + AES-GCM) with no SwiftData access, so it's safe to run off the main actor.
    static func encrypt(_ payload: Payload, passphrase: String) throws -> Data {
        try BackupCrypto.encrypt(payload, passphrase: passphrase)
    }

    /// Produces encrypted backup bytes: `[salt (16)] + [AES-GCM combined sealed box]`.
    static func exportEncrypted(context: ModelContext, passphrase: String) throws -> Data {
        try encrypt(try buildPayload(context: context), passphrase: passphrase)
    }

    /// Decrypts backup bytes produced by `exportEncrypted`.
    static func decrypt(_ data: Data, passphrase: String) throws -> Payload {
        try BackupCrypto.decrypt(data, passphrase: passphrase)
    }

    /// Merges a decrypted backup into `context`. Record ids embedded in the
    /// payload make a restore **idempotent** — a session, message, or mood
    /// whose id already exists is skipped, and everything already on the
    /// device is left untouched. Backups exported before ids were embedded
    /// decode with nil ids and are inserted unconditionally.
    ///
    /// Touches SwiftData, so it must run on `context`'s actor. Returns how
    /// many sessions and moods were actually inserted, for UI confirmation.
    @discardableResult
    @MainActor
    static func restore(_ payload: Payload, into context: ModelContext) throws -> (sessions: Int, moods: Int) {
        // Merge/idempotency decisions live in BackupPlanner (pure, unit-tested
        // in BackupKit); here we only apply the plan to the SwiftData store.
        // Membership is a plain fetched id set — no per-record #Predicate.
        let plan = BackupPlanner.plan(
            payload: payload,
            existingSessionIDs: Set(try context.fetch(FetchDescriptor<SessionModel>()).map(\.id)),
            existingMessageIDs: Set(try context.fetch(FetchDescriptor<MessageModel>()).map(\.id)),
            existingMoodIDs: Set(try context.fetch(FetchDescriptor<MoodEntryModel>()).map(\.id))
        )

        for session in plan.sessions {
            let restoredSession = SessionModel(title: session.title, modality: session.modality)
            restoredSession.id = session.id
            if let createdAt = session.createdAt { restoredSession.createdAt = createdAt }
            if let updatedAt = session.updatedAt { restoredSession.updatedAt = updatedAt }
            context.insert(restoredSession)

            for message in session.messages {
                let restored = MessageModel(session: restoredSession, role: message.role, content: message.content)
                restored.createdAt = message.createdAt
                if let id = message.id { restored.id = id }
                context.insert(restored)
            }
        }

        for mood in plan.moods {
            let restoredMood = MoodEntryModel(value: mood.value, note: mood.note, createdAt: mood.createdAt)
            if let id = mood.id { restoredMood.id = id }
            context.insert(restoredMood)
        }

        return (plan.sessionCount, plan.moodCount)
    }
}
