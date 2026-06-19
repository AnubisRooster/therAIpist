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
        let lower = message.lowercased()
        switch modality {
        case "adlerian":
            if lower.contains("family") || lower.contains("parent") {
                return "Explore family constellation and birth order dynamics"
            }
            if lower.contains("goal") || lower.contains("purpose") {
                return "Examine fictional finalism and teleological orientation"
            }
            return nil
        case "jungian":
            if lower.contains("dream") || lower.contains("night") {
                return "Encourage dream journaling and active imagination"
            }
            if lower.contains("angry") || lower.contains("shadow") {
                return "Explore shadow integration through creative expression"
            }
            return nil
        case "dbt":
            if lower.contains("overwhelm") || lower.contains("stress") {
                return "Teach TIPP skill: Temperature, Intense exercise, Paced breathing, Paired muscle relaxation"
            }
            if lower.contains("angry") || lower.contains("upset") {
                return "Practice STOP skill: Stop, Take a step back, Observe, Proceed mindfully"
            }
            return nil
        case "free_form":
            if lower.contains("feel") || lower.contains("emotion") {
                return "Reflect the feeling and invite exploration — 'What is that feeling like for you?'"
            }
            return nil
        case "cbt":
            if lower.contains("always") || lower.contains("never") || lower.contains("should") {
                return "Explore cognitive distortion — identify the automatic thought and examine the evidence"
            }
            if lower.contains("anxious") || lower.contains("worry") {
                return "Use a thought record to capture the situation, automatic thought, and balanced alternative"
            }
            return nil
        case "humanistic":
            if lower.contains("should") || lower.contains("supposed to") {
                return "Explore conditions of worth — 'Where did you learn you should be that way?'"
            }
            return nil
        case "existential":
            if lower.contains("meaning") || lower.contains("purpose") || lower.contains("point") {
                return "Explore existential meaning — 'What gives your life a sense of purpose?'"
            }
            if lower.contains("death") || lower.contains("die") || lower.contains("mortal") {
                return "Explore death awareness — 'How does knowing life is finite affect how you live?'"
            }
            return nil
        case "gestalt":
            if lower.contains("it") || lower.contains("they") || lower.contains("people") {
                return "Invite present-moment awareness — 'Can you say that as I feel... or I notice...?'"
            }
            return nil
        case "somatic":
            if lower.contains("tense") || lower.contains("tight") || lower.contains("heavy") {
                return "Invite body awareness — 'Where in your body do you feel that? Just notice it without changing it.'"
            }
            return nil
        case "narrative":
            if lower.contains("problem") || lower.contains("issue") || lower.contains("struggle") {
                return "Externalize the problem — 'If this struggle had a name, what would you call it?'"
            }
            return nil
        case "act":
            if lower.contains("can't stop") || lower.contains("trying to") || lower.contains("fighting") {
                return "Introduce defusion — 'What would it be like to just notice that thought without fighting it?'"
            }
            return nil
        case "psychodynamic":
            if lower.contains("always") || lower.contains("again") || lower.contains("repeat") {
                return "Explore repetition compulsion — 'This sounds like a pattern you've experienced before. Where do you think it started?'"
            }
            return nil
        case "ifs":
            if lower.contains("part of me") || lower.contains("a part") {
                return "Turn toward the part — 'Can you get curious about that part? How do you feel toward it?'"
            }
            return nil
        default:
            return nil
        }
    }
}
