import SwiftUI
import SwiftData

@main
struct SelfwardApp: App {
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
            NarrativeDocument.self,
            MoodEntryModel.self,
        ])
    }
}

// MARK: - Root tab view

/// Four-tab shell presented after the PIN gate.
struct RootTabView: View {
    @EnvironmentObject private var modelService:      ModelService
    @EnvironmentObject private var speechService:     SpeechService
    @EnvironmentObject private var localModelService: LocalModelService

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right")
                }

            NarrativeView()
                .tabItem {
                    Label("Narrative", systemImage: "book.pages")
                }

            DashboardTabView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }

            SettingsTabView()
                .environmentObject(modelService)
                .environmentObject(speechService)
                .environmentObject(localModelService)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Theme.accent)
    }
}

// MARK: -

/// Root routing: onboarding (first launch) → PIN → main app.
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var modelService      = ModelService()
    @StateObject private var speechService     = SpeechService.shared
    @StateObject private var localModelService = LocalModelService.shared

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
                RootTabView()
                    .environmentObject(modelService)
                    .environmentObject(speechService)
                    .environmentObject(localModelService)
                    .task {
                        BadgeBackfillService.runIfNeeded(context: modelContext)
                        // Encrypt the on-device journal at rest.
                        if !StoreProtection.applyToDefaultStore() {
                            print("⚠️ StoreProtection: failed to apply at-rest file protection to one or more stores")
                        }
                        // Resolve the OpenRouter key (Keychain only — no plaintext fallback).
                        let orKey = KeychainService.shared.openRouterKey()
                        await LLMService.shared.configure(apiKey: orKey, defaultModel: defaultModel)
                        await modelService.refreshIfNeeded(apiKey: orKey)
                        localModelService.refreshDownloadedStatus()
                    }
            }
        }
        // Re-lock whenever the app is backgrounded, so a PIN is required
        // every time the app becomes visible again — not just on cold
        // launch, which is the only time it fired before this fix.
        .onChange(of: scenePhase) { _, phase in
            if phase == .background, isUnlocked {
                isUnlocked = false
            }
        }
    }
}
