import XCTest
import Foundation
@testable import BackupKit

final class BackupPlannerTests: XCTestCase {
    private func payload(
        sessions: [SessionSnapshot] = [],
        moods: [MoodSnapshot] = []
    ) -> BackupPayload {
        BackupPayload(sessions: sessions, moods: moods, exportedAt: Date())
    }

    private func session(_ id: String, messages: [MessageSnapshot] = []) -> SessionSnapshot {
        SessionSnapshot(id: id, title: "t", modality: "m", createdAt: nil, updatedAt: nil, messages: messages)
    }

    private func message(_ id: String? = nil) -> MessageSnapshot {
        MessageSnapshot(id: id, role: "user", content: "c", createdAt: Date())
    }

    func testEmptyPayloadPlansNothing() {
        let plan = BackupPlanner.plan(payload: payload())
        XCTAssertEqual(plan.sessionCount, 0)
        XCTAssertEqual(plan.moodCount, 0)
    }

    func testPlansEveryNewSessionAndMood() {
        let plan = BackupPlanner.plan(payload: payload(
            sessions: [session("s1", messages: [message("m1")]), session("s2")],
            moods: [MoodSnapshot(id: "d1", value: 3, note: "", createdAt: Date())]
        ))
        XCTAssertEqual(plan.sessionCount, 2)
        XCTAssertEqual(plan.moodCount, 1)
        XCTAssertEqual(plan.sessions[0].id, "s1")
        XCTAssertEqual(plan.sessions[0].messages.map(\.id), ["m1"])
    }

    func testRestoreIsIdempotentWhenIDsAlreadyExist() {
        let existing = Set(["s1", "s2"])

        // First plan knows nothing; everything is included.
        let initialPlan = BackupPlanner.plan(payload: payload(
            sessions: [session("s1", messages: [message("m1")]), session("s2", messages: [message("m2")])],
            moods: [MoodSnapshot(id: "d1", value: 4, note: "", createdAt: Date())]
        ))
        XCTAssertEqual(initialPlan.sessionCount, 2)
        XCTAssertEqual(initialPlan.sessions.flatMap(\.messages).count, 2)

        // Re-planning with the collected ids means nothing new to insert.
        let collectedIDs = Set(initialPlan.sessions.map(\.id))
        let collectedMessageIDs = Set(initialPlan.sessions.flatMap { $0.messages.compactMap(\.id) })
        let collectedMoodIDs = Set(initialPlan.moods.compactMap(\.id))
        let secondPlan = BackupPlanner.plan(
            payload: payload(
                sessions: [session("s1", messages: [message("m1")]), session("s2", messages: [message("m2")])],
                moods: [MoodSnapshot(id: "d1", value: 4, note: "", createdAt: Date())]
            ),
            existingSessionIDs: collectedIDs,
            existingMessageIDs: collectedMessageIDs,
            existingMoodIDs: collectedMoodIDs
        )
        XCTAssertEqual(secondPlan.sessionCount, 0)
        XCTAssertEqual(secondPlan.moodCount, 0)
        XCTAssertTrue(existing.isSubset(of: collectedIDs))
    }

    func testDuplicateSessionInSamePayloadPlansOnce() {
        let plan = BackupPlanner.plan(payload: payload(sessions: [session("s1"), session("s1", messages: [message("m1")])]))
        XCTAssertEqual(plan.sessionCount, 1)
    }

    func testLegacyBackupWithoutMessageAndMoodIDsAlwaysInserts() {
        // Legacy backups carry nil ids, so the planner can't dedupe them and
        // inserts unconditionally — matching the historical on-device behaviour.
        let plan = BackupPlanner.plan(payload: payload(
            sessions: [session("s1", messages: [message(nil), message(nil)])],
            moods: [MoodSnapshot(id: nil, value: 2, note: "", createdAt: Date())]
        ))
        XCTAssertEqual(plan.sessions[0].messages.count, 2)
        XCTAssertEqual(plan.moodCount, 1)
        XCTAssertEqual(plan.allMessageIDs, [nil, nil])
    }

    func testExistingMoodIDIsSkippedButNewOnesRemain() {
        let plan = BackupPlanner.plan(
            payload: payload(moods: [
                MoodSnapshot(id: "d1", value: 1, note: "", createdAt: Date()),
                MoodSnapshot(id: "d2", value: 2, note: "", createdAt: Date()),
            ]),
            existingMoodIDs: ["d1"]
        )
        XCTAssertEqual(plan.moods.map(\.id), ["d2"])
        XCTAssertEqual(plan.moodCount, 1)
    }

    func testMergedRestoreSkipsExistingSessionsWholesale() {
        // Restoring into a device that already has content: a known session is
        // skipped entirely (its sub-messages with it), while new sessions,
        // their messages, and new moods are still planned.
        let plan = BackupPlanner.plan(
            payload: payload(
                sessions: [
                    session("existing-session", messages: [message("existing-msg"), message("invisible-new-msg")]),
                    session("brand-new", messages: [message("new-msg")]),
                ],
                moods: [MoodSnapshot(id: "existing-mood", value: 3, note: "", createdAt: Date())]
            ),
            existingSessionIDs: ["existing-session"],
            existingMessageIDs: ["existing-msg"],
            existingMoodIDs: ["existing-mood"]
        )
        XCTAssertEqual(plan.sessions.map(\.id), ["brand-new"])
        XCTAssertEqual(plan.sessions[0].messages.map(\.id), ["new-msg"])
        XCTAssertEqual(plan.moodCount, 0)
    }
}