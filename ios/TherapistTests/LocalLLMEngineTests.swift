import XCTest
@testable import Therapist

/// Validates fix #9: concurrent `loadModel` calls serialize instead of racing,
/// and a bad path fails gracefully (no crash, no stuck `isLoading`).
@MainActor
final class LocalLLMEngineTests: XCTestCase {

    func testConcurrentLoadOfMissingModelDoesNotDeadlockOrCrash() async {
        let engine = LocalLLMEngine.shared
        engine.unload()
        let bogus = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("missing-\(UUID().uuidString).gguf")

        // Fire two loads of the same id at once; serialization must let both
        // return, leaving a single consistent (failed) state.
        async let first: Void = engine.loadModel(id: "ghost", url: bogus)
        async let second: Void = engine.loadModel(id: "ghost", url: bogus)
        _ = await (first, second)

        XCTAssertFalse(engine.isLoading, "isLoading must be reset after a failed load")
        XCTAssertNil(engine.loadedModelID, "A missing file must not register as loaded")
        XCTAssertNotNil(engine.loadError, "A missing file should surface a load error")
    }

    func testGenerateWithoutLoadedModelThrowsNotLoaded() async {
        let engine = LocalLLMEngine.shared
        engine.unload()
        do {
            _ = try await engine.generate(modelID: "ghost",
                                          messages: [LLMMessage(role: "user", content: "hi")])
            XCTFail("Expected notLoaded error")
        } catch let error as LocalLLMError {
            if case .notLoaded = error {} else { XCTFail("Expected .notLoaded, got \(error)") }
        } catch {
            XCTFail("Expected LocalLLMError.notLoaded, got \(error)")
        }
    }
}
