import XCTest
import Foundation
@testable import BackupKit

final class BackupPayloadTests: XCTestCase {
    func testModernPayloadRoundTripsThroughJSONKeepingIDs() throws {
        let payload = BackupPayload(
            sessions: [
                SessionSnapshot(
                    id: "s-1", title: "T", modality: "m",
                    createdAt: Date(timeIntervalSince1970: 5), updatedAt: Date(timeIntervalSince1970: 6),
                    messages: [MessageSnapshot(id: "m-1", role: "r", content: "c", createdAt: Date(timeIntervalSince1970: 7))]
                )
            ],
            moods: [MoodSnapshot(id: "d-1", value: 3, note: "n", createdAt: Date(timeIntervalSince1970: 8))],
            exportedAt: Date(timeIntervalSince1970: 9)
        )
        let data = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(BackupPayload.self, from: data)
        XCTAssertEqual(decoded, payload)
    }

    func testLegacyPayloadWithoutIDsStillDecodes() throws {
        // Emulates backups exported before ids were embedded: no id keys at all.
        let json = """
        {
          "sessions": [
            {
              "id": "legacy-session",
              "title": "Old session",
              "modality": "integrated",
              "messages": [
                {"role": "assistant", "content": "hello", "createdAt": 123}
              ]
            }
          ],
          "moods": [
            {"value": 4, "note": "", "createdAt": 456}
          ],
          "exportedAt": 789
        }
        """
        let decoded = try JSONDecoder().decode(BackupPayload.self, from: Data(json.utf8))
        XCTAssertNil(decoded.sessions[0].messages[0].id)
        XCTAssertNil(decoded.moods[0].id)
        XCTAssertEqual(decoded.sessions[0].messages[0].content, "hello")
        XCTAssertEqual(decoded.moods[0].value, 4)
    }
}