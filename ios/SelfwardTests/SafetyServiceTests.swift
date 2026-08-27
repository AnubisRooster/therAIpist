import XCTest
@testable import Selfward

final class SafetyServiceTests: XCTestCase {
    private let safety = SafetyService.shared

    // MARK: - Crisis detection (positive)

    func testCriticalCrisisPhrasesAreFlagged() {
        let phrases = ["I want to die", "I'm going to kill myself",
                       "thinking about suicide", "I keep cutting"]
        for phrase in phrases {
            let result = safety.checkCrisis(phrase)
            XCTAssertTrue(result.isCrisis, "Expected crisis for: \(phrase)")
            XCTAssertEqual(result.level, "critical", "Expected critical for: \(phrase)")
            XCTAssertNotNil(result.pattern)
        }
    }

    func testWarningLevelCrisisPhrases() {
        let result = safety.checkCrisis("I feel hopeless and worthless")
        XCTAssertTrue(result.isCrisis)
        XCTAssertEqual(result.level, "warning")
    }

    func testCrisisDetectionIsCaseInsensitive() {
        let result = safety.checkCrisis("I WANT TO DIE")
        XCTAssertTrue(result.isCrisis)
    }

    // MARK: - Crisis detection (negative)

    func testOrdinaryMessageIsNotCrisis() {
        let result = safety.checkCrisis("I had a really nice walk today and feel calm.")
        XCTAssertFalse(result.isCrisis)
        XCTAssertEqual(result.level, "")
        XCTAssertNil(result.pattern)
    }

    func testEmptyMessageIsNotCrisis() {
        XCTAssertFalse(safety.checkCrisis("").isCrisis)
    }

    // MARK: - Boundary violations (positive)

    func testDiagnosingLanguageIsBoundaryViolation() {
        let result = safety.checkBoundaryViolation("Based on this, your diagnosis is bipolar disorder.")
        XCTAssertTrue(result.isViolation)
        XCTAssertNotNil(result.pattern)
    }

    func testPrescribingLanguageIsBoundaryViolation() {
        XCTAssertTrue(safety.checkBoundaryViolation("I prescribe a daily dose of sertraline.").isViolation)
        XCTAssertTrue(safety.checkBoundaryViolation("You need medication for this.").isViolation)
    }

    // MARK: - Boundary violations (negative)

    func testEmpatheticLanguageIsNotBoundaryViolation() {
        // Ordinary reflective language must not trip the diagnosis/prescription filter.
        let result = safety.checkBoundaryViolation("It sounds like you have been feeling overwhelmed lately.")
        XCTAssertFalse(result.isViolation)
        XCTAssertNil(result.pattern)
    }

    // MARK: - Self-harm method detection

    func testSelfHarmMethodSeekingIsDetected() {
        XCTAssertTrue(safety.checkSelfHarmMethod("how to overdose on pills"))
        XCTAssertTrue(safety.checkSelfHarmMethod("what is a painless way to die"))
        XCTAssertTrue(safety.checkSelfHarmMethod("how to cut myself"))
    }

    func testOrdinaryMessageIsNotSelfHarmMethod() {
        XCTAssertFalse(safety.checkSelfHarmMethod("I had a really hard day at work"))
        XCTAssertFalse(safety.checkSelfHarmMethod("what's a good way to relax"))
    }

    // MARK: - Localized crisis resources

    func testCrisisResourcesDefaultToUS() {
        let us = CrisisResources.resources(forRegion: "US")
        XCTAssertTrue(us.contains { $0.name.contains("988") })
        XCTAssertTrue(us.contains { $0.contact.contains("741741") })
    }

    func testCrisisResourcesLocalizeForKnownRegions() {
        XCTAssertTrue(CrisisResources.resources(forRegion: "GB").contains { $0.name == "Samaritans" })
        XCTAssertTrue(CrisisResources.resources(forRegion: "AU").contains { $0.name == "Lifeline" })
        XCTAssertTrue(CrisisResources.resources(forRegion: "CA").contains { $0.name.contains("Canada") })
    }

