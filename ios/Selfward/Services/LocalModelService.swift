import Foundation

// MARK: - LocalModel

/// Where a catalog entry came from. Curated models are vetted and bundled in
/// the app; Hugging Face models are fetched dynamically (see HuggingFaceModelService).
enum ModelSource: Hashable {
    case curated
    case huggingFace
}

struct LocalModel: Identifiable, Hashable {
    let id: String          // used as filename stem and session.localModel value
    let name: String
    let description: String
    let sizeBytes: Int64    // approximate
    let downloadURL: String
    let templateType: LocalModelTemplate
    let isRecommended: Bool
    var kind: LocalModelKind = .gguf
    var source: ModelSource = .curated
}

enum LocalModelTemplate {
    case llama3   // Llama 3.x instruct format
    case phi3     // Phi-3.x instruct format
    case chatML   // generic chatML  (<|im_start|> / <|im_end|>)
    case gemma    // Gemma 2 format  (<start_of_turn> / <end_of_turn>)
}

/// Whether a catalog entry is a GGUF file to download or a system-provided model.
enum LocalModelKind {
    case gguf
    case appleFoundation  // uses FoundationModels (iOS 26+, Apple Intelligence)
}

// MARK: - LocalModelService

/// Downloads, tracks, and deletes on-device GGUF model files.
/// Models are stored in `Documents/models/`.
@MainActor
final class LocalModelService: ObservableObject {
    static let shared = LocalModelService()

    // MARK: Catalog

    let catalog: [LocalModel] = [

        // MARK: Apple built-in (no download, iOS 26 + Apple Intelligence only)
        LocalModel(
            id: "apple-foundation",
            name: "Apple Intelligence",
            description: "Built-in · No download · Requires Apple Intelligence",
            sizeBytes: 0,
            downloadURL: "",
            templateType: .chatML,
            isRecommended: false,
            kind: .appleFoundation
        ),

        // MARK: Llama family
        LocalModel(
            id: "llama-3.2-1b",
            name: "Llama 3.2 1B",
            description: "Fastest · ~770 MB · Good for quick replies",
            sizeBytes: 808_000_000,
            downloadURL: "https://huggingface.co/unsloth/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            templateType: .llama3,
            isRecommended: false
        ),
        LocalModel(
            id: "llama-3.2-3b",
            name: "Llama 3.2 3B",
            description: "Balanced · ~1.9 GB · Recommended for most devices",
            sizeBytes: 1_950_000_000,
            downloadURL: "https://huggingface.co/unsloth/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf",
            templateType: .llama3,
            isRecommended: true
        ),
        LocalModel(
            id: "llama-3.1-8b",
            name: "Llama 3.1 8B",
            description: "Powerful · ~4.9 GB · Best quality on larger devices",
            sizeBytes: 4_920_000_000,
            downloadURL: "https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf",
            templateType: .llama3,
            isRecommended: false
        ),

        // MARK: Microsoft Phi
        LocalModel(
            id: "phi-4-mini",
            name: "Phi-4 Mini",
            description: "Smart · ~2.5 GB · 128K native context, strong instruction following",
            sizeBytes: 2_491_874_688,
            downloadURL: "https://huggingface.co/bartowski/microsoft_Phi-4-mini-instruct-GGUF/resolve/main/microsoft_Phi-4-mini-instruct-Q4_K_M.gguf",
            templateType: .phi3,
            isRecommended: false
        ),

        // MARK: Google Gemma
        LocalModel(
            id: "gemma-3-1b",
            name: "Gemma 3 1B",
            description: "Compact · ~0.8 GB · 32K context, fast",
            sizeBytes: 806_058_240,
            downloadURL: "https://huggingface.co/ggml-org/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q4_K_M.gguf",
            templateType: .gemma,
            isRecommended: false
        ),
        LocalModel(
            id: "gemma-3-4b",
            name: "Gemma 3 4B",
            description: "Balanced · ~2.5 GB · 128K context, Google-quality output",
            sizeBytes: 2_489_757_856,
            downloadURL: "https://huggingface.co/ggml-org/gemma-3-4b-it-GGUF/resolve/main/gemma-3-4b-it-Q4_K_M.gguf",
            templateType: .gemma,
            isRecommended: false
        ),

        // MARK: Alibaba Qwen
        LocalModel(
            id: "qwen2.5-1.5b",
            name: "Qwen 2.5 1.5B",
            description: "Tiny · ~1.0 GB · Multilingual, very fast",
            sizeBytes: 1_000_000_000,
            downloadURL: "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf",
            templateType: .chatML,
            isRecommended: false
        ),
        LocalModel(
            id: "qwen3-4b",
            name: "Qwen 3 4B",
            description: "Compact · ~2.5 GB · 256K native context, multilingual, strong reasoning",
            sizeBytes: 2_497_281_120,
            downloadURL: "https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf",
            templateType: .chatML,
            isRecommended: false
        ),

        // MARK: HuggingFace SmolLM
        LocalModel(
            id: "smollm2-1.7b",
            name: "SmolLM2 1.7B",
            description: "Efficient · ~1.1 GB · Built for on-device tasks",
            sizeBytes: 1_100_000_000,
            downloadURL: "https://huggingface.co/bartowski/SmolLM2-1.7B-Instruct-GGUF/resolve/main/SmolLM2-1.7B-Instruct-Q4_K_M.gguf",
            templateType: .chatML,
            isRecommended: false
        ),
    ]

