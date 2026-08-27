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
