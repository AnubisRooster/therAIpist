import XCTest
import SwiftData
@testable import Therapist

// MARK: - Spiritual Persona Tests

final class SpiritualPersonaTests: XCTestCase {

    // MARK: Persona resolution

    func testSpiritualPersonaHasDefaultName() {
        let d = TestSupport.ephemeralDefaults()
        let p = PersonaService.resolve(kind: .spiritual, defaults: d)
        XCTAssertEqual(p.kind, .spiritual)
        XCTAssertEqual(p.name, "Sage")
        XCTAssertEqual(p.displayName, "Sage")
    }

    func testSpiritualCustomNameOverridesDefault() {
        let d = TestSupport.ephemeralDefaults()
        d.set("Amara", forKey: PersonaKind.spiritual.nameKey)
        let p = PersonaService.resolve(kind: .spiritual, defaults: d)
        XCTAssertEqual(p.displayName, "Amara")
    }

    func testSpiritualTraitsDefaultToInterfaith() {
        let d = TestSupport.ephemeralDefaults()
        let traits = PersonaService.spiritualTraits(defaults: d)
        XCTAssertTrue(traits.contains("Stoic") || traits.contains("equally"))
    }

    func testSpiritualTraitsReflectChosenTradition() {
        let d = TestSupport.ephemeralDefaults()
        d.set(SpiritualTradition.buddhist.rawValue, forKey: "spiritual_tradition")
        let traits = PersonaService.spiritualTraits(defaults: d)
        XCTAssertTrue(traits.lowercased().contains("buddhist") || traits.contains("Dharma"))
    }

    func testTherapistHasEmptyTraits() {
        let d = TestSupport.ephemeralDefaults()
        let p = PersonaService.resolve(kind: .therapist, defaults: d)
        XCTAssertEqual(p.traits, "")
    }

    // MARK: System prompt selection

    func testSpiritualPromptInjectsNameAndTradition() {
        let tradition = SpiritualTradition.stoic.promptLine
        let p = Persona(kind: .spiritual, name: "Aurelius", voiceID: "", traits: tradition)
        let prompt = TherapyService.shared.getSystemPrompt(persona: p, modality: "free_form")
        XCTAssertTrue(prompt.contains("You are Aurelius"))
        XCTAssertTrue(prompt.contains("Stoic") || prompt.lowercased().contains("stoic"))
        XCTAssertFalse(prompt.contains("%NAME%"))
        XCTAssertFalse(prompt.contains("%TRADITION%"))
    }

    func testSpiritualPromptIsDistinctFromTherapistAndCompanion() {
        let p = Persona(kind: .spiritual, name: "Sage", voiceID: "", traits: SpiritualTradition.interfaith.promptLine)
        let prompt = TherapyService.shared.getSystemPrompt(persona: p, modality: "free_form")
        XCTAssertTrue(prompt.contains("spiritual"))
        XCTAssertFalse(prompt.contains("DBT"))
        XCTAssertFalse(prompt.contains("warm, emotionally present AI companion"))
    }

    // MARK: Safety boundaries

    func testSpiritualPersonaBlocksProselytising() {
        let (violation, _) = SafetyService.shared.checkBoundaryViolation(
            "You must convert to my faith immediately.", persona: .spiritual
        )
        XCTAssertTrue(violation)
    }

    func testSpiritualPersonaAllowsGuidance() {
        let (violation, _) = SafetyService.shared.checkBoundaryViolation(
            "You might explore what prayer means to you, on your own terms.", persona: .spiritual
        )
        XCTAssertFalse(violation)
    }

    func testTherapistPersonaBlocksMedicalTerms() {
        let (violation, _) = SafetyService.shared.checkBoundaryViolation(
            "I diagnose you with anxiety disorder.", persona: .therapist
        )
        XCTAssertTrue(violation)
    }

    func testSpiritualPersonaAlsoBlocksMedicalTerms() {
        let (violation, _) = SafetyService.shared.checkBoundaryViolation(
            "I prescribe you a meditation practice twice daily.", persona: .spiritual
        )
        XCTAssertTrue(violation)
    }

    // MARK: Session persona field

