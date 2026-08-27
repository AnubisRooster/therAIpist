import Foundation
import SwiftData

/// One-time migration that retro-tags historical messages with capture badges
/// and creates the knowledge-graph edges + global memories that older builds
/// never generated.
///
/// v1 additions:
///   - graph edges (edge wiring was added later)
///   - global memories (the old promotion threshold almost never fired)
///   - per-turn badge counts on assistant messages
///
/// v2 additions (bumped flag):
///   - auto-detected dreams from historical user messages
///   - one auto "Session Summary" reflection note per session
///   - capturedDream / capturedNote flags on assistant messages
enum BadgeBackfillService {
    /// Bump this suffix when the backfill logic changes and needs to re-run.
    private static let flagKey = "badge_backfill_v2_done"

    static func runIfNeeded(context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: flagKey) else { return }

        let graph   = GraphService.shared
        let global  = GlobalMemoryService.shared
        let dreams  = DreamService.shared

        let fetch = FetchDescriptor<SessionModel>()
        guard let sessions = try? context.fetch(fetch) else { return }

        for session in sessions {
            let ordered = session.messages.sorted { $0.createdAt < $1.createdAt }

            // Labels already credited to an earlier turn so each node is
            // attributed to the first turn that introduced it.
            var attributedLabels = Set<String>()

            var i = 0
            while i < ordered.count {
                let msg = ordered[i]
                guard msg.role == "user" else { i += 1; continue }

                let userText = msg.content

                // ── Node attribution (nodes already exist; credit first sighting)
                let extraction = graph.analyzeMessage(userText)
                let existingLabels = Set(session.graphNodes.map { $0.label })
                var newNodeCount = 0
                for spec in extraction.nodes where existingLabels.contains(spec.label) {
                    if !attributedLabels.contains(spec.label) {
                        attributedLabels.insert(spec.label)
                        newNodeCount += 1
                    }
                }

                // ── Edge creation (missing on old data)
                let edgesBefore = Set(session.graphNodes.flatMap(\.outgoingEdges).map(\.id))
                graph.extractEntitiesFromMessage(session: session, message: userText, context: context)
                let newEdgeCount = session.graphNodes
                    .flatMap(\.outgoingEdges)
                    .filter { !edgesBefore.contains($0.id) }
                    .count

                // ── Dream detection (new in v2)
                var dreamCaptured = false
                if let dreamCandidate = InsightCaptureService.detectDream(in: userText) {
                    // Only create a dream if one with the same narrative doesn't
                    // already exist (the user may have manually added it before).
                    let alreadyExists = session.dreams.contains {
                        $0.narrative.prefix(100) == dreamCandidate.narrative.prefix(100)
                    }
                    if !alreadyExists {
                        dreams.recordDream(
                            session: session,
                            narrative: dreamCandidate.narrative,
                            feelings: dreamCandidate.feelings,
                            symbols: dreamCandidate.symbols,
                            context: context
                        )
                        dreamCaptured = true
                    }
                }

                // ── Pair with the following assistant message (if any)
                if i + 1 < ordered.count && ordered[i + 1].role == "assistant" {
                    let assistant = ordered[i + 1]

                    let promoted = global.promoteIfValuable(
                        userMessage: userText,
                        assistantResponse: assistant.content,
                        sessionID: session.id,
                        context: context
                    )

                    assistant.capturedNodeCount    = newNodeCount
                    assistant.capturedEdgeCount    = newEdgeCount
                    // recordExchange historically stored exactly one episodic
                    // memory per completed exchange.
                    assistant.capturedMemoryCount  = 1
                    assistant.capturedGlobalMemory = promoted != nil
                    if dreamCaptured { assistant.capturedDream = true }

                    i += 2
                } else {
                    i += 1
                }
            }

            // ── Summary note (one per session, new in v2)
            if InsightCaptureService.existingSummaryNote(for: session) == nil,
               let summary = InsightCaptureService.summaryNote(for: session) {
                let note = NoteModel(session: session, type: "reflection",
                                     title: summary.title, content: summary.content)
                note.structuredData = InsightCaptureService.summaryNoteMarker
                context.insert(note)

                // Badge the last assistant message with capturedNote.
                if let lastAssistant = ordered.last(where: { $0.role == "assistant" }) {
                    lastAssistant.capturedNote = true
                }
            }
        }

        do {
            try context.save()
            defaults.set(true, forKey: flagKey)
        } catch {
            // Leave the flag unset so the backfill retries on the next launch.
        }
    }
}
