import SwiftUI
import SwiftData

// MARK: - NarrativeView

/// Displays an AI-generated, chronological story of the user's life as
/// understood across all sessions and personas.
///
/// Chapters are written incrementally — only new material since the last
/// build is processed — so regeneration is cheap even with a large history.
/// The view refreshes on launch/foreground when more than one hour has
/// elapsed since the last generation, and the user can also refresh manually.
struct NarrativeView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var localModelService: LocalModelService
    @Query(sort: \NarrativeChapter.createdAt, order: .forward)
    private var chapters: [NarrativeChapter]

    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showSettings = false
    @AppStorage("narrative_last_build")  private var lastBuildTimestamp: Double = 0
    /// Generation source: "" = automatic, "local", or a cloud `LLMProvider.rawValue`.
    @AppStorage("narrative_provider")    private var narrativeProvider = ""
    /// Optional override model for cloud generation (blank = use default).
    @AppStorage("narrative_cloud_model") private var narrativeCloudModel = ""
    @AppStorage("default_model")         private var defaultCloudModel = "meta-llama/llama-3.2-1b-instruct:free"
    @AppStorage("default_local_model")   private var defaultLocalModel = "llama-3.2-3b"

    private var needsRefresh: Bool {
        let elapsed = Date().timeIntervalSince1970 - lastBuildTimestamp
        return elapsed > 3600 // 1 hour
    }

    /// Whether at least one on-device model is downloaded.
    private var localAvailable: Bool {
        localModelService.catalog.contains { localModelService.isDownloaded($0.id) }
    }

    /// Cloud providers (with a base URL) that have a key configured.
    private var cloudProvidersWithKeys: [LLMProvider] {
        LLMProvider.allCases.filter { $0.baseURL != nil && KeychainService.shared.hasKey(for: $0) }
    }

    private var preferredCloudProvider: LLMProvider? {
        cloudProvidersWithKeys.contains(.openrouter) ? .openrouter : cloudProvidersWithKeys.first
    }

    /// The provider + model to actually generate with, honoring the user's
    /// choice and falling back sensibly. `nil` means nothing is configured.
    /// Automatic prefers a cloud model when a key is available.
    private var resolvedTarget: (provider: String, model: String)? {
        if narrativeProvider == "local", localAvailable {
            return ("local", resolvedLocalModel)
        }
        if let p = LLMProvider(rawValue: narrativeProvider),
           p != .local, cloudProvidersWithKeys.contains(p) {
            return (p.rawValue, resolvedCloudModel(for: p))
        }
        if let p = preferredCloudProvider {
            return (p.rawValue, resolvedCloudModel(for: p))
        }
        if localAvailable {
            return ("local", resolvedLocalModel)
        }
        return nil
    }

    private var resolvedLocalModel: String {
        defaultLocalModel.isEmpty ? "llama-3.2-3b" : defaultLocalModel
    }

    private func resolvedCloudModel(for provider: LLMProvider) -> String {
        let override = narrativeCloudModel.trimmingCharacters(in: .whitespaces)
        if !override.isEmpty { return override }
        if !defaultCloudModel.isEmpty { return defaultCloudModel }
        return provider.exampleModelID
    }

    /// Human-readable description of the active generation source.
    private var resolvedLabel: String {
        guard let target = resolvedTarget else { return "Not configured" }
        if target.provider == "local" {
            return "On-Device · \(target.model)"
        }
        let name = LLMProvider(rawValue: target.provider)?.displayName ?? target.provider
        return "\(name) · \(target.model)"
    }

    var body: some View {
        NavigationStack {
            Group {
                if chapters.isEmpty && !isGenerating {
                    emptyState
                } else {
                    chapterList
                }
            }
            .navigationTitle("Narrative")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Source: \(resolvedLabel)") {
                            Button {
                                showSettings = true
                            } label: {
                                Label("Generation settings…", systemImage: "slider.horizontal.3")
                            }
                            Button {
                                Task { await generate(manual: true) }
                            } label: {
                                Label("Refresh now", systemImage: "arrow.clockwise")
                            }
                            .disabled(isGenerating)
                        }
                    } label: {
                        if isGenerating {
                            ProgressView()
                        } else {
                            Image(systemName: "ellipsis.circle")
                                .accessibilityLabel("Narrative options")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                NarrativeSettingsSheet(
                    narrativeProvider: $narrativeProvider,
                    narrativeCloudModel: $narrativeCloudModel,
                    localAvailable: localAvailable,
                    cloudProviders: cloudProvidersWithKeys,
                    resolvedLabel: resolvedLabel,
                    defaultCloudModel: defaultCloudModel
                )
            }
            .task {
                // Only auto-build when a generation method is configured, so a
                // cloud-only or fresh user isn't hit with errors on every launch.
                if needsRefresh, resolvedTarget != nil {
                    await generate()
                }
            }
        }
    }

    // MARK: - Sub-views

    private var emptyState: some View {
        ContentUnavailableView {
            Label(isGenerating ? "Writing Your Story…" : "No Narrative Yet",
                  systemImage: "book.pages")
        } description: {
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else if resolvedTarget == nil {
                Text("Add an API key in Settings → Keys & Providers or download an on-device model, then generate your story here.")
            } else {
                Text("Your story will appear here after your first session. It updates automatically and grows with you over time.")
            }
        } actions: {
            if isGenerating {
                ProgressView()
            } else if resolvedTarget == nil {
                Button("Open Settings") { showSettings = true }
                    .buttonStyle(.borderedProminent)
            } else {
                Button("Generate Now") {
                    Task { await generate(manual: true) }
                }
                .buttonStyle(.borderedProminent)
                Button("Generation settings…") { showSettings = true }
                    .font(.footnote)
            }
        }
    }

    private var chapterList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                }
                if isGenerating {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Writing your story…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                ForEach(chapters) { chapter in
                    ChapterCard(chapter: chapter)
                }
            }
            .padding()
        }
    }

    // MARK: - Generation

    private func generate(manual: Bool = false) async {
        guard !isGenerating else { return }
        guard let target = resolvedTarget else {
            if manual {
                errorMessage = "No generation method is configured. Add an API key in Settings → Keys & Providers, or download an on-device model."
            }
            return
        }
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let produced = try await NarrativeService.shared.buildIncremental(
                context: context,
                provider: target.provider,
                model: target.model
            )
            lastBuildTimestamp = Date().timeIntervalSince1970
            if !produced && manual && chapters.isEmpty {
                errorMessage = "There's nothing to narrate yet. Have a conversation in the Chats tab first, then come back."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Narrative settings sheet

/// Lets the user choose which model writes their narrative (on-device or a
/// specific cloud provider/model) directly from the Narrative tab.
private struct NarrativeSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var narrativeProvider: String
    @Binding var narrativeCloudModel: String
    let localAvailable: Bool
    let cloudProviders: [LLMProvider]
    let resolvedLabel: String
    let defaultCloudModel: String

    /// Whether the current selection will use a cloud provider (so the model
    /// field is relevant).
    private var usesCloud: Bool {
        if narrativeProvider == "local" { return false }
        // Automatic or an explicit cloud provider both use cloud when keys exist.
        return !cloudProviders.isEmpty
    }

    private var cloudModelPlaceholder: String {
        if !defaultCloudModel.isEmpty { return defaultCloudModel }
        return (LLMProvider(rawValue: narrativeProvider) ?? cloudProviders.first ?? .openrouter).exampleModelID
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Generate with", selection: $narrativeProvider) {
                        Text("Automatic").tag("")
                        if localAvailable {
                            Text("On-Device").tag("local")
                        }
                        ForEach(cloudProviders) { provider in
                            Text(provider.displayName).tag(provider.rawValue)
                        }
                    }
                } header: {
                    Text("Source")
                } footer: {
                    Text("Automatic prefers a cloud model when an API key is set. Currently using: \(resolvedLabel).")
                }

                if usesCloud {
                    Section {
                        TextField(cloudModelPlaceholder, text: $narrativeCloudModel)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } header: {
                        Text("Cloud Model")
                    } footer: {
                        Text("Leave blank to use your default cloud model from Settings → Models. Add provider keys in Settings → Keys & Providers.")
                    }
                }

                if cloudProviders.isEmpty && !localAvailable {
                    Section {
                        Text("No models are available yet. Add an API key in Settings → Keys & Providers, or download an on-device model in Settings → Models.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Narrative Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Chapter card

private struct ChapterCard: View {
    let chapter: NarrativeChapter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if !chapter.personaLabel.isEmpty {
                    TagCapsule(label: chapter.personaLabel,
                               color: personaColor(chapter.personaLabel))
                }
                Spacer()
                Text(chapter.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            if !chapter.title.isEmpty {
                Text(chapter.title)
                    .font(.headline)
            }
            MarkdownText(chapter.content)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private func personaColor(_ label: String) -> Color {
        let l = label.lowercased()
        if l.contains("spiritual") { return Theme.personaColor(.spiritual) }
        if l.contains("companion") { return Theme.personaColor(.companion) }
        return Theme.personaColor(.therapist)
    }
}
