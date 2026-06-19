import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SessionModel.updatedAt, order: .reverse) private var sessions: [SessionModel]
    @State private var showNewSession = false
    @State private var showSettings = false
    @State private var showDashboard = false

    var body: some View {
        NavigationStack {
            List {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions",
                        systemImage: "brain.head.profile",
                        description: Text("Start a new therapy session to begin.")
                    )
                }
                ForEach(sessions) { session in
                    NavigationLink(destination: ChatView(session: session)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title.isEmpty ? "Untitled Session" : session.title)
                                .font(.headline)
                            HStack(spacing: 8) {
                                Label(session.modality.capitalized, systemImage: modalityIcon(session.modality))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Label(session.provider, systemImage: "network")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if !session.mode.isEmpty && session.mode != "auto" {
                                    Text(session.mode.uppercased())
                                        .font(.caption2)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                            Text("\(session.messages.count) messages")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationTitle("Therapist")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Button("Dashboard", systemImage: "chart.bar") {
                            showDashboard = true
                        }
                        Button("Settings", systemImage: "gear") {
                            showSettings = true
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Session", systemImage: "plus") {
                        showNewSession = true
                    }
                }
            }
            .sheet(isPresented: $showNewSession) {
                NewSessionView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showDashboard) {
                DashboardView()
            }
        }
    }

    private func deleteSessions(_ offsets: IndexSet) {
        for index in offsets {
            context.delete(sessions[index])
        }
    }

    private func modalityIcon(_ modality: String) -> String {
        switch modality {
        case "adlerian": return "figure.walk"
        case "jungian": return "moon.stars"
        case "dbt": return "brain"
        default: return "sparkles"
        }
    }
}
