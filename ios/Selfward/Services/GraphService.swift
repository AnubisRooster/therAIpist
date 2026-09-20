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

        let eventWords = [
            "interview", "argument", "breakup", "break up", "diagnosis",
            "funeral", "wedding", "layoff", "laid off", "fight", "accident",
            "surgery", "divorce", "deadline", "exam", "presentation",
            "promotion", "fired", "quit", "moved", "moving", "miscarriage",
            "hospital", "birthday", "anniversary", "graduation", "relapse",
        ]

        var emotions: [NodeSpec] = []
        var persons:  [NodeSpec] = []
        var beliefs:  [NodeSpec] = []
        var events:   [NodeSpec] = []

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

        for word in eventWords where lower.contains(word) {
            events.append(NodeSpec(type: "event", label: word.capitalized,
                                   properties: ["source": "message"]))
        }

        // De-duplicate within a single message (same label twice → once)
        emotions = dedupe(emotions)
        persons  = dedupe(persons)
        beliefs  = dedupe(beliefs)
        events   = dedupe(events)

        var edges: [EdgeSpec] = []

        // person → TRIGGERS → emotion
        for person in persons {
            for emotion in emotions {
                edges.append(EdgeSpec(sourceLabel: person.label,
                                      targetLabel: emotion.label, type: "TRIGGERS"))
            }
        }
        // event → TRIGGERS → emotion
        for event in events {
            for emotion in emotions {
                edges.append(EdgeSpec(sourceLabel: event.label,
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

        return Extraction(nodes: emotions + persons + beliefs + events, edges: edges)
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

    /// How many of the most recent prior user messages are treated as "still
    /// in play" when wiring edges for the current one. Without this, edges
    /// only ever formed between entities mentioned in the exact same
    /// message -- but a person raised two turns ago and a feeling named just
    /// now are exactly the kind of connection a therapy conversation should
    /// surface, and they almost never land in one message together.
    static let recentContextWindow = 6

    /// Extracts entities from a single message, wires edges between
    /// co-occurring nodes in that message, and -- when `recentMessages` is
    /// given -- also wires edges between this message's new entities and
    /// entities from those recent prior messages, so a feeling mentioned now
    /// can still connect back to a person or event raised a few turns
    /// earlier. Returns the nodes created / reinforced for `message` itself;
    /// entities from `recentMessages` are looked up (they were already
    /// created when they were the "current" message in their own turn), not
    /// re-created or re-reinforced here.
    @discardableResult
    func extractEntitiesFromMessage(session: SessionModel,
                                    message: String,
                                    recentMessages: [String] = [],
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

        if !recentMessages.isEmpty {
            let recentNodes = recentMessages.suffix(Self.recentContextWindow)
                .flatMap { analyzeMessage($0).nodes }
            for edge in Self.crossWindowEdges(current: extraction.nodes, recent: recentNodes) {
                guard let source = findNode(session: session, label: edge.sourceLabel) else { continue }
                addEdge(session: session, source: source,
                        targetLabel: edge.targetLabel, type: edge.type, context: context)
            }
        }

        return created
    }

    /// Edges between `current`'s entities and `recent`'s, in both directions,
    /// using the same relationship rules `analyzeMessage` applies within a
    /// single message. Pure so it's independently testable.
    static func crossWindowEdges(current: [NodeSpec], recent: [NodeSpec]) -> [EdgeSpec] {
        func of(_ specs: [NodeSpec], _ type: String) -> [NodeSpec] { specs.filter { $0.type == type } }

        var edges: [EdgeSpec] = []
        func link(_ sources: [NodeSpec], _ targets: [NodeSpec], _ type: String) {
            for source in sources {
                for target in targets {
                    edges.append(EdgeSpec(sourceLabel: source.label, targetLabel: target.label, type: type))
                }
            }
        }

        // person/event → TRIGGERS → emotion, checked in both time directions.
        link(of(recent, "person"), of(current, "emotion"), "TRIGGERS")
        link(of(current, "person"), of(recent, "emotion"), "TRIGGERS")
        link(of(recent, "event"), of(current, "emotion"), "TRIGGERS")
        link(of(current, "event"), of(recent, "emotion"), "TRIGGERS")
        // emotion → CAUSES → belief
        link(of(recent, "emotion"), of(current, "belief"), "CAUSES")
        link(of(current, "emotion"), of(recent, "belief"), "CAUSES")
        // belief → ASSOCIATED_WITH → emotion
        link(of(recent, "belief"), of(current, "emotion"), "ASSOCIATED_WITH")
        link(of(current, "belief"), of(recent, "emotion"), "ASSOCIATED_WITH")

        return edges
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

    /// Plain-language phrasing for an edge type, so the relationship reads as a
    /// sentence in the UI (e.g. "Mother brings up Sadness") instead of exposing
    /// raw graph-theory verbs.
    func getEdgeTypeLabel(_ type: String) -> String {
        switch type {
        case "CAUSES":           return "leads to"
        case "TRIGGERS":         return "brings up"
        case "SUPPRESSES":       return "pushes down"
        case "COMPENSATES_FOR":  return "covers for"
        case "ASSOCIATED_WITH":  return "goes with"
        default:                 return type.replacingOccurrences(of: "_", with: " ").lowercased()
        }
    }
}
