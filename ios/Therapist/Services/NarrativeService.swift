import Foundation
import SwiftData

/// Builds and incrementally revises the user's single life narrative document.
///
/// There is always at most one `NarrativeDocument` in the store. Each call to
/// `buildIncremental` fetches (or creates) that document, collects all source
/// material newer than its `sourceWatermark`, and asks the LLM to rewrite the
/// document as one cohesive, comprehensive story integrating everything so far.
///
/// This "revise-in-place" strategy is incremental (only new material is
/// re-processed) while always producing a single, unified narrative rather than
/// a pile of disconnected per-session chapters.
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

    /// Builds or updates the single `NarrativeDocument`.
    ///
    /// - Parameters:
    ///   - context: The SwiftData `ModelContext` to read from and write to.
    ///   - provider: The LLM provider to use (`LLMProvider.rawValue`).
    ///   - model: The model identifier to use for the chosen provider.
    /// - Returns: `true` if the document was updated, `false` if there was no
    ///   new material to incorporate.
    @discardableResult
    func buildIncremental(context: ModelContext, provider: String, model: String) async throws -> Bool {
        // 1. Fetch or create the single document.
        let existing = try context.fetch(FetchDescriptor<NarrativeDocument>())
        let document: NarrativeDocument
        if let first = existing.first {
            document = first
        } else {
            document = NarrativeDocument()
            context.insert(document)
        }

        let watermark = document.sourceWatermark

        // 2. Collect sources newer than the watermark.
        let sessions = try context.fetch(FetchDescriptor<SessionModel>())
        var sources = collectSources(sessions: sessions, after: watermark, context: context)
        if sources.isEmpty {
            sources = collectConversationSources(sessions: sessions, after: watermark)
        }

        guard !sources.isEmpty else { return false }

        let latestSourceDate = sources.map(\.date).max() ?? Date()

        // 3. Build the LLM prompt.
        let sourceText = sources.map { "[\($0.kind)] \($0.text)" }.joined(separator: "\n\n")

        let latestSession = sessions
            .filter { !$0.messages.isEmpty }
            .sorted { $0.updatedAt > $1.updatedAt }
            .first
        let persona = latestSession.map { PersonaService.resolve(for: $0) }
        let systemPrompt = narrativeSystemPrompt(persona: persona)

        let userMessage: String
        if document.content.isEmpty {
            // First-ever generation — build from scratch.
            userMessage = """
            Here is a collection of insights, memories, and conversations from this person's \
            sessions. Weave them into a single cohesive narrative that reads like a compassionate \
            biographer's account of their inner life. Use the third person and past tense. \
            Organise with light Markdown section headings (## heading) where natural. \
            Be warm, specific, and true to the material — avoid generalities.

            Sources:
            \(sourceText)
            """
        } else {
            // Incremental revision — integrate new material into the existing story.
            userMessage = """
            Below is the person's existing life narrative, followed by new material from \
            recent sessions that has not yet been incorporated.

            Rewrite the narrative as ONE cohesive, comprehensive story that seamlessly \
            integrates the new material with everything that came before. Preserve all \
            existing detail and voice. Use the third person, past tense, and light Markdown \
            section headings (## heading) where natural. The result should read as a single, \
            unified account — not a concatenation.

            ## Existing narrative

            \(document.content)

            ## New material to integrate

            \(sourceText)
            """
        }

        // 4. Call the LLM.
        let rawResponse = try await LLMService.shared.sendMessage(
            provider: provider,
            model: model,
            messages: [
                LLMMessage(role: "system", content: systemPrompt),
                LLMMessage(role: "user",   content: userMessage),
            ]
        )

        // 5. Overwrite the document in place.
        document.content         = rawResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        document.sourceWatermark = latestSourceDate
        document.sessionCount    = sessions.filter { !$0.messages.isEmpty }.count
        document.updatedAt       = Date()
        try context.save()
        return true
    }

    // MARK: - Source gathering (high-signal artifacts)

    private struct Source {
        let date: Date
        let kind: String
        let text: String
    }

    private func collectSources(sessions: [SessionModel],
                                after watermark: Date,
                                context: ModelContext) -> [Source] {
        var sources: [Source] = []
        for session in sessions {
            for note in session.notes where note.createdAt > watermark {
                let snippet = note.content.isEmpty ? note.title : note.content
                sources.append(Source(date: note.createdAt, kind: "Note", text: snippet))
            }
            for dream in session.dreams where dream.createdAt > watermark {
                let text = dream.analysis.isEmpty ? dream.narrative : dream.analysis
                sources.append(Source(date: dream.createdAt, kind: "Dream", text: text))
            }
        }
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

    /// Fallback: gather raw conversation turns so chat-only history can be narrated.
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
        return turns.sorted { $0.date < $1.date }.suffix(maxTurns).map { $0 }
    }

    // MARK: - Prompt

    private func narrativeSystemPrompt(persona: Persona?) -> String {
        let personaName = persona?.displayName ?? "a compassionate therapist"
        return """
        You are narrating the story of a person's inner life as understood by \(personaName). \
        Your tone is warm, thoughtful, and literary — like a compassionate biographer who sees \
        the patterns and growth in this person's journey. Write about real feelings and real \
        growth. Never interpret beyond the evidence, but find the threads that connect events \
        into a meaningful arc. Use Markdown section headings (## heading) to organise the \
        narrative. Keep the language clear and accessible, not clinical. \
        Refer to the person as "they" — never by name.
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
