import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var modality = "free_form"

    var body: some View {
        NavigationStack {
            Form {
                Section("Session") {
                    TextField("Title (optional)", text: $title)
                }

                Section("Therapy Modality") {
                    Picker("Modality", selection: $modality) {
                        ForEach(allModalities, id: \.self) { m in
                            HStack {
                                Image(systemName: modalityIcons[m] ?? "sparkles")
                                    .foregroundColor(modalityColor(m))
                                Text(m.replacingOccurrences(of: "_", with: " ").capitalized)
                            }.tag(m)
                        }
                    }
                    .pickerStyle(.menu)

                    Text(modalityDescriptions[modality] ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Model") {
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
