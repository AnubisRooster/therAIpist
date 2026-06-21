import Foundation
import XCTest
import SwiftData
@testable import Therapist

@MainActor
final class GraphExportServiceTests: XCTestCase {

    // MARK: - Helpers

    private func makeGraph(container: ModelContainer,
                           sessionCount: Int = 1) throws -> [SessionModel] {
        let ctx = container.mainContext
        var sessions: [SessionModel] = []
        for i in 0..<sessionCount {
            let session = SessionModel(title: "Session \(i)")
            ctx.insert(session)

            // Two emotion nodes
            let n1 = GraphNodeModel(session: session, type: "emotion", label: "Sadness", strength: 1.0)
            let n2 = GraphNodeModel(session: session, type: "emotion", label: "Anger",   strength: 0.5)
            let n3 = GraphNodeModel(session: session, type: "person",  label: "Mother",  strength: 1.0)
            ctx.insert(n1); ctx.insert(n2); ctx.insert(n3)

            // Edge: Mother → TRIGGERS → Sadness
            let e = GraphEdgeModel(session: session, sourceNode: n3,
                                   targetNodeID: n1.id, type: "TRIGGERS", weight: 1.0)
            ctx.insert(e)

            sessions.append(session)
        }
        try ctx.save()
        return sessions
    }

    // MARK: - Aggregation

    func test_aggregate_singleSession_nodeCount() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container)
        let graph = GraphExportService.aggregate(sessions: sessions)
        XCTAssertEqual(graph.nodes.count, 3)
    }

    func test_aggregate_twoSessionsMergesSameLabel() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container, sessionCount: 2)
        let graph = GraphExportService.aggregate(sessions: sessions)
        // "Sadness", "Anger", "Mother" each appear in both sessions → still 3 unique nodes
        XCTAssertEqual(graph.nodes.count, 3)
    }

    func test_aggregate_strengthSummedAcrossSessions() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container, sessionCount: 2)
        let graph = GraphExportService.aggregate(sessions: sessions)
        let sadness = graph.nodes.first { $0.label == "Sadness" }
        // 1.0 + 1.0 = 2.0
        XCTAssertEqual(sadness?.strength ?? 0, 2.0, accuracy: 0.01)
    }

    func test_aggregate_sessionCountTracked() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container, sessionCount: 3)
        let graph = GraphExportService.aggregate(sessions: sessions)
        let mother = graph.nodes.first { $0.label == "Mother" }
        XCTAssertEqual(mother?.sessionCount, 3)
    }

    func test_aggregate_edgesMergedByTypeAndNodes() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container, sessionCount: 2)
        let graph = GraphExportService.aggregate(sessions: sessions)
        // Mother → TRIGGERS → Sadness exists in both sessions → 1 merged edge
        XCTAssertEqual(graph.edges.count, 1)
        let edge = graph.edges.first!
        XCTAssertEqual(edge.type, "TRIGGERS")
        XCTAssertEqual(edge.weight, 2.0, accuracy: 0.01)
    }

    func test_aggregate_emptySessionsReturnsEmptyGraph() {
        let graph = GraphExportService.aggregate(sessions: [])
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertTrue(graph.edges.isEmpty)
    }

    // MARK: - Cytoscape JSON

    func test_cytoscapeJSON_validJSON() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container)
        let graph = GraphExportService.aggregate(sessions: sessions)
        let json = GraphExportService.cytoscapeJSON(graph: graph)

        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }

    func test_cytoscapeJSON_shape() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container)
        let graph = GraphExportService.aggregate(sessions: sessions)
        let json = GraphExportService.cytoscapeJSON(graph: graph)

        let parsed = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!) as! [String: Any]
        let elements = parsed["elements"] as? [String: Any]
        XCTAssertNotNil(elements)
        let nodes = elements?["nodes"] as? [[String: Any]]
        let edges = elements?["edges"] as? [[String: Any]]
        XCTAssertEqual(nodes?.count, 3)
        XCTAssertEqual(edges?.count, 1)
        // Each node data should have id, label, type, strength.
        let firstNodeData = (nodes?.first)?["data"] as? [String: Any]
        XCTAssertNotNil(firstNodeData?["id"])
        XCTAssertNotNil(firstNodeData?["label"])
        XCTAssertNotNil(firstNodeData?["type"])
        XCTAssertNotNil(firstNodeData?["strength"])
    }

    func test_cytoscapeJSON_emptyGraph_validJSON() {
        let graph = AggregatedGraph(nodes: [], edges: [])
        let json = GraphExportService.cytoscapeJSON(graph: graph)
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: json.data(using: .utf8)!))
    }

    // MARK: - GraphML

    func test_graphML_wellFormed() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container)
        let graph = GraphExportService.aggregate(sessions: sessions)
        let xml = GraphExportService.graphML(graph: graph)

        let data = xml.data(using: .utf8)!
        let parser = XMLParser(data: data)
        let delegate = XMLParserRecorder()
        parser.delegate = delegate
        XCTAssertTrue(parser.parse(), "GraphML should parse as valid XML")
        XCTAssertNil(delegate.parseError)
    }

    func test_graphML_containsAllNodes() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container)
        let graph = GraphExportService.aggregate(sessions: sessions)
        let xml = GraphExportService.graphML(graph: graph)

        XCTAssertTrue(xml.contains("Sadness"))
        XCTAssertTrue(xml.contains("Anger"))
        XCTAssertTrue(xml.contains("Mother"))
    }

    func test_graphML_containsEdge() throws {
        let container = TestSupport.makeInMemoryContainer()
        let sessions = try makeGraph(container: container)
        let graph = GraphExportService.aggregate(sessions: sessions)
        let xml = GraphExportService.graphML(graph: graph)
        XCTAssertTrue(xml.contains("TRIGGERS"))
        XCTAssertTrue(xml.contains("<edge "))
    }

    func test_graphML_emptyGraph_valid() {
        let graph = AggregatedGraph(nodes: [], edges: [])
        let xml = GraphExportService.graphML(graph: graph)
        let data = xml.data(using: .utf8)!
        let parser = XMLParser(data: data)
        XCTAssertTrue(parser.parse(), "Empty GraphML should still be valid XML")
    }

    func test_graphML_specialCharactersEscaped() throws {
        // Node label with XML-special characters.
        let node = AggregatedNode(id: "emotion:love&fear", type: "emotion",
                                   label: "Love & Fear", strength: 1.0, sessionCount: 1)
        let graph = AggregatedGraph(nodes: [node], edges: [])
        let xml = GraphExportService.graphML(graph: graph)
        XCTAssertTrue(xml.contains("Love &amp; Fear"), "& should be XML-escaped")
        // Must still parse cleanly.
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        XCTAssertTrue(parser.parse())
    }

    // MARK: - File writing helpers

    func test_writeGraphML_createsFile() throws {
        let graph = AggregatedGraph(nodes: [], edges: [])
        let content = GraphExportService.graphML(graph: graph)
        guard let url = GraphExportService.writeGraphML(content) else {
            XCTFail("writeGraphML should return a URL"); return
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        try? FileManager.default.removeItem(at: url)
    }

    func test_writeCytoscapeJSON_createsFile() throws {
        let graph = AggregatedGraph(nodes: [], edges: [])
        let content = GraphExportService.cytoscapeJSON(graph: graph)
        guard let url = GraphExportService.writeCytoscapeJSON(content) else {
            XCTFail("writeCytoscapeJSON should return a URL"); return
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - XMLParserRecorder (helper)

private final class XMLParserRecorder: NSObject, XMLParserDelegate {
    var parseError: Error?
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
}
