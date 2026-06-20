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

    // MARK: - Pure analysis (no mutation)

    struct NodeSpec {
        let type: String
        let label: String
        let properties: [String: String]
    }

    struct EdgeSpec {
        let sourceLabel: String
        let targetLabel: String
        let type: String
    }

    struct Extraction {
        let nodes: [NodeSpec]
        let edges: [EdgeSpec]
    }

    /// Analyzes a message and returns the entities + edges it implies, without
    /// touching SwiftData. Both the live extraction and the backfill use this so
    /// their labels always agree.
    func analyzeMessage(_ message: String) -> Extraction {
        let lower = message.lowercased()

        let emotionWords = [
            "angry", "anger", "sad", "sadness", "happy", "anxious", "anxiety",
            "fearful", "fear", "guilty", "guilt", "ashamed", "shame", "hopeful",
            "lonely", "loneliness", "frustrated", "frustration", "overwhelmed",
            "hopeless", "jealous", "jealousy", "grief", "hurt", "betrayed",
            "confused", "numb", "empty", "worthless", "helpless",
        ]

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

        let beliefPatterns = [
            "i believe", "i think that", "i feel that", "i always", "i never",
            "i should", "i must", "i can't", "i have to", "i am worthless",
            "i am not good enough", "i am a failure", "i don't deserve",
            "nobody cares", "i am broken", "i will never",
        ]

        var emotions: [NodeSpec] = []
        var persons:  [NodeSpec] = []
        var beliefs:  [NodeSpec] = []

        for word in emotionWords where lower.contains(word) {
            emotions.append(NodeSpec(type: "emotion", label: word.capitalized,
                                     properties: ["source": "message"]))
        }

        for item in personPatterns where lower.contains(item.pattern) {
            persons.append(NodeSpec(type: "person", label: item.label,
                                    properties: ["relation": item.pattern]))
        }

        for pattern in beliefPatterns where lower.contains(pattern) {
            let parts = lower.components(separatedBy: pattern)
            if parts.count > 1 {
                let tail = parts[1].trimmingCharacters(in: .whitespacesAndNewlines
                    .union(.punctuationCharacters)).prefix(50)
                let label = tail.isEmpty ? pattern : "\(pattern) \(tail)"
                beliefs.append(NodeSpec(type: "belief", label: String(label),
                                        properties: ["pattern": pattern]))
            }
        }

        // De-duplicate within a single message (same label twice → once)
        emotions = dedupe(emotions)
        persons  = dedupe(persons)
        beliefs  = dedupe(beliefs)

        var edges: [EdgeSpec] = []

        // person → TRIGGERS → emotion
        for person in persons {
            for emotion in emotions {
                edges.append(EdgeSpec(sourceLabel: person.label,
                                      targetLabel: emotion.label, type: "TRIGGERS"))
            }
        }
        // emotion → CAUSES → belief
        for emotion in emotions {
            for belief in beliefs {
                edges.append(EdgeSpec(sourceLabel: emotion.label,
                                      targetLabel: belief.label, type: "CAUSES"))
            }
        }
        // belief → ASSOCIATED_WITH → emotion
        for belief in beliefs {
            for emotion in emotions {
                edges.append(EdgeSpec(sourceLabel: belief.label,
                                      targetLabel: emotion.label, type: "ASSOCIATED_WITH"))
            }
        }
        // emotion → ASSOCIATED_WITH → emotion (co-occurring)
        if emotions.count > 1 {
            for i in 0..<emotions.count {
                for j in (i + 1)..<emotions.count {
                    edges.append(EdgeSpec(sourceLabel: emotions[i].label,
                                          targetLabel: emotions[j].label,
                                          type: "ASSOCIATED_WITH"))
                }
            }
        }

        return Extraction(nodes: emotions + persons + beliefs, edges: edges)
    }

    private func dedupe(_ specs: [NodeSpec]) -> [NodeSpec] {
        var seen = Set<String>()
        var out: [NodeSpec] = []
        for s in specs where !seen.contains(s.label) {
            seen.insert(s.label)
            out.append(s)
        }
        return out
    }

    // MARK: - Live extraction (mutates the graph)

    /// Extracts entities from a single message and wires edges between
    /// co-occurring nodes. Returns the nodes created / reinforced.
    @discardableResult
    func extractEntitiesFromMessage(session: SessionModel,
                                    message: String,
                                    context: ModelContext) -> [GraphNodeModel] {
        let extraction = analyzeMessage(message)

        var created: [GraphNodeModel] = []
        for spec in extraction.nodes {
            let node = addNode(session: session, type: spec.type, label: spec.label,
                               properties: spec.properties, context: context)
            created.append(node)
        }

        for edge in extraction.edges {
            guard let source = findNode(session: session, label: edge.sourceLabel) else { continue }
            addEdge(session: session, source: source,
                    targetLabel: edge.targetLabel, type: edge.type, context: context)
        }

        return created
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
