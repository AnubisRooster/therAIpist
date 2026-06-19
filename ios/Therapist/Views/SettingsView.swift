import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var modelService: ModelService
    @AppStorage("openrouter_key") private var openrouterKey = ""
    @AppStorage("default_model") private var defaultModel = "meta-llama/llama-3.2-1b-instruct:free"
    @State private var showKey = false
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
