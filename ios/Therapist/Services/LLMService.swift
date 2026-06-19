import Foundation

actor LLMService {
    static let shared = LLMService()

    private var ollamaHost: String = "http://localhost:11434"
    private let openRouterBase = "https://openrouter.ai/api/v1"
    private var openRouterKey: String = ""
    private var defaultModel: String = "openai/gpt-4o-mini"

    func configure(openRouterKey: String, ollamaHost: String = "http://localhost:11434", defaultModel: String = "openai/gpt-4o-mini") {
        self.openRouterKey = openRouterKey
        self.ollamaHost = ollamaHost
        self.defaultModel = defaultModel
    }

    func sendMessage(provider: String, model: String, messages: [LLMMessage]) async throws -> String {
        if provider == "openrouter" {
            return try await callOpenRouter(model: model.isEmpty ? defaultModel : model, messages: messages)
        }
        return try await callOllama(model: model.isEmpty ? "llama3.2" : model, messages: messages)
    }

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

    private func callOllama(model: String, messages: [LLMMessage]) async throws -> String {
        let url = URL(string: "\(ollamaHost)/api/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = OllamaChatRequest(model: model, messages: messages, stream: false)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LLMError.apiError(String(data: data, encoding: .utf8) ?? "Unknown error")
        }

        let result = try JSONDecoder().decode(OllamaChatResponse.self, from: data)
        return result.message.content
    }

    func sendJSONQuery(provider: String, model: String, systemPrompt: String, userMessage: String) async throws -> String {
        let messages = [
            LLMMessage(role: "system", content: "\(systemPrompt)\n\nRespond with valid JSON only, no markdown."),
            LLMMessage(role: "user", content: userMessage),
        ]
        return try await sendMessage(provider: provider, model: model, messages: messages)
    }
}

enum LLMError: LocalizedError {
    case noAPIKey
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey: return "OpenRouter API key not configured. Add it in Settings."
        case .apiError(let msg): return "API error: \(msg)"
        }
    }
}
