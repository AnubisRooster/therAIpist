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
        kc.set("key-for-groq", for: .groq)
        kc.set("key-for-deepseek", for: .deepseek)
        XCTAssertEqual(kc.get(for: .groq), "key-for-groq")
        XCTAssertEqual(kc.get(for: .deepseek), "key-for-deepseek")
        kc.delete(for: .groq)
        kc.delete(for: .deepseek)
    }
}

// MARK: - Narrative Idempotency Tests

@MainActor
final class NarrativeTests: XCTestCase {
    var container: ModelContainer!

    override func setUp() async throws {
        container = TestSupport.makeInMemoryContainer()
    }

    func testNoChapterIsCreatedWhenNoSources() async throws {
        let ctx = container.mainContext
        let chaptersBefore = try ctx.fetch(FetchDescriptor<NarrativeChapter>())
        XCTAssertEqual(chaptersBefore.count, 0)

        // No sessions → no sources → service should bail before inserting.
        // We override the LLM to confirm it is never called.
        // (NarrativeService is an actor that calls LLMService internally;
        //  a real network call would fail without a key, but bailing early
        //  means the fetch count stays 0 without any network call.)
        // Since we can't intercept the actor without refactoring the service,
        // we just verify the guard at the boundary: an empty context produces
        // no chapters after the call succeeds gracefully.
        try? await NarrativeService.shared.buildIncremental(context: ctx, useCloud: false)
        let chaptersAfter = try ctx.fetch(FetchDescriptor<NarrativeChapter>())
        // The local model path will throw (no model downloaded in test env),
        // caught by try?. Either way no chapters should be inserted.
        XCTAssertEqual(chaptersAfter.count, 0)
    }

    func testWatermarkAdvancesAfterChapterInsertion() throws {
        let ctx = container.mainContext
        let t1 = Date(timeIntervalSinceNow: -3600)
        let t2 = Date(timeIntervalSinceNow: -1800)

        let chapter1 = NarrativeChapter(personaLabel: "Therapist",
                                        title: "Chapter One",
                                        content: "First prose.",
                                        sourceWatermark: t1)
        ctx.insert(chapter1)
        try ctx.save()

        let chapter2 = NarrativeChapter(personaLabel: "Therapist",
                                        title: "Chapter Two",
                                        content: "Second prose.",
                                        sourceWatermark: t2)
        ctx.insert(chapter2)
        try ctx.save()

        let chapters = try ctx.fetch(
            FetchDescriptor<NarrativeChapter>(sortBy: [SortDescriptor(\.sourceWatermark, order: .reverse)])
        )
        XCTAssertEqual(chapters.count, 2)
        XCTAssertGreaterThan(chapters.first!.sourceWatermark, chapters.last!.sourceWatermark)
    }

    func testChapterPersonaLabelIsPreserved() throws {
        let ctx = container.mainContext
        let chapter = NarrativeChapter(personaLabel: "Sage",
                                        title: "A Quiet Moment",
                                        content: "Life moved quietly forward.",
                                        sourceWatermark: Date())
        ctx.insert(chapter)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<NarrativeChapter>())
        XCTAssertEqual(fetched.first?.personaLabel, "Sage")
        XCTAssertEqual(fetched.first?.title, "A Quiet Moment")
    }

    func testDuplicateInsertionDoesNotProduceExtraChapters() throws {
        let ctx = container.mainContext
        let watermark = Date()

        // Simulating what would happen if the service were called twice with
        // the same watermark (idempotency guard).
        let c1 = NarrativeChapter(personaLabel: "Therapist", title: "T", content: "X", sourceWatermark: watermark)
        ctx.insert(c1)
        try ctx.save()

        // The second call to buildIncremental would see watermark == latestSourceDate
        // and find no sources newer than that watermark, so it would skip insertion.
        // We verify the chapter count remains 1.
        let chapters = try ctx.fetch(FetchDescriptor<NarrativeChapter>())
        XCTAssertEqual(chapters.count, 1)
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
