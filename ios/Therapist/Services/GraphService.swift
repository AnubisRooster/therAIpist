import Foundation
import SwiftData

class GraphService {
    static let shared = GraphService()

    // MARK: - Node / Edge primitives

    @discardableResult
    func addNode(session: SessionModel, type: String, label: String,
                 properties: [String: String] = [:], context: ModelContext) -> GraphNodeModel {
        if let existing = findNode(session: session, label: label) {
            existing.strength = min(existing.strength + 0.5, 2.0)
            return existing
        }
        let node = GraphNodeModel(session: session, type: type, label: label, properties: properties)
        context.insert(node)
        return node
    }

    func addEdge(session: SessionModel, source: GraphNodeModel,
                 targetLabel: String, type: String, context: ModelContext) {
        guard let target = findNode(session: session, label: targetLabel) else { return }
        if let existing = source.outgoingEdges.first(where: {
            $0.targetNodeID == target.id && $0.type == type
        }) {
            existing.weight = min(existing.weight + 0.5, 2.0)
            return
        }
        let edge = GraphEdgeModel(session: session, sourceNode: source,
                                  targetNodeID: target.id, type: type)
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

    // MARK: - Entity + edge extraction

    /// Extracts entities from a single user message and wires edges between
    /// co-occurring nodes.  Returns the nodes created / reinforced so the
    /// caller can use them for further analysis.
    @discardableResult
    func extractEntitiesFromMessage(session: SessionModel,
                                    message: String,
                                    context: ModelContext) -> [GraphNodeModel] {
        let lower = message.lowercased()

        // ── Emotion words ──────────────────────────────────────────────────
        let emotionWords = [
            "angry", "anger", "sad", "sadness", "happy", "anxious", "anxiety",
            "fearful", "fear", "guilty", "guilt", "ashamed", "shame", "hopeful",
            "lonely", "loneliness", "frustrated", "frustration", "overwhelmed",
            "hopeless", "jealous", "jealousy", "grief", "hurt", "betrayed",
            "confused", "numb", "empty", "worthless", "helpless",
        ]

        // ── Person / relationship patterns ────────────────────────────────
        let personPatterns: [(pattern: String, label: String)] = [
            ("my mother", "Mother"), ("my mom", "Mother"),
            ("my father", "Father"), ("my dad", "Father"),
            ("my sister", "Sister"), ("my brother", "Brother"),
            ("my partner", "Partner"), ("my husband", "Husband"),
            ("my wife", "Wife"), ("my friend", "Friend"),
            ("my boss", "Boss"), ("my therapist", "Previous therapist"),
            ("my child", "Child"), ("my daughter", "Daughter"),
            ("my son", "Son"), ("my colleague", "Colleague"),
            ("my ex", "Ex-partner"),
        ]

        // ── Belief / cognitive patterns ───────────────────────────────────
        let beliefPatterns = [
            "i believe", "i think that", "i feel that", "i always", "i never",
            "i should", "i must", "i can't", "i have to", "i am worthless",
            "i am not good enough", "i am a failure", "i don't deserve",
            "nobody cares", "i am broken", "i will never",
        ]

        var extractedEmotions: [GraphNodeModel] = []
        var extractedPersons:  [GraphNodeModel] = []
        var extractedBeliefs:  [GraphNodeModel] = []

        // Extract emotions
        for word in emotionWords where lower.contains(word) {
            let node = addNode(session: session, type: "emotion",
                               label: word.capitalized,
                               properties: ["source": "message"],
                               context: context)
            extractedEmotions.append(node)
        }

        // Extract persons
        for item in personPatterns where lower.contains(item.pattern) {
            let node = addNode(session: session, type: "person",
                               label: item.label,
                               properties: ["relation": item.pattern],
                               context: context)
            extractedPersons.append(node)
        }

        // Extract beliefs (capture the phrase that follows the opener)
        for pattern in beliefPatterns where lower.contains(pattern) {
            let parts = lower.components(separatedBy: pattern)
            if parts.count > 1 {
                let tail = parts[1].trimmingCharacters(in: .whitespacesAndNewlines
                    .union(.punctuationCharacters)).prefix(50)
                let label = tail.isEmpty ? pattern : "\(pattern) \(tail)"
                let node = addNode(session: session, type: "belief",
                                   label: String(label),
                                   properties: ["pattern": pattern],
                                   context: context)
                extractedBeliefs.append(node)
            }
        }

        // ── Wire edges from co-occurrence ─────────────────────────────────
        //
        // person → TRIGGERS → emotion  (person nodes that are mentioned alongside emotions)
        for person in extractedPersons {
            for emotion in extractedEmotions {
                addEdge(session: session, source: person,
                        targetLabel: emotion.label, type: "TRIGGERS", context: context)
            }
        }

        // emotion → CAUSES → belief  (feeling driving a cognitive pattern)
        for emotion in extractedEmotions {
            for belief in extractedBeliefs {
                addEdge(session: session, source: emotion,
                        targetLabel: belief.label, type: "CAUSES", context: context)
            }
        }

        // belief → ASSOCIATED_WITH → emotion  (reciprocal link)
        for belief in extractedBeliefs {
            for emotion in extractedEmotions {
                addEdge(session: session, source: belief,
                        targetLabel: emotion.label, type: "ASSOCIATED_WITH", context: context)
            }
        }

        // emotion → ASSOCIATED_WITH → emotion  (co-occurring feelings)
        if extractedEmotions.count > 1 {
            for i in 0..<extractedEmotions.count {
                for j in (i + 1)..<extractedEmotions.count {
                    addEdge(session: session, source: extractedEmotions[i],
                            targetLabel: extractedEmotions[j].label,
                            type: "ASSOCIATED_WITH", context: context)
                }
            }
        }

        return extractedEmotions + extractedPersons + extractedBeliefs
    }

    // MARK: - Graph analysis

    func detectCycles(session: SessionModel) -> [[String]] {
        var allCycles: [[String]] = []
        var visited = Set<String>()
        let nodes = session.graphNodes

        func dfs(current: String, path: [String]) {
            guard !path.contains(current) else {
                if let idx = path.firstIndex(of: current) {
                    allCycles.append(Array(path[idx...]) + [current])
                }
                return
            }
            guard !visited.contains(current) else { return }
            visited.insert(current)
            guard let node = nodes.first(where: { $0.id == current }) else { return }
            for edge in node.outgoingEdges {
                dfs(current: edge.targetNodeID, path: path + [current])
            }
        }

        for node in nodes { visited.removeAll(); dfs(current: node.id, path: []) }
        return allCycles
    }

    // MARK: - Display helpers

    func getNodeTypeColor(_ type: String) -> String {
        switch type {
        case "person":  return "#4A90D9"
        case "event":   return "#F5A623"
        case "emotion": return "#D0021B"
        case "belief":  return "#7ED321"
        case "theme":   return "#9B59B6"
        default:        return "#999999"
        }
    }

    func getEdgeTypeLabel(_ type: String) -> String {
        switch type {
        case "CAUSES":           return "causes"
        case "TRIGGERS":         return "triggers"
        case "SUPPRESSES":       return "suppresses"
        case "COMPENSATES_FOR":  return "compensates for"
        case "ASSOCIATED_WITH":  return "associated with"
        default:                 return type.lowercased()
        }
    }
}
