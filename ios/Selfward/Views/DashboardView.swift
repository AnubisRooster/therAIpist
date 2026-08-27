import SwiftUI
import SwiftData

// MARK: - DashboardView

/// Top-level host for the Dashboard inside the Insights tab.
/// Wraps `DashboardView` (the list content) in a plain `NavigationStack`
/// without a Done button — the tab bar itself serves as navigation.
struct DashboardTabView: View {
    var body: some View {
        NavigationStack {
            DashboardView()
        }
    }
}

// MARK: -

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query private var sessions: [SessionModel]

    // Sheet routing
    @State private var sheet: DashboardSheet?

    private enum DashboardSheet: Identifiable {
        case nodes, edges, notes, dreams, memories, globalMemories, graphMap
        var id: Int { hashValue }
    }

    // Aggregates
    private var allNodes:   [GraphNodeModel]   { sessions.flatMap(\.graphNodes) }
    private var allEdges:   [GraphEdgeModel]   { sessions.flatMap { $0.graphNodes.flatMap(\.outgoingEdges) } }
    private var allNotes:   [NoteModel]        { sessions.flatMap(\.notes) }
    private var allDreams:  [DreamModel]       { sessions.flatMap(\.dreams) }
    private var allMemories:[MemoryModel]      { sessions.flatMap(\.memories) }
    private var globalMemories: [GlobalMemoryModel] {
        (try? context.fetch(FetchDescriptor<GlobalMemoryModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        ))) ?? []
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: Overview
                Section("Overview") {
                    StatRow(label: "Total Sessions",  value: "\(sessions.count)")
                    StatRow(label: "Total Messages",
                            value: "\(sessions.reduce(0) { $0 + $1.messages.count })")
                    StatRow(label: "Active Sessions",
                            value: "\(sessions.filter { !$0.messages.isEmpty }.count)")
                }

                // MARK: Modality Distribution
                Section("Modality Distribution") {
                    let counts = Dictionary(grouping: sessions, by: \.modality).mapValues(\.count)
                    ForEach(Array(counts.keys.sorted()), id: \.self) { modality in
                        StatRow(label: modality.replacingOccurrences(of: "_", with: " ").capitalized,
                                value: "\(counts[modality] ?? 0)",
                                color: Theme.modalityColor(modality))
                    }
                }

                // MARK: Your Patterns
                Section {
                    TappableStatRow(label: "Patterns found", value: "\(allNodes.count)",
                                   icon: "circle.hexagongrid") {
                        sheet = .nodes
                    }
                    TappableStatRow(label: "Links found", value: "\(allEdges.count)",
                                   icon: "arrow.triangle.branch") {
                        sheet = .edges
                    }
                    TappableStatRow(label: "Inner Map", value: "",
                                   icon: "point.3.connected.trianglepath.dotted") {
                        sheet = .graphMap
                    }
                } header: {
                    Text("Your Patterns")
                } footer: {
                    Text("Patterns are the emotions, people, and beliefs that show up in your sessions. Links show how they influence each other.")
                }

                // MARK: Content
                Section("Content") {
                    TappableStatRow(label: "Notes",          value: "\(allNotes.count)",     icon: "note.text")        { sheet = .notes }
                    TappableStatRow(label: "Dreams",         value: "\(allDreams.count)",    icon: "moon.stars")       { sheet = .dreams }
                    TappableStatRow(label: "Memories",       value: "\(allMemories.count)",  icon: "brain")            { sheet = .memories }
                    TappableStatRow(label: "Global Memories",value: "\(globalMemories.count)",icon: "globe")           { sheet = .globalMemories }
                }

                // MARK: Recent Notes preview
                if !recentNotes.isEmpty {
                    Section("Recent Notes") {
                        ForEach(recentNotes, id: \.note.id) { item in
                            Button { sheet = .notes } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.note.title.isEmpty ? "Untitled" : item.note.title)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                    Text(item.sessionTitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            // Drill-down sheets
            .sheet(item: $sheet) { destination in
                switch destination {
                case .nodes:          NodesListView(nodes: allNodes, sessions: sessions)
                case .edges:          EdgesListView(edges: allEdges, sessions: sessions)
                case .notes:          NotesListView(notes: allNotes, sessions: sessions)
                case .dreams:         DreamsListView(dreams: allDreams, sessions: sessions)
                case .memories:       MemoriesListView(memories: allMemories, sessions: sessions)
                case .globalMemories: GlobalMemoriesListView(memories: globalMemories)
                case .graphMap:       GraphVisualizationSheet(sessions: sessions)
                }
            }
        }
    }

    // MARK: Helpers

    private struct RecentNoteItem { let note: NoteModel; let sessionTitle: String }
    private var recentNotes: [RecentNoteItem] {
        sessions.flatMap { s in s.notes.map { RecentNoteItem(note: $0, sessionTitle: s.title) } }
            .sorted { $0.note.createdAt > $1.note.createdAt }
            .prefix(5)
            .map { $0 }
    }

}

