import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context

    @Query(
        filter: #Predicate<SessionModel> { !$0.isArchived },
        sort: \SessionModel.updatedAt,
        order: .reverse
    ) private var sessions: [SessionModel]

    @State private var showNewSession = false
    @State private var showArchive    = false

    var body: some View {
        NavigationStack {
            List {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions",
                        systemImage: "brain.head.profile",
                        description: Text("Tap + to start your first session.")
                    )
                }
                ForEach(sessions) { session in
                    NavigationLink(destination: ChatView(session: session)) {
                        SessionRow(session: session)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            archive(session)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(.orange)
                    }
                }
            }
            .navigationTitle("therAIpist")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Archive", systemImage: "archivebox") {
                        showArchive = true
                    }
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Archived sessions")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Session", systemImage: "plus") {
                        showNewSession = true
                    }
                    .accessibilityLabel("Start new session")
                }
            }
            .sheet(isPresented: $showNewSession) {
                NewSessionView()
            }
            .sheet(isPresented: $showArchive) {
                ArchivedSessionsView()
            }
        }
    }

    private func archive(_ session: SessionModel) {
        session.isArchived = true
        session.updatedAt  = Date()
        try? context.save()
    }

}

// MARK: - Session row

private struct SessionRow: View {
    let session: SessionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.title.isEmpty ? "Untitled Session" : session.title)
                .font(.headline)
            HStack(spacing: 8) {
                Label(session.modality.capitalized,
                      systemImage: modalityIcons[session.modality] ?? "sparkles")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Label(session.modelLabel,
                      systemImage: session.resolvedProvider == "local" ? "cpu" : "cloud")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            HStack(spacing: 8) {
                Text("\(session.messages.count) messages")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                if !session.graphNodes.isEmpty {
                    Label("\(session.graphNodes.count)", systemImage: "circle.hexagongrid")
                        .font(.caption2)
                        .foregroundColor(.purple.opacity(0.7))
                }
                if !session.memories.isEmpty {
                    Label("\(session.memories.count)", systemImage: "brain")
                        .font(.caption2)
                        .foregroundColor(.teal.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - Archived sessions sheet

struct ArchivedSessionsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(
        filter: #Predicate<SessionModel> { $0.isArchived },
        sort: \SessionModel.updatedAt,
        order: .reverse
    ) private var archived: [SessionModel]

    var body: some View {
        NavigationStack {
            List {
                if archived.isEmpty {
                    ContentUnavailableView(
                        "No Archived Sessions",
                        systemImage: "archivebox",
                        description: Text("Swipe left on a session to archive it. Archived sessions preserve all memories, notes, and graph data.")
                    )
                }
                ForEach(archived) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title.isEmpty ? "Untitled Session" : session.title)
                                .font(.headline)
                            Text(session.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(session.messages.count) messages · \(session.memories.count) memories · \(session.graphNodes.count) nodes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            restore(session)
                        } label: {
                            Label("Restore", systemImage: "arrow.uturn.backward")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.teal)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            context.delete(session)
                            try? context.save()
                        } label: {
                            Label("Delete Forever", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Archived Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func restore(_ session: SessionModel) {
        session.isArchived = false
        session.updatedAt  = Date()
        try? context.save()
    }
}
