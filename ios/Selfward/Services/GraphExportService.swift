import Foundation
import SwiftData

// MARK: - Aggregated graph types

/// A merged node across all sessions. Nodes are keyed by `(type, label.lowercased())`.
struct AggregatedNode: Identifiable {
    let id: String          // stable, derived from key
    let type: String
    let label: String
    var strength: Float
    var sessionCount: Int
}

/// A merged edge across all sessions, keyed by `(sourceID, targetID, type)`.
struct AggregatedEdge: Identifiable {
    let id: String
    let sourceID: String
    let targetID: String
    let type: String
    var weight: Float
}

struct AggregatedGraph {
    let nodes: [AggregatedNode]
    let edges: [AggregatedEdge]
}

// MARK: - GraphExportService

/// Aggregates the per-session knowledge graph across all sessions and
/// serialises it to formats suitable for Cytoscape.js, Neo4j import, and
/// Gephi (GraphML).
enum GraphExportService {

    // MARK: - Aggregation

    /// Merges every session's graph into a single flat graph.
    ///
    /// Nodes: merged by `(type, lowercased label)`. Strength is summed and
    /// capped at 10.
    ///
    /// Edges: each per-session `GraphEdgeModel` has a `targetNodeID` that
    /// refers to a node in the *same* session's `graphNodes` array. We
    /// resolve that to a stable `(type,label)` key, then union across
    /// sessions by `(sourceKey, targetKey, type)` and sum weights.
    static func aggregate(sessions: [SessionModel]) -> AggregatedGraph {
        // Build a stable ID from the node key.
        func nodeID(type: String, label: String) -> String {
            "\(type):\(label.lowercased())"
        }

        // Pass 1: collect all nodes, merging by key.
        var nodeMap: [String: AggregatedNode] = [:]
        for session in sessions {
            for n in session.graphNodes {
                let key = nodeID(type: n.type, label: n.label)
                if var existing = nodeMap[key] {
                    existing.strength = min(existing.strength + n.strength, 10)
                    existing.sessionCount += 1
                    nodeMap[key] = existing
                } else {
                    nodeMap[key] = AggregatedNode(
                        id: key,
                        type: n.type,
                        label: n.label,
                        strength: n.strength,
                        sessionCount: 1
                    )
                }
            }
        }

        // Pass 2: resolve edges.
        // For each session, build a per-session id -> key lookup, then remap edges.
        var edgeMap: [String: AggregatedEdge] = [:]
        for session in sessions {
            // Map SwiftData node id → stable key for THIS session.
            var idToKey: [String: String] = [:]
            for n in session.graphNodes {
                idToKey[n.id] = nodeID(type: n.type, label: n.label)
            }
            for n in session.graphNodes {
                for e in n.outgoingEdges {
                    guard
                        let sourceKey = idToKey[e.sourceNode?.id ?? ""],
                        let targetKey = idToKey[e.targetNodeID]
                    else { continue }
                    let edgeKey = "\(sourceKey)→\(targetKey):\(e.type)"
                    if var existing = edgeMap[edgeKey] {
                        existing.weight = min(existing.weight + e.weight, 10)
                        edgeMap[edgeKey] = existing
                    } else {
                        edgeMap[edgeKey] = AggregatedEdge(
                            id: edgeKey,
                            sourceID: sourceKey,
                            targetID: targetKey,
                            type: e.type,
                            weight: e.weight
                        )
                    }
                }
            }
        }

        // Drop edges whose source or target was not merged into nodeMap
        // (shouldn't happen but guards against orphan references).
        let validEdges = edgeMap.values.filter {
            nodeMap[$0.sourceID] != nil && nodeMap[$0.targetID] != nil
        }

        return AggregatedGraph(
            nodes: Array(nodeMap.values).sorted { $0.label < $1.label },
            edges: Array(validEdges).sorted { $0.id < $1.id }
        )
    }

    // MARK: - Cytoscape / Neo4j-compatible JSON

    /// Returns a Cytoscape.js `elements` JSON string.
    ///
    /// Shape:
    /// ```json
    /// {
    ///   "elements": {
    ///     "nodes": [{ "data": { "id": "…", "label": "…", "type": "…", "strength": 1.0 } }],
    ///     "edges": [{ "data": { "id": "…", "source": "…", "target": "…", "type": "…", "weight": 1.0 } }]
    ///   }
    /// }
    /// ```
    /// The same shape is Neo4j-import friendly (nodes = objects with an `id`
    /// property; edges = objects with `source`/`target` IDs).
    static func cytoscapeJSON(graph: AggregatedGraph) -> String {
        var nodeItems: [String] = []
        for n in graph.nodes {
            let label   = jsonEscape(n.label)
            let type    = jsonEscape(n.type)
            let id      = jsonEscape(n.id)
            nodeItems.append(
                """
                {"data":{"id":"\(id)","label":"\(label)","type":"\(type)","strength":\(String(format:"%.2f",n.strength)),"sessions":\(n.sessionCount)}}
                """
            )
        }
        var edgeItems: [String] = []
        for e in graph.edges {
            let id     = jsonEscape(e.id)
            let src    = jsonEscape(e.sourceID)
            let tgt    = jsonEscape(e.targetID)
            let type   = jsonEscape(e.type)
            edgeItems.append(
                """
                {"data":{"id":"\(id)","source":"\(src)","target":"\(tgt)","type":"\(type)","weight":\(String(format:"%.2f",e.weight))}}
                """
            )
        }
        let nodesJSON = nodeItems.joined(separator: ",")
        let edgesJSON = edgeItems.joined(separator: ",")
        return """
        {"elements":{"nodes":[\(nodesJSON)],"edges":[\(edgesJSON)]}}
        """
    }

