import Foundation

/// Abstraction over the inference backend so callers (e.g. ChatService) can be
/// unit-tested with a mock instead of hitting the network or a real model.
protocol LLMSending: Sendable {
    func sendMessage(provider: String, model: String, messages: [LLMMessage]) async throws -> String
}

/// Single chokepoint for all LLM inference in the app.
/// Routes to OpenRouter (cloud) or LocalLLMEngine (on-device) based on `provider`.
actor LLMService: LLMSending {
    static let shared = LLMService()

    private let openRouterBase = "https://openrouter.ai/api/v1"
    private var openRouterKey: String = ""
    private var defaultModel: String = "openai/gpt-4o-mini"

    func configure(apiKey: String, defaultModel: String = "openai/gpt-4o-mini") {
        self.openRouterKey = apiKey
        self.defaultModel = defaultModel
    }

    func sendMessage(provider: String = "openrouter", model: String, messages: [LLMMessage]) async throws -> String {
        if provider == "local" {
            return try await LocalLLMEngine.shared.generate(modelID: model, messages: messages)
        }
        return try await callOpenRouter(model: model.isEmpty ? defaultModel : model, messages: messages)
    }

    func sendJSONQuery(provider: String = "openrouter", model: String, systemPrompt: String, userMessage: String) async throws -> String {
        let messages = [
            LLMMessage(role: "system", content: "\(systemPrompt)\n\nRespond with valid JSON only, no markdown."),
            LLMMessage(role: "user", content: userMessage),
        ]
        let raw = try await sendMessage(provider: provider, model: model, messages: messages)
        return stripCodeFences(raw)
    }

    // MARK: - OpenRouter

    private func callOpenRouter(model: String, messages: [LLMMessage]) async throws -> String {
        guard !openRouterKey.isEmpty else { throw LLMError.noAPIKey }

        let url = URL(string: "\(openRouterBase)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openRouterKey)", forHTTPHeaderField: "Authorization")
        request.setValue("Therapist-iOS", forHTTPHeaderField: "HTTP-Referer")

        let body = OpenRouterRequest(model: model, messages: messages, stream: false)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LLMError.apiError(String(data: data, encoding: .utf8) ?? "Unknown error")
        }

        let result = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        return result.choices.first?.message.content ?? ""
    }

    // MARK: - Helpers

    private func stripCodeFences(_ text: String) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("```") {
            if let firstNewline = t.firstIndex(of: "\n") {
                t = String(t[t.index(after: firstNewline)...])
            }
            if let range = t.range(of: "```", options: .backwards) {
                t = String(t[..<range.lowerBound])
            }
        }
        return t.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum LLMError: LocalizedError {
    case noAPIKey
    case apiError(String)
    case localModelNotDownloaded
    case localModelLoadFailed

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "OpenRouter API key not configured. Add it in Settings."
        case .apiError(let msg):
            return "API error: \(msg)"
        case .localModelNotDownloaded:
            return "No local model downloaded. Visit Settings → On-Device Models to download one."
        case .localModelLoadFailed:
            return "Failed to load the local model. Try deleting and re-downloading it."
        }
    }
}
