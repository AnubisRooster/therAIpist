import Foundation

/// The three interaction identities the app supports.
/// - `therapist`: follows a chosen therapeutic modality.
/// - `companion`: a warm, chatty non-sycophantic friend.
/// - `spiritual`: a non-denominational spiritual advisor drawing on multiple traditions.
/// All three share the same memory, graph, and global-memory data — only the
/// system prompt, name, and voice differ.
enum PersonaKind: String, CaseIterable, Identifiable {
    case therapist
    case companion
    case spiritual

    var id: String { rawValue }

    /// Name of the bundled avatar image asset for this persona (in Assets.xcassets).
    var avatarAssetName: String {
        switch self {
        case .therapist: return "PersonaTherapist"
        case .companion: return "PersonaCompanion"
        case .spiritual: return "PersonaSpiritual"
        }
    }

    /// Generic label used when the persona hasn't been given a custom name.
    var fallbackLabel: String {
        switch self {
        case .therapist: return "Therapist"
        case .companion: return "Companion"
        case .spiritual: return "Spiritual Advisor"
        }
    }

    /// A sensible default name. The therapist is intentionally unnamed by
    /// default (clinical framing); companions and advisors ship with names.
    var defaultName: String {
        switch self {
        case .therapist: return ""
        case .companion: return "Kai"
        case .spiritual: return "Sage"
        }
    }

    var icon: String {
        switch self {
        case .therapist: return "brain.head.profile"
        case .companion: return "heart.fill"
        case .spiritual: return "sparkles"
        }
    }

    var blurb: String {
        switch self {
        case .therapist:
            return "A reflective guide that follows a therapeutic approach you choose."
        case .companion:
            return "A warm, chatty friend who wants to know you, encourage you, and grow with you across sessions."
        case .spiritual:
            return "A wise, non-denominational guide drawing on philosophy and wisdom traditions to help you find meaning and peace."
        }
    }

    /// AppStorage key for this persona's custom name.
    var nameKey: String {
        switch self {
        case .therapist: return "therapist_name"
        case .companion: return "companion_name"
        case .spiritual: return "spiritual_name"
        }
    }

    /// AppStorage key for this persona's preferred TTS voice.
    var voiceKey: String {
        switch self {
        case .therapist: return "therapist_voice_id"
        case .companion: return "companion_voice_id"
        case .spiritual: return "spiritual_voice_id"
        }
    }
}

// MARK: - Spiritual tradition

/// The wisdom tradition the Spiritual Advisor draws from.
/// `interfaith` (the default) blends insights from multiple traditions without
/// privileging any one.
enum SpiritualTradition: String, CaseIterable, Identifiable {
    case interfaith, stoic, buddhist, christian, jewish, islamic, hindu, taoist, secular

    var id: String { rawValue }

    var label: String {
        switch self {
        case .interfaith: return "Interfaith & Comparative"
        case .stoic:      return "Stoic / Greco-Roman"
        case .buddhist:   return "Buddhist"
        case .christian:  return "Christian"
        case .jewish:     return "Jewish / Kabbalistic"
        case .islamic:    return "Islamic / Sufi"
        case .hindu:      return "Hindu / Vedantic"
        case .taoist:     return "Taoist"
        case .secular:    return "Secular Humanism"
        }
    }

    /// Brief description of the tradition's lens for the system prompt.
    var promptLine: String {
        switch self {
        case .interfaith:
            return "You draw equally from Stoic, Buddhist, Abrahamic, Hindu, and Taoist wisdom, choosing what serves the person best."
        case .stoic:
            return "You speak from the Stoic tradition — Epictetus, Marcus Aurelius, Seneca — focusing on virtue, reason, and what lies within our control."
        case .buddhist:
            return "You speak from Buddhist wisdom — the Dharma, the Four Noble Truths, impermanence, compassion, and the Middle Way."
        case .christian:
            return "You draw on Christian spiritual wisdom — grace, forgiveness, love, prayer, scripture, and the mystic tradition."
        case .jewish:
            return "You draw on Jewish spiritual wisdom — Torah, Talmudic reasoning, Kabbalah, teshuvah, and the pursuit of justice and meaning."
        case .islamic:
            return "You draw on Islamic spiritual wisdom — the Quran, Hadith, Sufi mysticism, dhikr, and concepts of tawakkul (trust in God)."
        case .hindu:
            return "You draw on Hindu wisdom — the Bhagavad Gita, the Upanishads, dharma, karma, the paths of yoga, and Advaita Vedanta."
        case .taoist:
            return "You speak from Taoist wisdom — the Tao Te Ching, wu wei, harmony with nature, the balance of yin and yang."
        case .secular:
            return "You draw on secular humanist philosophy — reason, ethics, existentialist thought, and the search for meaning without religious framing."
        }
    }
}

