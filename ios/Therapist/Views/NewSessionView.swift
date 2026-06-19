import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var modality = "integrated"
    @State private var provider = "openrouter"
    @State private var mode = "auto"

    let modalities = ["integrated", "adlerian", "jungian", "dbt"]
    let providers = ["openrouter", "ollama"]
    let modes = ["auto", "local", "cloud", "hybrid"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Session") {
                    TextField("Title", text: $title)
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

                Section("LLM Provider") {
                    Picker("Provider", selection: $provider) {
                        ForEach(providers, id: \.self) { p in
                            Text(p.capitalized).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)

                    if provider == "openrouter" {
                        Text("Requires API key in Settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Requires Ollama on your network")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Mode") {
                    Picker("Mode", selection: $mode) {
                        ForEach(modes, id: \.self) { m in
                            Text(m.capitalized).tag(m)
                        }
                    }
                    .pickerStyle(.menu)

                    Text(modeDescription(mode))
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
            provider: provider,
            modality: modality
        )
        session.mode = mode
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

    private func modeDescription(_ mode: String) -> String {
        switch mode {
        case "local": return "Force local Ollama provider"
        case "cloud": return "Force cloud OpenRouter provider"
        case "hybrid": return "Use session's configured provider"
        default: return "Automatically select based on availability"
        }
    }
}
