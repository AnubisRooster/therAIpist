import Foundation

class TherapyService {
    static let shared = TherapyService()

    func getSystemPrompt(modality: String, customPrompt: String = "") -> String {
        let basePrompt = modalityPrompts[modality] ?? modalityPrompts["integrated"]!
        if !customPrompt.isEmpty {
            return "\(basePrompt)\n\nAdditional instructions: \(customPrompt)"
        }
        return basePrompt
    }

    func buildMessages(modality: String, customPrompt: String, messageHistory: [(String, String)], userMessage: String, memoryContext: String) -> [LLMMessage] {
        var messages: [LLMMessage] = []

        let systemPrompt = getSystemPrompt(modality: modality, customPrompt: customPrompt)
        messages.append(LLMMessage(role: "system", content: systemPrompt))

        if !memoryContext.isEmpty {
            messages.append(LLMMessage(role: "system", content: "Relevant context from previous sessions:\n\(memoryContext)"))
        }

        for (role, content) in messageHistory.suffix(20) {
            messages.append(LLMMessage(role: role, content: content))
        }
        messages.append(LLMMessage(role: "user", content: userMessage))

        return messages
    }

    func suggestIntervention(modality: String, message: String) -> String? {
        switch modality {
        case "adlerian":
            if message.contains("family") || message.contains("parent") {
                return "Explore family constellation and birth order dynamics"
            }
            if message.contains("goal") || message.contains("purpose") {
                return "Examine fictional finalism and teleological orientation"
            }
            return nil
        case "jungian":
            if message.contains("dream") || message.contains("night") {
                return "Encourage dream journaling and active imagination"
            }
            if message.contains("angry") || message.contains("shadow") {
                return "Explore shadow integration through creative expression"
            }
            return nil
        case "dbt":
            if message.contains("overwhelm") || message.contains("stress") {
                return "Teach TIPP skill: Temperature, Intense exercise, Paced breathing, Paired muscle relaxation"
            }
            if message.contains("angry") || message.contains("upset") {
                return "Practice STOP skill: Stop, Take a step back, Observe, Proceed mindfully"
            }
            return nil
        default:
            return nil
        }
    }
}
