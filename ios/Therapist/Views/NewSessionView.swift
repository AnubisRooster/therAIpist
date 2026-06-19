import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var modality = "integrated"

    let modalities = ["integrated", "adlerian", "jungian", "dbt"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Session") {
                    TextField("Title (optional)", text: $title)
                }

                Section("Therapy Modality") {
                    Picker("Modality", selection: $modality) {
                        ForEach(modalities, id: \.self) { m in
                            HStack {
                                Image(systemName: modalityIcon(m))
                                Text(m.capitalized)
                            }.tag(m)
                        }
                    }
                    .pickerStyle(.menu)

                    Text(modalityDescription(modality))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section {
                    Text("Choose your model from the chat screen after starting.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createSession()
                        dismiss()
                    }
                }
            }
        }
    }

    private func createSession() {
        let session = SessionModel(
            title: title.isEmpty ? "Session \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))" : title,
            provider: "openrouter",
            modality: modality
        )
        context.insert(session)
        try? context.save()
    }

    private func modalityIcon(_ modality: String) -> String {
        switch modality {
        case "adlerian": return "figure.walk"
        case "jungian": return "moon.stars"
        case "dbt": return "brain"
        default: return "sparkles"
        }
    }

    private func modalityDescription(_ modality: String) -> String {
        switch modality {
        case "adlerian": return "Focus on lifestyle, goals, and social interest"
        case "jungian": return "Explore symbols, archetypes, and individuation"
        case "dbt": return "Skills-based: mindfulness, distress tolerance, emotion regulation"
        default: return "Integrates Jungian, Adlerian, and DBT approaches"
        }
    }
}
