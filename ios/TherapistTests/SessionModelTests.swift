import XCTest
@testable import Therapist

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
