import SwiftUI
import VoiceLoopKit

// MARK: - Settings tab wrapper

/// Hosts SettingsView inside the Settings tab with its own NavigationStack.
struct SettingsTabView: View {
    @EnvironmentObject private var modelService:      ModelService
    @EnvironmentObject private var speechService:     SpeechService
    @EnvironmentObject private var localModelService: LocalModelService

    var body: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(modelService)
                .environmentObject(speechService)
                .environmentObject(localModelService)
        }
    }
}

// MARK: - Root settings list

struct SettingsView: View {
    @EnvironmentObject private var modelService:      ModelService
    @EnvironmentObject private var speechService:     SpeechService
    @EnvironmentObject private var localModelService: LocalModelService

    @State private var showChangePIN = false

    var body: some View {
        Form {
            Section("AI & Models") {
                NavigationLink {
                    KeysAndProvidersSettingsView()
                        .environmentObject(modelService)
                } label: {
                    Label("Keys & Providers", systemImage: "key")
                }
                NavigationLink {
                    ModelsSettingsView()
                        .environmentObject(modelService)
                        .environmentObject(localModelService)
                } label: {
                    Label("Models", systemImage: "cpu")
                }
            }

            Section("Experience") {
                NavigationLink {
                    VoiceSettingsView()
                        .environmentObject(speechService)
                } label: {
                    Label("Voice & Speech", systemImage: "speaker.wave.2")
                }
                NavigationLink {
                    PersonasSettingsView()
                        .environmentObject(speechService)
                } label: {
                    Label("Personas", systemImage: "person.2")
                }
            }

            Section("About You") {
                NavigationLink {
                    AboutYouSettingsView()
                } label: {
                    Label("Profile & Intake", systemImage: "person.crop.circle")
                }
            }

            Section("Security & Privacy") {
                Button("Change PIN…") { showChangePIN = true }
                    .foregroundStyle(.primary)
                Text("Your PIN is stored only in this device's Keychain.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                NavigationLink {
                    PrivacySettingsView()
                } label: {
                    Label("Privacy", systemImage: "lock.shield")
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showChangePIN) {
            PINView(onSuccess: { showChangePIN = false }, forceSetup: true)
        }
    }
}

// MARK: - Keys & Providers sub-screen

struct KeysAndProvidersSettingsView: View {
    @EnvironmentObject private var modelService: ModelService

    @AppStorage("default_provider") private var defaultProvider = "openrouter"

    var body: some View {
        Form {
            Section {
                Picker("Default provider", selection: $defaultProvider) {
                    ForEach(LLMProvider.allCases.filter { $0 != .local }) { p in
                        Text(p.displayName).tag(p.rawValue)
                    }
                    Text("On-Device").tag(LLMProvider.local.rawValue)
                }
            } header: {
                Text("Default Provider")
            } footer: {
                Text("This sets the default for new sessions. You can switch per-session from the chat screen.")
                    .font(.caption)
            }

            // Per-provider key rows for every cloud provider
            ForEach(LLMProvider.allCases.filter { $0.baseURL != nil }) { provider in
                ProviderKeySection(provider: provider) {
                    // Refresh the OpenRouter catalogue as soon as its key changes
                    // so the model list and inference stay in sync.
                    if provider == .openrouter {
                        Task { await modelService.refresh() }
                    }
                }
            }

            Section("Privacy") {
                Text("API keys are stored in the system Keychain — they never leave this device unencrypted.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("When using a cloud provider, your messages are sent to that provider's servers to generate a response.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Keys & Providers")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Inline key-entry row for a single provider.
private struct ProviderKeySection<P: APIKeyProvider>: View {
    let provider: P
    var onSaved: () -> Void = {}
    private let keychain = KeychainService.shared

    @State private var keyText  = ""
    @State private var revealed = false
    @State private var saved    = false

    var body: some View {
        Section {
            HStack {
                Group {
                    if revealed {
                        TextField("API Key", text: $keyText)
                    } else {
                        SecureField("API Key", text: $keyText)
                    }
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: keyText) { _, _ in saved = false }

                Button { revealed.toggle() } label: {
                    Image(systemName: revealed ? "eye.slash" : "eye")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(revealed ? "Hide key" : "Show key")
            }
            Button(saved ? "Saved ✓" : "Save") {
                keychain.set(keyText, for: provider)
                saved = true
                onSaved()
            }
            .disabled(keyText.trimmingCharacters(in: .whitespaces).isEmpty || saved)
            if !provider.keyHint.isEmpty {
                Text("Get your key at \(provider.keyHint)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } header: {
            Label(provider.displayName, systemImage: "key")
        }
        .onAppear { keyText = keychain.get(for: provider) ?? "" }
    }
}

// MARK: - Models sub-screen

struct ModelsSettingsView: View {
    @EnvironmentObject private var modelService:      ModelService
    @EnvironmentObject private var localModelService: LocalModelService

    @AppStorage("default_model")       private var defaultModel        = "meta-llama/llama-3.2-1b-instruct:free"
    @AppStorage("default_local_model") private var defaultLocalModel   = "llama-3.2-3b"
    @AppStorage("default_provider")    private var defaultProvider     = "openrouter"

    var body: some View {
        Form {
            Section {
                TextField("Default Model ID", text: $defaultModel)
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
                    Task { await modelService.refresh() }
                }
                .disabled(modelService.isLoading)
            } header: {
                Label("Cloud (OpenRouter)", systemImage: "cloud")
            } footer: {
                Text("Pick a specific model per session from the chat screen.")
                    .font(.caption)
            }

            Section {
                ForEach(localModelService.catalog) { model in
                    localModelCard(model)
                }
                if defaultProvider == "local" {
                    Picker("Default local model", selection: $defaultLocalModel) {
                        ForEach(localModelService.catalog.filter { localModelService.isDownloaded($0.id) }) { m in
                            Text(m.name).tag(m.id)
                        }
                    }
                }
            } header: {
                Label("On-Device Models", systemImage: "cpu")
            } footer: {
                Text("Models are stored in the app's Documents folder. Requires Wi-Fi for download. Inference runs fully on-device via Metal.")
                    .font(.caption)
            }
        }
        .navigationTitle("Models")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func localModelCard(_ model: LocalModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(model.name).font(.headline)
                        if model.isRecommended {
                            TagCapsule(label: "Recommended", color: .blue)
                        }
                        if model.kind == .appleFoundation {
                            TagCapsule(label: "Built-in", color: .indigo)
                        }
                    }
                    if model.kind == .gguf {
                        Text(localModelService.sizeLabel(model))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                // Apple Foundation model — show status, no download/delete.
                if model.kind == .appleFoundation {
                    appleModelStatusBadge
                } else if localModelService.isDownloading(model.id) {
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
            Text(model.description)
                .font(.caption)
                .foregroundColor(.secondary)
            if let progress = localModelService.downloadProgress[model.id] {
                ProgressView(value: progress).tint(.blue)
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else if localModelService.isDownloaded(model.id), model.kind == .gguf {
                Label("Downloaded", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var appleModelStatusBadge: some View {
        if #available(iOS 26, *) {
            let label = AppleFoundationEngine.statusLabel
            let available = AppleFoundationEngine.isAvailable
            Label(label, systemImage: available ? "checkmark.circle.fill" : "exclamationmark.circle")
                .font(.caption)
                .foregroundColor(available ? .green : .secondary)
        } else {
            Label("iOS 26+ required", systemImage: "exclamationmark.circle")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Voice & Speech sub-screen

struct VoiceSettingsView: View {
    @EnvironmentObject private var speechService: SpeechService
    @StateObject private var tts = TTSCoordinator.shared

    @AppStorage("tts_enabled")           private var ttsEnabled   = false
    @AppStorage("tts_provider")          private var ttsProvider  = "ondevice"
    @AppStorage("tts_rate")              private var ttsRate: Double  = 0.5
    @AppStorage("tts_pitch")             private var ttsPitch: Double = 1.0
    @AppStorage("tts_voice_id")          private var ttsVoiceID   = ""
    @AppStorage("tts_openai_voice")      private var openAIVoice  = OpenAITTSEngine.defaultVoice
    @AppStorage("tts_openai_model")      private var openAIModel  = OpenAITTSEngine.defaultModel
    @AppStorage("tts_elevenlabs_voice_id") private var elevenLabsVoiceID = ElevenLabsTTSEngine.defaultVoiceId
    @AppStorage("voice_silence_seconds") private var voiceSilenceSeconds: Double = 5.0

    @State private var elevenLabsVoices: [ElevenLabsTTSEngine.Voice] = []
    @State private var voicesError: String?
    @State private var previewError: String?

    var body: some View {
        Form {
            Section {
                Toggle("Speak responses aloud", isOn: $ttsEnabled)
                if ttsEnabled {
                    Picker("Voice Engine", selection: $ttsProvider) {
                        Text("On-Device").tag("ondevice")
                        Text("OpenAI").tag("openai")
                        Text("ElevenLabs").tag("elevenlabs")
                    }
                    .pickerStyle(.segmented)

                    switch ttsProvider {
                    case "openai":
                        openAISection
                    case "elevenlabs":
                        elevenLabsSection
                    default:
                        onDeviceSection
                    }

                    if let previewError {
                        Text(previewError).font(.caption).foregroundColor(.red)
                    }
                    Button("Preview") {
                        previewError = nil
                        tts.speak("Hello. How are you feeling today?",
                                  rate: Float(ttsRate), pitch: Float(ttsPitch), voiceID: ttsVoiceID,
                                  onError: { previewError = $0 })
                    }
                }
            } header: {
                Text("Text-to-Speech")
            } footer: {
                Text(ttsProvider == "ondevice"
                     ? "Uses on-device TTS. No audio leaves the device. Download more voices in iOS Settings → Accessibility → Spoken Content → Voices."
                     : "Cloud voice replies are sent to a third-party service to synthesize speech.")
                    .font(.caption)
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pause before sending: \(String(format: "%.1f", voiceSilenceSeconds))s")
                        .font(.caption).foregroundColor(.secondary)
                    Slider(value: $voiceSilenceSeconds, in: 2...12, step: 0.5)
                }
            } header: {
                Text("Hands-Free Mode")
            } footer: {
                Text("How long to wait after you stop speaking before your turn is sent. You can also say \"send\" to send immediately.")
                    .font(.caption)
            }
        }
        .navigationTitle("Voice & Speech")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var onDeviceSection: some View {
        NavigationLink {
            VoicePickerView().environmentObject(speechService)
        } label: {
            LabeledContent("Default Voice", value: SpeechService.voiceName(for: ttsVoiceID))
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
    }

    @ViewBuilder
    private var openAISection: some View {
        if KeychainService.shared.hasKey(for: LLMProvider.openai) {
            Picker("Voice", selection: $openAIVoice) {
                ForEach(OpenAITTSEngine.availableVoices, id: \.self) { Text($0.capitalized).tag($0) }
            }
            Picker("Model", selection: $openAIModel) {
                ForEach(OpenAITTSEngine.availableModels, id: \.self) { Text($0).tag($0) }
            }
        } else {
            Text("Uses your existing OpenAI API key from Keys & Providers.")
                .font(.caption).foregroundColor(.secondary)
            Text("No OpenAI key configured yet — add one in Settings → Keys & Providers to use OpenAI voices.")
                .font(.caption).foregroundColor(.orange)
        }
    }

    @ViewBuilder
    private var elevenLabsSection: some View {
        ProviderKeySection(provider: TTSKeyProvider.elevenlabs) {
            Task { await loadElevenLabsVoices() }
        }
        if elevenLabsVoices.isEmpty {
            if let voicesError {
                Text(voicesError).font(.caption).foregroundColor(.red)
            }
            Button("Load Voices") { Task { await loadElevenLabsVoices() } }
                .disabled(!KeychainService.shared.hasKey(for: TTSKeyProvider.elevenlabs))
        } else {
            Picker("Voice", selection: $elevenLabsVoiceID) {
                ForEach(elevenLabsVoices) { Text($0.name).tag($0.id) }
            }
        }
    }

    private func loadElevenLabsVoices() async {
        guard let key = KeychainService.shared.get(for: TTSKeyProvider.elevenlabs) else { return }
        do {
            elevenLabsVoices = try await ElevenLabsTTSEngine.fetchVoices(apiKey: key)
            voicesError = nil
        } catch {
            voicesError = "Couldn't load voices: \(error.localizedDescription)"
        }
    }
}

// MARK: - Personas sub-screen

struct PersonasSettingsView: View {
    @EnvironmentObject private var speechService: SpeechService

    @AppStorage("therapist_name")        private var therapistName        = ""
    @AppStorage("therapist_voice_id")    private var therapistVoiceID     = ""
    @AppStorage("companion_name")        private var companionName        = "Kai"
    @AppStorage("companion_voice_id")    private var companionVoiceID     = ""
    @AppStorage("companion_gender")      private var companionGender      = CompanionGender.unspecified.rawValue
    @AppStorage("companion_personality") private var companionPersonality = CompanionPersonality.warm.rawValue
    @AppStorage("spiritual_name")        private var spiritualName        = "Sage"
    @AppStorage("spiritual_voice_id")    private var spiritualVoiceID     = ""
    @AppStorage("spiritual_tradition")   private var spiritualTradition   = SpiritualTradition.interfaith.rawValue

    var body: some View {
        Form {
            Section {
                TextField("Name (optional)", text: $therapistName)
                NavigationLink {
                    VoicePickerView(storageKey: "therapist_voice_id")
                        .environmentObject(speechService)
                } label: {
                    LabeledContent("Voice", value: SpeechService.voiceName(for: therapistVoiceID))
                }
            } header: {
                Label("Therapist", systemImage: PersonaKind.therapist.icon)
            } footer: {
                Text("The therapeutic approach is chosen per session. All personas share the same memories and knowledge graph.")
                    .font(.caption)
            }

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
                NavigationLink {
                    VoicePickerView(storageKey: "companion_voice_id")
                        .environmentObject(speechService)
                } label: {
                    LabeledContent("Voice", value: SpeechService.voiceName(for: companionVoiceID))
                }
            } header: {
                Label("Companion", systemImage: PersonaKind.companion.icon)
            } footer: {
                Text("A warm, chatty friend who grows with you across every session.")
                    .font(.caption)
            }

            Section {
                TextField("Name", text: $spiritualName)
                Picker("Tradition", selection: $spiritualTradition) {
                    ForEach(SpiritualTradition.allCases) { t in
                        Text(t.label).tag(t.rawValue)
                    }
                }
                NavigationLink {
                    VoicePickerView(storageKey: "spiritual_voice_id")
                        .environmentObject(speechService)
                } label: {
                    LabeledContent("Voice", value: SpeechService.voiceName(for: spiritualVoiceID))
                }
            } header: {
                Label("Spiritual Advisor", systemImage: PersonaKind.spiritual.icon)
            } footer: {
                Text("Draws on wisdom from across religious and philosophical traditions. Will not proselytise or judge.")
                    .font(.caption)
            }
        }
        .navigationTitle("Personas")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - About You sub-screen

struct AboutYouSettingsView: View {
    @AppStorage("user_name")       private var userName       = ""
    @AppStorage("user_pronouns")   private var userPronouns   = ""
    @AppStorage("user_age")        private var userAge        = ""
    @AppStorage("intake_concerns") private var intakeConcerns = ""
    @AppStorage("intake_history")  private var intakeHistory  = ""
    @AppStorage("intake_goals")    private var intakeGoals    = ""

    var body: some View {
        Form {
            Section("Identity") {
                TextField("Name", text: $userName)
                TextField("Pronouns", text: $userPronouns)
                TextField("Age", text: $userAge).keyboardType(.numberPad)
            }
            Section {
                TextField("What brings you here?", text: $intakeConcerns, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                Text("Presenting Concerns")
            }
            Section {
                TextField("Any prior therapy or counselling?", text: $intakeHistory, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                Text("Background")
            }
            Section {
                TextField("What would you like to work toward?", text: $intakeGoals, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                Text("Goals")
            }
        }
        .navigationTitle("Profile & Intake")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy sub-screen

struct PrivacySettingsView: View {
    var body: some View {
        Form {
            Section("Data Storage") {
                Text("Conversations, memories, notes, and dreams are stored locally on this device only.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Memory embeddings are computed on-device by Apple's NLEmbedding framework — no embedding calls leave the device.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Section("Cloud Providers") {
                Text("When you use a cloud model (OpenRouter or BYOK), your messages are sent to that provider's servers to generate a response. Review the provider's privacy policy for how they handle data.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Section("On-Device Models") {
                Text("When using an on-device model, no messages leave this device. All inference is performed locally via llama.cpp / Metal.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