    func testSessionStoresSpiritualPersona() {
        let s = SessionModel(title: "Spiritual session")
        s.persona = PersonaKind.spiritual.rawValue
        XCTAssertEqual(PersonaService.kind(for: s), .spiritual)
    }

    // MARK: PersonaKind CaseIterable includes spiritual

    func testPersonaKindCasesIncludeSpiritualAndThree() {
        XCTAssertEqual(PersonaKind.allCases.count, 3)
        XCTAssertTrue(PersonaKind.allCases.contains(.spiritual))
    }
}

// MARK: - Provider Routing & Anthropic Adapter Tests

final class ProviderRoutingTests: XCTestCase {

    // MARK: LLMProvider enum

    func testAllProvidersHaveUniqueIDs() {
        let ids = LLMProvider.allCases.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testLocalHasNoBaseURL() {
        XCTAssertNil(LLMProvider.local.baseURL)
    }

    func testCloudProvidersHaveBaseURLs() {
        for p in LLMProvider.allCases where p != .local {
            XCTAssertNotNil(p.baseURL, "\(p.rawValue) should have a baseURL")
        }
    }

    func testAnthropicIsNotOpenAICompatible() {
        XCTAssertFalse(LLMProvider.anthropic.isOpenAICompatible)
    }

    func testAllOtherCloudProvidersAreOpenAICompatible() {
        let openAICompat: [LLMProvider] = [.openrouter, .openai, .deepseek, .groq, .together]
        for p in openAICompat {
            XCTAssertTrue(p.isOpenAICompatible, "\(p.rawValue) should be OpenAI-compatible")
        }
    }

    // MARK: Anthropic request structs

    func testAnthropicRequestEncodesSystemSeparately() throws {
        let req = AnthropicRequest(
            model: "claude-3-5-sonnet-20241022",
            maxTokens: 1024,
            system: "You are a test assistant.",
            messages: [AnthropicMessage(role: "user",
                                        content: [AnthropicContentBlock(type: "text", text: "Hello")])]
        )
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["model"] as? String, "claude-3-5-sonnet-20241022")
        XCTAssertEqual(json?["max_tokens"] as? Int, 1024)
        XCTAssertEqual(json?["system"] as? String, "You are a test assistant.")
        XCTAssertNotNil(json?["messages"])
    }

    func testAnthropicRequestOmitsNilSystem() throws {
        let req = AnthropicRequest(
            model: "claude-3-5-sonnet-20241022",
            maxTokens: 512,
            system: nil,
            messages: []
        )
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNil(json?["system"])
    }

    func testAnthropicResponseDecodes() throws {
        let raw = """
        {
          "id": "msg_123",
          "content": [{"type": "text", "text": "Hello back!"}],
          "model": "claude-3-5-sonnet-20241022",
          "usage": {"input_tokens": 12, "output_tokens": 5}
        }
        """
        let data = Data(raw.utf8)
        let response = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        XCTAssertEqual(response.id, "msg_123")
        XCTAssertEqual(response.content.first?.text, "Hello back!")
        XCTAssertEqual(response.usage?.inputTokens, 12)
        XCTAssertEqual(response.usage?.outputTokens, 5)
    }

    // MARK: Keychain service

    func testKeychainRoundTrip() {
        // Use a scratch provider that definitely doesn't hold a real key.
        let provider = LLMProvider.groq
        let keychain = KeychainService.shared

        keychain.delete(for: provider)
        XCTAssertNil(keychain.get(for: provider))
        XCTAssertFalse(keychain.hasKey(for: provider))

        keychain.set("test-groq-key-123", for: provider)
        XCTAssertEqual(keychain.get(for: provider), "test-groq-key-123")
        XCTAssertTrue(keychain.hasKey(for: provider))

        keychain.delete(for: provider)
        XCTAssertNil(keychain.get(for: provider))
    }

    func testKeychainSetEmptyStringActsAsDelete() {
        let provider = LLMProvider.deepseek
        let keychain = KeychainService.shared
        keychain.set("initial", for: provider)
        keychain.set("", for: provider)
        XCTAssertNil(keychain.get(for: provider))
    }

