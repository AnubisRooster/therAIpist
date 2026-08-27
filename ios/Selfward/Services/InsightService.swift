import Foundation
import SwiftData

class InsightService {
    static let shared = InsightService()

    func generateInsights(session: SessionModel) -> InsightResult {
        let cycles = GraphService.shared.detectCycles(session: session)
        let topEmotions = getTopEmotions(session: session)
        let themes = getThemes(session: session)

        let modality = session.modality
        let modalityAnalysis: String = {
            switch modality {
            case "free_form": return ""
            case "cbt": return generateCBTInsight(session: session, topEmotions: topEmotions)
            case "humanistic": return generateHumanisticInsight(session: session)
            case "existential": return generateExistentialInsight(session: session, themes: themes)
            case "gestalt": return generateGestaltInsight(session: session)
            case "somatic": return generateSomaticInsight(session: session)
            case "narrative": return generateNarrativeInsight(session: session)
            case "act": return generateACTInsight(session: session, topEmotions: topEmotions)
            case "psychodynamic": return generatePsychodynamicInsight(session: session, cycles: cycles)
            case "ifs": return generateIFSInsight(session: session)
            default: return ""
            }
        }()

        return InsightResult(
            adlerianInsight: generateAdlerianInsight(session: session, themes: themes),
            dbtRecommendation: generateDBTRecommendation(session: session, topEmotions: topEmotions),
            shadowObservation: generateShadowObservation(session: session, cycles: cycles),
            repeatingLoops: cycles.map { formatCycle($0, session: session) },
            modalityAnalysis: modalityAnalysis
        )
    }

    /// Plain-language, client-facing highlights that read an edge "out loud"
    /// (e.g. "You often feel anxious when Mother comes up"). Falls back to the
    /// most prominent emotions when no relationships have formed yet.
    func plainLanguageHighlights(session: SessionModel) -> [String] {
        let nodes = session.graphNodes
        func node(_ id: String) -> GraphNodeModel? { nodes.first { $0.id == id } }
        let edges = nodes.flatMap(\.outgoingEdges).sorted { $0.weight > $1.weight }

        var out: [String] = []
        var seen = Set<String>()
        for edge in edges {
            guard let source = edge.sourceNode, let target = node(edge.targetNodeID) else { continue }
            let sentence: String
            switch (source.type, edge.type, target.type) {
            case ("person", "TRIGGERS", "emotion"):
                sentence = "You often feel \(target.label.lowercased()) when \(source.label) comes up."
            case ("emotion", "CAUSES", "belief"):
                sentence = "Feeling \(source.label.lowercased()) seems to lead to the thought \u{201C}\(target.label)\u{201D}."
            case ("emotion", "ASSOCIATED_WITH", "emotion"):
                sentence = "\(source.label) and \(target.label.lowercased()) tend to show up together."
            case ("belief", "ASSOCIATED_WITH", "emotion"):
                sentence = "The belief \u{201C}\(source.label)\u{201D} goes with feeling \(target.label.lowercased())."
            default:
                sentence = "\(source.label) \(GraphService.shared.getEdgeTypeLabel(edge.type)) \(target.label)."
            }
            if !seen.contains(sentence) {
                seen.insert(sentence)
                out.append(sentence)
            }
            if out.count >= 4 { break }
        }

        if out.isEmpty {
            let topEmotions = getTopEmotions(session: session).prefix(3).map { $0.0 }
            if !topEmotions.isEmpty {
                out.append("Feelings that have come up: \(topEmotions.joined(separator: ", ")).")
            }
        }
        return out
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

    private func generateCBTInsight(session: SessionModel, topEmotions: [(String, Float)]) -> String {
        let beliefs = session.graphNodes.filter { $0.type == "belief" }.map(\.label)
        if beliefs.isEmpty {
            return "Continue tracking automatic thoughts and cognitive patterns."
        }
        return "CBT Analysis:\nIdentified beliefs: \(beliefs.joined(separator: ", ")).\nThese may represent core beliefs driving automatic thoughts. Consider examining the evidence for and against each belief, and developing more balanced alternatives."
    }

    private func generateHumanisticInsight(session: SessionModel) -> String {
        let conditions = session.graphNodes.filter { $0.type == "belief" && ($0.label.lowercased().contains("should") || $0.label.lowercased().contains("must")) }
        if conditions.isEmpty {
            return "Explore the client's organismic valuing process and conditions of worth."
        }
        return "Humanistic Reflection:\nDetected should/must statements that may represent introjected conditions of worth. Support the client in reconnecting with their own organismic valuing process."
    }

    private func generateExistentialInsight(session: SessionModel, themes: [String]) -> String {
        if themes.isEmpty {
            return "Continue exploring existential themes as they naturally arise."
        }
        return "Existential Analysis:\nEmerging themes: \(themes.joined(separator: ", ")).\nExplore how the client confronts these givens of existence and what they reveal about their authentic or inauthentic modes of living."
    }

    private func generateGestaltInsight(session: SessionModel) -> String {
        return "Gestalt Awareness:\nNotice patterns of contact boundary disturbance — introjection, projection, retroflection, deflection, confluence. Help the client bring awareness to what they are avoiding in the present moment."
    }

    private func generateSomaticInsight(session: SessionModel) -> String {
        return "Somatic Observation:\nTrack nervous system state patterns — are they primarily in sympathetic (hyperarousal) or dorsal vagal (hypoarousal) activation? Support resourcing, grounding, and pendulation between activation and settling."
    }

    private func generateNarrativeInsight(session: SessionModel) -> String {
        return "Narrative Analysis:\nListen for the dominant problem story. What names might the client give to the problem? Search for unique outcomes — moments when the problem could have dominated but didn't. These are entry points for re-authoring."
    }

    private func generateACTInsight(session: SessionModel, topEmotions: [(String, Float)]) -> String {
        if topEmotions.isEmpty {
            return "Explore the client's values and areas of experiential avoidance."
        }
        let primary = topEmotions.first?.0.lowercased() ?? ""
        return "ACT Analysis:\nDominant emotion: \(primary). This may indicate areas of experiential avoidance. Explore how the client relates to this emotion — fusion, avoidance, or willingness. Clarify values that can guide committed action."
    }

    private func generatePsychodynamicInsight(session: SessionModel, cycles: [[String]]) -> String {
        if cycles.isEmpty {
            return "Listen for unconscious themes and emerging transference patterns."
        }
        return "Psychodynamic Observation:\nDetected \(cycles.count) recurring relational pattern(s). These may represent repetition compulsion — the client unconsciously recreates early attachment patterns. Explore how these patterns manifest in the therapeutic relationship."
    }

    private func generateIFSInsight(session: SessionModel) -> String {
        let protectorCount = session.graphNodes.filter { $0.type == "belief" }.count
        if protectorCount == 0 {
            return "Begin mapping the client's internal system — identify protectors that manage daily life and firefighters that react when exiles are activated."
        }
        return "IFS Analysis:\n\(protectorCount) identified protector part(s). Work with protectors first — understand their role, appreciate their good intentions, and negotiate access to exiles they protect. Track Self-energy: curiosity, compassion, calm, clarity."
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
    let modalityAnalysis: String
}
