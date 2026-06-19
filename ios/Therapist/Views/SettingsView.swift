import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var modelService:      ModelService
    @EnvironmentObject private var speechService:     SpeechService
    @EnvironmentObject private var localModelService: LocalModelService

    @AppStorage("openrouter_key")      private var openrouterKey    = ""
    @AppStorage("default_model")       private var defaultModel     = "meta-llama/llama-3.2-1b-instruct:free"
    @AppStorage("default_provider")    private var defaultProvider  = "openrouter"
    @AppStorage("default_local_model") private var defaultLocalModel = "llama-3.2-3b"

    // TTS
    @AppStorage("tts_enabled")     private var ttsEnabled    = false
    @AppStorage("tts_rate")        private var ttsRate: Double  = 0.5
    @AppStorage("tts_pitch")       private var ttsPitch: Double = 1.0
    @AppStorage("tts_voice_id")    private var ttsVoiceID     = ""

    // Intake profile (editable after onboarding)
    @AppStorage("user_name")       private var userName       = ""
    @AppStorage("user_pronouns")   private var userPronouns   = ""
    @AppStorage("user_age")        private var userAge        = ""
    @AppStorage("intake_concerns") private var intakeConcerns = ""
    @AppStorage("intake_history")  private var intakeHistory  = ""
    @AppStorage("intake_goals")    private var intakeGoals    = ""

    @State private var showKey       = false
    @State private var showChangePIN = false

    var body: some View {
        NavigationStack {
            Form {
                Section("OpenRouter") {
                    HStack {
                        if showKey {
                            TextField("API Key", text: $openrouterKey)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("API Key", text: $openrouterKey)
                        }
                        Button(action: { showKey.toggle() }) {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                        }
                    }
                    Text("Get your key at openrouter.ai/keys")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Default Model") {
                    TextField("Default Model", text: $defaultModel)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    if modelService.isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading models…").font(.caption).foregroundColor(.secondary)
                        }
                    } else if !modelService.freeModels.isEmpty {
                        Text("\(modelService.freeModels.count) free models available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if let error = modelService.lastError {
                        Text(error).font(.caption).foregroundColor(.red)
                    }

                    Button("Refresh model list") {
                        Task { await modelService.refresh(apiKey: openrouterKey) }
                    }
                    .disabled(modelService.isLoading)

                    Text("Pick a model per session from the chat screen.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section {
                    Toggle("Speak responses aloud", isOn: $ttsEnabled)

                    if ttsEnabled {
                        NavigationLink {
                            VoicePickerView().environmentObject(speechService)
                        } label: {
                            LabeledContent("Voice", value: SpeechService.voiceName(for: ttsVoiceID))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Speed: \(String(format: "%.2f", ttsRate))")
                                .font(.caption).foregroundColor(.secondary)
                            Slider(value: $ttsRate, in: 0.2...0.7, step: 0.025)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pitch: \(String(format: "%.1f", ttsPitch))")
                                .font(.caption).foregroundColor(.secondary)
                            Slider(value: $ttsPitch, in: 0.75...1.25, step: 0.05)
                        }

                        Button("Preview") {
                            speechService.speak("Hello. How are you feeling today?",
                                                rate: Float(ttsRate), pitch: Float(ttsPitch),
                                                voiceID: ttsVoiceID)
                        }
                    }
                } header: {
                    Text("Voice")
                } footer: {
                    Text("Uses on-device text-to-speech. No audio leaves the device. Download more voices in iOS Settings → Accessibility → Spoken Content → Voices.")
                        .font(.caption)
                }

                Section("About You") {
                    TextField("Name", text: $userName)
                    TextField("Pronouns", text: $userPronouns)
                    TextField("Age", text: $userAge).keyboardType(.numberPad)
                    TextField("What brings you here?", text: $intakeConcerns, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Therapy background", text: $intakeHistory, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Goals", text: $intakeGoals, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Security") {
                    Button("Change PIN…") { showChangePIN = true }
                    Text("Your PIN is stored only in this device's Keychain.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section {
                    Picker("Default provider", selection: $defaultProvider) {
                        Text("OpenRouter (cloud)").tag("openrouter")
                        Text("On-Device").tag("local")
                    }
                    .pickerStyle(.segmented)

                    if defaultProvider == "local" {
                        Picker("Default local model", selection: $defaultLocalModel) {
                            ForEach(localModelService.catalog.filter { localModelService.isDownloaded($0.id) }) { m in
                                Text(m.name).tag(m.id)
                            }
                        }
                        if localModelService.catalog.filter({ localModelService.isDownloaded($0.id) }).isEmpty {
                            Text("No local models downloaded yet.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Default Provider")
                } footer: {
                    Text(defaultProvider == "local"
                         ? "New sessions will use the selected on-device model by default."
                         : "New sessions will use OpenRouter by default.")
                        .font(.caption)
                }

                Section {
                    ForEach(localModelService.catalog) { model in
                        localModelCard(model)
                    }
                } header: {
                    Text("On-Device Models")
                } footer: {
                    Text("Models are stored in the app's Documents folder. Requires Wi-Fi for download. Inference runs fully on-device via Metal.")
                        .font(.caption)
                }

                Section("Data & Privacy") {
                    Text("Conversations are stored locally on this device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Memories use on-device embeddings — no extra network calls.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showChangePIN) {
            PINView(onSuccess: { showChangePIN = false }, forceSetup: true)
        }
    }

    // MARK: - On-Device Model Card

    @ViewBuilder
    private func localModelCard(_ model: LocalModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(model.name).font(.headline)
                        if model.isRecommended {
                            Text("Recommended")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    Text(localModelService.sizeLabel(model))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()

                // Download / Cancel / Delete button
                if localModelService.isDownloading(model.id) {
                    Button(role: .destructive) {
                        localModelService.cancelDownload(model.id)
                    } label: {
                        Label("Cancel", systemImage: "xmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                } else if localModelService.isDownloaded(model.id) {
                    Button(role: .destructive) {
                        localModelService.deleteModel(model.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                } else {
                    Button {
                        localModelService.startDownload(model)
                    } label: {
                        Label("Download", systemImage: "arrow.down.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }

            // Description
            Text(model.description)
                .font(.caption)
                .foregroundColor(.secondary)

            // Progress bar while downloading
            if let progress = localModelService.downloadProgress[model.id] {
                ProgressView(value: progress)
                    .tint(.blue)
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else if localModelService.isDownloaded(model.id) {
                Label("Downloaded", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}