    // MARK: Published state

    @Published private(set) var downloadProgress: [String: Double] = [:]
    @Published private(set) var downloadedIDs: Set<String> = []
    @Published private(set) var dynamicModels: [LocalModel] = []
    @Published private(set) var isCatalogLoading = false

    private var activeTasks: [String: URLSessionDownloadTask] = [:]

    // MARK: Init

    private init() {
        // Start from the last cached Hugging Face catalogue (offline-safe), then
        // refresh in the background if the 24h cache is stale or empty.
        dynamicModels = HuggingFaceModelService.modelsFromCache()
        refreshDownloadedStatus()
        if HuggingFaceModelService.isCacheStale() || dynamicModels.isEmpty {
            Task { await refreshCatalog() }
        }
    }

    // MARK: Catalog (curated + dynamic)

    /// All selectable models: curated first, then dynamic Hugging Face models,
    /// de-duplicated by id (curated wins).
    var availableModels: [LocalModel] {
        var seen = Set<String>()
        var out: [LocalModel] = []
        for m in catalog + dynamicModels {
            if seen.contains(m.id) { continue }
            seen.insert(m.id)
            out.append(m)
        }
        return out
    }

    var recommendedModels: [LocalModel] { catalog.filter { $0.isRecommended } }
    var huggingFaceModels: [LocalModel] { availableModels.filter { $0.source == .huggingFace } }

    /// Refreshes the dynamic Hugging Face catalogue from the network.
    func refreshCatalog() async {
        isCatalogLoading = true
        defer { isCatalogLoading = false }
        let models = await HuggingFaceModelService.fetch()
        if !models.isEmpty { dynamicModels = models }
    }

    /// Test-only hook so unit tests can exercise the catalog merge without
    /// hitting the network.
    func setDynamicModels(_ models: [LocalModel]) {
        dynamicModels = models
    }

    /// Recommends a local model id for the device's RAM so new users start with
    /// something that fits. Prefers Apple Foundation (iOS 26+, no download).
    func recommendedModelID(ramGB: Int) -> String {
        if #available(iOS 26, *),
           let apple = catalog.first(where: { $0.kind == .appleFoundation }) {
            return apple.id
        }
        let budget: Int64
        switch ramGB {
        case ..<4:  budget = 1_300_000_000
        case 4..<6: budget = 1_300_000_000
        case 6..<8: budget = 2_600_000_000
        default:    budget = 5_500_000_000
        }
        let gguf = catalog.filter { $0.kind == .gguf && $0.sizeBytes <= budget }
        if let best = gguf.max(by: { $0.sizeBytes < $1.sizeBytes }) { return best.id }
        return catalog.filter { $0.kind == .gguf }
            .min(by: { $0.sizeBytes < $1.sizeBytes })?.id ?? "llama-3.2-1b"
    }

    // MARK: Public API

    func isDownloaded(_ id: String) -> Bool { downloadedIDs.contains(id) }

    func isDownloading(_ id: String) -> Bool { activeTasks[id] != nil }

    func modelFilePath(id: String) -> URL {
        modelsDirectory.appendingPathComponent("\(id).gguf")
    }

    func startDownload(_ model: LocalModel) {
        guard model.kind == .gguf else { return }
        // `activeTasks` isn't populated until the async download actually starts,
        // so also guard on `downloadProgress` to stop a rapid double-tap from
        // kicking off two concurrent downloads of the same model.
        guard activeTasks[model.id] == nil,
              downloadProgress[model.id] == nil,
              !isDownloaded(model.id) else { return }
        downloadProgress[model.id] = 0.001
        Task { await performDownload(model) }
    }

    func cancelDownload(_ id: String) {
        activeTasks[id]?.cancel()
        activeTasks.removeValue(forKey: id)
        downloadProgress.removeValue(forKey: id)
        try? FileManager.default.removeItem(at: modelFilePath(id: id))
    }