// MARK: - Stat row helpers

struct StatRow: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.headline).foregroundStyle(color)
        }
    }
}

struct TappableStatRow: View {
    let label: String
    let value: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(label, systemImage: icon).foregroundStyle(.secondary)
                Spacer()
                Text(value).font(.headline).foregroundStyle(.primary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Nodes list

struct NodesListView: View {
    @Environment(\.dismiss) private var dismiss
    let nodes: [GraphNodeModel]
    let sessions: [SessionModel]

    @State private var selected: GraphNodeModel?
    @State private var query = ""

    private var filtered: [GraphNodeModel] {
        guard !query.isEmpty else { return nodes.sorted { $0.createdAt > $1.createdAt } }
        let q = query.lowercased()
        return nodes.filter { $0.label.lowercased().contains(q) || $0.type.lowercased().contains(q) }
    }

    private func sessionTitle(for node: GraphNodeModel) -> String {
        sessions.first { $0.id == node.session?.id }?.title ?? "Unknown Session"
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.id) { node in
                Button { selected = node } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label(node.label, systemImage: nodeIcon(node.type))
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(node.type.capitalized)
                                .font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Theme.nodeColor(node.type).opacity(0.15))
                                .foregroundStyle(Theme.nodeColor(node.type))
                                .clipShape(Capsule())
                        }
                        HStack {
                            Text("Strength \(String(format: "%.1f", node.strength))")
                            Text("·")
                            Text(sessionTitle(for: node))
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $query, prompt: "Search patterns")
            .navigationTitle("Patterns (\(nodes.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
        .sheet(item: $selected) { node in NodeDetailView(node: node) }
    }

    private func nodeIcon(_ type: String) -> String {
        switch type {
        case "person":  return "person.circle"
        case "event":   return "calendar"
        case "emotion": return "heart"
        case "belief":  return "lightbulb"
        case "theme":   return "tag"
        default:        return "circle"
        }
    }

}

struct NodeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let node: GraphNodeModel

    private var properties: [String: String] {
        guard let data = Data(base64Encoded: node.propertiesData),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else { return [:] }
        return dict
    }

    /// Resolves an outgoing edge's target node to its human-readable label by
    /// looking it up within the same session (edges store only the target id).
    private func targetLabel(for edge: GraphEdgeModel) -> String {
        node.session?.graphNodes.first { $0.id == edge.targetNodeID }?.label ?? "another pattern"
    }

