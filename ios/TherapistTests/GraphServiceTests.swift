import XCTest
import SwiftData
@testable import Therapist

@MainActor
final class GraphServiceTests: XCTestCase {
    private let graph = GraphService.shared

    // MARK: - Pure analysis (positive)

    func testAnalyzeExtractsEmotionPersonAndEdge() {
        let extraction = graph.analyzeMessage("I am so angry at my mother")
        let labels = Set(extraction.nodes.map(\.label))
        XCTAssertTrue(labels.contains("Angry"))
        XCTAssertTrue(labels.contains("Mother"))

        // A person co-occurring with an emotion should imply a TRIGGERS edge.
        XCTAssertTrue(extraction.edges.contains {
            $0.sourceLabel == "Mother" && $0.targetLabel == "Angry" && $0.type == "TRIGGERS"
        })
    }

    func testAnalyzeDeduplicatesRepeatedEmotion() {
        let extraction = graph.analyzeMessage("angry angry angry, so angry")
        let angryCount = extraction.nodes.filter { $0.label == "Angry" }.count
        XCTAssertEqual(angryCount, 1)
    }

    func testCoOccurringEmotionsProduceAssociation() {
        let extraction = graph.analyzeMessage("I feel anxious and also lonely")
        XCTAssertTrue(extraction.edges.contains { $0.type == "ASSOCIATED_WITH" })
    }

    // MARK: - Pure analysis (negative)

    func testNeutralMessageProducesNoNodes() {
        let extraction = graph.analyzeMessage("The weather is mild and the train was on time.")
        XCTAssertTrue(extraction.nodes.isEmpty)
        XCTAssertTrue(extraction.edges.isEmpty)
    }

    // MARK: - Live extraction into SwiftData

    func testExtractEntitiesCreatesNodesAndEdges() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = SessionModel(title: "T")
        ctx.insert(session)

        graph.extractEntitiesFromMessage(session: session,
                                         message: "I am angry at my mother",
                                         context: ctx)

        XCTAssertEqual(session.graphNodes.count, 2)
        let edges = session.graphNodes.flatMap(\.outgoingEdges)
        XCTAssertEqual(edges.count, 1)
        XCTAssertEqual(edges.first?.type, "TRIGGERS")
    }

    func testRepeatedEntityReinforcesInsteadOfDuplicating() throws {
        let container = TestSupport.makeInMemoryContainer()
        let ctx = container.mainContext
        let session = SessionModel(title: "T")
        ctx.insert(session)

        graph.extractEntitiesFromMessage(session: session, message: "I feel angry", context: ctx)
        let firstStrength = graph.findNode(session: session, label: "Angry")?.strength ?? 0
        graph.extractEntitiesFromMessage(session: session, message: "still angry", context: ctx)

        // Still one node, but reinforced.
        XCTAssertEqual(session.graphNodes.filter { $0.label == "Angry" }.count, 1)
        let secondStrength = graph.findNode(session: session, label: "Angry")?.strength ?? 0
        XCTAssertGreaterThan(secondStrength, firstStrength)
    }

    // MARK: - Plain-language edge labels

    func testEdgeTypeLabelsArePlainLanguage() {
        XCTAssertEqual(graph.getEdgeTypeLabel("TRIGGERS"), "brings up")
        XCTAssertEqual(graph.getEdgeTypeLabel("CAUSES"), "leads to")
        XCTAssertEqual(graph.getEdgeTypeLabel("SUPPRESSES"), "pushes down")
        XCTAssertEqual(graph.getEdgeTypeLabel("COMPENSATES_FOR"), "covers for")
        XCTAssertEqual(graph.getEdgeTypeLabel("ASSOCIATED_WITH"), "goes with")
    }

    func testEdgeTypeLabelUnknownTypeIsHumanized() {
        // Unknown types should be de-underscored and lowercased, not crash.
        XCTAssertEqual(graph.getEdgeTypeLabel("SOME_NEW_TYPE"), "some new type")
    }

    func testEdgeTypeLabelNeverReturnsRawConstant() {
        for type in ["TRIGGERS", "CAUSES", "SUPPRESSES", "COMPENSATES_FOR", "ASSOCIATED_WITH"] {
            let label = graph.getEdgeTypeLabel(type)
            XCTAssertFalse(label.contains("_"), "Label should not contain underscores")
            XCTAssertEqual(label, label.lowercased(), "Label should be lowercased phrasing")
        }
    }
}
