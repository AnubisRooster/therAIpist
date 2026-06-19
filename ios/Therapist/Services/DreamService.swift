import Foundation
import SwiftData

class DreamService {
    static let shared = DreamService()

    func recordDream(session: SessionModel, narrative: String, feelings: [String], context: ModelContext) -> DreamModel {
        let dream = DreamModel(session: session, narrative: narrative, feelings: feelings)
        context.insert(dream)
        return dream
    }

    func analyzeDream(session: SessionModel, dream: DreamModel, provider: String, model: String) async throws -> String {
        let prompt = """
        You are a Jungian dream analyst. Analyze this dream narrative and provide:
        1. Key symbols and their possible archetypal meanings
        2. How the dream might relate to the dreamer's current life situation
        3. Shadow elements that may be emerging
        4. Possible directions for active imagination work

        Dream narrative: \(dream.narrative)
        Feelings: \(dream.feelings)
        """
        let messages = [LLMMessage(role: "user", content: prompt)]
        let analysis = try await LLMService.shared.sendMessage(provider: provider, model: model, messages: messages)
        dream.analysis = analysis
        return analysis
    }

    func extractSymbols(session: SessionModel, dream: DreamModel, context: ModelContext) -> [String] {
        let commonSymbols = ["water", "house", "forest", "animal", "flight", "falling", "chase",
                             "death", "birth", "marriage", "child", "snake", "bird", "fire",
                             "mountain", "ocean", "door", "window", "bridge", "shadow", "light"]

        let lower = dream.narrative.lowercased()
        let found = commonSymbols.filter { lower.contains($0) }
        if let existingData = Data(base64Encoded: dream.symbolsData),
           let existing = try? JSONDecoder().decode([String].self, from: existingData) {
            dream.symbolsData = (try? JSONEncoder().encode(Array(Set(existing + found))))?.base64EncodedString() ?? ""
        }
        return found
    }
}