    /// Approximate co-occurrence count from an edge weight (weight starts at 1.0
    /// and rises ~0.5 per shared mention).
    private func timesSeen(_ weight: Float) -> String {
        let n = max(1, Int(((weight - 1.0) / 0.5).rounded()) + 1)
        return "\(n) time\(n == 1 ? "" : "s")"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Pattern") {
                    LabeledContent("Name", value: node.label)
                    LabeledContent("Kind", value: node.type.capitalized)
                    LabeledContent("First noticed", value: node.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
                if !node.outgoingEdges.isEmpty {
                    Section("Connections (\(node.outgoingEdges.count))") {
                        ForEach(node.outgoingEdges, id: \.id) { edge in
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(node.label) \(GraphService.shared.getEdgeTypeLabel(edge.type)) \(targetLabel(for: edge))")
                                    .font(.subheadline.weight(.medium))
                                Text("Seen together \(timesSeen(edge.weight))")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                if !properties.isEmpty {
                    Section("Properties") {
                        ForEach(Array(properties.keys.sorted()), id: \.self) { key in
                            LabeledContent(key.capitalized, value: properties[key] ?? "")
                        }
                    }
                }
            }
            .navigationTitle(node.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}

// MARK: - Edges list

struct EdgesListView: View {
    @Environment(\.dismiss) private var dismiss
    let edges: [GraphEdgeModel]
    let sessions: [SessionModel]

    @State private var query = ""

    private func targetLabel(for edge: GraphEdgeModel) -> String {
        edge.sourceNode?.session?.graphNodes.first { $0.id == edge.targetNodeID }?.label ?? "another pattern"
    }

    private func sentence(for edge: GraphEdgeModel) -> String {
        let source = edge.sourceNode?.label ?? "Something"
        return "\(source) \(GraphService.shared.getEdgeTypeLabel(edge.type)) \(targetLabel(for: edge))"
    }

    private func timesSeen(_ weight: Float) -> String {
        let n = max(1, Int(((weight - 1.0) / 0.5).rounded()) + 1)
        return "seen together \(n) time\(n == 1 ? "" : "s")"
    }

    private var filtered: [GraphEdgeModel] {
        let base = edges.sorted { $0.createdAt > $1.createdAt }
        guard !query.isEmpty else { return base }
        let q = query.lowercased()
        return base.filter { sentence(for: $0).lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.id) { edge in
                VStack(alignment: .leading, spacing: 4) {
                    Text(sentence(for: edge))
                        .font(.subheadline.weight(.semibold))
                    Text(timesSeen(edge.weight))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(edge.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .searchable(text: $query, prompt: "Search links")
            .navigationTitle("Links (\(edges.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}

// MARK: - Notes list

struct NotesListView: View {
    @Environment(\.dismiss) private var dismiss
    let notes: [NoteModel]
    let sessions: [SessionModel]

    @State private var selected: NoteModel?
    @State private var query = ""

    private var sorted: [NoteModel] {
        let base = notes.sorted { $0.createdAt > $1.createdAt }
        guard !query.isEmpty else { return base }
        let q = query.lowercased()
        return base.filter { $0.title.lowercased().contains(q) || $0.content.lowercased().contains(q) }
    }

    private func sessionTitle(for note: NoteModel) -> String {
        sessions.first { $0.id == note.session?.id }?.title ?? "Unknown Session"
    }

    var body: some View {
        NavigationStack {
            List(sorted, id: \.id) { note in
                Button { selected = note } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(note.title.isEmpty ? "Untitled" : note.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(note.type.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.orange.opacity(0.12))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                        Text(note.content.prefix(80))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text(sessionTitle(for: note))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $query, prompt: "Search notes")
            .navigationTitle("Notes (\(notes.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
        .sheet(item: $selected) { note in NoteDetailView(note: note) }
    }
}

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let note: NoteModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(note.type.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                        Spacer()
                        Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(note.content.isEmpty ? "No content." : note.content)
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle(note.title.isEmpty ? "Note" : note.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}

// MARK: - Dreams list

struct DreamsListView: View {
    @Environment(\.dismiss) private var dismiss
    let dreams: [DreamModel]
    let sessions: [SessionModel]

    @State private var selected: DreamModel?
    @State private var query = ""

    private var sorted: [DreamModel] {
        let base = dreams.sorted { $0.createdAt > $1.createdAt }
        guard !query.isEmpty else { return base }
        let q = query.lowercased()
        return base.filter { $0.narrative.lowercased().contains(q) || $0.analysis.lowercased().contains(q) }
    }

    private func sessionTitle(for dream: DreamModel) -> String {
        sessions.first { $0.id == dream.session?.id }?.title ?? "Unknown Session"
    }

    private func symbols(for dream: DreamModel) -> [String] {
        guard let data = Data(base64Encoded: dream.symbolsData),
              let arr = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return arr
    }

    var body: some View {
        NavigationStack {
            List(sorted, id: \.id) { dream in
                Button { selected = dream } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dream.narrative.prefix(80))
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        let syms = symbols(for: dream)
                        if !syms.isEmpty {
                            Text(syms.joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(.purple)
                        }
                        Text(sessionTitle(for: dream))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $query, prompt: "Search dreams")
            .navigationTitle("Dreams (\(dreams.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
        .sheet(item: $selected) { dream in DreamDetailView(dream: dream) }
    }
}

struct DreamDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let dream: DreamModel

    private var feelings: [String] {
        guard let data = Data(base64Encoded: dream.feelings),
              let arr = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return arr
    }

    private var symbols: [String] {
        guard let data = Data(base64Encoded: dream.symbolsData),
              let arr = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return arr
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Narrative") {
                    Text(dream.narrative.isEmpty ? "No narrative recorded." : dream.narrative)
                        .font(.body)
                }
                if !feelings.isEmpty {
                    Section("Feelings") {
                        FlowTagView(tags: feelings, color: .pink)
                    }
                }
                if !symbols.isEmpty {
                    Section("Symbols") {
                        FlowTagView(tags: symbols, color: .purple)
                    }
                }
                if !dream.analysis.isEmpty {
                    Section("Analysis") {
                        Text(dream.analysis).font(.body)
                    }
                }
                Section {
                    LabeledContent("Recorded", value: dream.createdAt.formatted(date: .long, time: .shortened))
                }
            }
            .navigationTitle("Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}

// MARK: - Memories list

struct MemoriesListView: View {
    @Environment(\.dismiss) private var dismiss
    let memories: [MemoryModel]
    let sessions: [SessionModel]

    @State private var selected: MemoryModel?
    @State private var query = ""
    @State private var typeFilter = "all"

    private let types = ["all", "episodic", "semantic", "procedural"]

    private var filtered: [MemoryModel] {
        var base = memories.sorted { $0.createdAt > $1.createdAt }
        if typeFilter != "all" { base = base.filter { $0.type == typeFilter } }
        if !query.isEmpty {
            let q = query.lowercased()
            base = base.filter { $0.content.lowercased().contains(q) || $0.keywords.lowercased().contains(q) }
        }
        return base
    }

    private func sessionTitle(for memory: MemoryModel) -> String {
        sessions.first { $0.id == memory.session?.id }?.title ?? "Unknown Session"
    }

    var body: some View {
        NavigationStack {
            List {
                Picker("Type", selection: $typeFilter) {
                    ForEach(types, id: \.self) { Text($0.capitalized).tag($0) }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(.init())
                .padding(.vertical, 4)

                ForEach(filtered, id: \.id) { memory in
                    Button { selected = memory } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(memory.type.capitalized)
                                    .font(.caption2.weight(.semibold))
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(memoryColor(memory.type).opacity(0.15))
                                    .foregroundStyle(memoryColor(memory.type))
                                    .clipShape(Capsule())
                                Spacer()
                                Text("imp \(String(format: "%.1f", memory.importance))")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            Text(memory.content.prefix(120))
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            Text(sessionTitle(for: memory))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .searchable(text: $query, prompt: "Search memories")
            .navigationTitle("Memories (\(memories.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
        .sheet(item: $selected) { mem in MemoryDetailView(memory: mem) }
    }

    private func memoryColor(_ type: String) -> Color {
        switch type {
        case "episodic":   return .blue
        case "semantic":   return .green
        case "procedural": return .orange
        default:           return .secondary
        }
    }
}

struct MemoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let memory: MemoryModel

    var body: some View {
        NavigationStack {
            List {
                Section("Content") {
                    Text(memory.content.isEmpty ? "No content." : memory.content)
                        .font(.body)
                }
                if !memory.keywords.isEmpty {
                    Section("Keywords") {
                        Text(memory.keywords)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Metadata") {
                    LabeledContent("Type",       value: memory.type.capitalized)
                    LabeledContent("Importance", value: String(format: "%.2f", memory.importance))
                    LabeledContent("Created",    value: memory.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
            }
            .navigationTitle("\(memory.type.capitalized) Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}

// MARK: - Global Memories list

struct GlobalMemoriesListView: View {
    @Environment(\.dismiss) private var dismiss
    let memories: [GlobalMemoryModel]

    @State private var selected: GlobalMemoryModel?
    @State private var query = ""

    private var filtered: [GlobalMemoryModel] {
        guard !query.isEmpty else { return memories }
        let q = query.lowercased()
        return memories.filter { $0.content.lowercased().contains(q) || $0.keywords.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.id) { memory in
                Button { selected = memory } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(memory.type.capitalized)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(globalMemoryColor(memory.type).opacity(0.15))
                                .foregroundStyle(globalMemoryColor(memory.type))
                                .clipShape(Capsule())
                            Spacer()
                            Text("imp \(String(format: "%.1f", memory.importance))")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        Text(memory.content.prefix(120))
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        if let sid = memory.sessionID {
                            Text("Session \(sid.prefix(8))…")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $query, prompt: "Search global memories")
            .navigationTitle("Global Memories (\(memories.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
        .sheet(item: $selected) { mem in GlobalMemoryDetailView(memory: mem) }
    }

    private func globalMemoryColor(_ type: String) -> Color {
        switch type {
        case "episodic": return .blue
        case "semantic": return .green
        case "insight":  return .purple
        case "theme":    return .orange
        default:         return .secondary
        }
    }
}

struct GlobalMemoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let memory: GlobalMemoryModel

    var body: some View {
        NavigationStack {
            List {
                Section("Content") {
                    Text(memory.content.isEmpty ? "No content." : memory.content)
                        .font(.body)
                }
                if !memory.keywords.isEmpty {
                    Section("Keywords") {
                        Text(memory.keywords)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Metadata") {
                    LabeledContent("Type",       value: memory.type.capitalized)
                    LabeledContent("Importance", value: String(format: "%.2f", memory.importance))
                    LabeledContent("Created",    value: memory.createdAt.formatted(date: .abbreviated, time: .shortened))
                    if let sid = memory.sessionID {
                        LabeledContent("Session", value: String(sid.prefix(8)) + "…")
                    }
                }
            }
            .navigationTitle("\(memory.type.capitalized) Global Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}

// MARK: - FlowTagView helper

struct FlowTagView: View {
    let tags: [String]
    var color: Color = .blue

    var body: some View {
        // Simple wrapping layout using a LazyVStack of HStacks
        let rows = buildRows(tags: tags, maxPerRow: 4)
        VStack(alignment: .leading, spacing: 6) {
            ForEach(rows.indices, id: \.self) { i in
                HStack(spacing: 6) {
                    ForEach(rows[i], id: \.self) { tag in
                        Text(tag)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(color.opacity(0.12))
                            .foregroundStyle(color)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func buildRows(tags: [String], maxPerRow: Int) -> [[String]] {
        var rows: [[String]] = []
        var current: [String] = []
        for tag in tags {
            current.append(tag)
            if current.count == maxPerRow {
                rows.append(current)
                current = []
            }
        }
        if !current.isEmpty { rows.append(current) }
        return rows
    }
}

// MARK: - Identifiable conformances for .sheet(item:)

extension GraphNodeModel:  @retroactive Identifiable {}
extension NoteModel:       @retroactive Identifiable {}
extension DreamModel:      @retroactive Identifiable {}
extension MemoryModel:     @retroactive Identifiable {}
extension GlobalMemoryModel: @retroactive Identifiable {}
