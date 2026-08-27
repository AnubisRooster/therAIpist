import Foundation
import SwiftData

class NoteService {
    static let shared = NoteService()

    func createNote(session: SessionModel, type: String, title: String, content: String, context: ModelContext) -> NoteModel {
        let note = NoteModel(session: session, type: type, title: title, content: content)
        context.insert(note)
        return note
    }

    func createSOAPNote(session: SessionModel, subjective: String, objective: String, assessment: String, plan: String, context: ModelContext) -> NoteModel {
        let content = """
        SUBJECTIVE:\n\(subjective)\n\nOBJECTIVE:\n\(objective)\n\nASSESSMENT:\n\(assessment)\n\nPLAN:\n\(plan)
        """
        let note = NoteModel(session: session, type: "session_note", title: "SOAP Note - \(formattedDate())", content: content)
        note.structuredData = """
        {"format":"SOAP","subjective":"\(escape(subjective))","objective":"\(escape(objective))","assessment":"\(escape(assessment))","plan":"\(escape(plan))"}
        """
        context.insert(note)
        return note
    }

    func createDAPNote(session: SessionModel, data: String, assessment: String, plan: String, context: ModelContext) -> NoteModel {
        let content = "DATA:\n\(data)\n\nASSESSMENT:\n\(assessment)\n\nPLAN:\n\(plan)"
        let note = NoteModel(session: session, type: "session_note", title: "DAP Note - \(formattedDate())", content: content)
        note.structuredData = """
        {"format":"DAP","data":"\(escape(data))","assessment":"\(escape(assessment))","plan":"\(escape(plan))"}
        """
        context.insert(note)
        return note
    }

    private func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "\n", with: "\\n")
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
