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
    @AppStorage("spiritual_name")        private var spiritualName        = "Sage"
    @AppStorage("spiritual_tradition")   private var spiritualTradition   = SpiritualTradition.interfaith.rawValue

    private var personaName: String {
        let raw: String
        switch persona {
        case .therapist: raw = therapistName
        case .companion: raw = companionName
        case .spiritual: raw = spiritualName
        }
        return raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? persona.defaultName
            : raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Persona picker
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
                        Text("You'll be chatting with \(personaName). Change names and voices in Settings → Personas.")
                            .font(.caption)
                    }
                }

                // MARK: Companion inline customisation
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
                        Text("These settings apply to all companion chats. Adjust voice in Settings → Personas.")
                            .font(.caption)
                    }
                }

                // MARK: Spiritual inline customisation
                if persona == .spiritual {
                    Section {
                        TextField("Name", text: $spiritualName)
                        Picker("Tradition", selection: $spiritualTradition) {
                            ForEach(SpiritualTradition.allCases) { t in
                                Text(t.label).tag(t.rawValue)
                            }
                        }
                    } header: {
                        Text("Your spiritual advisor")
                    } footer: {
                        Text("The advisor draws on this tradition's wisdom. They will never proselytise or judge your beliefs. Adjust voice in Settings → Personas.")
                            .font(.caption)
                    }
                }

                // MARK: Session title
                Section("Session") {
                    TextField("Title (optional)", text: $title)
                }

                // MARK: Therapy modality
                if persona == .therapist {
                    Section("Therapy Modality") {
                        Picker("Modality", selection: $modality) {
                            ForEach(allModalities, id: \.self) { m in
                                HStack {
                                    Image(systemName: modalityIcons[m] ?? "sparkles")
                                        .foregroundColor(Theme.modalityColor(m))
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
        let defaultTitle: String
        switch persona {
        case .companion: defaultTitle = "\(personaName) · \(dateLabel)"
        case .spiritual: defaultTitle = "\(personaName) · \(dateLabel)"
        case .therapist: defaultTitle = "Session \(dateLabel)"
        }
        let sessionModality: String
        switch persona {
        case .therapist: sessionModality = modality
        case .companion, .spiritual: sessionModality = "free_form"
        }
        let session = SessionModel(
            title: title.isEmpty ? defaultTitle : title,
            provider: "openrouter",
            modality: sessionModality
        )
        session.persona = persona.rawValue
        context.insert(session)
        try? context.save()
    }
}
