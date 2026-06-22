import Foundation

// MARK: - LocalModel

struct LocalModel: Identifiable, Hashable {
    let id: String          // used as filename stem and session.localModel value
    let name: String
    let description: String
    let sizeBytes: Int64    // approximate
    let downloadURL: String
    let templateType: LocalModelTemplate
    let isRecommended: Bool
    var kind: LocalModelKind = .gguf
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
            id: "phi-3.5-mini",
            name: "Phi-3.5 Mini",
            description: "Smart · ~2.2 GB · Strong instruction following",
            sizeBytes: 2_200_000_000,
            downloadURL: "https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf",
            templateType: .phi3,
            isRecommended: false
        ),

        // MARK: Google Gemma
        LocalModel(
            id: "gemma-2-2b",
            name: "Gemma 2 2B",
            description: "Compact · ~1.6 GB · Fast, Google-quality output",
            sizeBytes: 1_620_000_000,
            downloadURL: "https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf",
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
            id: "qwen2.5-3b",
            name: "Qwen 2.5 3B",
            description: "Compact · ~1.9 GB · Multilingual, strong reasoning",
            sizeBytes: 1_940_000_000,
            downloadURL: "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf",
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

    private var activeTasks: [String: URLSessionDownloadTask] = [:]

    // MARK: Init

    private init() {
        refreshDownloadedStatus()
    }

    // MARK: Public API

    func isDownloaded(_ id: String) -> Bool { downloadedIDs.contains(id) }

    func isDownloading(_ id: String) -> Bool { activeTasks[id] != nil }

    func modelFilePath(id: String) -> URL {
        modelsDirectory.appendingPathComponent("\(id).gguf")
    }

    func startDownload(_ model: LocalModel) {
        guard model.kind == .gguf else { return }
        guard activeTasks[model.id] == nil, !isDownloaded(model.id) else { return }
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
        if let model = catalog.first(where: { $0.id == id }), model.kind == .appleFoundation { return }
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
        for model in catalog {
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