    // MARK: - GraphML (Gephi-ready)

    /// Returns a valid GraphML document string.
    /// Keys defined:
    ///   - `d0`: node `label` (string)
    ///   - `d1`: node `type`  (string)
    ///   - `d2`: node `strength` (double)
    ///   - `d3`: node `sessions`  (int)
    ///   - `d4`: edge `type`   (string)
    ///   - `d5`: edge `weight` (double)
    static func graphML(graph: AggregatedGraph) -> String {
        var lines: [String] = []
        lines.append(#"<?xml version="1.0" encoding="UTF-8"?>"#)
        lines.append(#"<graphml xmlns="http://graphml.graphdrawing.org/graphml""#)
        lines.append(#"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance""#)
        lines.append(#"  xsi:schemaLocation="http://graphml.graphdrawing.org/graphml http://graphml.graphdrawing.org/graphml/graphml.xsd">"#)
        // Attribute keys
        lines.append(#"  <key id="d0" for="node" attr.name="label"    attr.type="string"/>"#)
        lines.append(#"  <key id="d1" for="node" attr.name="type"     attr.type="string"/>"#)
        lines.append(#"  <key id="d2" for="node" attr.name="strength" attr.type="double"/>"#)
        lines.append(#"  <key id="d3" for="node" attr.name="sessions" attr.type="int"/>"#)
        lines.append(#"  <key id="d4" for="edge" attr.name="type"     attr.type="string"/>"#)
        lines.append(#"  <key id="d5" for="edge" attr.name="weight"   attr.type="double"/>"#)
        lines.append(#"  <graph id="G" edgedefault="directed">"#)

        for n in graph.nodes {
            let id = xmlEscape(n.id)
            lines.append(#"    <node id="\#(id)">"#)
            lines.append(#"      <data key="d0">\#(xmlEscape(n.label))</data>"#)
            lines.append(#"      <data key="d1">\#(xmlEscape(n.type))</data>"#)
            lines.append(#"      <data key="d2">\#(String(format:"%.4f",n.strength))</data>"#)
            lines.append(#"      <data key="d3">\#(n.sessionCount)</data>"#)
            lines.append(#"    </node>"#)
        }

        for (idx, e) in graph.edges.enumerated() {
            let src = xmlEscape(e.sourceID)
            let tgt = xmlEscape(e.targetID)
            lines.append(#"    <edge id="e\#(idx)" source="\#(src)" target="\#(tgt)">"#)
            lines.append(#"      <data key="d4">\#(xmlEscape(e.type))</data>"#)
            lines.append(#"      <data key="d5">\#(String(format:"%.4f",e.weight))</data>"#)
            lines.append(#"    </edge>"#)
        }

        lines.append("  </graph>")
        lines.append("</graphml>")
        return lines.joined(separator: "\n")
    }

    // MARK: - Export helpers

    /// Writes `graphML` to a temp file and returns the URL, or `nil` on failure.
    static func writeGraphML(_ content: String) -> URL? {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("knowledge-graph.graphml")
        do {
            try content.write(to: tmp, atomically: true, encoding: .utf8)
            return tmp
        } catch {
            return nil
        }
    }

    /// Writes the Cytoscape/Neo4j JSON to a temp file and returns the URL.
    static func writeCytoscapeJSON(_ content: String) -> URL? {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("knowledge-graph.json")
        do {
            try content.write(to: tmp, atomically: true, encoding: .utf8)
            return tmp
        } catch {
            return nil
        }
    }

    // MARK: - Private helpers

    private static func jsonEscape(_ s: String) -> String {
        s.replacingOccurrences(of: "\\", with: "\\\\")
         .replacingOccurrences(of: "\"", with: "\\\"")
         .replacingOccurrences(of: "\n", with: "\\n")
         .replacingOccurrences(of: "\r", with: "\\r")
    }

    private static func xmlEscape(_ s: String) -> String {
        s.replacingOccurrences(of: "&",  with: "&amp;")
         .replacingOccurrences(of: "<",  with: "&lt;")
         .replacingOccurrences(of: ">",  with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
