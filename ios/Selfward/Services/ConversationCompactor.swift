import Foundation

// MARK: - ConversationCompactor

/// Token-aware conversation budgeting plus a rolling-summary compactor.
///
/// The on-device engine (`LLM.swift` → llama.cpp) re-evaluates the *entire*
/// prompt from position 0 on every turn and offers no KV-cache reuse, so the
/// only way to keep a long, coherent conversation inside a small context
/// window is to control what gets sent: a distilled rolling summary of the
/// older turns (generated lazily once, then reused) plus the most recent turns
/// verbatim. Cloud providers get a large token budget instead, so their big
/// context windows stop being wasted on a blanket "last 10 messages" trim.
@MainActor
final class ConversationCompactor {
    static let shared = ConversationCompactor()

    /// Fallback context window for cloud models whose `context_length` isn't in
    /// the local model catalogue yet (OpenRouter serves a wide range).
    nonisolated static let defaultCloudContextLength = 32_000

    /// Never spend more than this many history tokens on a cloud model — large
    /// enough for any therapy conversation, small enough to keep cost and
    /// prefill latency sane even on 128k-window models.
    nonisolated static let maxHistoryTokens = 20_000

    /// Share of the context window we're willing to spend on message history,
    /// leaving the rest for the system/memory prompt, the in-flight summary,
    /// and the model's own reply.
    nonisolated static let historyBudgetFraction = 0.6

    /// Reserved space (as a fraction of the budget) for the rolling summary.
    nonisolated static let summaryBudgetFraction = 0.25

    /// Minimum size (estimated tokens) a block of not-yet-summarized turns
    /// must reach before we spend a model call summarizing it. Without this
    /// floor, once a long local conversation crosses the compaction
    /// threshold, every single subsequent turn pays for a second full model
    /// generation just to fold in one new exchange — on-device that means
    /// running the (possibly large) chat model twice per message, which is
    /// what made long local conversations slow. Below this floor, pending
    /// turns simply ride along verbatim in the budget-trimmed recent window
    /// until enough accumulate to summarize in one batch.
    nonisolated static let minSummarizationBlockTokens = 600

    /// Hard ceiling (estimated tokens) the rolling summary is allowed to
    /// reach, enforced in code rather than trusted to the summarizer's
    /// prompt instruction alone — an LLM asked to stay "under 150 words"
    /// won't always obey exactly, and the summary is re-condensed (old
    /// summary + new material) every time it regenerates, so a small
    /// overshoot could compound across many cycles in a long-running
    /// conversation. ~150 words plus headroom.
    nonisolated static let maxSummaryTokens = 220

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Token estimation

    /// Rough token estimate that mirrors the app's existing charset/4 heuristic
    /// (see ChatService's `tokenCount`). Under-estimates for non-Latin text but
    /// is consistent and cheap.
    nonisolated static func estimatedTokens(_ text: String) -> Int {
        max(0, text.count / 4)
    }

    nonisolated static func estimatedTokens(_ messages: [(String, String)]) -> Int {
        messages.reduce(0) { $0 + estimatedTokens($1.0) + estimatedTokens($1.1) }
    }

    // MARK: - Budgeting

    /// How many history tokens we allow for `provider`.
    /// - `localContextWindow`: the on-device window (RAM-scaled `n_ctx`); pass
    ///   `LocalLLMEngine.contextWindow()` for the local provider.
    nonisolated static func historyTokenBudget(provider: String,
                                               knownContextLength: Int?,
                                               localContextWindow: Int? = nil) -> Int {
        let window: Int
        if provider == "local" {
            window = localContextWindow ?? defaultCloudContextLength
        } else if let known = knownContextLength, known > 0 {
            window = known
        } else {
            window = defaultCloudContextLength
        }
        let budget = Int(Double(window) * historyBudgetFraction)
        if provider == "local" {
            return max(budget, 512)
        }
        return min(budget, maxHistoryTokens)
    }

    /// Local-only history budget that accounts for the actual cost of
    /// everything else sharing the same prompt — the system prompt, recalled
    /// memories, and the current message — instead of assuming a fixed
    /// fraction of the window is always enough room. Also reserves space for
    /// the rolling summary (capped by `maxSummaryTokens`) whether or not one
    /// exists yet, and a floor for the model's own reply.
    ///
    /// Cloud keeps the simpler `historyTokenBudget` above: its windows are
    /// large enough that this same fixed overhead is a rounding error by
    /// comparison, and it never uses a rolling summary.
    nonisolated static func localHistoryBudget(maxWindow: Int,
                                               systemPrompt: String,
                                               memoryContext: String,
                                               userMessage: String) -> Int {
        let overhead = estimatedTokens(systemPrompt) + estimatedTokens(memoryContext)
            + estimatedTokens(userMessage) + maxSummaryTokens
        let replyReserve = max(maxWindow / 8, 128)
        return max(maxWindow - overhead - replyReserve, 256)
    }

    /// Truncates `text` to approximately `maxTokens` (using the same char/4
    /// estimate used throughout this file), cutting at the nearest preceding
    /// word boundary so it doesn't end mid-word.
    nonisolated static func capped(_ text: String, toApproxTokens maxTokens: Int) -> String {
        let maxChars = maxTokens * 4
        guard text.count > maxChars else { return text }
        let cutoff = text.index(text.startIndex, offsetBy: maxChars)
        let prefix = String(text[..<cutoff])
        guard let lastSpace = prefix.range(of: " ", options: .backwards) else { return prefix }
        return String(prefix[..<lastSpace.lowerBound])
    }

