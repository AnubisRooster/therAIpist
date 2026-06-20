import Foundation
import SwiftData

/// One-time migration that retro-tags historical messages with capture badges
/// and creates the knowledge-graph edges + global memories that older builds
/// never generated.
///
/// Older conversations have:
///   - graph **nodes** (created at the time, deduped by label)
///   - episodic **memories** (one per exchange via recordExchange)
/// but were missing:
///   - graph **edges** (edge wiring was added later)
///   - **global memories** (the old promotion threshold almost never fired)
/// and none of their messages carry per-turn badge counts.
///
/// This pass walks every session chronologically and, for each user→assistant
/// exchange, attributes node "first sightings", creates the missing edges, runs
/// global-memory promotion, and stamps the assistant message so the chat bubbles
/// show the same badges new messages get.
enum BadgeBackfillService {
    /// Bump this suffix if the backfill logic changes and needs to re-run.
    private static let flagKey = "badge_backfill_v1_done"

    static func runIfNeeded(context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: flagKey) else { return }

        let graph  = GraphService.shared
        let global = GlobalMemoryService.shared

        // Include archived sessions too.
        let fetch = FetchDescriptor<SessionModel>()
        guard let sessions = try? context.fetch(fetch) else { return }

        for session in sessions {
            let ordered = session.messages.sorted { $0.createdAt < $1.createdAt }

            // Labels already attributed to an earlier message in this session,
            // so each node is credited to the first turn that introduced it.
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

                // ── Edge creation (missing on old data) + count newly created
                let edgesBefore = Set(session.graphNodes.flatMap(\.outgoingEdges).map(\.id))
                graph.extractEntitiesFromMessage(session: session, message: userText, context: context)
                let newEdgeCount = session.graphNodes
                    .flatMap(\.outgoingEdges)
                    .filter { !edgesBefore.contains($0.id) }
                    .count

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

                    i += 2
                } else {
                    i += 1
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
