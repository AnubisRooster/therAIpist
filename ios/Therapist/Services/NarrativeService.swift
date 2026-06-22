import Foundation
import SwiftData

/// Builds and incrementally updates the user's life narrative.
///
/// The service gathers the highest-signal sources in chronological order —
/// session summary notes, plain-language insight highlights, global memories,
/// and dreams — then asks the active LLM to write a short story-form chapter
/// covering only material newer than the last watermark. This keeps each run
/// cheap even with a large history.
actor NarrativeService {
    static let shared = NarrativeService()

    // MARK: - Public API

    /// Back-compat convenience that resolves the provider/model from the stored
    /// defaults based on a simple cloud/local choice.
    @discardableResult
    func buildIncremental(context: ModelContext, useCloud: Bool) async throws -> Bool {
        let provider = useCloud ? resolvedCloudProvider() : "local"
        let model    = useCloud ? resolvedCloudModel()    : resolvedLocalModel()
        return try await buildIncremental(context: context, provider: provider, model: model)
    }

    /// Processes all material newer than the most-recent chapter's watermark
    /// and, if any exists, appends a new `NarrativeChapter` to the store.
    ///
    /// - Parameters:
    ///   - context: The SwiftData `ModelContext` to read sessions from and insert the new chapter into.
    ///   - provider: The LLM provider to use (`LLMProvider.rawValue`, e.g. "openrouter", "anthropic", or "local").
    ///   - model: The model identifier to use for the chosen provider.
    /// - Returns: `true` if a new chapter was generated, `false` if there was
    ///   nothing new to narrate.
    @discardableResult
    func buildIncremental(context: ModelContext, provider: String, model: String) async throws -> Bool {
        // 1. Determine the watermark — the latest source timestamp already covered.
        let existingChapters = try context.fetch(
            FetchDescriptor<NarrativeChapter>(sortBy: [SortDescriptor(\.sourceWatermark, order: .reverse)])
        )
        let watermark: Date = existingChapters.first?.sourceWatermark ?? .distantPast

        // 2. Collect sources newer than the watermark. Prefer high-signal
        //    artifacts (notes/dreams/insights); if none exist yet, fall back to
        //    the raw conversation transcript so any chat history can be narrated.
        let sessions = try context.fetch(FetchDescriptor<SessionModel>())
        var sources = collectSources(sessions: sessions, after: watermark, context: context)
        if sources.isEmpty {
            sources = collectConversationSources(sessions: sessions, after: watermark)
        }

        guard !sources.isEmpty else { return false } // Nothing new to narrate.

        let latestSourceDate = sources.map(\.date).max() ?? Date()

        // 3. Determine persona attribution from the most-recent session.
        let latestSession = sessions
            .filter { !$0.messages.isEmpty }
            .sorted { $0.updatedAt > $1.updatedAt }
            .first
        let persona = latestSession.map { PersonaService.resolve(for: $0) }
        let personaLabel = persona?.displayName ?? "Therapist"

        // 4. Build the LLM prompt.
        let sourceText = sources.map { "[\($0.kind)] \($0.text)" }.joined(separator: "\n\n")
        let systemPrompt = narrativeSystemPrompt(persona: persona)
        let userMessage = """
        Here is a collection of recent insights, memories, and events from this person's \
        sessions. Weave them into 2–4 cohesive paragraphs of flowing, story-form prose \
        that reads like a compassionate biographer recounting recent chapters of their life. \
        Write in the third person, past tense. Give the chapter a brief, evocative title \
        on the first line (title only, no "Chapter" prefix). Be warm and specific — use \
        the person's actual experiences, not generalities.

        Sources:
        \(sourceText)
        """

        // 5. Call the LLM with the caller-chosen provider/model.
        let rawResponse = try await LLMService.shared.sendMessage(
            provider: provider,
            model: model,
            messages: [
                LLMMessage(role: "system", content: systemPrompt),
                LLMMessage(role: "user", content: userMessage),
            ]
        )

        // 6. Parse title from the first line.
        let lines = rawResponse.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
        let title   = lines.first.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""
        let content = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        // 7. Insert the new chapter.
        let chapter = NarrativeChapter(
            personaLabel: personaLabel,
            title: title,
            content: content.isEmpty ? rawResponse : content,
            sourceWatermark: latestSourceDate
        )
        context.insert(chapter)
        try context.save()
        return true
    }

    // MARK: - Source gathering

    private struct Source {
        let date: Date
        let kind: String
        let text: String
    }

    private func collectSources(sessions: [SessionModel], after watermark: Date, context: ModelContext) -> [Source] {
        var sources: [Source] = []

        for session in sessions {
            // Session summary notes (InsightCaptureService summaries).
            for note in session.notes where note.createdAt > watermark {
                let snippet = note.content.isEmpty ? note.title : note.content
                sources.append(Source(date: note.createdAt, kind: "Note", text: snippet))
            }
            // Dreams.
            for dream in session.dreams where dream.createdAt > watermark {
                let text = dream.analysis.isEmpty ? dream.narrative : dream.analysis
                sources.append(Source(date: dream.createdAt, kind: "Dream", text: text))
            }
        }

        // Global memories (promoted cross-session insights).
        if let globalMems = try? context.fetch(
            FetchDescriptor<GlobalMemoryModel>(
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
        ) {
            for mem in globalMems where mem.createdAt > watermark {
                sources.append(Source(date: mem.createdAt, kind: "Insight", text: mem.content))
            }
        }

        return sources.sorted { $0.date < $1.date }
    }

    /// Fallback: gather raw conversation turns newer than the watermark so a
    /// narrative can be produced from chat history alone. Capped to the most
    /// recent turns to keep the prompt (and cost) bounded.
    private func collectConversationSources(sessions: [SessionModel], after watermark: Date) -> [Source] {
        let maxTurns = 60
        let maxChars = 600

        var turns: [Source] = []
        for session in sessions {
            for message in session.messages where message.createdAt > watermark {
                let trimmed = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                let snippet = trimmed.count > maxChars ? String(trimmed.prefix(maxChars)) + "…" : trimmed
                let kind = message.role == "user" ? "You said" : "Reflection"
                turns.append(Source(date: message.createdAt, kind: kind, text: snippet))
            }
        }

        // Keep the most recent turns, then restore chronological order.
        return turns
            .sorted { $0.date < $1.date }
            .suffix(maxTurns)
            .map { $0 }
    }

    // MARK: - Prompt

    private func narrativeSystemPrompt(persona: Persona?) -> String {
        let personaName = persona?.displayName ?? "a compassionate therapist"
        return """
        You are narrating the story of a person's inner life as understood by \(personaName). \
        Your tone is warm, thoughtful, and literary — like a compassionate biographer. \
        You write about real feelings and real growth. You never interpret beyond the evidence, \
        but you find the threads that connect events into a meaningful arc. \
        You protect the person's privacy: use "the person" or implied "they", never their name. \
        Keep each chapter to 2–4 paragraphs.
        """
    }

    // MARK: - Provider resolution helpers

    private func resolvedCloudProvider() -> String {
        UserDefaults.standard.string(forKey: "default_provider") ?? "openrouter"
    }

    private func resolvedCloudModel() -> String {
        UserDefaults.standard.string(forKey: "default_model") ?? "meta-llama/llama-3.2-1b-instruct:free"
    }

    private func resolvedLocalModel() -> String {
        UserDefaults.standard.string(forKey: "default_local_model") ?? "llama-3.2-3b"
    }
}
