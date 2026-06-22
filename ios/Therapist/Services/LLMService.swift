import Foundation

// MARK: - Provider enumeration

/// All supported LLM inference backends.
/// `local` is special-cased to route to `LocalLLMEngine`; all cloud providers
/// share the OpenAI-compatible chat-completions format except Anthropic which
/// uses its own message schema.
enum LLMProvider: String, CaseIterable, Identifiable {
    case openrouter
    case openai
    case anthropic
    case deepseek
    case groq
    case together
    case local

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .openrouter: return "OpenRouter"
        case .openai:     return "OpenAI"
        case .anthropic:  return "Anthropic"
        case .deepseek:   return "DeepSeek"
        case .groq:       return "Groq"
        case .together:   return "Together AI"
        case .local:      return "On-Device"
        }
    }

    /// REST base URL for the provider (nil for `local`).
    var baseURL: String? {
        switch self {
        case .openrouter: return "https://openrouter.ai/api/v1"
        case .openai:     return "https://api.openai.com/v1"
        case .anthropic:  return "https://api.anthropic.com/v1"
        case .deepseek:   return "https://api.deepseek.com/v1"
        case .groq:       return "https://api.groq.com/openai/v1"
        case .together:   return "https://api.together.xyz/v1"
        case .local:      return nil
        }
    }

    /// Whether this provider uses the OpenAI-compatible chat-completions schema.
    var isOpenAICompatible: Bool { self != .anthropic && self != .local }

    /// The Keychain service identifier for this provider's API key.
    var keychainKey: String { "llm_key_\(rawValue)" }

    /// An example model identifier shown as a placeholder in the BYOK field.
    var exampleModelID: String {
        switch self {
        case .openrouter: return "openai/gpt-4o-mini"
        case .openai:     return "gpt-4o-mini"
        case .anthropic:  return "claude-3-5-sonnet-20241022"
        case .deepseek:   return "deepseek-chat"
        case .groq:       return "llama-3.3-70b-versatile"
        case .together:   return "meta-llama/Llama-3.3-70B-Instruct-Turbo"
        case .local:      return ""
        }
    }

    /// Help text shown under the key field.
    var keyHint: String {
        switch self {
        case .openrouter: return "openrouter.ai/keys"
        case .openai:     return "platform.openai.com/api-keys"
        case .anthropic:  return "console.anthropic.com/keys"
        case .deepseek:   return "platform.deepseek.com"
        case .groq:       return "console.groq.com/keys"
        case .together:   return "api.together.ai"
        case .local:      return ""
        }
    }
}

// MARK: - LLM sending protocol

/// Abstraction over the inference backend so callers (e.g. ChatService) can be
/// unit-tested with a mock instead of hitting the network or a real model.
protocol LLMSending: Sendable {
    func sendMessage(provider: String, model: String, messages: [LLMMessage]) async throws -> String
}

// MARK: - LLMService

