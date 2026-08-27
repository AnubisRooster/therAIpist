import SwiftUI
import SwiftData
import UIKit

// MARK: - NarrativeView

/// Displays the user's single, evolving life narrative as a continuous journal
/// page. The narrative is an AI-generated, holistic account of all sessions that
/// grows and is revised in place over time — not a list of per-session chapters.
///
/// Visual design: warm parchment tones, serif body text, a decorative chapter
/// ornament, and a "Last written …" footer — evoking an old-fashioned journal.
struct NarrativeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme)  private var colorScheme
    @EnvironmentObject private var localModelService: LocalModelService

    @Query private var documents: [NarrativeDocument]
    private var document: NarrativeDocument? { documents.first }

    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showSettings = false
    @State private var showExport   = false
    @State private var exportItems: [Any] = []

    @AppStorage("narrative_last_build")  private var lastBuildTimestamp: Double = 0
    @AppStorage("narrative_provider")    private var narrativeProvider    = ""
    @AppStorage("narrative_cloud_model") private var narrativeCloudModel  = ""
    @AppStorage("default_model")         private var defaultCloudModel    = "meta-llama/llama-3.2-1b-instruct:free"
    @AppStorage("default_local_model")   private var defaultLocalModel    = "llama-3.2-3b"

    // MARK: - Helpers

    private var needsRefresh: Bool {
        Date().timeIntervalSince1970 - lastBuildTimestamp > 3600
    }

    private var localAvailable: Bool {
        localModelService.catalog.contains { localModelService.isDownloaded($0.id) }
    }

    private var cloudProvidersWithKeys: [LLMProvider] {
        LLMProvider.allCases.filter { $0.baseURL != nil && KeychainService.shared.hasKey(for: $0) }
    }

    private var preferredCloudProvider: LLMProvider? {
        cloudProvidersWithKeys.contains(.openrouter) ? .openrouter : cloudProvidersWithKeys.first
    }

    private var resolvedTarget: (provider: String, model: String)? {
        if narrativeProvider == "local", localAvailable {
            return ("local", resolvedLocalModel)
        }
        if let p = LLMProvider(rawValue: narrativeProvider), p != .local,
           cloudProvidersWithKeys.contains(p) {
            return (p.rawValue, resolvedCloudModel(for: p))
        }
        if let p = preferredCloudProvider {
            return (p.rawValue, resolvedCloudModel(for: p))
        }
        if localAvailable { return ("local", resolvedLocalModel) }
        return nil
    }

    private var resolvedLocalModel: String {
        // Prefer the user's chosen default when it's actually available…
        if !defaultLocalModel.isEmpty, localModelService.isDownloaded(defaultLocalModel) {
            return defaultLocalModel
        }
        // …otherwise fall back to any available on-device model (a downloaded
        // GGUF or the built-in Apple model) so we never try to load a model
        // that isn't present.
        if let available = localModelService.catalog.first(where: { localModelService.isDownloaded($0.id) }) {
            return available.id
        }
        return defaultLocalModel.isEmpty ? "llama-3.2-3b" : defaultLocalModel
    }

    private func resolvedCloudModel(for provider: LLMProvider) -> String {
        let override = narrativeCloudModel.trimmingCharacters(in: .whitespaces)
        if !override.isEmpty { return override }
        if !defaultCloudModel.isEmpty { return defaultCloudModel }
        return provider.exampleModelID
    }

    private var resolvedLabel: String {
        guard let target = resolvedTarget else { return "Not configured" }
        if target.provider == "local" {
            return "On-Device · \(target.model)"
        }
        let name = LLMProvider(rawValue: target.provider)?.displayName ?? target.provider
        return "\(name) · \(target.model)"
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Parchment background
                if colorScheme == .dark {
                    Theme.narrativeBackgroundDark.ignoresSafeArea()
                } else {
                    Theme.narrativeBackground.ignoresSafeArea()
                }

                if let doc = document, !doc.content.isEmpty {
                    narrativePage(doc)
                } else {
                    emptyState
                }
            }
            .navigationTitle("My Story")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarItems }
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
            .sheet(isPresented: $showExport) {
                ShareSheet(items: exportItems)
            }
            .task {
                if needsRefresh, resolvedTarget != nil {
                    await generate()
                }
            }
        }
    }

    // MARK: - Narrative page

    @ViewBuilder
    private func narrativePage(_ doc: NarrativeDocument) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Error banner
                if let msg = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(msg)
                            .font(.caption)
                    }
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                // Generating spinner
                if isGenerating {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Revising your story…")
                            .font(Theme.narrativeFont(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                // Ornamental chapter rule
                chapterOrnament

                // Body text
                MarkdownText(doc.content)
                    .font(Theme.narrativeFont(size: 17))
                    .foregroundStyle(colorScheme == .dark
                                     ? Color(white: 0.9)
                                     : Color(white: 0.15))
                    .lineSpacing(5)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 12)

                Divider()
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)

                // Footer
                HStack {
                    Spacer()
                    VStack(spacing: 2) {
                        Text("Last written \(doc.updatedAt.formatted(date: .long, time: .omitted))")
                        Text("\(doc.sessionCount) session\(doc.sessionCount == 1 ? "" : "s") woven in")
                    }
                    .font(Theme.narrativeFont(size: 12))
                    .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
    }

    private var chapterOrnament: some View {
        HStack {
            Spacer()
            HStack(spacing: 12) {
                line
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.warmAccent.opacity(0.7))
                line
            }
            .frame(width: 160)
            Spacer()
        }
        .padding(.vertical, 20)
    }

    private var line: some View {
        Rectangle()
            .fill(Theme.warmAccent.opacity(0.4))
            .frame(height: 0.5)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        AnimatedEmptyState(
            icon: "book.closed.fill",
            title: isGenerating ? "Writing Your Story…" : "Your Story Begins Here",
            description: emptyDescription,
            iconColor: Theme.warmAccent
        ) {
            if isGenerating {
                ProgressView()
            } else if resolvedTarget == nil {
                Button("Open Settings") { showSettings = true }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.warmAccent)
            } else {
                VStack(spacing: 12) {
                    Button {
                        Task { await generate(manual: true) }
                    } label: {
                        Label("Generate Now", systemImage: "sparkles")
                            .font(Theme.roundedFont(size: 16))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.warmAccent)

                    Button("Generation settings…") { showSettings = true }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var emptyDescription: String {
        if let msg = errorMessage { return msg }
        if resolvedTarget == nil {
            return "Add an API key in Settings → Keys & Providers or download an on-device model, then generate your story."
        }
        return "Your story will grow here, beautifully, with every session. It is written as a single, living account — not a list of notes."
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                // Export button (only when content exists)
                if let doc = document, !doc.content.isEmpty {
                    Button {
                        Task { await prepareExport(doc) }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .accessibilityLabel("Export narrative")
                    }
                }

                // Options menu
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
            if produced {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else if manual && (document?.content.isEmpty ?? true) {
                errorMessage = "There's nothing to narrate yet. Have a conversation in the Chats tab first, then come back."
            }
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Export

    private func prepareExport(_ doc: NarrativeDocument) async {
        let service = NarrativeExportService()
        var items: [Any] = []
        if let md  = service.writeMarkdown(document: doc) { items.append(md) }
        if let pdf = service.writePDF(document: doc)      { items.append(pdf) }
        guard !items.isEmpty else {
            errorMessage = "Couldn't prepare the export files. Please try again."
            return
        }
        exportItems = items
        showExport  = true
    }
}

// MARK: - Narrative settings sheet

private struct NarrativeSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var narrativeProvider: String
    @Binding var narrativeCloudModel: String
    let localAvailable: Bool
    let cloudProviders: [LLMProvider]
    let resolvedLabel: String
    let defaultCloudModel: String

    private var usesCloud: Bool {
        if narrativeProvider == "local" { return false }
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
                        Text("Leave blank to use your default cloud model from Settings → Models.")
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