    // MARK: - Retention

    /// Keeps the newest messages of `history` that fit `budget`, always keeping
    /// at least the most recent turn — and up to `minimumKeep` recent turns even
    /// if they slightly exceed the budget, so a couple of long late messages
    /// can't erase all recency.
    nonisolated static func retainedHistory(_ history: [(String, String)],
                                            budget: Int,
                                            minimumKeep: Int = 3) -> [(String, String)] {
        guard !history.isEmpty else { return [] }
        var kept: [(String, String)] = []
        var used = 0
        for message in history.reversed() {
            let cost = estimatedTokens(message.0) + estimatedTokens(message.1)
            let fits = kept.isEmpty || used + cost <= budget
            if fits {
                kept.append(message)
                used += cost
            } else if kept.count < minimumKeep {
                kept.append(message)
                used += cost
            } else {
                break
            }
        }
        return kept.reversed()
    }

    // MARK: - Rolling summary

    private struct StoredState: Codable {
        var coveredCount: Int
        var summary: String
        var updatedAt: Date
    }

    private nonisolated static let keyPrefix = "conversation_summary_v1_"

    /// Compacts `messages` (ascending chronological `(role, content)` pairs) so
    /// what we send the model stays inside `budget`: the most recent
    /// `minimumRecentTurns` are kept verbatim and everything older is folded
    /// into a rolling summary. The summary is generated lazily via `summarizer`
    /// — at most once per newly-accumulated block of old turns — and cached per
    /// session, so a long local conversation is compacted without paying a
    /// summarization cost on every single turn.
    ///
    /// Returns `nil` when nothing needs compacting (either everything already
    /// fits, or the summarizer failed and the caller should fall back to plain
    /// truncation).
    func compact(messages: [(String, String)],
                 sessionID: String,
                 budget: Int,
                 minimumRecentTurns: Int,
                 summarizer: (String) async throws -> String)
        async throws -> (summary: String, recent: [(String, String)])? {
        guard messages.count > minimumRecentTurns else { return nil }
        guard Self.estimatedTokens(messages) > budget else { return nil }

        // Recent turns we keep verbatim, sized to leave room for the summary.
        let recentBudget = max(Int(Double(budget) * (1 - Self.summaryBudgetFraction)), 512)
        let recentStart = messages.count - minimumRecentTurns
        var recent = Self.retainedHistory(Array(messages[recentStart...]),
                                          budget: recentBudget,
                                          minimumKeep: 2)
        let summarizedCount = messages.count - recent.count

        // Nothing old enough to summarize — just truncate to the budget.
        guard summarizedCount > 0 else { return nil }

        let existing = load(sessionID: sessionID)
        let coveredCount = existing?.coveredCount ?? 0

        // Turns older than the verbatim window that aren't covered by an
        // earlier summary yet — this is what summarizer must absorb now.
        var newBlock: [(String, String)] = []
        if coveredCount < summarizedCount {
            newBlock = Array(messages[coveredCount..<summarizedCount])
        }

        if newBlock.isEmpty, let existing, !existing.summary.isEmpty {
            // Nothing new to fold in — reuse the cached summary untouched.
            store(coveredCount: summarizedCount, summary: existing.summary, sessionID: sessionID)
            return (existing.summary, recent)
        }

        // Not enough new material yet to justify another model call: fold the
        // pending block into the verbatim window instead (still budget-
        // trimmed) and keep accumulating. `coveredCount` is deliberately left
        // untouched so this same block — plus whatever comes next — is what
        // eventually gets summarized once it crosses the threshold.
        if Self.estimatedTokens(newBlock) < Self.minSummarizationBlockTokens {
            guard let existing, !existing.summary.isEmpty else { return nil }
            let combined = Self.retainedHistory(newBlock + recent, budget: recentBudget, minimumKeep: 2)
            return (existing.summary, combined)
        }

        var parts: [String] = []
        if let existing, !existing.summary.isEmpty {
            parts.append("Earlier summary:\n\(existing.summary)")
        }
        parts.append(Self.formatBlock(newBlock))
        let rawSummary = try await summarizer(parts.joined(separator: "\n\n"))
        let newSummary = Self.capped(rawSummary, toApproxTokens: Self.maxSummaryTokens)

        store(coveredCount: summarizedCount, summary: newSummary, sessionID: sessionID)
        return (newSummary, recent)
    }

    /// Deletes any stored rolling summary for `sessionID` (e.g. when a session
    /// is deleted).
    func reset(sessionID: String) {
        defaults.removeObject(forKey: Self.keyPrefix + sessionID)
    }

    /// Formats `(role, content)` pairs as a compact, skimmable transcript for
    /// the summarizer.
    nonisolated static func formatBlock(_ messages: [(String, String)]) -> String {
        messages.map { "\(Self.speakerLabel($0.0)): \($0.1)" }.joined(separator: "\n")
    }

    private nonisolated static func speakerLabel(_ role: String) -> String {
        role == "user" ? "Client" : "Therapist"
    }

    // MARK: - Storage

    private func load(sessionID: String) -> StoredState? {
        guard let data = defaults.data(forKey: Self.keyPrefix + sessionID),
              let state = try? JSONDecoder().decode(StoredState.self, from: data) else { return nil }
        return state
    }

    private func store(coveredCount: Int, summary: String, sessionID: String) {
        let state = StoredState(coveredCount: coveredCount, summary: summary, updatedAt: Date())
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: Self.keyPrefix + sessionID)
        }
    }
}
