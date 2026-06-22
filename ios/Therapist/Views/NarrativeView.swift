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
    @AppStorage("narrative_last_build") private var lastBuildTimestamp: Double = 0
    @AppStorage("narrative_use_cloud") private var useCloud = false

    private var needsRefresh: Bool {
        let elapsed = Date().timeIntervalSince1970 - lastBuildTimestamp
        return elapsed > 3600 // 1 hour
    }

    /// Whether at least one on-device model is downloaded.
    private var localAvailable: Bool {
        localModelService.catalog.contains { localModelService.isDownloaded($0.id) }
    }

    /// Whether at least one cloud provider has a key configured.
    private var cloudAvailable: Bool {
        LLMProvider.allCases.contains { $0.baseURL != nil && KeychainService.shared.hasKey(for: $0) }
    }

    /// The generation method to actually use, honoring the toggle but falling
    /// back to whichever is available. `nil` means neither is configured.
    private var effectiveUseCloud: Bool? {
        switch (localAvailable, cloudAvailable) {
        case (true, true):   return useCloud
        case (true, false):  return false
        case (false, true):  return true
        case (false, false): return nil
        }
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
                        Toggle("Generate with cloud model", isOn: $useCloud)
                            .disabled(!cloudAvailable)
                        Button {
                            Task { await generate() }
                        } label: {
                            Label("Refresh now", systemImage: "arrow.clockwise")
                        }
                        .disabled(isGenerating)
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
            .task {
                // Only auto-build when a generation method is configured, so a
                // cloud-only or fresh user isn't hit with errors on every launch.
                if needsRefresh, effectiveUseCloud != nil {
                    await generate()
                }
            }
        }
    }

    // MARK: - Sub-views

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Narrative Yet", systemImage: "book.pages")
        } description: {
            if effectiveUseCloud == nil {
                Text("Add an API key in Settings → Keys & Providers or download an on-device model, then generate your story here.")
            } else {
                Text("Your story will appear here after your first session. It updates automatically and grows with you over time.")
            }
        } actions: {
            Button("Generate Now") {
                Task { await generate() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isGenerating || effectiveUseCloud == nil)
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

    private func generate() async {
        guard !isGenerating else { return }
        guard let useCloudEffective = effectiveUseCloud else {
            errorMessage = "No generation method is configured. Add an API key in Settings → Keys & Providers, or download an on-device model."
            return
        }
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            try await NarrativeService.shared.buildIncremental(context: context, useCloud: useCloudEffective)
            lastBuildTimestamp = Date().timeIntervalSince1970
        } catch {
            errorMessage = error.localizedDescription
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
