import XCTest
@testable import Selfward

/// Validates the provider/model resolution that decides where inference runs.
/// These read UserDefaults.standard, so we snapshot and restore the keys.
final class SessionModelTests: XCTestCase {
    private let keys = ["default_provider", "default_local_model", "default_model"]
    private var saved: [String: Any?] = [:]

    override func setUp() {
        super.setUp()
        for k in keys { saved[k] = UserDefaults.standard.object(forKey: k) }
        for k in keys { UserDefaults.standard.removeObject(forKey: k) }
    }

    override func tearDown() {
        for k in keys {
            if let value = saved[k] ?? nil { UserDefaults.standard.set(value, forKey: k) }
            else { UserDefaults.standard.removeObject(forKey: k) }
        }
        super.tearDown()
    }

    func testExplicitProviderWins() {
        let s = SessionModel(title: "T", provider: "local")
        XCTAssertEqual(s.resolvedProvider, "local")
    }

    func testFallsBackToOpenRouterWhenNoDefault() {
        let s = SessionModel(title: "T", provider: "")
        XCTAssertEqual(s.resolvedProvider, "openrouter")
    }

    func testUsesAppDefaultProviderWhenSessionEmpty() {
        UserDefaults.standard.set("local", forKey: "default_provider")
        let s = SessionModel(title: "T", provider: "")
        XCTAssertEqual(s.resolvedProvider, "local")
    }

    func testLocalModelResolutionPrefersSessionLocalModel() {
        let s = SessionModel(title: "T", provider: "local")
        s.localModel = "phi-3-mini"
        XCTAssertEqual(s.resolvedModel, "phi-3-mini")
    }

    func testLocalModelFallsBackToDefaultLocalModel() {
        let s = SessionModel(title: "T", provider: "local")
        XCTAssertEqual(s.resolvedModel, "llama-3.2-3b")
    }

    func testCloudModelResolutionPrefersSessionModel() {
        let s = SessionModel(title: "T", provider: "openrouter", model: "anthropic/claude")
        XCTAssertEqual(s.resolvedModel, "anthropic/claude")
    }

    func testCloudModelFallsBackToFreeModel() {
        let s = SessionModel(title: "T", provider: "openrouter", model: "")
        XCTAssertEqual(s.resolvedModel, "meta-llama/llama-3.2-1b-instruct:free")
    }
}

// MARK: - Hugging Face catalogue parsing

@MainActor
final class HuggingFaceCatalogTests: XCTestCase {

