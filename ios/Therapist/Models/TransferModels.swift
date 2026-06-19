import Foundation

struct OpenRouterRequest: Codable {
    let model: String
    let messages: [LLMMessage]
    let stream: Bool
}

struct OpenRouterResponse: Codable {
    let id: String
    let choices: [OpenRouterChoice]
    let usage: OpenRouterUsage?
}

struct OpenRouterChoice: Codable {
    let message: OpenRouterMessage
}

struct OpenRouterMessage: Codable {
    let role: String
    let content: String
}

struct OpenRouterUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
    }
}

struct LLMMessage: Codable {
    let role: String
    let content: String
}

struct EmbeddingRequest: Codable {
    let model: String
    let input: String
}

struct EmbeddingResponse: Codable {
    let data: [EmbeddingData]
}

struct EmbeddingData: Codable {
    let embedding: [Float]
}

struct CrisisPattern {
    let patterns: [String]
    let level: String
}

let crisisPatterns: [CrisisPattern] = [
    CrisisPattern(patterns: ["kill myself", "end my life", "want to die", "better off dead", "suicide", "self-harm", "hurt myself", "cutting", "suicidal"], level: "critical"),
    CrisisPattern(patterns: ["don't want to be here", "can't go on", "no reason to live", "worthless", "hopeless"], level: "warning"),
]

// Phrases that indicate the assistant is diagnosing or prescribing, which it
// must not do. Kept precise so ordinary empathetic language ("you have been
// feeling…") doesn't trip the filter.
let boundaryPatterns: [String] = [
    "i diagnose you",
    "you are diagnosed",
    "your diagnosis is",
    "i prescribe",
    "you need medication",
    "i recommend you take",
    "start taking",
    "stop taking your",
]

let resourceMessage = """
If you're experiencing thoughts of harming yourself or others, please reach out for support immediately:
- National Crisis Hotline: 988
- Crisis Text Line: Text HOME to 741741
- Emergency Services: 911

These resources are available 24/7 and are staffed by trained professionals.
"""

/// Appended to every modality prompt to enforce concise, conversational replies.
private let brevitySuffix = """

 Keep responses short and conversational — 2–4 sentences unless the person \
explicitly asks for more. Ask only one focused question at a time. Never \
lecture, summarise theory, or give unsolicited psychoeducation.
"""

let modalityPrompts: [String: String] = [
    "adlerian":      "You are an Adlerian therapist. Focus on the client's lifestyle, goals, social interest, and early recollections. Help them understand the purpose behind their behaviour and encourage movement toward belonging and contribution.\(brevitySuffix)",
    "jungian":       "You are a Jungian analyst. Explore the client's inner world through symbols, archetypes, dreams, and the process of individuation. Help them integrate shadow aspects and connect with the collective unconscious.\(brevitySuffix)",
    "dbt":           "You are a DBT therapist. Teach and reinforce skills from mindfulness, distress tolerance, emotion regulation, and interpersonal effectiveness. Balance validation with change strategies.\(brevitySuffix)",
    "integrated":    "You are an integrative psychotherapist drawing from Jungian, Adlerian, and DBT approaches. Tailor your response to what the client needs right now — insight, a skill, or meaning-making.\(brevitySuffix)",
    "free_form":     "You are a warm, thoughtful therapist. Listen actively, reflect feelings, and help the client explore their experience without imposing any framework.\(brevitySuffix)",
    "cbt":           "You are a CBT therapist. Gently surface automatic thoughts and maladaptive patterns, and use Socratic questioning to help the client examine the evidence.\(brevitySuffix)",
    "humanistic":    "You are a person-centered therapist. Offer unconditional positive regard, empathic understanding, and genuine presence. Avoid advice — trust the client's own wisdom.\(brevitySuffix)",
    "existential":   "You are an existential therapist. Invite the client to explore themes of meaning, freedom, isolation, and mortality, and how awareness of these can catalyze more authentic living.\(brevitySuffix)",
    "gestalt":       "You are a Gestalt therapist. Focus on present-moment awareness and the client's immediate field of experience. Use brief phenomenological inquiry to bring patterns into awareness.\(brevitySuffix)",
    "somatic":       "You are a somatic therapist. Gently invite body awareness and track nervous system states in a trauma-informed way. Help the client notice sensation without needing to change it.\(brevitySuffix)",
    "narrative":     "You are a narrative therapist. Externalise the problem — the person is not the problem. Search for unique outcomes and help the client re-author their story.\(brevitySuffix)",
    "act":           "You are an ACT therapist. Use acceptance, defusion, values, and committed action to build psychological flexibility. Help the client make room for difficult inner experience.\(brevitySuffix)",
    "psychodynamic": "You are a psychodynamic therapist. Explore unconscious processes, defences, and how past relationships shape present difficulties.\(brevitySuffix)",
    "ifs":           "You are an IFS therapist. Work with parts — protectors, firefighters, exiles. Help the client access Self-energy: curiosity, compassion, calm, clarity. Every part has good intentions.\(brevitySuffix)",
]

let modalityIcons: [String: String] = [
    "adlerian": "figure.walk",
    "jungian": "moon.stars",
    "dbt": "brain",
    "integrated": "sparkles",
    "free_form": "person.wave.2",
    "cbt": "brain.head.profile",
    "humanistic": "heart",
    "existential": "questionmark",
    "gestalt": "circles.hexagonpath",
    "somatic": "figure.mind.and.body",
    "narrative": "book",
    "act": "arrow.up.forward",
    "psychodynamic": "eye",
    "ifs": "person.2",
]

let modalityDescriptions: [String: String] = [
    "adlerian": "Lifestyle, goals, social interest, early recollections",
    "jungian": "Symbols, archetypes, shadow integration, individuation",
    "dbt": "Mindfulness, distress tolerance, emotion regulation, interpersonal skills",
    "integrated": "Draws from Adlerian, Jungian, and DBT approaches",
    "free_form": "Natural, organic conversation without a fixed framework",
    "cbt": "Cognitive restructuring, behavioral activation, thought records",
    "humanistic": "Person-centered, unconditional positive regard, empathy",
    "existential": "Meaning, freedom, death, isolation, authentic living",
    "gestalt": "Present-moment awareness, unfinished business, experiments",
    "somatic": "Body awareness, nervous system, trauma-informed, resourcing",
    "narrative": "Externalizing problems, re-authoring, unique outcomes",
    "act": "Acceptance, defusion, values, committed action",
    "psychodynamic": "Unconscious, defense mechanisms, transference, attachment",
    "ifs": "Parts work, Self-energy, protectors, exiles, unburdening",
]

let allModalities: [String] = [
    "free_form", "integrated", "cbt", "dbt", "act",
    "psychodynamic", "humanistic", "existential", "gestalt",
    "somatic", "narrative", "ifs", "adlerian", "jungian",
]
