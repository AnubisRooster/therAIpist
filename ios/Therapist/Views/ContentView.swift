import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var modelService: ModelService
    @EnvironmentObject private var speechService: SpeechService
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
                                Label(session.resolvedModel.components(separatedBy: "/").last ?? session.resolvedModel,
                                      systemImage: "cpu")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
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
                    .environmentObject(modelService)
                    .environmentObject(speechService)
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
        modalityIcons[modality] ?? "sparkles"
    }
}
