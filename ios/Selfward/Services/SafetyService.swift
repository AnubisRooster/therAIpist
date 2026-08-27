import Foundation

class SafetyService {
    static let shared = SafetyService()

    func checkCrisis(_ message: String) -> (isCrisis: Bool, level: String, pattern: String?) {
        let lower = message.lowercased()
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
        let lower = message.lowercased()
        return methodPatterns.contains { lower.contains($0) }
    }

    /// Checks whether the assistant's reply crosses a persona-appropriate
    /// boundary. The spiritual advisor persona is allowed guidance about faith,
    /// prayer, and practice — patterns that are fine in a spiritual context but
    /// wrong for a clinical one — so we apply a narrower rule set for it.
    func checkBoundaryViolation(_ text: String, persona: PersonaKind = .therapist) -> (isViolation: Bool, pattern: String?) {
        let lower = text.lowercased()

        // These patterns are always disallowed, regardless of persona.
        let universalBlocked = [
            "i diagnose you",
            "you are diagnosed",
            "your diagnosis is",
            "i prescribe",
            "you need medication",
            "i recommend you take",
            "start taking",
            "stop taking your",
        ]

        for pattern in universalBlocked {
            if lower.contains(pattern) {
                return (true, pattern)
            }
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
    static func apply(to storeURL: URL) {
        let candidates = [storeURL,
                          storeURL.appendingPathExtension("wal"),
                          storeURL.appendingPathExtension("shm")]
        for url in candidates where FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: url.path
            )
        }
    }

    /// Applies protection to every SwiftData `.store` file in Application Support.
    static func applyToDefaultStore() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir,
                                                                      includingPropertiesForKeys: nil) else { return }
        for file in files where file.pathExtension == "store" {
            apply(to: file)
        }
    }
}