    private let fixture = #"""
    [
      {
        "id": "unsloth/Llama-3.3-3B-Instruct-GGUF",
        "downloads": 1000,
        "siblings": [
          { "rfilename": "Llama-3.3-3B-Instruct-Q8_0.gguf" },
          { "rfilename": "Llama-3.3-3B-Instruct-Q4_K_M.gguf" }
        ]
      },
      {
        "id": "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF",
        "downloads": 500,
        "siblings": [ { "rfilename": "qwen2.5-coder-7b-instruct-q4_k_m.gguf" } ]
      },
      {
        "id": "randomdev/CoolModel-GGUF",
        "downloads": 10,
        "siblings": [ { "rfilename": "coolmodel-q4_k_m.gguf" } ]
      },
      {
        "id": "unsloth/TextEmbeddingModel",
        "downloads": 5,
        "siblings": [ { "rfilename": "model.safetensors" } ]
      }
    ]
    """#

    func testParsesOnlyTrustedTextGGUFAndExcludesCodingAndNonTrusted() throws {
        let data = try XCTUnwrap(fixture.data(using: .utf8))
        let models = HuggingFaceModelService.models(from: data)

        // Only the unsloth Llama survives: Qwen is a coder, randomdev is not a
        // trusted org, and the embedding model has no .gguf sibling.
        XCTAssertEqual(models.count, 1)

        let m = try XCTUnwrap(models.first)
        XCTAssertEqual(m.id, "unsloth__Llama-3.3-3B-Instruct-GGUF_Llama-3.3-3B-Instruct-Q4_K_M")
        XCTAssertEqual(m.templateType, .llama3)
        XCTAssertEqual(m.sizeBytes, 1_650_000_000)
        XCTAssertEqual(m.source, .huggingFace)
        XCTAssertTrue(m.downloadURL.contains("Llama-3.3-3B-Instruct-Q4_K_M.gguf"))
    }

    func testPrefersQ4QuantOverHigherQuants() throws {
        let json = #"""
        [
          {
            "id": "unsloth/Model-GGUF",
            "downloads": 1,
            "siblings": [
              { "rfilename": "model-Q8_0.gguf" },
              { "rfilename": "model-Q4_K_M.gguf" },
              { "rfilename": "model-Q2_K.gguf" }
            ]
          }
        ]
        """#
        let data = try XCTUnwrap(json.data(using: .utf8))
        let m = try XCTUnwrap(HuggingFaceModelService.models(from: data).first)
        XCTAssertTrue(m.downloadURL.contains("model-Q4_K_M.gguf"), "should pick Q4_K_M quant")
    }
}

// MARK: - Local catalogue merge + recommendations

@MainActor
final class LocalModelServiceCatalogTests: XCTestCase {

    private var service: LocalModelService { LocalModelService.shared }

    override func tearDown() {
        // Restore the singleton so other tests aren't affected by injected models.
        service.setDynamicModels([])
        super.tearDown()
    }

    func testRecommendedModelIDAlwaysFitsBudget() {
        let budgets: [(ram: Int, budget: Int64)] = [
            (3, 1_300_000_000),
            (5, 1_300_000_000),
            (7, 2_600_000_000),
            (12, 5_500_000_000)
        ]
        for (ram, budget) in budgets {
            let id = service.recommendedModelID(ramGB: ram)
            guard let model = service.catalog.first(where: { $0.id == id }) else {
                XCTFail("recommended id \(id) not found in curated catalogue for ram \(ram)")
                continue
            }
            if model.kind == .appleFoundation {
                XCTAssertEqual(model.sizeBytes, 0)
            } else {
                XCTAssertLessThanOrEqual(model.sizeBytes, budget, "ram \(ram) exceeds budget")
            }
        }
    }

    func testAvailableModelsDeduplicatesCuratedAndAddsNew() {
        let baseCount = service.catalog.count
        var duplicate = LocalModel(
            id: "llama-3.2-3b", name: "dup", description: "", sizeBytes: 1,
            downloadURL: "", templateType: .llama3, isRecommended: false,
            kind: .gguf
        )
        duplicate.source = .huggingFace
        var fresh = LocalModel(
            id: "hf_new_model_x", name: "New HF", description: "", sizeBytes: 1,
            downloadURL: "https://huggingface.co/x/y.gguf", templateType: .chatML,
            isRecommended: false, kind: .gguf
        )
        fresh.source = .huggingFace
        service.setDynamicModels([duplicate, fresh])

        let avail = service.availableModels
        XCTAssertEqual(avail.filter { $0.id == "llama-3.2-3b" }.count, 1, "must de-dupe by id (curated wins)")
        XCTAssertTrue(avail.contains { $0.id == "hf_new_model_x" }, "new HF model must appear")
        XCTAssertEqual(avail.count, baseCount + 1, "only the non-duplicate adds to the list")
    }
}

// MARK: - OpenRouter text-first filtering

final class OpenRouterModelFilterTests: XCTestCase {

    private func decode(_ json: String) throws -> OpenRouterModel {
        let data = try XCTUnwrap(json.data(using: .utf8))
        return try JSONDecoder().decode(OpenRouterModel.self, from: data)
    }

    func testTextModelPasses() throws {
        let a = try decode(#"{"id":"anthropic/claude-3.5-sonnet","name":"x","pricing":{"prompt":"0","completion":"0"},"context_length":0,"architecture":{"modality":"text","input_modalities":["text"],"output_modalities":["text"]}}"#)
        XCTAssertTrue(a.isTextFirst)
        let b = try decode(#"{"id":"openai/gpt-4o","name":"x","pricing":{"prompt":"0","completion":"0"},"context_length":0,"architecture":{"modality":"multimodal","input_modalities":["text","image"],"output_modalities":["text"]}}"#)
        XCTAssertTrue(b.isTextFirst)
        let c = try decode(#"{"id":"x/y","name":"x","pricing":{"prompt":"0","completion":"0"},"context_length":0}"#)
        XCTAssertTrue(c.isTextFirst)
    }

    func testImageModelExcluded() throws {
        let a = try decode(#"{"id":"stability/stable-diffusion","name":"x","pricing":{"prompt":"0","completion":"0"},"context_length":0,"architecture":{"modality":"text","input_modalities":["text"],"output_modalities":["image"]}}"#)
        XCTAssertFalse(a.isTextFirst)
        let b = try decode(#"{"id":"x/flux","name":"x","pricing":{"prompt":"0","completion":"0"},"context_length":0,"architecture":{"modality":"image"}}"#)
        XCTAssertFalse(b.isTextFirst)
    }

    func testCodingModelExcludedById() throws {
        let a = try decode(#"{"id":"qwen/qwen2.5-coder-7b","name":"x","pricing":{"prompt":"0","completion":"0"},"context_length":0,"architecture":{"modality":"text","input_modalities":["text"],"output_modalities":["text"]}}"#)
        XCTAssertFalse(a.isTextFirst)
        let b = try decode(#"{"id":"deepseek/deepcoder-1.5b","name":"x","pricing":{"prompt":"0","completion":"0"},"context_length":0,"architecture":{"modality":"text","input_modalities":["text"],"output_modalities":["text"]}}"#)
        XCTAssertFalse(b.isTextFirst)
    }
}
