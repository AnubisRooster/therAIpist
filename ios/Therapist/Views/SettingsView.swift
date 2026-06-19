import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var modelService:  ModelService
    @EnvironmentObject private var speechService: SpeechService

    @AppStorage("openrouter_key")  private var openrouterKey = ""
    @AppStorage("default_model")   private var defaultModel  = "meta-llama/llama-3.2-1b-instruct:free"

    // TTS
    @AppStorage("tts_enabled")     private var ttsEnabled    = false
    @AppStorage("tts_rate")        private var ttsRate: Double = 0.5
    @AppStorage("tts_pitch")       private var ttsPitch: Double = 1.0

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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Speed: \(String(format: "%.2f", ttsRate))")
                                .font(.caption).foregroundColor(.secondary)
                            Slider(value: $ttsRate, in: 0.2...0.6, step: 0.05)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pitch: \(String(format: "%.1f", ttsPitch))")
                                .font(.caption).foregroundColor(.secondary)
                            Slider(value: $ttsPitch, in: 0.8...1.2, step: 0.05)
                        }
                        Button("Preview voice") {
                            speechService.speak("Hello. How are you feeling today?",
                                                rate: Float(ttsRate), pitch: Float(ttsPitch))
                        }
                    }
                } header: {
                    Text("Voice")
                } footer: {
                    Text("Uses on-device text-to-speech. No data leaves the device.")
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
}
