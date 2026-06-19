import SwiftUI
import SwiftData

@main
struct TherapistApp: App {
    @AppStorage("openrouter_key") private var openrouterKey = ""
    @AppStorage("ollama_host") private var ollamaHost = "http://localhost:11434"
    @AppStorage("default_model") private var defaultModel = "openai/gpt-4o-mini"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    LLMService.shared.configure(
                        openRouterKey: openrouterKey,
                        ollamaHost: ollamaHost,
                        defaultModel: defaultModel
                    )
                }
                .onChange(of: openrouterKey) { _, newKey in
                    LLMService.shared.configure(
                        openRouterKey: newKey,
                        ollamaHost: ollamaHost,
                        defaultModel: defaultModel
                    )
                }
        }
        .modelContainer(for: [
            SessionModel.self,
            MessageModel.self,
            MemoryModel.self,
            GraphNodeModel.self,
            GraphEdgeModel.self,
            NoteModel.self,
            DreamModel.self,
            VoiceRecordingModel.self,
            SafetyEventModel.self,
        ])
    }
}
