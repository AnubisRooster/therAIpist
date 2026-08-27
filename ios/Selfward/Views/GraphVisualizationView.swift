import SwiftUI
import WebKit

// MARK: - GraphVisualizationView

/// A full-screen Cytoscape.js graph rendered in an offline WKWebView.
/// Pass the Cytoscape JSON string produced by `GraphExportService.cytoscapeJSON`.
struct GraphVisualizationView: UIViewRepresentable {
    let cytoscapeJSON: String
    /// Called with the tapped node's id (the aggregated `(type:label)` key).
    var onNodeTap: ((String) -> Void)? = nil

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // graph.html posts the tapped node id on this channel.
        config.userContentController.add(context.coordinator, name: "nodeTap")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        context.coordinator.pendingJSON = cytoscapeJSON

        // graph.html may be bundled either inside a "Graph" folder reference or
        // flattened into the resources root (xcodegen copies the files
        // individually), so try the subdirectory first and fall back to root.
        // `loadFileURL(allowingReadAccessTo:)` grants the WebView read access to
        // the containing directory so the sibling cytoscape.min.js loads too.
        let htmlURL = Bundle.main.url(forResource: "graph", withExtension: "html", subdirectory: "Graph")
            ?? Bundle.main.url(forResource: "graph", withExtension: "html")
        if let htmlURL {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Keep the coordinator's callback and data current across re-renders.
        context.coordinator.onNodeTap = onNodeTap
        context.coordinator.pendingJSON = cytoscapeJSON
        if context.coordinator.isLoaded {
            context.coordinator.inject(into: webView)
        }
    }

    func makeCoordinator() -> Coordinator {
        let c = Coordinator()
        c.onNodeTap = onNodeTap
        return c
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        // Avoid leaking the strong reference the userContentController holds.
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "nodeTap")
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var pendingJSON: String = ""
        var isLoaded = false
        var onNodeTap: ((String) -> Void)?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
            inject(into: webView)
        }

        func userContentController(_ controller: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "nodeTap", let id = message.body as? String else { return }
            onNodeTap?(id)
        }

        func inject(into webView: WKWebView) {
            guard !pendingJSON.isEmpty else { return }
            // Escape backticks and backslashes so the JS template literal is safe.
            let safe = pendingJSON
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "`",  with: "\\`")
            let js = "renderGraph(`\(safe)`);"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}

// MARK: - GraphVisualizationSheet

/// A full-screen sheet that shows the aggregated graph + an Export toolbar button.
struct GraphVisualizationSheet: View {
    let sessions: [SessionModel]
    @Environment(\.dismiss) private var dismiss

    @State private var shareItems: [Any] = []
    @State private var showShare = false
    @State private var selectedNode: AggregatedNode?

    var body: some View {
        // Aggregate once per render rather than recomputing for the web view,
        // the count badge, and the export action separately.
        let graph = GraphExportService.aggregate(sessions: sessions)
        let json = GraphExportService.cytoscapeJSON(graph: graph)
        NavigationStack {
            GraphVisualizationView(cytoscapeJSON: json, onNodeTap: { id in
                selectedNode = graph.nodes.first { $0.id == id }
            })
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Inner Map")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Export", systemImage: "square.and.arrow.up") {
                            prepareExport(graph: graph, json: json)
                        }
                    }
                }
                .overlay(alignment: .top) {
                    // Pattern/link count + one-line explainer. Placed at the top so
                    // it never overlaps the colour legend pinned to the bottom of
                    // the web view.
                    let nodeCount = graph.nodes.count
                    let edgeCount = graph.edges.count
                    if nodeCount > 0 {
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Label("\(nodeCount) patterns", systemImage: "circle.hexagongrid")
                                Label("\(edgeCount) links", systemImage: "arrow.triangle.branch")
                            }
                            .font(.caption)
                            Text("Tap a pattern or link to see how it connects.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 8)
                    }
                }
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: shareItems)
        }
        .sheet(item: $selectedNode) { node in
            NodeConnectionsSheet(node: node,
                                 graph: GraphExportService.aggregate(sessions: sessions))
        }
    }

    private func prepareExport(graph: AggregatedGraph, json: String) {
        var items: [Any] = []
        let graphMLContent = GraphExportService.graphML(graph: graph)
        if let url = GraphExportService.writeGraphML(graphMLContent) {
            items.append(url)
        }
        if let url = GraphExportService.writeCytoscapeJSON(json) {
            items.append(url)
        }
        shareItems = items
        showShare = true
    }
}

// MARK: - NodeConnectionsSheet

/// Lists every pattern connected to a tapped node in a table, with the
/// plain-language relationship and how often the two appeared together.
struct NodeConnectionsSheet: View {
    let node: AggregatedNode
    let graph: AggregatedGraph
    @Environment(\.dismiss) private var dismiss

    /// One connected pattern + how it relates to the tapped node.
    private struct Connection: Identifiable {
        let id: String
        let otherLabel: String
        let otherType: String
        let relationship: String   // full plain-language sentence
        let timesSeen: Int
    }

    private var connections: [Connection] {
        var nodeByID: [String: AggregatedNode] = [:]
        for n in graph.nodes { nodeByID[n.id] = n }

        var rows: [Connection] = []
        for e in graph.edges {
            let phrase = GraphService.shared.getEdgeTypeLabel(e.type)
            let times = max(1, Int(e.weight.rounded()))
            if e.sourceID == node.id, let other = nodeByID[e.targetID] {
                rows.append(Connection(
                    id: e.id,
                    otherLabel: other.label,
                    otherType: other.type,
                    relationship: "\(node.label) \(phrase) \(other.label)",
                    timesSeen: times
                ))
            } else if e.targetID == node.id, let other = nodeByID[e.sourceID] {
                rows.append(Connection(
                    id: e.id,
                    otherLabel: other.label,
                    otherType: other.type,
                    relationship: "\(other.label) \(phrase) \(node.label)",
                    timesSeen: times
                ))
            }
        }
        // Most-reinforced links first, then alphabetical.
        return rows.sorted {
            $0.timesSeen != $1.timesSeen ? $0.timesSeen > $1.timesSeen
                                         : $0.otherLabel < $1.otherLabel
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if connections.isEmpty {
                    Section {
                        Text("No links yet for this pattern. As it comes up alongside other things in your sessions, connections will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section {
                        ForEach(connections) { c in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(c.otherLabel)
                                        .font(.body.weight(.semibold))
                                    Spacer()
                                    typeCapsule(c.otherType)
                                }
                                Text(c.relationship)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Seen together \(c.timesSeen) time\(c.timesSeen == 1 ? "" : "s")")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 2)
                        }
                    } header: {
                        Text("\(connections.count) connection\(connections.count == 1 ? "" : "s")")
                    }
                }
            }
            .navigationTitle(node.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text(node.label).font(.headline)
                        Text(node.type.capitalized)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func typeCapsule(_ type: String) -> some View {
        TagCapsule(label: type.capitalized, color: Theme.nodeColor(type), prominent: true)
    }
}

// MARK: - ShareSheet wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
