import XCTest
import SwiftData
@testable import Therapist

/// Covers persona resolution (name + voice), the persona-specific system prompts,
/// and an end-to-end Companion-Mode chat turn.
final class PersonaTests: XCTestCase {

    // MARK: - Resolution

    func testTherapistDefaultsToUnnamedWithFallbackLabel() {
        let d = TestSupport.ephemeralDefaults()
        let p = PersonaService.resolve(kind: .therapist, defaults: d)
        XCTAssertEqual(p.kind, .therapist)
        XCTAssertEqual(p.name, "")               // intentionally unnamed
        XCTAssertEqual(p.displayName, "Therapist")
    }

    func testCompanionHasADefaultName() {
        let d = TestSupport.ephemeralDefaults()
        let p = PersonaService.resolve(kind: .companion, defaults: d)
        XCTAssertEqual(p.kind, .companion)
        XCTAssertEqual(p.name, "Kai")
        XCTAssertEqual(p.displayName, "Kai")
    }

    func testCustomNamesOverrideDefaults() {
        let d = TestSupport.ephemeralDefaults()
        d.set("Dr. Wise", forKey: PersonaKind.therapist.nameKey)
        d.set("Robin", forKey: PersonaKind.companion.nameKey)

        XCTAssertEqual(PersonaService.resolve(kind: .therapist, defaults: d).displayName, "Dr. Wise")
        XCTAssertEqual(PersonaService.resolve(kind: .companion, defaults: d).displayName, "Robin")
    }

    func testBlankCustomNameFallsBackToDefault() {
        let d = TestSupport.ephemeralDefaults()
        d.set("   ", forKey: PersonaKind.companion.nameKey)   // whitespace only
        XCTAssertEqual(PersonaService.resolve(kind: .companion, defaults: d).name, "Kai")
    }

    func testVoicePrefersPersonaVoiceThenGlobalThenEmpty() {
        let d = TestSupport.ephemeralDefaults()
        // Nothing set → empty (best system voice chosen downstream).
        XCTAssertEqual(PersonaService.resolve(kind: .companion, defaults: d).voiceID, "")

        // Global voice set → used as fallback.
        d.set("global.voice", forKey: "tts_voice_id")
        XCTAssertEqual(PersonaService.resolve(kind: .companion, defaults: d).voiceID, "global.voice")

        // Persona voice set → wins over global.
        d.set("companion.voice", forKey: PersonaKind.companion.voiceKey)
        XCTAssertEqual(PersonaService.resolve(kind: .companion, defaults: d).voiceID, "companion.voice")
        // Therapist still falls back to global since it has no persona voice.
        XCTAssertEqual(PersonaService.resolve(kind: .therapist, defaults: d).voiceID, "global.voice")
    }

    func testKindReadsSessionPersonaField() {
        let s = SessionModel(title: "T")
        XCTAssertEqual(PersonaService.kind(for: s), .therapist)   // default
        s.persona = "companion"
        XCTAssertEqual(PersonaService.kind(for: s), .companion)
        s.persona = "garbage"
        XCTAssertEqual(PersonaService.kind(for: s), .therapist)   // unknown → therapist
    }

    // MARK: - System prompts

    func testCompanionPromptInjectsNameAndIsWarm() {
        let p = Persona(kind: .companion, name: "Remy", voiceID: "")
        let prompt = TherapyService.shared.getSystemPrompt(persona: p, modality: "free_form")
        XCTAssertTrue(prompt.contains("You are Remy"))
        XCTAssertTrue(prompt.lowercased().contains("companion"))
        XCTAssertFalse(prompt.contains("%NAME%"))               // placeholder replaced
        XCTAssertFalse(prompt.contains("You are a Gestalt"))    // not a modality prompt
    }

    func testTherapistPromptUsesModalityAndInjectsNameWhenSet() {
        let named = Persona(kind: .therapist, name: "Sage", voiceID: "")
        let prompt = TherapyService.shared.getSystemPrompt(persona: named, modality: "cbt")
        XCTAssertTrue(prompt.contains("Your name is Sage"))
        XCTAssertTrue(prompt.contains("CBT therapist"))
    }

    func testUnnamedTherapistPromptHasNoNameLine() {
        let unnamed = Persona(kind: .therapist, name: "", voiceID: "")
        let prompt = TherapyService.shared.getSystemPrompt(persona: unnamed, modality: "dbt")
        XCTAssertFalse(prompt.contains("Your name is"))
        XCTAssertTrue(prompt.contains("DBT therapist"))
    }

    // MARK: - End-to-end Companion turn

    @MainActor
    func testCompanionSessionSendsCompanionSystemPrompt() async {
        let savedName = UserDefaults.standard.object(forKey: PersonaKind.companion.nameKey)
        UserDefaults.standard.set("Remy", forKey: PersonaKind.companion.nameKey)
        defer {
            if let savedName { UserDefaults.standard.set(savedName, forKey: PersonaKind.companion.nameKey) }
            else { UserDefaults.standard.removeObject(forKey: PersonaKind.companion.nameKey) }
        }

        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let mock = MockLLM(response: "Hey, I'm so glad you're here.")
        let chat = ChatService(llm: mock)

        let session = SessionModel(title: "Companion", provider: "openrouter", model: "test/model")
        session.persona = "companion"
        ctx.insert(session)

        _ = await chat.processMessage(session: session,
                                      userMessage: "hi, how are you?",
                                      context: ctx)

        let system = mock.lastMessages.first { $0.role == "system" }
        XCTAssertNotNil(system)
        XCTAssertTrue(system?.content.contains("You are Remy") ?? false)
        XCTAssertTrue(session.messages.contains { $0.role == "assistant" })
    }
}
