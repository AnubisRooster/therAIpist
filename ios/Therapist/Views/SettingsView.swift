import SwiftUI

struct SettingsView: View {
    @AppStorage("openrouter_key") private var openrouterKey = ""
    @AppStorage("ollama_host") private var ollamaHost = "http://localhost:11434"
    @AppStorage("default_model") private var defaultModel = "openai/gpt-4o-mini"
    @State private var showKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section("OpenRouter") {
                    HStack {
                        if showKey {
                            TextField("API Key", text: $openrouterKey)
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

                    TextField("Default Model", text: $defaultModel)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Text("e.g. openai/gpt-4o-mini, anthropic/claude-3-haiku")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Ollama (Local)") {
                    TextField("Host URL", text: $ollamaHost)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Text("Must be accessible from this device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Storage") {
                    Text("All data stored locally on device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Memories and knowledge graph are on-device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