    func deleteModel(_ id: String) {
        guard activeTasks[id] == nil else { return }
        // Apple Foundation model has no file to delete.
        if let model = availableModels.first(where: { $0.id == id }), model.kind == .appleFoundation { return }
        try? FileManager.default.removeItem(at: modelFilePath(id: id))
        downloadedIDs.remove(id)

        // Unload from engine if this model is currently loaded.
        if LocalLLMEngine.shared.loadedModelID == id {
            LocalLLMEngine.shared.unload()
        }
    }

    func refreshDownloadedStatus() {
        let fm = FileManager.default
        try? fm.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
        var found = Set<String>()
        for model in availableModels {
            switch model.kind {
            case .appleFoundation:
                // Treated as "downloaded" when available; availability is checked
                // at runtime by AppleFoundationEngine on iOS 26+ devices.
                if #available(iOS 26, *) {
                    found.insert(model.id)
                }
            case .gguf:
                if fm.fileExists(atPath: modelFilePath(id: model.id).path) {
                    found.insert(model.id)
                }
            }
        }
        downloadedIDs = found
    }

    // MARK: Formatted helpers

    func sizeLabel(_ model: LocalModel) -> String {
        let gb = Double(model.sizeBytes) / 1_000_000_000
        return String(format: "%.1f GB", gb)
    }

    // MARK: Private

    private var modelsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("models")
    }

    private func performDownload(_ model: LocalModel) async {
        let dest = modelFilePath(id: model.id)
        guard let source = URL(string: model.downloadURL) else {
            downloadProgress.removeValue(forKey: model.id)
            return
        }

        do {
            try await downloadFile(from: source, to: dest, modelID: model.id)
            downloadedIDs.insert(model.id)
        } catch {
            // Clean up partial file on failure or cancellation.
            try? FileManager.default.removeItem(at: dest)
        }

        downloadProgress.removeValue(forKey: model.id)
        activeTasks.removeValue(forKey: model.id)
    }

    private func downloadFile(from source: URL, to dest: URL, modelID: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            let delegate = DownloadProgressDelegate(
                onProgress: { [weak self] fraction in
                    Task { @MainActor [weak self] in
                        self?.downloadProgress[modelID] = fraction
                    }
                },
                onComplete: { result in
                    switch result {
                    case .success(let tempURL):
                        do {
                            if FileManager.default.fileExists(atPath: dest.path) {
                                try FileManager.default.removeItem(at: dest)
                            }
                            try FileManager.default.moveItem(at: tempURL, to: dest)
                            cont.resume()
                        } catch {
                            cont.resume(throwing: error)
                        }
                    case .failure(let error):
                        cont.resume(throwing: error)
                    }
                }
            )
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
            let task = session.downloadTask(with: source)
            // Store before resume so cancelDownload() can cancel it.
            self.activeTasks[modelID] = task
            task.resume()
            // Release the session (and its strongly-retained delegate) once the
            // download finishes, instead of leaking one session per download.
            session.finishTasksAndInvalidate()
        }
    }
}

// MARK: - URLSession delegate

private final class DownloadProgressDelegate: NSObject, URLSessionDownloadDelegate {
    let onProgress: (Double) -> Void
    let onComplete: (Result<URL, Error>) -> Void
    private var finished = false

    init(onProgress: @escaping (Double) -> Void, onComplete: @escaping (Result<URL, Error>) -> Void) {
        self.onProgress = onProgress
        self.onComplete = onComplete
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard !finished else { return }
        finished = true
        onComplete(.success(location))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard !finished, let error else { return }
        finished = true
        onComplete(.failure(error))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData _: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        onProgress(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }
}

// MARK: - Hugging Face dynamic catalogue

/// Fetches the continuously-updated catalogue of downloadable GGUF models from
/// the Hugging Face Hub, so on-device model choices stay current without shipping
/// an app update. Results are merged with the curated `catalog` by `LocalModelService`.
/// The catalogue is cached for 24h (mirrors `ModelService`).
enum HuggingFaceModelService {

    private static let cacheKey     = "hf_models_cache_v1"
    private static let timestampKey = "hf_models_timestamp_v1"
    private static let maxAge: TimeInterval = 86_400

    // Reputable curators we trust to surface for a mental-health app. Models from
    // other orgs are ignored to avoid low-quality or unsafe instruction following.
    private static let trustedOrgs = Set([
        "unsloth", "bartowski", "qwen", "google", "maziyarpanahi",
        "mobiuslab", "prithivml", "dataset", "saveml", "replete-ai",
        "nousresearch", "allenai", "microsoft", "huggingface"
    ])

    private static let codingKeywords = ["coder", "code-", "codestral", "codellama",
                                         "codegemma", "deepcoder", "codegeex", "codeium"]

    // MARK: API

