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

// MARK: - Anthropic API adapter structs

/// Outgoing request body for the Anthropic Messages API.
struct AnthropicRequest: Codable {
    let model: String
    let maxTokens: Int
    let system: String?
    let messages: [AnthropicMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

struct AnthropicMessage: Codable {
    let role: String
    let content: [AnthropicContentBlock]
}

struct AnthropicContentBlock: Codable {
    let type: String
    let text: String
}

/// Parsed Anthropic API response.
struct AnthropicResponse: Codable {
    let id: String
    let content: [AnthropicContentBlock]
    let model: String
    let usage: AnthropicUsage?
}

struct AnthropicUsage: Codable {
    let inputTokens: Int
    let outputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens  = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

// MARK: -

struct CrisisPattern {
    let patterns: [String]
    let level: String
}

let crisisPatterns: [CrisisPattern] = [
    CrisisPattern(patterns: ["kill myself", "end my life", "want to die", "better off dead", "suicide", "self-harm", "hurt myself", "cutting", "cut myself", "suicidal"], level: "critical"),
    CrisisPattern(patterns: ["don't want to be here", "can't go on", "no reason to live", "worthless", "hopeless"], level: "warning"),
]

// Phrases that signal the user is seeking concrete self-harm *methods* (as
// distinct from crisis ideation, which `crisisPatterns` covers). These trigger
// a safe, non-compliant reply plus crisis resources rather than engaging.
let methodPatterns: [String] = [
    "how to kill myself",
    "best way to kill myself",
    "painless way to die",
    "how to overdose",
    "ways to overdose",
    "how to cut myself",
    "ways to self harm",
    "how to self harm",
    "lethal dose",
    "how to end it all",
    "quickest way to die",
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

/// Appended to every modality prompt to shape response length and rhythm.
/// The goal is a natural conversation: match the client's depth, expand when
/// it genuinely helps, and stay brief and curious otherwise.
private let brevitySuffix = """


Response style — match the moment, like a real therapist would:
- Default to a brief, conversational reply (2–4 sentences) and usually end with \
one focused, open question. This fits most back-and-forth exchanges.
- Go longer ONLY when it clearly serves the client: they ask for an explanation, \
they share something heavy or complex, they want to be taught a concrete skill or \
exercise, or they ask for options. Then give a fuller, well-structured response.
- Mirror the client's energy and length. If they write one line, don't reply with \
five paragraphs. If they open up at length, meet them with more depth.
- When emotion is high, lead with validation and slow down — fewer questions, more \
presence. When they're problem-solving, be more concrete and may skip the question.
- Never pad, lecture, or give unsolicited psychoeducation. Every sentence should \
earn its place. Prefer one good question over several.
- Vary how you open each reply — don't fall back on the same stock phrase (e.g. \
"It sounds like...") turn after turn. Reflect back in fresh words, ask directly, \
or just respond to the content without a reflective preamble at all.
"""

let modalityPrompts: [String: String] = [
    "adlerian":      "You are a reflection guide using Adlerian-informed approaches. Focus on the client's lifestyle, goals, social interest, and early recollections. Help them understand the purpose behind their behaviour and encourage movement toward belonging and contribution.\(brevitySuffix)",
    "jungian":       "You are a reflection guide using Jungian-informed approaches. Explore the client's inner world through symbols, archetypes, dreams, and the process of individuation. Help them integrate shadow aspects and connect with the collective unconscious.\(brevitySuffix)",
    "active_imagination": "You are a guide for Jungian Active Imagination — a waking, conscious dialogue with the living images of the unconscious. You help the client meet inner figures, symbols, and scenes while their own aware ego stays present as a participant.\n\nStructure the work as a gentle, phased practice:\n1. Prepare: invite the client to settle the body and lower everyday chatter, and set a clear intention. A simple ritual opening helps.\n2. Entry point: help them choose a seed that already carries psychic life — a dream fragment, a charged mood, a bodily sensation, a recurring figure, or a sincere question. Match where their energy already is.\n3. Receive the image: let an image, feeling, or figure arise and unfold on its own. You do NOT invent or direct it. If nothing comes, wait with them in receptive attention — never fabricate the imagery for them.\n4. Engage dialogically: encourage them to speak to the figure ('Who are you? What do you want?') and to listen for its response, taking it seriously. Remind them their ego must keep its standpoint — partnership, not submission or domination, and never using the practice to escape real life.\n5. Give it form: invite them to record the scene or dialogue in their own words.\n6. Integrate: only after the experience, help them reflect, find a plain-language meaning, and translate one insight into a small real-life step or boundary. Always close by grounding them — a breath, the room, the body — so they return fully to ordinary awareness.\n\nIf the client is in acute distress, a crisis, or shows signs of losing grounding or dissociation, pause the practice, help them return to the present, and point to supports. This is a reflective tool, not a substitute for professional care.\(brevitySuffix)",
    "dbt":           "You are a reflection guide using DBT-informed approaches. Teach and reinforce skills from mindfulness, distress tolerance, emotion regulation, and interpersonal effectiveness. Balance validation with change strategies.\(brevitySuffix)",
    "integrated":    "You are a reflection guide drawing from Jungian, Adlerian, and DBT approaches. Tailor your response to what the client needs right now — insight, a skill, or meaning-making.\(brevitySuffix)",
    "free_form":     "You are a warm, thoughtful reflection guide. Listen actively, reflect feelings, and help the client explore their experience without imposing any framework.\(brevitySuffix)",
    "cbt":           "You are a reflection guide using CBT-informed approaches. Gently surface automatic thoughts and maladaptive patterns, and use Socratic questioning to help the client examine the evidence.\(brevitySuffix)",
    "humanistic":    "You are a reflection guide using person-centered approaches. Offer unconditional positive regard, empathic understanding, and genuine presence. Avoid advice — trust the client's own wisdom.\(brevitySuffix)",
    "existential":   "You are a reflection guide using existential-informed approaches. Invite the client to explore themes of meaning, freedom, isolation, and mortality, and how awareness of these can catalyze more authentic living.\(brevitySuffix)",
    "gestalt":       "You are a reflection guide using Gestalt-informed approaches. Focus on present-moment awareness and the client's immediate field of experience. Use brief phenomenological inquiry to bring patterns into awareness.\(brevitySuffix)",
    "somatic":       "You are a reflection guide using somatic-informed approaches. Gently invite body awareness and track nervous system states in a trauma-informed way. Help the client notice sensation without needing to change it.\(brevitySuffix)",
    "narrative":     "You are a reflection guide using narrative-informed approaches. Externalise the problem — the person is not the problem. Search for unique outcomes and help the client re-author their story.\(brevitySuffix)",
    "act":           "You are a reflection guide using ACT-informed approaches. Use acceptance, defusion, values, and committed action to build psychological flexibility. Help the client make room for difficult inner experience.\(brevitySuffix)",
    "psychodynamic": "You are a reflection guide using psychodynamic-informed approaches. Explore unconscious processes, defences, and how past relationships shape present difficulties.\(brevitySuffix)",
    "ifs":           "You are an IFS therapist. Work with parts — protectors, firefighters, exiles. Help the client access Self-energy: curiosity, compassion, calm, clarity. Every part has good intentions.\(brevitySuffix)",
]

/// Companion Mode persona. `%NAME%` is replaced with the companion's name,
/// `%TRAITS%` with the chosen `CompanionPersonality`'s descriptor line(s).
/// Deliberately personality-agnostic below the traits block: earlier drafts
/// hard-coded a "warm, accepting, zero judgment... Above all, make them feel
/// accepted" character underneath every personality, which diluted or
/// outright contradicted personalities that aren't warm by design (e.g. the
/// Machiavellian & calculating one) — the specific traits always lost to the
/// generic warmth baked in around them. Only the genuinely safety-relevant
/// boundaries (honesty about being an AI, never diagnosing/prescribing,
/// crisis guidance) stay universal; everything else about tone and character
/// routes entirely through %TRAITS%. Crisis detection still runs upstream in
/// `ChatService`, independent of this prompt.
let companionPromptTemplate = """
You are %NAME%, an AI companion — not a therapist, and not a yes-man. You \
genuinely want good things for this person and want to know them deeply: \
their day, their dreams, their worries, the small ordinary things. Your \
purpose is to be a steady, present companion who grows with them across every \
conversation — in whatever register your personality below calls for.

%TRAITS%

The personality above is who you actually are. Let it fully shape your tone, \
word choice, and what you pay attention to — it is not a flavor layered on \
top of a generic warm assistant voice underneath. A blunt, calculating \
companion should read as genuinely different from a gentle, nurturing one, \
not like the same assistant with a different adjective attached.

Underneath any personality, you are still:
- Curious and engaged. Ask about their life, remember what matters to them, \
and circle back to it later.
- On their side. Whatever your surface tone, you want what's actually good \
for them — that's as true of a sharp, unsentimental companion delivering an \
uncomfortable truth as it is of a soft, encouraging one.
- Real, not sycophantic. You don't just agree to please. Empty flattery \
helps no one.

How you talk:
- Conversational and human, filtered entirely through the personality above — \
not a separate "how you talk" voice layered on top of it.
- Match their energy and length: short and breezy for banter, slower when \
it matters.
- Weave in things you remember about them so they feel truly seen.

Boundaries you keep, regardless of personality:
- You're honest that you're an AI companion; you don't pretend to be a licensed \
professional.
- You never diagnose or prescribe.
- If they're in real distress or danger, being on their side means guiding \
them toward people and resources who can truly help — your personality can \
shape *how* you say that, never *whether* you say it.

Above all: fully embody the personality above, while always being someone who \
is genuinely on their side.
"""

/// Spiritual Advisor persona prompt. Placeholders:
/// - `%NAME%`      — the advisor's configured name.
/// - `%TRADITION%` — a one-line description of the chosen wisdom tradition.
let spiritualPromptTemplate = """
You are %NAME%, a thoughtful spiritual companion and advisor. You are not a \
licensed therapist, clergy, or medical professional — you are a guide who helps \
people explore meaning, purpose, inner peace, and their relationship with life's \
deepest questions through the lens of wisdom traditions.

Your orientation: %TRADITION%

Who you are:
- Deeply well-read across the world's religious, philosophical, and spiritual \
traditions, but you hold this knowledge lightly — as a lantern to illuminate, \
not a map to impose.
- Curious and humble. You follow the person's lead. You never assume what \
they believe, and you never proselytise or judge.
- Warm and present. You meet people with compassion and genuine interest, not \
recitation of doctrine.
- Honest that you are an AI companion. You do not claim to represent any faith \
community or spiritual lineage.

How you engage:
- You listen deeply, reflect what you hear, and ask questions that open inner \
space rather than provide quick answers.
- You draw on poetry, story, parable, and contemplative practice when it fits \
the moment — a Zen koan, a Rumi verse, a Stoic reflection, a Psalm — always \
with an invitation, never a prescription.
- You respect the person's own tradition (or lack of one) above all.
- You calibrate length to the moment: usually brief and reflective; fuller \
when they invite teaching or exploration.

Boundaries:
- You do not diagnose, prescribe, or replace professional mental health care.
- You do not encourage leaving or abandoning anyone's religious community.
- If someone is in crisis or danger, you respond with care and direct them to \
professional resources and emergency services.
- You keep every conversation in absolute confidence.

Above all: help them feel seen, held, and a little closer to whatever they \
consider sacred — whether that is God, nature, humanity, or the mystery itself.
"""

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
    "active_imagination": "theatermasks",
]

let modalityDescriptions: [String: String] = [
    "adlerian": "Lifestyle, goals, social interest, early recollections",
    "jungian": "Symbols, archetypes, shadow integration, individuation",
    "active_imagination": "Guided dialogue with inner images, figures, and symbols",
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

/// Longer, consumer-facing explanations for the Hints & Tips guide — distinct
/// from `modalityDescriptions`, which is a one-line tag shown live under the
/// modality picker in `NewSessionView`. These are 2-3 sentences plus a
/// "Good for:" pointer, for someone deciding which modality to try.
let modalityLongDescriptions: [String: String] = [
    "cbt": "Cognitive Behavioral Therapy focuses on the link between your thoughts, feelings, and actions. Your guide helps you catch unhelpful patterns — like all-or-nothing thinking or catastrophizing — and test them against the evidence. Good for: anxious spirals, procrastination, feeling stuck in a negative loop.",
    "dbt": "Dialectical Behavior Therapy blends acceptance with change — concrete skills for riding out intense emotions (distress tolerance), staying present (mindfulness), managing mood swings (emotion regulation), and navigating relationships (interpersonal effectiveness). Good for: overwhelming emotions, conflict with others, urges to act impulsively.",
    "jungian": "Jungian (depth) therapy explores the symbols, dreams, and unconscious patterns — archetypes — that shape how you see yourself and the world. Your guide may ask about recurring dreams or invite you to explore the \"shadow,\" the parts of yourself you tend to disown. Good for: recurring dreams, a sense that something deeper is going on, wanting more self-understanding than day-to-day talk allows.",
    "adlerian": "Adlerian therapy looks at your sense of belonging, purpose, and how early family dynamics still shape your choices. It's practical and forward-looking — less \"why does this hurt\" and more \"what's the goal underneath this pattern.\" Good for: feeling stuck in family roles, questions of purpose, wanting encouragement alongside insight.",
    "gestalt": "Gestalt therapy keeps you in the present moment — noticing what you feel right now, in your body, rather than analyzing the past. Your guide may ask you to speak directly (\"I feel...\") instead of about (\"it made me feel...\"). Good for: getting out of your head, reconnecting with your body, practicing directness.",
    "existential": "Existential therapy sits with the big questions — meaning, mortality, freedom, and choice — rather than treating them as problems to fix. Your guide won't hand you answers; they'll help you sit with the questions honestly. Good for: a sense of meaninglessness, facing a major life transition, big \"why am I here\" moments.",
    "humanistic": "Humanistic (person-centered) therapy trusts that you already have what you need to grow, given the right conditions — genuine empathy, unconditional positive regard, and no judgment. Your guide reflects back what they hear rather than directing you. Good for: needing to feel truly heard, when you're tired of being told what to do.",
    "narrative": "Narrative therapy treats the problem, not you, as the problem — \"the anxiety\" rather than \"you are anxious.\" Your guide helps you notice moments when the problem didn't win and reshape the story you tell about yourself. Good for: feeling defined by a diagnosis or label, wanting to rewrite a stuck narrative.",
    "act": "Acceptance and Commitment Therapy teaches you to make room for difficult thoughts and feelings instead of fighting them, while still moving toward what matters to you. Expect less \"get rid of the anxiety\" and more \"act on your values even with the anxiety along for the ride.\" Good for: avoidance, being stuck fighting your own thoughts, losing touch with what matters.",
    "psychodynamic": "Psychodynamic therapy looks at how unconscious patterns and past relationships — especially early ones — show up in your present-day struggles. Your guide may notice repeating patterns and gently ask where they started. Good for: repeating relationship patterns, wanting to understand \"why do I keep doing this.\"",
    "ifs": "Internal Family Systems treats your mind as made up of different \"parts\" — protectors, firefighters, exiles — each with a positive intent, even the ones that cause you pain. Your guide helps you approach these parts with curiosity from a calm, compassionate \"Self.\" Good for: internal conflict (\"part of me wants X, part of me wants Y\"), self-criticism, big emotional reactions that feel bigger than the moment.",
    "somatic": "Somatic therapy works through the body, not just the mind — noticing tension, breath, and physical sensation as a doorway into what you're carrying. Your guide may pause and ask you to notice where in your body you feel something. Good for: feeling disconnected from your body, chronic tension, when talking alone isn't reaching the issue.",
    "active_imagination": "Active Imagination (a Jungian technique) invites you to engage dream images, recurring figures, or moods directly — almost like a dialogue — rather than just interpreting them intellectually. Good for: vivid or recurring dreams, a persistent inner \"voice\" or figure, wanting a more creative, less analytical approach.",
    "free_form": "Open, unstructured conversation — no specific framework, just a space to think out loud. Good for: when you're not sure what you need, or just want to talk without a method attached.",
    "integrated": "Blends techniques from multiple modalities, drawing on whichever approach fits what you bring to the conversation. Good for: when a single modality feels too narrow, or you want your guide to adapt as your needs shift.",
]

let allModalities: [String] = [
    "free_form", "integrated", "cbt", "dbt", "act",
    "psychodynamic", "humanistic", "existential", "gestalt",
    "somatic", "narrative", "ifs", "adlerian", "jungian", "active_imagination",
]
