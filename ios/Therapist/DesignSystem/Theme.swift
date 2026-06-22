import SwiftUI

/// Single source of truth for all design tokens in therAIpist.
/// Use these instead of hardcoded colour literals or per-file switch statements.
enum Theme {

    // MARK: - Brand accent

    /// The global teal accent used throughout the app for interactive elements,
    /// voice-active states, and primary CTAs.
    static let accent: Color = .teal

    // MARK: - Modality colours

    /// Returns the accent colour for a given therapy modality identifier.
    /// Mirrors the per-file `modalityColor` switch that was previously duplicated
    /// in `ChatView`, `NewSessionView`, and `DashboardView`.
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
    /// Mirrors the RGB colours in graph.html's `typeColors` map so Swift UI and
    /// the Cytoscape canvas always agree.
    static func nodeColor(_ type: String) -> Color {
        switch type {
        case "person":  return Color(red: 0.29, green: 0.56, blue: 0.85)   // #4A90D9
        case "event":   return Color(red: 0.96, green: 0.65, blue: 0.14)   // #F5A623
        case "emotion": return Color(red: 0.82, green: 0.01, blue: 0.11)   // #D0021B
        case "belief":  return Color(red: 0.49, green: 0.83, blue: 0.13)   // #7ED321
        case "theme":   return Color(red: 0.61, green: 0.35, blue: 0.71)   // #9B59B6
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

    // MARK: - Chat bubble colours

    static let userBubbleBackground   = Color.blue.opacity(0.2)
    static let assistantBubbleBackground = Color.green.opacity(0.15)
}