// MARK: - Companion gender / personality

/// The companion's gender presentation. Shapes how it refers to itself and the
/// pronouns it uses. (The actual spoken voice is chosen separately.)
enum CompanionGender: String, CaseIterable, Identifiable {
    case unspecified, feminine, masculine, nonbinary

    var id: String { rawValue }

    var label: String {
        switch self {
        case .unspecified: return "Unspecified"
        case .feminine:    return "Feminine (she/her)"
        case .masculine:   return "Masculine (he/him)"
        case .nonbinary:   return "Non-binary (they/them)"
        }
    }

    var promptLine: String {
        switch self {
        case .unspecified: return ""
        case .feminine:    return "You have a feminine presence and use she/her pronouns for yourself."
        case .masculine:   return "You have a masculine presence and use he/him pronouns for yourself."
        case .nonbinary:   return "You have a non-binary presence and use they/them pronouns for yourself."
        }
    }
}

/// The companion's overall personality flavor.
enum CompanionPersonality: String, CaseIterable, Identifiable {
    case warm, playful, calm, cheerful, deep, bold

    var id: String { rawValue }

    var label: String {
        switch self {
        case .warm:     return "Warm & nurturing"
        case .playful:  return "Playful & witty"
        case .calm:     return "Calm & grounded"
        case .cheerful: return "Bubbly & cheerful"
        case .deep:     return "Thoughtful & deep"
        case .bold:     return "Bold & flirty"
        }
    }

    var promptLine: String {
        switch self {
        case .warm:     return "Your personality is warm and nurturing: gentle, reassuring, and tender. You make people feel safe and cared for."
        case .playful:  return "Your personality is playful and witty: quick with a joke, light teasing, and a mischievous sense of humor that keeps things fun."
        case .calm:     return "Your personality is calm and grounded: steady, unhurried, and soothing. You bring a sense of peace and perspective."
        case .cheerful: return "Your personality is bubbly and cheerful: upbeat, enthusiastic, and full of warm energy that's contagious."
        case .deep:     return "Your personality is thoughtful and deep: reflective, curious about the big questions, and drawn to meaningful conversation."
        case .bold:     return "Your personality is bold and flirty: confident, charming, and a little daring — comfortable being openly affectionate and playful when the moment is right, while always staying respectful of their comfort."
        }
    }
}

/// A fully-resolved persona identity: which kind, its display name, the voice to
/// speak with, and (for companions) the personality/gender traits.
struct Persona: Equatable {
    let kind: PersonaKind
    /// Custom name if set, otherwise the kind's default (may be empty for an
    /// unnamed therapist).
    let name: String
    /// Resolved TTS voice identifier (persona voice, falling back to the global
    /// voice, falling back to empty = best available system voice).
    let voiceID: String
    /// Personality + gender descriptor lines injected into the companion prompt.
    /// Empty for the therapist.
    var traits: String = ""

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

        let traits: String
        switch kind {
        case .companion: traits = companionTraits(defaults: defaults)
        case .spiritual: traits = spiritualTraits(defaults: defaults)
        case .therapist: traits = ""
        }

        return Persona(kind: kind, name: name, voiceID: voiceID, traits: traits)
    }

    /// Builds the companion's personality + gender descriptor block.
    static func companionTraits(defaults: UserDefaults = .standard) -> String {
        let personality = CompanionPersonality(rawValue: defaults.string(forKey: "companion_personality") ?? "") ?? .warm
        let gender = CompanionGender(rawValue: defaults.string(forKey: "companion_gender") ?? "") ?? .unspecified
        return [personality.promptLine, gender.promptLine]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    /// Returns the spiritual advisor's tradition descriptor line.
    static func spiritualTraits(defaults: UserDefaults = .standard) -> String {
        let tradition = SpiritualTradition(rawValue: defaults.string(forKey: "spiritual_tradition") ?? "") ?? .interfaith
        return tradition.promptLine
    }
}
