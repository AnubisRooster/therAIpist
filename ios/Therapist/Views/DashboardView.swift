import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query private var sessions: [SessionModel]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    StatRow(label: "Total Sessions", value: "\(sessions.count)")
                    StatRow(label: "Total Messages",
                            value: "\(sessions.reduce(0) { $0 + $1.messages.count })")
                    StatRow(label: "Active Sessions",
                            value: "\(sessions.filter { $0.messages.count > 0 }.count)")
                }

                Section("Modality Distribution") {
                    let counts = Dictionary(grouping: sessions, by: { $0.modality }).mapValues(\.count)
                    ForEach(Array(counts.keys.sorted()), id: \.self) { modality in
                        StatRow(label: modality.capitalized,
                                value: "\(counts[modality] ?? 0)",
                                color: modalityColor(modality))
                    }
                }

                Section("Knowledge Graph") {
                    let totalNodes = sessions.reduce(0) { $0 + $1.graphNodes.count }
                    let totalEdges = sessions.reduce(0) { $0 + $1.graphNodes.reduce(0) { $0 + $1.outgoingEdges.count } }
                    StatRow(label: "Total Nodes", value: "\(totalNodes)")
                    StatRow(label: "Total Edges", value: "\(totalEdges)")
                }

                Section("Content") {
                    StatRow(label: "Notes", value: "\(sessions.reduce(0) { $0 + $1.notes.count })")
                    StatRow(label: "Dreams", value: "\(sessions.reduce(0) { $0 + $1.dreams.count })")
                    StatRow(label: "Memories", value: "\(sessions.reduce(0) { $0 + $1.memories.count })")
                    let globalCount = (try? context.fetch(FetchDescriptor<GlobalMemoryModel>()).count) ?? 0
                    StatRow(label: "Global Memories", value: "\(globalCount)")
                }

                if !recentNotes.isEmpty {
                    Section("Recent Notes") {
                        ForEach(recentNotes, id: \.0 + \.1) { (sessionTitle, noteTitle, _) in
                            VStack(alignment: .leading) {
                                Text(noteTitle).font(.headline)
                                Text(sessionTitle).font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var recentNotes: [(String, String, Date)] {
        sessions.flatMap { session in
            session.notes.map { (session.title, $0.title, $0.createdAt) }
        }.sorted { $0.2 > $1.2 }.prefix(5).map { ($0.0, $0.1, $0.2) }
    }

    private func modalityColor(_ modality: String) -> Color {
        switch modality {
        case "adlerian": return .blue
        case "jungian": return .purple
        case "dbt": return .green
        case "integrated": return .orange
        case "free_form": return .teal
        case "cbt": return .indigo
        case "humanistic": return .pink
        case "existential": return .gray
        case "gestalt": return .yellow
        case "somatic": return .mint
        case "narrative": return .brown
        case "act": return .cyan
        case "psychodynamic": return .red
        case "ifs": return .primary
        default: return .secondary
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
    }
}
