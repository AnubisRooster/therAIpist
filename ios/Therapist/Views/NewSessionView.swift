import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var modality = "free_form"
    @State private var persona: PersonaKind = .therapist

    @AppStorage("therapist_name")        private var therapistName        = ""
    @AppStorage("companion_name")        private var companionName        = "Kai"
    @AppStorage("companion_gender")      private var companionGender      = CompanionGender.unspecified.rawValue
    @AppStorage("companion_personality") private var companionPersonality = CompanionPersonality.warm.rawValue

    private var personaName: String {
        let raw = (persona == .therapist ? therapistName : companionName)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return raw.isEmpty ? persona.defaultName : raw
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Talk with", selection: $persona) {
                        ForEach(PersonaKind.allCases) { kind in
                            Label(kind.fallbackLabel, systemImage: kind.icon).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(persona.blurb)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Who do you want to talk with?")
                } footer: {
                    if !personaName.isEmpty {
                        Text("You'll be chatting with \(personaName). Change names and voices in Settings.")
                            .font(.caption)
                    }
                }

                if persona == .companion {
                    Section {
                        TextField("Name", text: $companionName)
                        Picker("Gender", selection: $companionGender) {
                            ForEach(CompanionGender.allCases) { g in
                                Text(g.label).tag(g.rawValue)
                            }
                        }
                        Picker("Personality", selection: $companionPersonality) {
                            ForEach(CompanionPersonality.allCases) { p in
                                Text(p.label).tag(p.rawValue)
                            }
                        }
                    } header: {
                        Text("Your companion")
                    } footer: {
                        Text("These apply to all your companion chats and can be changed anytime in Settings. Pick a voice in Settings too.")
                            .font(.caption)
                    }
                }

                Section("Session") {
                    TextField("Title (optional)", text: $title)
                }

                if persona == .therapist {
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
        let dateLabel = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let defaultTitle = persona == .companion
            ? "\(personaName) · \(dateLabel)"
            : "Session \(dateLabel)"
        let session = SessionModel(
            title: title.isEmpty ? defaultTitle : title,
            provider: "openrouter",
            modality: persona == .companion ? "free_form" : modality
        )
        session.persona = persona.rawValue
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
