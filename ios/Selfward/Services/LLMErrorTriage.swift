import Foundation
import BYOKLLMKit

// MARK: - LLMErrorTriage

/// Pure helpers for classifying and retrying transient LLM API failures.
///
/// Kept out of `LLMService` so that actor file stays focused and so the
/// triage logic is independently testable — these functions carry no actor
/// state and are safe to call from any context.
enum LLMErrorTriage {
    /// Builds a user-facing error message from a failed response, with the
    /// literal API key redacted. Some providers echo a form of the submitted
    /// key back into auth-failure bodies, and this text is displayed
    /// directly in the UI — it must never carry the secret verbatim.
    nonisolated static func sanitizedErrorBody(_ data: Data, status: Int?, apiKey: String) -> String {
        var body = String(data: data, encoding: .utf8) ?? "Unknown error"
        if !apiKey.isEmpty {
            body = body.replacingOccurrences(of: apiKey, with: "[redacted]")
        }
        let statusText = status.map(String.init) ?? "unknown"
        return "HTTP \(statusText): \(body)"
    }

    /// Classifies a non-200 HTTP response into a structured `LLMError` so
    /// callers can react to the failure mode (rate limiting vs a prompt that
    /// outpaced the model's context window vs a generic API error) instead of
    /// swallowing every error the same way.
    nonisolated static func classifyHTTPFailure(status: Int?,
                                                retryAfter: String?,
                                                data: Data,
                                                apiKey: String) -> LLMError {
        let sanitized = sanitizedErrorBody(data, status: status, apiKey: apiKey)
        let lower = sanitized.lowercased()
        switch status {
        case 429, 529:
            // 429 = too many requests; 529 = model overloaded/building load
            // shedder (OpenRouter). Both are transient — safe to retry.
            return .rateLimited(retryAfter: retryAfter.flatMap(Double.init))
        case 400, 413:
            let contextHints = ["context length", "context_length", "maximum context",
                                "max context", "prompt is too long", "too many tokens",
                                "token limit", "context window", "exceeded"]
            if contextHints.contains(where: { lower.contains($0) }) {
                return .contextLengthExceeded
            }
            return .apiError(sanitized)
        default:
            return .apiError(sanitized)
        }
    }

    /// Re-runs `operation` when it throws `.rateLimited`, sleeping for the
    /// server's `Retry-After` (clamped to avoid stalling the client for an
    /// unreasonably long window) or a short default. Real HTTP timeouts and
    /// connection failures are *not* retried — only explicit rate-limit
    /// responses, which are unambiguous signals the upstream is temporarily
    /// saturated.
    static func retryTransient(maxAttempts: Int = 3,
                               operation: () async throws -> String) async throws -> String {
        var remaining = maxAttempts
        while true {
            do {
                return try await operation()
            } catch let error as LLMError {
                guard case .rateLimited(let retryAfter) = error, remaining > 1 else {
                    throw error
                }
                remaining -= 1
                let wait = min(retryAfter ?? 3.0, 15.0)
                try await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
            } catch {
                throw error
            }
        }
    }

    /// Whether `error` looks like a transient rate-limit / overload failure.
    /// `BYOKLLMKit` only surfaces the response body (no structured status), so
    /// this also pattern-matches on the sanitized body text.
    nonisolated static func isRateLimitLike(_ error: Error, apiKey: String = "") -> Bool {
        switch error {
        case let value as LLMError:
            if case .rateLimited = value { return true }
            guard case .apiError(let message) = value else { return false }
            return transientRateLimitHints(in: message, apiKey: apiKey)
        case let value as BYOKLLMKit.LLMError:
            guard case .apiError(let message) = value else { return false }
            return transientRateLimitHints(in: message, apiKey: apiKey)
        default:
            return false
        }
    }

    private nonisolated static func transientRateLimitHints(in message: String, apiKey: String) -> Bool {
        var text = message
        if !apiKey.isEmpty {
            text = text.replacingOccurrences(of: apiKey, with: "[redacted]")
        }
        let lower = text.lowercased()
        return lower.contains("429")
            || lower.contains("529")
            || lower.contains("too many requests")
            || lower.contains("rate limit")
            || lower.contains("overloaded")
    }
}
