import SwiftUI
import SwiftData

@main
struct TherapistApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
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

/// Gates the app behind a PIN and wires up shared services (LLM config, model
/// list) once the user is authenticated.
struct AppRootView: View {
    @StateObject private var modelService = ModelService()

    @AppStorage("openrouter_key") private var openrouterKey = ""
    @AppStorage("default_model") private var defaultModel = "meta-llama/llama-3.2-1b-instruct:free"

    @State private var isUnlocked = false

    var body: some View {
        Group {
            if isUnlocked {
                ContentView()
                    .environmentObject(modelService)
                    .task {
                        await LLMService.shared.configure(apiKey: openrouterKey, defaultModel: defaultModel)
                        await modelService.refreshIfNeeded(apiKey: openrouterKey)
                    }
                    .onChange(of: openrouterKey) { _, newKey in
                        Task {
                            await LLMService.shared.configure(apiKey: newKey, defaultModel: defaultModel)
                            await modelService.refresh(apiKey: newKey)
                        }
                    }
            } else {
                PINView(onSuccess: { isUnlocked = true })
            }
        }
    }
}
