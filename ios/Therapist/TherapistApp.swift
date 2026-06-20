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
            GlobalMemoryModel.self,
        ])
    }
}

/// Root routing: onboarding (first launch) → PIN → main app.
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var modelService      = ModelService()
    @StateObject private var speechService     = SpeechService.shared
    @StateObject private var localModelService = LocalModelService.shared

    @AppStorage("openrouter_key")      private var openrouterKey      = ""
    @AppStorage("default_model")       private var defaultModel       = "meta-llama/llama-3.2-1b-instruct:free"
    @AppStorage("onboarding_complete") private var onboardingComplete = false

    @State private var isUnlocked = false

    var body: some View {
        Group {
            if !onboardingComplete {
                OnboardingView()
            } else if !isUnlocked {
                PINView(onSuccess: { isUnlocked = true })
            } else {
                ContentView()
                    .environmentObject(modelService)
                    .environmentObject(speechService)
                    .environmentObject(localModelService)
                    .task {
                        BadgeBackfillService.runIfNeeded(context: modelContext)
                        await LLMService.shared.configure(apiKey: openrouterKey, defaultModel: defaultModel)
                        await modelService.refreshIfNeeded(apiKey: openrouterKey)
                        localModelService.refreshDownloadedStatus()
                    }
                    .onChange(of: openrouterKey) { _, newKey in
                        Task {
                            await LLMService.shared.configure(apiKey: newKey, defaultModel: defaultModel)
                            await modelService.refresh(apiKey: newKey)
                        }
                    }
            }
        }
    }
}
