import Foundation

// MARK: - Availability helper (iOS 17-compatible)

/// Returns whether Apple Foundation Models are available on this device.
/// Safe to call from iOS 17+ code; returns `false` on older OSes or SDKs that
/// don't ship FoundationModels.
func appleFoundationModelAvailable() -> Bool {
    #if canImport(FoundationModels)
    if #available(iOS 26, *) {
        return AppleFoundationEngine.isAvailable
    }
    #endif
    return false
}

// MARK: - Engine (iOS 26+, FoundationModels SDK)

#if canImport(FoundationModels)
import FoundationModels

/// Wraps Apple's on-device Foundation Models framework (`FoundationModels`).
///
/// Only compiled when the FoundationModels SDK is present (Xcode 26+) and
/// only runs on iOS 26+. Each `generate` call creates a fresh
/// `LanguageModelSession` with the system prompt baked in as instructions,
/// then replays the conversation history and generates a response.
///
/// Apple Intelligence must be enabled on the device; if it is not, generation
/// throws `AppleFoundationError.unavailable` with a user-friendly message.
@available(iOS 26, *)
enum AppleFoundationEngine {

    // MARK: - Availability

    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    // MARK: - Status label (shown in the model picker UI)

    static var statusLabel: String {
        switch SystemLanguageModel.default.availability {
        case .available:
            return "Available"
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Apple Intelligence off"
        case .unavailable(.deviceNotEligible):
            return "Device not supported"
        case .unavailable(.modelNotReady):
            return "Model not ready"
        case .unavailable:
            return "Unavailable"
        @unknown default:
            return "Unavailable"
        }
    }

    // MARK: - Generation

    /// Generates a chat response using the on-device Apple Intelligence model.
    ///
    /// - Parameters:
    ///   - systemPrompt: Injected as the session's instruction set.
    ///   - messages: Full conversation history in `[LLMMessage]` format.
    /// - Returns: The assistant's reply as a plain string.
    /// - Throws: `AppleFoundationError.unavailable` if Apple Intelligence is off
    ///   or the device is ineligible; re-throws any generation error.
    static func generate(systemPrompt: String, messages: [LLMMessage]) async throws -> String {
        guard isAvailable else {
            throw AppleFoundationError.unavailable(statusLabel)
        }

        let instructionText = systemPrompt.isEmpty ? "You are a helpful assistant." : systemPrompt
        let session = LanguageModelSession(instructions: Instructions(instructionText))

        // Build a single prompt incorporating prior turns for context.
        let history = messages.filter { $0.role != "system" }
        var contextLines: [String] = []
        for msg in history.dropLast() {
            let label = msg.role == "user" ? "User" : "Assistant"
            contextLines.append("\(label): \(msg.content)")
        }

        let lastUserContent = history.last(where: { $0.role == "user" })?.content ?? ""
        let fullPrompt = contextLines.isEmpty
            ? lastUserContent
            : contextLines.joined(separator: "\n") + "\n\nUser: " + lastUserContent

        let response = try await session.respond(to: Prompt(fullPrompt))
        return response.content
    }
}

#else

// Stub so callers compile cleanly on SDKs without FoundationModels.
@available(iOS 26, *)
enum AppleFoundationEngine {
    static var isAvailable: Bool { false }
    static var statusLabel: String { "Requires Xcode 26+ SDK" }
    static func generate(systemPrompt: String, messages: [LLMMessage]) async throws -> String {
        throw AppleFoundationError.unavailable("FoundationModels framework not available in this build")
    }
}

#endif

// MARK: - Errors

enum AppleFoundationError: LocalizedError {
    case unavailable(String)

    var errorDescription: String? {
        switch self {
        case .unavailable(let reason):
            return "Apple Intelligence is not available on this device (\(reason)). Switch to a cloud model or download a GGUF model in Settings → Models."
        }
    }
}
