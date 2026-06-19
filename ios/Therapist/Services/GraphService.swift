import Foundation
import SwiftData

class GraphService {
    static let shared = GraphService()

    func addNode(session: SessionModel, type: String, label: String, properties: [String: String] = [:], context: ModelContext) -> GraphNodeModel {
        if let existing = findNode(session: session, label: label) {
            existing.strength = min(existing.strength + 0.5, 2.0)
            return existing
        }
        let node = GraphNodeModel(session: session, type: type, label: label, properties: properties)
        context.insert(node)
        return node
    }

    func addEdge(session: SessionModel, source: GraphNodeModel, targetLabel: String, type: String, context: ModelContext) {
        guard let target = findNode(session: session, label: targetLabel) else { return }
        if let existing = source.outgoingEdges.first(where: { $0.targetNodeID == target.id && $0.type == type }) {
            existing.weight = min(existing.weight + 0.5, 2.0)
            return
        }
        let edge = GraphEdgeModel(session: session, sourceNode: source, targetNodeID: target.id, type: type)
        context.insert(edge)
    }

    func findNode(session: SessionModel, label: String) -> GraphNodeModel? {
        session.graphNodes.first { $0.label.lowercased() == label.lowercased() }
    }

    func getAdjacentNodes(session: SessionModel, nodeID: String) -> [GraphNodeModel] {
        guard let node = session.graphNodes.first(where: { $0.id == nodeID }) else { return [] }
        let targetIDs = Set(node.outgoingEdges.map(\.targetNodeID))
        return session.graphNodes.filter { targetIDs.contains($0.id) }
    }

    func detectCycles(session: SessionModel) -> [[String]] {
        var allCycles: [[String]] = []
        var visited = Set<String>()
        let nodes = session.graphNodes

        func dfs(current: String, path: [String]) {
            guard !path.contains(current) else {
                if let idx = path.firstIndex(of: current) {
                    let cycle = Array(path[idx...]) + [current]
                    allCycles.append(cycle)
                }
                return
            }
            guard !visited.contains(current) else { return }
            visited.insert(current)
            guard let node = nodes.first(where: { $0.id == current }) else { return }
            let newPath = path + [current]
            for edge in node.outgoingEdges {
                dfs(current: edge.targetNodeID, path: newPath)
            }
        }

        for node in nodes {
            visited.removeAll()
            dfs(current: node.id, path: [])
        }
        return allCycles
    }

    func getNodeTypeColor(_ type: String) -> String {
        switch type {
        case "person": return "#4A90D9"
        case "event": return "#F5A623"
        case "emotion": return "#D0021B"
        case "belief": return "#7ED321"
        case "theme": return "#9B59B6"
        default: return "#999999"
        }
    }

    func getEdgeTypeLabel(_ type: String) -> String {
        switch type {
        case "CAUSES": return "causes"
        case "TRIGGERS": return "triggers"
        case "SUPPRESSES": return "suppresses"
        case "COMPENSATES_FOR": return "compensates for"
        case "ASSOCIATED_WITH": return "associated with"
        default: return type.lowercased()
        }
    }

    func extractEntitiesFromMessage(session: SessionModel, message: String) {
        let lower = message.lowercased()
        let emotionWords = ["angry", "sad", "happy", "anxious", "fearful", "guilty", "ashamed",
                            "hopeful", "lonely", "frustrated", "overwhelmed", "hopeless", "jealous"]
        let personPatterns = ["my mother", "my father", "my sister", "my brother", "my partner",
                              "my husband", "my wife", "my friend", "my boss", "my therapist",
                              "my child", "my daughter", "my son", "my mom", "my dad"]
        let beliefPatterns = ["i believe", "i think", "i feel that", "i always", "i never",
                              "i should", "i must", "i can't", "i have to"]

        for emotion in emotionWords where lower.contains(emotion) {
            let _ = addNode(session: session, type: "emotion", label: emotion.capitalized,
                         properties: ["source": "extracted"], context: session.modelContext!)
        }

        for person in personPatterns where lower.contains(person) {
            let _ = addNode(session: session, type: "person", label: person,
                         properties: ["relation": "family"], context: session.modelContext!)
        }

        for belief in beliefPatterns where lower.contains(belief) {
            let parts = lower.components(separatedBy: belief)
            if parts.count > 1 {
                let beliefText = String(parts[1].trimmingCharacters(in: .punctuationCharacters).prefix(40))
                if !beliefText.isEmpty {
                    let _ = addNode(session: session, type: "belief", label: "\(belief) \(beliefText)",
                                 properties: ["pattern": belief], context: session.modelContext!)
                }
            }
        }
    }
}