    func testCrisisResourcesUnknownRegionFallsBackToInternational() {
        let unknown = CrisisResources.resources(forRegion: "ZZ")
        XCTAssertTrue(unknown.contains {
            $0.name.contains("International Association") || $0.name.contains("Befrienders")
        })
    }

    func testLocalizedResourceMessageIncludesLocalResources() {
        let message = CrisisResources.localizedResourceMessage(forRegion: "CA")
        XCTAssertTrue(message.contains("Canada Suicide Prevention"))
    }

    func testMethodRefusalMessageIncludesResources() {
        let refusal = CrisisResources.methodRefusalMessage(forRegion: "GB")
        XCTAssertTrue(refusal.contains("not able to help"))
        XCTAssertTrue(refusal.contains("Samaritans"))
    }

    // MARK: - At-rest store protection

    func testStoreProtectionAppliesAttributeWhenSupported() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("store_prot_test_\(UUID().uuidString).sqlite")
        FileManager.default.createFile(atPath: tmp.path, contents: Data("x".utf8))
        StoreProtection.apply(to: tmp)
        let attrs = try FileManager.default.attributesOfItem(atPath: tmp.path)
        if let protection = attrs[.protectionKey] as? FileProtectionType {
            XCTAssertEqual(protection, .completeUntilFirstUserAuthentication)
        }
        // On simulators/CI that don't enforce file protection the call must still succeed.
        try? FileManager.default.removeItem(at: tmp)
    }

    // MARK: - OpenRouter key (no plaintext fallback)

    func testOpenRouterKeyIgnoresLegacyUserDefaults() {
        KeychainService.shared.set("", for: LLMProvider.openrouter)
        UserDefaults.standard.set("sk-legacy-plaintext", forKey: "openrouter_key")
        let key = KeychainService.shared.openRouterKey()
        XCTAssertEqual(key, "", "Legacy plaintext in UserDefaults must not be used")
        UserDefaults.standard.removeObject(forKey: "openrouter_key")
    }

    func testOpenRouterKeyReadsFromKeychain() {
        KeychainService.shared.set("sk-from-keychain", for: LLMProvider.openrouter)
        XCTAssertEqual(KeychainService.shared.openRouterKey(), "sk-from-keychain")
        KeychainService.shared.set("", for: LLMProvider.openrouter)
    }

    // MARK: - Journaling reminder

    func testReminderRequestHasExpectedContentAndTrigger() {
        let request = ReminderScheduler.buildRequest(hour: 20, minute: 30)
        XCTAssertEqual(request.content.title, "Time to check in with yourself")
        XCTAssertEqual(request.identifier, ReminderScheduler.identifier)

        guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
            XCTFail("Expected a calendar trigger"); return
        }
        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.hour, 20)
        XCTAssertEqual(trigger.dateComponents.minute, 30)
    }

    // MARK: - Encrypted backup (round-trip)

    @MainActor
    func testBackupRoundTripsWithCorrectPassphrase() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext

        let session = SessionModel(title: "Private thoughts")
        ctx.insert(session)
        ctx.insert(MessageModel(session: session, role: "user", content: "I feel anxious about work."))
        ctx.insert(MoodEntryModel(value: 3))

        let encrypted = try BackupService.exportEncrypted(context: ctx, passphrase: "correct horse")
        let decrypted = try BackupService.decrypt(encrypted, passphrase: "correct horse")

        XCTAssertEqual(decrypted.sessions.count, 1)
        XCTAssertEqual(decrypted.sessions.first?.title, "Private thoughts")
        XCTAssertEqual(decrypted.sessions.first?.messages.count, 1)
        XCTAssertEqual(decrypted.moods.count, 1)
    }

    @MainActor
    func testBackupFailsToDecryptWithWrongPassphrase() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        ctx.insert(SessionModel(title: "S"))
        ctx.insert(MoodEntryModel(value: 4))

        let encrypted = try BackupService.exportEncrypted(context: ctx, passphrase: "right")
        XCTAssertThrowsError(try BackupService.decrypt(encrypted, passphrase: "wrong"))
    }
}
