import Foundation

// MARK: - OpenRouter model catalogue

struct OpenRouterModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let pricing: ModelPricing
    let contextLength: Int

    /// A model is free when both prompt and completion cost strings are "0".
    var isFree: Bool { pricing.prompt == "0" && pricing.completion == "0" }

    /// The portion after the slash, used for compact display (e.g. "gpt-4o").
    var shortName: String { id.components(separatedBy: "/").last ?? id }

    enum CodingKeys: String, CodingKey {
        case id, name, pricing
        case contextLength = "context_length"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = (try? c.decode(String.self, forKey: .name)) ?? id
        pricing = (try? c.decode(ModelPricing.self, forKey: .pricing)) ?? ModelPricing(prompt: "0", completion: "0")
        contextLength = (try? c.decode(Int.self, forKey: .contextLength)) ?? 0
    }
}

struct ModelPricing: Codable, Hashable {
    let prompt: String
    let completion: String
}

private struct ModelsResponse: Codable {
    let data: [OpenRouterModel]
}

// MARK: - Service

@MainActor
final class ModelService: ObservableObject {

    @Published private(set) var models: [OpenRouterModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?

    private let cacheKey     = "or_models_cache_v1"
    private let timestampKey = "or_models_timestamp_v1"
    private let maxAge: TimeInterval = 86_400  // 24 h

    init() { loadCache() }

    // MARK: Sorted views

    var freeModels: [OpenRouterModel] {
        models.filter(\.isFree).sorted { $0.contextLength > $1.contextLength }
    }

    var paidModels: [OpenRouterModel] {
        models.filter { !$0.isFree }.sorted { $0.contextLength > $1.contextLength }
    }

    // MARK: Fetch

    /// Refresh only when the cache is empty or older than `maxAge`.
    func refreshIfNeeded(apiKey: String) async {
        let age = Date().timeIntervalSince1970 - UserDefaults.standard.double(forKey: timestampKey)
        guard models.isEmpty || age > maxAge else { return }
        await refresh(apiKey: apiKey)
    }

    func refresh(apiKey: String) async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        // The models endpoint is public, but include the key when present so
        // user-specific availability is reflected.
        var req = URLRequest(url: URL(string: "https://openrouter.ai/api/v1/models")!)
        if !apiKey.isEmpty {
            req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                lastError = "Model list request failed (HTTP \(http.statusCode))."
                return
            }
            let decoded = try JSONDecoder().decode(ModelsResponse.self, from: data)
            models = sort(decoded.data)
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: timestampKey)
        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: Helpers

    private func loadCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let decoded = try? JSONDecoder().decode(ModelsResponse.self, from: data) else { return }
        models = sort(decoded.data)
    }

    private func sort(_ list: [OpenRouterModel]) -> [OpenRouterModel] {
        list.sorted { lhs, rhs in
            if lhs.isFree != rhs.isFree { return lhs.isFree }
            return lhs.contextLength > rhs.contextLength
        }
    }
}
