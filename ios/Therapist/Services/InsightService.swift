import Foundation
import SwiftData

class InsightService {
    static let shared = InsightService()

    func generateInsights(session: SessionModel) -> InsightResult {
        let cycles = GraphService.shared.detectCycles(session: session)
        let topEmotions = getTopEmotions(session: session)
        let themes = getThemes(session: session)

        return InsightResult(
            adlerianInsight: generateAdlerianInsight(session: session, themes: themes),
            dbtRecommendation: generateDBTRecommendation(session: session, topEmotions: topEmotions),
            shadowObservation: generateShadowObservation(session: session, cycles: cycles),
            repeatingLoops: cycles.map { formatCycle($0, session: session) }
        )
    }

    private func getTopEmotions(session: SessionModel) -> [(String, Float)] {
        let emotionNodes = session.graphNodes.filter { $0.type == "emotion" }
        return emotionNodes.map { ($0.label, $0.strength) }.sorted { $0.1 > $1.1 }
    }

    private func getThemes(session: SessionModel) -> [String] {
        let themeNodes = session.graphNodes.filter { $0.type == "theme" }
        return themeNodes.map(\.label)
    }

    private func generateAdlerianInsight(session: SessionModel, themes: [String]) -> String {
        let beliefs = session.graphNodes.filter { $0.type == "belief" }.map(\.label)
        if beliefs.isEmpty {
            return "Continue exploring to identify lifestyle convictions and private logic patterns."
        }
        var insight = "Adlerian Analysis:\n"
        insight += "Identified beliefs: \(beliefs.joined(separator: ", "))\n"
        insight += "These beliefs may reflect the client's lifestyle organization and private logic. "
        insight += "Consider exploring early recollections that reinforce these convictions."
        return insight
    }

    private func generateDBTRecommendation(session: SessionModel, topEmotions: [(String, Float)]) -> String {
        if topEmotions.isEmpty {
            return "Continue building therapeutic alliance and assessing emotion regulation needs."
        }
        var recommendation = "DBT Skill Recommendation:\n"
        recommendation += "Based on emotional patterns (\(topEmotions.map { "\($0.0)" }.joined(separator: ", "))):\n"
        let primary = topEmotions.first?.0.lowercased() ?? ""
        if ["angry", "frustrated"].contains(primary) {
            recommendation += "Practice opposite action and interpersonal effectiveness skills."
        } else if ["anxious", "fearful"].contains(primary) {
            recommendation += "Practice mindfulness and distress tolerance skills."
        } else if ["sad", "lonely", "hopeless"].contains(primary) {
            recommendation += "Practice emotion regulation and opposite action to build mastery."
        }
        return recommendation
    }

    private func generateShadowObservation(session: SessionModel, cycles: [[String]]) -> String {
        if cycles.isEmpty {
            return "No recurring patterns detected yet. Continue exploring to identify shadow dynamics."
        }
        return "Jungian Shadow Observation:\nDetected \(cycles.count) recurring pattern(s) in the client's narrative. These may represent shadow content seeking integration. Consider exploring what parts of self are being disowned and how they might be acknowledged compassionately."
    }

    private func formatCycle(_ cycle: [String], session: SessionModel) -> String {
        let labels = cycle.compactMap { id in session.graphNodes.first(where: { $0.id == id })?.label }
        return labels.joined(separator: " → ")
    }
}

struct InsightResult {
    let adlerianInsight: String
    let dbtRecommendation: String
    let shadowObservation: String
    let repeatingLoops: [String]
}