    private struct HFModel: Codable {
        let id: String
        let downloads: Int
        let siblings: [HFSibling]?
        struct HFSibling: Codable { let rfilename: String }
    }

    static func fetch() async -> [LocalModel] {
        var components = URLComponents(string: "https://huggingface.co/api/models")!
        components.queryItems = [
            URLQueryItem(name: "library", value: "gguf"),
            URLQueryItem(name: "pipeline_tag", value: "text-generation"),
            URLQueryItem(name: "sort", value: "downloads"),
            URLQueryItem(name: "direction", value: "-1"),
            URLQueryItem(name: "limit", value: "60")
        ]
        guard let url = components.url else { return [] }
        var req = URLRequest(url: url)
        req.timeoutInterval = 30

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                return modelsFromCache()
            }
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: timestampKey)
            return models(from: data)
        } catch {
            return modelsFromCache()
        }
    }

    /// Builds the dynamic model list from cached data (offline / first launch).
    static func modelsFromCache() -> [LocalModel] {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return [] }
        return models(from: data)
    }

    static func isCacheStale() -> Bool {
        let age = Date().timeIntervalSince1970 - UserDefaults.standard.double(forKey: timestampKey)
        return age > maxAge
    }

    // MARK: Parsing

    static func models(from data: Data) -> [LocalModel] {
        guard let list = try? JSONDecoder().decode([HFModel].self, from: data) else { return [] }
        var result: [LocalModel] = []
        for m in list {
            let org = m.id.components(separatedBy: "/").first?.lowercased() ?? ""
            if !trustedOrgs.contains(org) { continue }
            if codingKeywords.contains(where: { m.id.lowercased().contains($0) }) { continue }

            guard let siblings = m.siblings else { continue }
            let ggufs = siblings.map(\.rfilename).filter { $0.lowercased().hasSuffix(".gguf") }
            guard let file = pickGGUF(ggufs) else { continue }

            let downloadURL = "https://huggingface.co/\(m.id)/resolve/main/\(file)"
            let base = (m.id.components(separatedBy: "/").last ?? m.id)
            let quant = quant(from: file)
            let size = estimatedBytes(params: params(from: m.id), quant: quant)
            let id = "\(m.id.replacingOccurrences(of: "/", with: "__"))_\(URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent)"

            var model = LocalModel(
                id: id,
                name: "\(base) · \(quant)",
                description: "Auto · Hugging Face · ~\(String(format: "%.1f", Double(size) / 1_000_000_000)) GB",
                sizeBytes: size,
                downloadURL: downloadURL,
                templateType: template(for: m.id),
                isRecommended: false,
                kind: .gguf
            )
            model.source = .huggingFace
            result.append(model)
        }
        return result
    }

    // Pick a sensible quant: prefer Q4_K_M, then fall back the quality ladder.
    private static func pickGGUF(_ files: [String]) -> String? {
        let ranked = ["Q4_K_M", "Q4_K_S", "Q4_0", "Q3_K_M", "Q3_K_S", "Q2_K", "Q5_K_M", "Q6_K", "Q8_0"]
        for token in ranked {
            if let f = files.first(where: { $0.uppercased().contains(token) }) { return f }
        }
        return files.min(by: { $0.count < $1.count }) ?? files.first
    }

    private static func quant(from file: String) -> String {
        let upper = file.uppercased()
        for token in ["Q2_K", "Q3_K", "Q4_K_M", "Q4_K_S", "Q4_0", "Q5_K_M", "Q6_K", "Q8_0", "F16", "BF16"] {
            if upper.contains(token) { return token }
        }
        return "Q4"
    }

    // Rough param count from the repo id, e.g. "Llama-3.3-3B" -> 3.0
    private static func params(from id: String) -> Double {
        let pattern = #"(\d+(?:\.\d+)?)\s*([BM])"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: id, range: NSRange(id.startIndex..., in: id)),
              let range = Range(match.range(at: 1), in: id),
              let val = Double(id[range]) else { return 3.0 }
        return val
    }

    private static func estimatedBytes(params: Double, quant: String) -> Int64 {
        let factor: Double
        switch quant {
        case "Q2_K": factor = 0.30
        case "Q3_K": factor = 0.38
        case "Q4_K_M", "Q4_K_S", "Q4_0": factor = 0.55
        case "Q5_K": factor = 0.65
        case "Q6_K": factor = 0.75
        case "Q8_0": factor = 1.0
        default: factor = 0.55
        }
        return Int64(params * factor * 1_000_000_000)
    }

    private static func template(for id: String) -> LocalModelTemplate {
        let l = id.lowercased()
        if l.contains("llama") || l.contains("mistral") { return .llama3 }
        if l.contains("phi") { return .phi3 }
        if l.contains("gemma") { return .gemma }
        return .chatML
    }
}
