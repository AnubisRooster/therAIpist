import XCTest
@testable import Therapist

/// Tests for the Active Imagination modality registration and intervention logic.
final class ActiveImaginationTests: XCTestCase {

    // MARK: - Registration

    func testActiveImaginationIsRegistered() {
        XCTAssertNotNil(modalityPrompts["active_imagination"],
                        "active_imagination must have a system prompt")
    }

    func testActiveImaginationPromptEncodesThePhasedPractice() {
        let prompt = modalityPrompts["active_imagination"] ?? ""
        XCTAssertTrue(prompt.contains("Active Imagination"),
                      "prompt should name the practice")
        // The six phases should all be present.
        XCTAssertTrue(prompt.contains("Prepare"), "phase 1 missing")
        XCTAssertTrue(prompt.contains("Entry point"), "phase 2 missing")
        XCTAssertTrue(prompt.contains("Receive the image"), "phase 3 missing")
        XCTAssertTrue(prompt.contains("Engage dialogically"), "phase 4 missing")
        XCTAssertTrue(prompt.contains("Give it form"), "phase 5 missing")
        XCTAssertTrue(prompt.contains("Integrate"), "phase 6 missing")
    }

    func testActiveImaginationPromptForbidsFabricatingTheImage() {
        let prompt = modalityPrompts["active_imagination"] ?? ""
        XCTAssertTrue(prompt.lowercased().contains("never fabricate"),
                      "must instruct the guide not to invent imagery for the client")
    }

    func testActiveImaginationPromptPausesOnCrisis() {
        let prompt = modalityPrompts["active_imagination"] ?? ""
        XCTAssertTrue(prompt.lowercased().contains("crisis") && prompt.lowercased().contains("pause"),
                      "must pause the practice when the client is in acute distress")
    }

    func testActiveImaginationAppearsInAllModalities() {
        XCTAssertTrue(allModalities.contains("active_imagination"),
                      "must be selectable in the new-session picker")
    }

    func testActiveImaginationHasIconAndDescription() {
        XCTAssertFalse((modalityIcons["active_imagination"] ?? "").isEmpty,
                       "needs an icon for the picker")
        XCTAssertFalse((modalityDescriptions["active_imagination"] ?? "").isEmpty,
                       "needs a description for the picker")
    }

    func testFallsBackToIntegratedWhenUnknown() {
        // TherapyService uses modalityPrompts[modality] ?? integrated, so an
        // unknown modality must still resolve rather than crash.
        let persona = Persona(kind: .therapist, name: "", voiceID: "", traits: "")
        let prompt = TherapyService.shared.getSystemPrompt(persona: persona, modality: "does_not_exist")
        XCTAssertFalse(prompt.isEmpty, "unknown modality should fall back gracefully")
    }

    // MARK: - suggestIntervention

    func testSuggestInterventionEntryPoint() {
        let hint = TherapyService.shared.suggestIntervention(modality: "active_imagination",
                                                             message: "I keep having this dream about a locked door")
        XCTAssertNotNil(hint)
        XCTAssertTrue(hint!.lowercased().contains("entry point"),
                      "dream cue should surface the entry-point nudge")
    }

    func testSuggestInterventionDialogue() {
        let hint = TherapyService.shared.suggestIntervention(modality: "active_imagination",
                                                             message: "the figure said it was afraid of me")
        XCTAssertNotNil(hint)
        XCTAssertTrue(hint!.lowercased().contains("dialog"),
                      "figure cue should surface the dialogic nudge")
    }

    func testSuggestInterventionGroundingOnDistress() {
        let hint = TherapyService.shared.suggestIntervention(modality: "active_imagination",
                                                             message: "I feel like I'm dissociating and spinning out")
        XCTAssertNotNil(hint)
        XCTAssertTrue(hint!.lowercased().contains("ground"),
                      "dissociation cue should surface a grounding nudge")
    }

    func testSuggestInterventionIntegration() {
        let hint = TherapyService.shared.suggestIntervention(modality: "active_imagination",
                                                             message: "ok what does it mean, what's the takeaway")
        XCTAssertNotNil(hint)
        XCTAssertTrue(hint!.lowercased().contains("integrat"),
                      "meaning cue should surface the integration nudge")
    }

    func testSuggestInterventionReturnsNilForNeutralMessage() {
        let hint = TherapyService.shared.suggestIntervention(modality: "active_imagination",
                                                             message: "hello there, how are you today")
        XCTAssertNil(hint, "no modality cue should return nil")
    }
}
