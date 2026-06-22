import SwiftUI

/// Single source of truth for all design tokens in therAIpist.
/// Use these instead of hardcoded colour literals or per-file switch statements.
enum Theme {

    // MARK: - Brand accent

    /// The global teal accent used throughout the app for interactive elements,
    /// voice-active states, and primary CTAs.
    static let accent: Color = .teal

    /// Warm amber used for narrative/journal elements and secondary highlights.
    static let warmAccent: Color = Color(red: 0.85, green: 0.60, blue: 0.20)

    // MARK: - Typography

    /// Serif font for narrative body text and long-form reading.
    static func narrativeFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// Rounded font for chrome elements (tab labels, capsule labels).
    static func roundedFont(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    // MARK: - Narrative / journal colours

    /// Subtle warm gradient used as the background of the Narrative page.
    static var narrativeBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.96, blue: 0.91),
                Color(red: 0.95, green: 0.91, blue: 0.84),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Dark counterpart for narrative background (used in dark mode).
    static var narrativeBackgroundDark: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.14, green: 0.12, blue: 0.10),
                Color(red: 0.11, green: 0.09, blue: 0.07),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Modality colours

    /// Returns the accent colour for a given therapy modality identifier.
    static func modalityColor(_ modality: String) -> Color {
        switch modality {
        case "adlerian":      return .blue
        case "jungian":       return .purple
        case "dbt":           return .green
        case "integrated":    return .orange
        case "free_form":     return .teal
        case "cbt":           return .indigo
        case "humanistic":    return .pink
        case "existential":   return .gray
        case "gestalt":       return .yellow
        case "somatic":       return .mint
        case "narrative":     return .brown
        case "act":           return .cyan
        case "psychodynamic": return .red
        case "ifs":           return .primary
        default:              return .secondary
        }
    }

    // MARK: - Graph node-type colours

    /// Returns the colour for a knowledge-graph node type.
    static func nodeColor(_ type: String) -> Color {
        switch type {
        case "person":  return Color(red: 0.29, green: 0.56, blue: 0.85)
        case "event":   return Color(red: 0.96, green: 0.65, blue: 0.14)
        case "emotion": return Color(red: 0.82, green: 0.01, blue: 0.11)
        case "belief":  return Color(red: 0.49, green: 0.83, blue: 0.13)
        case "theme":   return Color(red: 0.61, green: 0.35, blue: 0.71)
        default:        return .gray
        }
    }

    // MARK: - Persona colours

    /// Returns the tint colour for a given `PersonaKind`.
    static func personaColor(_ kind: PersonaKind) -> Color {
        switch kind {
        case .therapist: return .teal
        case .companion: return .pink
        case .spiritual: return .indigo
        }
    }

    /// Gradient for a persona avatar background circle.
    static func personaGradient(_ kind: PersonaKind) -> LinearGradient {
        switch kind {
        case .therapist:
            return LinearGradient(colors: [Color.teal.opacity(0.8), Color.teal],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .companion:
            return LinearGradient(colors: [Color.pink.opacity(0.7), Color.purple.opacity(0.8)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .spiritual:
            return LinearGradient(colors: [Color.indigo.opacity(0.7), Color(red: 0.5, green: 0.2, blue: 0.8)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    // MARK: - Chat bubble colours

    static let userBubbleBackground      = Color.blue.opacity(0.2)
    static let assistantBubbleBackground = Color.green.opacity(0.15)
}
