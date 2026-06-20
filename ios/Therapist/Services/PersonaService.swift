import Foundation

/// The two interaction identities the app supports. A `therapist` follows a
/// chosen modality; a `companion` is a warm, chatty friend. Both read the same
/// memory, graph, and global-memory data — only the system prompt, name, and
/// voice differ.
enum PersonaKind: String, CaseIterable, Identifiable {
    case therapist
    case companion

    var id: String { rawValue }

    /// Generic label used when the persona hasn't been given a custom name.
    var fallbackLabel: String {
        switch self {
        case .therapist: return "Therapist"
        case .companion: return "Companion"
        }
    }

    /// A sensible default name. The therapist is intentionally unnamed by
    /// default (it keeps the original clinical framing); the companion ships
    /// with a friendly name so it always has a personality.
    var defaultName: String {
        switch self {
        case .therapist: return ""
        case .companion: return "Kai"
        }
    }

    var icon: String {
        switch self {
        case .therapist: return "brain.head.profile"
        case .companion: return "heart.fill"
        }
    }

    var blurb: String {
        switch self {
        case .therapist:
            return "A reflective guide that follows a therapeutic approach you choose."
        case .companion:
            return "A warm, chatty friend who wants to know you, encourage you, and grow with you across sessions."
        }
    }

    /// AppStorage key for this persona's custom name.
    var nameKey: String {
        switch self {
        case .therapist: return "therapist_name"
        case .companion: return "companion_name"
        }
    }

    /// AppStorage key for this persona's preferred TTS voice.
    var voiceKey: String {
        switch self {
        case .therapist: return "therapist_voice_id"
        case .companion: return "companion_voice_id"
        }
    }
}

/// A fully-resolved persona identity: which kind, its display name, and the
/// voice to speak with.
struct Persona: Equatable {
    let kind: PersonaKind
    /// Custom name if set, otherwise the kind's default (may be empty for an
    /// unnamed therapist).
    let name: String
    /// Resolved TTS voice identifier (persona voice, falling back to the global
    /// voice, falling back to empty = best available system voice).
    let voiceID: String

    /// Name to show in the UI; never empty.
    var displayName: String {
        name.isEmpty ? kind.fallbackLabel : name
    }
}

/// Resolves persona identities from a session + app-wide settings.
enum PersonaService {
    static func kind(for session: SessionModel) -> PersonaKind {
        PersonaKind(rawValue: session.persona) ?? .therapist
    }

    static func resolve(for session: SessionModel,
                        defaults: UserDefaults = .standard) -> Persona {
        resolve(kind: kind(for: session), defaults: defaults)
    }

    static func resolve(kind: PersonaKind,
                        defaults: UserDefaults = .standard) -> Persona {
        let stored = (defaults.string(forKey: kind.nameKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let name = stored.isEmpty ? kind.defaultName : stored

        let personaVoice = defaults.string(forKey: kind.voiceKey) ?? ""
        let globalVoice = defaults.string(forKey: "tts_voice_id") ?? ""
        let voiceID = personaVoice.isEmpty ? globalVoice : personaVoice

        return Persona(kind: kind, name: name, voiceID: voiceID)
    }
}
