import XCTest

@testable import Selfward

/// Validates the OpenRouter catalogue's text-first filter: the picker must
/// surface free models usable for text chat and drop audio/video generators
/// (Google Lyria is a music model), image-generation models, and coding models.
final class ModelServiceTests: XCTestCase {

    /// Decode a single OpenRouter model fixture in the endpoint's JSON shape
    /// (`architecture.modality`, `input_modalities` / `output_modalities`,
    /// `pricing`, `context_length`). Passing all-nil modalities omits the
    /// `architecture` key entirely (legacy / missing-architecture case).
    private func decodeModel(id: String = "test/model:free",
                             prompt: String = "0",
                             completion: String = "0",
                             modality: String? = "text+image->text",
                             input: [String]? = ["text"],
                             output: [String]? = ["text"]) throws -> OpenRouterModel {
        let archJSON: String
        if let modality, let input, let output {
            let inputJSON = input.map { "\"\($0)\"" }.joined(separator: ",")
            let outputJSON = output.map { "\"\($0)\"" }.joined(separator: ",")
            archJSON = """
                "architecture": {
                    "modality": "\(modality)",
                    "input_modalities": [\(inputJSON)],
                    "output_modalities": [\(outputJSON)]
                },
                """
        } else {
            archJSON = ""
        }
        let json = """
            {
                "id": "\(id)",
                "name": "\(id)",
                "pricing": { "prompt": "\(prompt)", "completion": "\(completion)" },
                "context_length": 65536,
                \(archJSON)
            }
            """
        return try JSONDecoder().decode(OpenRouterModel.self, from: Data(json.utf8))
    }

    // MARK: - isTextFirst

    func testTextOnlyModelIsTextFirst() throws {
        let m = try decodeModel(output: ["text"])
        XCTAssertTrue(m.isTextFirst)
    }

    func testMultimodalTextOutputModelIsTextFirst() throws {
        // e.g. gemma-4: accepts text+image/video, replies with text.
        let m = try decodeModel(id: "google/gemma-4-31b-it:free",
                                modality: "text+image+video->text",
                                input: ["text", "image", "video"],
                                output: ["text"])
        XCTAssertTrue(m.isTextFirst)
    }

    func testLyriaMusicModelIsExcluded() throws {
        // google/lyria-3-pro-preview is text+image -> text+audio (music gen).
        let m = try decodeModel(id: "google/lyria-3-pro-preview",
                                modality: "text+image->text+audio",
                                input: ["text", "image"],
                                output: ["text", "audio"])
        XCTAssertFalse(m.isTextFirst)
    }

    func testAudioOutputModelIsExcluded() throws {
        let m = try decodeModel(output: ["text", "audio"])
        XCTAssertFalse(m.isTextFirst)
    }

    func testVideoOutputModelIsExcluded() throws {
        let m = try decodeModel(output: ["text", "video"])
        XCTAssertFalse(m.isTextFirst)
    }

    func testImageGenerationModelIsExcluded() throws {
        let m = try decodeModel(id: "google/gemini-2.5-flash-image", output: ["text", "image"])
        XCTAssertFalse(m.isTextFirst)
    }

    func testCodingModelIsExcluded() throws {
        let m = try decodeModel(id: "codestral/latest", output: ["text"])
        XCTAssertFalse(m.isTextFirst)
    }

    func testMissingArchitectureFallsBackToIncluded() throws {
        let m = try decodeModel(modality: nil, input: nil, output: nil)
        XCTAssertTrue(m.isTextFirst)
    }

    // MARK: - Pricing / free-list selection

    func testFreeModelIsFree() throws {
        let m = try decodeModel()
        XCTAssertTrue(m.isFree)
        XCTAssertTrue(m.isTextFirst)
    }

    func testPaidModelIsNotFree() throws {
        let m = try decodeModel(prompt: "0.5", completion: "1.0")
        XCTAssertFalse(m.isFree)
        XCTAssertTrue(m.isTextFirst)
    }

    func testLyriaIsFreeButExcludedFromSelection() throws {
        let m = try decodeModel(id: "google/lyria-3-pro-preview",
                                modality: "text+image->text+audio",
                                output: ["text", "audio"])
        XCTAssertTrue(m.isFree)
        XCTAssertFalse(m.isTextFirst)
    }
}