/// Single chokepoint for all LLM inference in the app.
/// Routes to the appropriate cloud provider or `LocalLLMEngine` based on the
/// `provider` string (matches `LLMProvider.rawValue`).
actor LLMService: LLMSending {
    static let shared = LLMService()

    private var defaultModel: String = "openai/gpt-4o-mini"
    private let keychain = KeychainService.shared

    func configure(apiKey: String, defaultModel: String = "openai/gpt-4o-mini") {
        self.defaultModel = defaultModel
        // Migrate legacy plaintext openrouter key on first configure call.
        if !apiKey.isEmpty {
            keychain.set(apiKey, for: .openrouter)
        }
    }

    func sendMessage(provider: String = "openrouter",
                     model: String,
                     messages: [LLMMessage]) async throws -> String {
        let providerEnum = LLMProvider(rawValue: provider) ?? .openrouter

        if providerEnum == .local {
            // Route to Apple Foundation Models when the model ID is "apple-foundation".
            if model == "apple-foundation" {
                if #available(iOS 26, *) {
                    let sysPrompt = messages.first(where: { $0.role == "system" })?.content ?? ""
                    return try await AppleFoundationEngine.generate(systemPrompt: sysPrompt,
                                                                    messages: messages)
                }
                throw AppleFoundationError.unavailable("iOS 26 or later required")
            }
            return try await LocalLLMEngine.shared.generate(modelID: model, messages: messages)
        }

        let resolvedModel = model.isEmpty ? defaultModel : model

        if providerEnum == .anthropic {
            return try await callAnthropic(model: resolvedModel, messages: messages)
        }

        return try await callOpenAICompatible(provider: providerEnum,
                                              model: resolvedModel,
                                              messages: messages)
    }

    func sendJSONQuery(provider: String = "openrouter",
                       model: String,
                       systemPrompt: String,
                       userMessage: String) async throws -> String {
        let messages = [
            LLMMessage(role: "system", content: "\(systemPrompt)\n\nRespond with valid JSON only, no markdown."),
            LLMMessage(role: "user", content: userMessage),
        ]
        let raw = try await sendMessage(provider: provider, model: model, messages: messages)
        return stripCodeFences(raw)
    }

    // MARK: - OpenAI-compatible (OpenRouter, OpenAI, DeepSeek, Groq, Together)

    private func callOpenAICompatible(provider: LLMProvider,
                                      model: String,
                                      messages: [LLMMessage]) async throws -> String {
        guard let baseURL = provider.baseURL else {
            throw LLMError.unsupportedProvider(provider.rawValue)
        }
        let apiKey = keychain.get(for: provider) ?? ""
        guard !apiKey.isEmpty else { throw LLMError.noAPIKey }

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",   forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)",   forHTTPHeaderField: "Authorization")
        if provider == .openrouter {
            request.setValue("Therapist-iOS", forHTTPHeaderField: "HTTP-Referer")
        }

        let body = OpenRouterRequest(model: model, messages: messages, stream: false)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw LLMError.apiError(String(data: data, encoding: .utf8) ?? "Unknown error")
        }

        let result = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        return result.choices.first?.message.content ?? ""
    }

    // MARK: - Anthropic

    private func callAnthropic(model: String, messages: [LLMMessage]) async throws -> String {
        guard let baseURL = LLMProvider.anthropic.baseURL else {
            throw LLMError.unsupportedProvider("anthropic")
        }
        let apiKey = keychain.get(for: .anthropic) ?? ""
        guard !apiKey.isEmpty else { throw LLMError.noAPIKey }

        let url = URL(string: "\(baseURL)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",        forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey,                    forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",              forHTTPHeaderField: "anthropic-version")

        let body = try buildAnthropicRequest(model: model, messages: messages)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw LLMError.apiError(String(data: data, encoding: .utf8) ?? "Unknown error")
        }

        let result = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        return result.content.first?.text ?? ""
    }

    private func buildAnthropicRequest(model: String, messages: [LLMMessage]) throws -> Data {
        // Anthropic keeps `system` at the top level, separate from `messages`.
        let systemMessages = messages.filter { $0.role == "system" }.map(\.content).joined(separator: "\n\n")
        let conversationMessages = messages.filter { $0.role != "system" }
            .map { AnthropicMessage(role: $0.role, content: [AnthropicContentBlock(type: "text", text: $0.content)]) }

        let body = AnthropicRequest(model: model,
                                    maxTokens: 4096,
                                    system: systemMessages.isEmpty ? nil : systemMessages,
                                    messages: conversationMessages)
        return try JSONEncoder().encode(body)
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

// MARK: - Errors

enum LLMError: LocalizedError {
    case noAPIKey
    case apiError(String)
    case localModelNotDownloaded
    case localModelLoadFailed
    case unsupportedProvider(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured. Add it in Settings → Keys & Providers."
        case .apiError(let msg):
            return "API error: \(msg)"
        case .localModelNotDownloaded:
            return "No local model downloaded. Visit Settings → Models to download one."
        case .localModelLoadFailed:
            return "Failed to load the local model. Try deleting and re-downloading it."
        case .unsupportedProvider(let p):
            return "Unsupported provider: \(p)."
        }
    }
}