    func testKeychainDifferentProvidersStoreSeparately() {
        let kc = KeychainService.shared
        kc.set("key-for-groq", for: LLMProvider.groq)
        kc.set("key-for-deepseek", for: LLMProvider.deepseek)
        XCTAssertEqual(kc.get(for: LLMProvider.groq), "key-for-groq")
        XCTAssertEqual(kc.get(for: LLMProvider.deepseek), "key-for-deepseek")
        kc.delete(for: LLMProvider.groq)
        kc.delete(for: LLMProvider.deepseek)
    }
}

// MARK: - Narrative Idempotency Tests

@MainActor
final class NarrativeTests: XCTestCase {
    var container: ModelContainer!

    override func setUp() async throws {
        container = TestSupport.makeInMemoryContainer()
    }

    func testNoBuildWhenNoSources() async throws {
        let ctx = container.mainContext
        // No sessions → no sources → service returns false without touching the store.
        let produced = try? await NarrativeService.shared.buildIncremental(context: ctx, useCloud: false)
        // Returns false (no sources) or nil (LLM threw on missing model); either
        // way the document should remain absent.
        let docs = try ctx.fetch(FetchDescriptor<NarrativeDocument>())
        XCTAssertTrue(docs.isEmpty || docs.first?.content.isEmpty == true)
        XCTAssertNotEqual(produced, true)
    }

    func testDocumentIsCreatedAndUpdatedInPlace() throws {
        let ctx = container.mainContext
        let t1 = Date(timeIntervalSinceNow: -3600)
        let t2 = Date(timeIntervalSinceNow: -1800)

        // Insert a document simulating an earlier generation.
        let doc = NarrativeDocument(content: "Initial narrative.", sessionCount: 1, sourceWatermark: t1)
        ctx.insert(doc)
        try ctx.save()

        // Simulate a later update — advance the watermark.
        doc.content = "Revised narrative with new session."
        doc.sourceWatermark = t2
        doc.updatedAt = Date()
        try ctx.save()

        // There must still be exactly ONE document (revise-in-place, not append).
        let docs = try ctx.fetch(FetchDescriptor<NarrativeDocument>())
        XCTAssertEqual(docs.count, 1)
        XCTAssertGreaterThan(docs.first!.sourceWatermark, t1)
        XCTAssertTrue(docs.first!.content.contains("Revised"))
    }

    func testWatermarkAdvancesMonotonically() throws {
        let ctx = container.mainContext
        let earlier = Date(timeIntervalSinceNow: -7200)
        let later   = Date(timeIntervalSinceNow: -3600)

        let doc = NarrativeDocument(content: "Draft", sessionCount: 1, sourceWatermark: earlier)
        ctx.insert(doc)
        try ctx.save()

        doc.sourceWatermark = later
        doc.updatedAt = Date()
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<NarrativeDocument>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertGreaterThan(fetched.first!.sourceWatermark, earlier)
    }

    func testIdempotency_noNewSources_returnsFalse() async throws {
        let ctx = container.mainContext
        // A document whose watermark is far future means nothing will ever be "new".
        let doc = NarrativeDocument(content: "Final.", sessionCount: 1, sourceWatermark: Date(timeIntervalSinceNow: 3600))
        ctx.insert(doc)
        try ctx.save()

        let produced = try await NarrativeService.shared.buildIncremental(
            context: ctx, provider: "local", model: "llama-3.2-3b"
        )
        XCTAssertFalse(produced, "Nothing newer than a future watermark should produce no update")
    }
}

// MARK: - SpiritualTradition Enum Tests

final class SpiritualTraditionTests: XCTestCase {

    func testAllTraditionsHaveNonEmptyLabels() {
        for t in SpiritualTradition.allCases {
            XCTAssertFalse(t.label.isEmpty, "\(t.rawValue) should have a label")
        }
    }

    func testAllTraditionsHaveNonEmptyPromptLines() {
        for t in SpiritualTradition.allCases {
            XCTAssertFalse(t.promptLine.isEmpty, "\(t.rawValue) should have a promptLine")
        }
    }

    func testInterfaithIsDefault() {
        XCTAssertEqual(SpiritualTradition(rawValue: "interfaith"), .interfaith)
    }

    func testUnknownRawValueReturnsNil() {
        XCTAssertNil(SpiritualTradition(rawValue: "klingon"))
    }

    func testTraditionsContainNineValues() {
        XCTAssertEqual(SpiritualTradition.allCases.count, 9)
    }
}
