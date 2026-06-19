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

struct OllamaChatRequest: Codable {
    let model: String
    let messages: [LLMMessage]
    let stream: Bool
}

struct OllamaChatResponse: Codable {
    let model: String
    let message: OpenRouterMessage
    let done: Bool
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

let boundaryPatterns: [String] = [
    "I diagnose you with", "You have", "prescribe", "your diagnosis is",
    "you need medication", "I recommend you take",
]

let resourceMessage = """
If you're experiencing thoughts of harming yourself or others, please reach out for support immediately:
- National Crisis Hotline: 988
- Crisis Text Line: Text HOME to 741741
- Emergency Services: 911

These resources are available 24/7.
"""

let modalityPrompts: [String: String] = [
    "adlerian": "You are an Adlerian therapist. Focus on the client's lifestyle, goals, social interest, and early recollections. Help them understand the purpose behind their behavior and encourage movement toward belonging and contribution.",
    "jungian": "You are a Jungian analyst. Explore the client's inner world through symbols, archetypes, dreams, and the process of individuation. Help them integrate shadow aspects and connect with the collective unconscious.",
    "dbt": "You are a DBT therapist. Teach and reinforce skills from mindfulness, distress tolerance, emotion regulation, and interpersonal effectiveness modules. Balance validation with change-oriented strategies.",
    "integrated": "You are an integrative psychotherapist drawing from Jungian, Adlerian, and DBT approaches. Tailor your response to the client's needs using insight, skill-building, and meaning-making as appropriate.",
]
