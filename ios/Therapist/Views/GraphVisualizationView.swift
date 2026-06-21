import SwiftUI
import WebKit

// MARK: - GraphVisualizationView

/// A full-screen Cytoscape.js graph rendered in an offline WKWebView.
/// Pass the Cytoscape JSON string produced by `GraphExportService.cytoscapeJSON`.
struct GraphVisualizationView: UIViewRepresentable {
    let cytoscapeJSON: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Allow local file access so cytoscape.min.js loads from the bundle.
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        context.coordinator.pendingJSON = cytoscapeJSON

        // Load graph.html from the main bundle (copied by the Graph resource group).
        if let htmlURL = Bundle.main.url(forResource: "graph", withExtension: "html",
                                          subdirectory: "Graph") {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // If the JSON changes (e.g. data reloaded) re-inject once the page is loaded.
        context.coordinator.pendingJSON = cytoscapeJSON
        if context.coordinator.isLoaded {
            context.coordinator.inject(into: webView)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate {
        var pendingJSON: String = ""
        var isLoaded = false

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
            inject(into: webView)
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
    @State private var showExportMenu = false

    private var graph: AggregatedGraph {
        GraphExportService.aggregate(sessions: sessions)
    }

    private var cytoscapeJSON: String {
        GraphExportService.cytoscapeJSON(graph: graph)
    }

    var body: some View {
        NavigationStack {
            GraphVisualizationView(cytoscapeJSON: cytoscapeJSON)
                .ignoresSafeArea()
                .navigationTitle("Knowledge Graph")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Export", systemImage: "square.and.arrow.up") {
                            prepareExport()
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    // Node count badge
                    let nodeCount = graph.nodes.count
                    let edgeCount = graph.edges.count
                    if nodeCount > 0 {
                        HStack(spacing: 8) {
                            Label("\(nodeCount) nodes", systemImage: "circle.hexagongrid")
                            Label("\(edgeCount) edges", systemImage: "arrow.triangle.branch")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 12)
                    }
                }
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: shareItems)
        }
    }

    private func prepareExport() {
        var items: [Any] = []
        let graphMLContent = GraphExportService.graphML(graph: graph)
        if let url = GraphExportService.writeGraphML(graphMLContent) {
            items.append(url)
        }
        let jsonContent = cytoscapeJSON
        if let url = GraphExportService.writeCytoscapeJSON(jsonContent) {
            items.append(url)
        }
        shareItems = items
        showShare = true
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
