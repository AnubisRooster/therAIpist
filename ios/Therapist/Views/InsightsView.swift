import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.dismiss) var dismiss
    let session: SessionModel

    var body: some View {
        NavigationStack {
            let insights = InsightService.shared.generateInsights(session: session)
            let highlights = InsightService.shared.plainLanguageHighlights(session: session)

            List {
                if !highlights.isEmpty {
                    Section {
                        ForEach(highlights, id: \.self) { line in
                            Text(line).font(.body)
                        }
                    } header: {
                        Text("What comes up most for you")
                    } footer: {
                        Text("Drawn from the patterns and links in your conversations.")
                    }
                }

                Section("Repeating Loops") {
                    if insights.repeatingLoops.isEmpty {
                        Text("No patterns detected yet")
                            .foregroundColor(.secondary)
                    }
                    ForEach(insights.repeatingLoops, id: \.self) { loop in
                        Text(loop)
                            .font(.caption)
                    }
                }

                Section("Adlerian Insight") {
                    Text(insights.adlerianInsight)
                        .font(.body)
                }

                Section("DBT Recommendation") {
                    Text(insights.dbtRecommendation)
                        .font(.body)
                }

                Section("Jungian Shadow Observation") {
                    Text(insights.shadowObservation)
                        .font(.body)
                }

                Section("Emotions") {
                    let emotions = session.graphNodes.filter { $0.type == "emotion" }
                    if emotions.isEmpty {
                        Text("No emotions recorded yet")
                            .foregroundColor(.secondary)
                    }
                    ForEach(emotions) { emotion in
                        HStack {
                            Text(emotion.label)
                            Spacer()
                            Text(String(format: "%.1f", emotion.strength))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct NotesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    let session: SessionModel

    @State private var showNewNote = false
    @State private var noteTitle = ""
    @State private var noteContent = ""
    @State private var noteType = "reflection"

    var body: some View {
        NavigationStack {
            List {
                if session.notes.isEmpty {
                    ContentUnavailableView("No Notes", systemImage: "note.text",
                                           description: Text("Add a note to track your observations"))
                }
                ForEach(session.notes.sorted(by: { $0.createdAt > $1.createdAt })) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.content.prefix(100) + (note.content.count > 100 ? "..." : ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(note.type.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Note", systemImage: "plus") { showNewNote = true }
                }
            }
            .sheet(isPresented: $showNewNote) {
                NavigationStack {
                    Form {
                        Picker("Type", selection: $noteType) {
                            Text("Reflection").tag("reflection")
                            Text("Session Note").tag("session_note")
                            Text("Journal").tag("journal")
                        }
                        TextField("Title", text: $noteTitle)
                        TextEditor(text: $noteContent)
                            .frame(minHeight: 150)
                    }
                    .navigationTitle("New Note")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showNewNote = false } }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                NoteService.shared.createNote(
                                    session: session,
                                    type: noteType,
                                    title: noteTitle,
                                    content: noteContent,
                                    context: context
                                )
                                try? context.save()
                                showNewNote = false
                                noteTitle = ""
                                noteContent = ""
                            }
                            .disabled(noteTitle.isEmpty || noteContent.isEmpty)
                        }
                    }
                }
            }
        }
    }

    private func deleteNotes(_ offsets: IndexSet) {
        let sorted = session.notes.sorted(by: { $0.createdAt > $1.createdAt })
        for index in offsets {
            context.delete(sorted[index])
        }
    }
}

struct DreamsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    let session: SessionModel

    @State private var showNewDream = false
    @State private var dreamNarrative = ""
    @State private var dreamFeelings = ""
    @State private var analyzing = false

    var body: some View {
        NavigationStack {
            List {
                if session.dreams.isEmpty {
                    ContentUnavailableView("No Dreams", systemImage: "moon.zzz",
                                           description: Text("Record dreams for Jungian analysis"))
                }
                ForEach(session.dreams.sorted(by: { $0.createdAt > $1.createdAt })) { dream in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dream.narrative.prefix(100))
                            .font(.body)
                        if !dream.analysis.isEmpty {
                            Text(dream.analysis.prefix(100))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(dream.createdAt, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteDreams)
            }
            .navigationTitle("Dreams")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .bottomBar) {
                    Button("Record Dream", systemImage: "plus") { showNewDream = true }
                }
            }
            .sheet(isPresented: $showNewDream) {
                NavigationStack {
                    Form {
                        Section("Dream Narrative") {
                            TextEditor(text: $dreamNarrative)
                                .frame(minHeight: 150)
                        }
                        TextField("Feelings (comma separated)", text: $dreamFeelings)
                    }
                    .navigationTitle("Record Dream")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showNewDream = false } }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let feelings = dreamFeelings
                                    .split(separator: ",")
                                    .map(String.init)
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                                let _ = DreamService.shared.recordDream(
                                    session: session,
                                    narrative: dreamNarrative,
                                    feelings: feelings,
                                    context: context
                                )
                                try? context.save()
                                showNewDream = false
                                dreamNarrative = ""
                                dreamFeelings = ""
                            }
                            .disabled(dreamNarrative.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
        }
    }

    private func deleteDreams(_ offsets: IndexSet) {
        let sorted = session.dreams.sorted(by: { $0.createdAt > $1.createdAt })
        for index in offsets {
            context.delete(sorted[index])
        }
    }
}

struct GraphView: View {
    @Environment(\.dismiss) var dismiss
    let session: SessionModel

    var body: some View {
        NavigationStack {
            List {
                Section("Patterns (\(session.graphNodes.count))") {
                    let types = Dictionary(grouping: session.graphNodes, by: { $0.type })
                    ForEach(Array(types.keys.sorted()), id: \.self) { type in
                        if let nodes = types[type] {
                            Section(type.capitalized) {
                                ForEach(nodes) { node in
                                    HStack {
                                        Circle()
                                            .fill(Color(nodeColor(node.type)))
                                            .frame(width: 8, height: 8)
                                        Text(node.label)
                                        Spacer()
                                        Text(String(format: "%.1f", node.strength))
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Connections") {
                    let edges = session.graphNodes.flatMap(\.outgoingEdges)
                    if edges.isEmpty {
                        Text("No connections yet")
                            .foregroundColor(.secondary)
                    }
                    ForEach(edges) { edge in
                        let sourceLabel = edge.sourceNode?.label ?? "Something"
                        let targetLabel = session.graphNodes.first { $0.id == edge.targetNodeID }?.label ?? "another pattern"
                        HStack(spacing: 4) {
                            Text(sourceLabel)
                                .font(.caption.weight(.medium))
                            Text(GraphService.shared.getEdgeTypeLabel(edge.type))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(targetLabel)
                                .font(.caption.weight(.medium))
                        }
                    }
                }

                Section("Overview") {
                    let nodes = session.graphNodes
                    let edges = nodes.flatMap(\.outgoingEdges)
                    let isolated = nodes.filter { node in
                        !edges.contains(where: { $0.sourceNode?.id == node.id || $0.targetNodeID == node.id })
                    }
                    Text("\(nodes.count) patterns · \(edges.count) links")
                    Text("Patterns with no links yet: \(isolated.count)")
                }
            }
            .navigationTitle("Your Patterns")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }

    private func nodeColor(_ type: String) -> String {
        GraphService.shared.getNodeTypeColor(type)
    }
}
