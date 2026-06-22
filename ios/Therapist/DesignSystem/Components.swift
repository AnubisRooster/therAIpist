import SwiftUI

// MARK: - BadgePill

/// A small pill badge with an icon and label — used beneath assistant messages
/// to indicate captured memories, nodes, edges, dreams, and notes.
/// Previously private to ChatView; now shared so other views can reuse it.
struct BadgePill: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
        .accessibilityLabel(label)
    }
}

// MARK: - TagCapsule

/// A pill tag used in lists (model picker "FREE" tag, recommended model badge,
/// node-type labels, persona type labels, etc.). Replaces the 5+ ad-hoc
/// capsule-badge implementations that each file previously defined inline.
struct TagCapsule: View {
    let label: String
    let color: Color
    var prominent: Bool = false

    var body: some View {
        Text(label)
            .font(prominent ? .caption.weight(.semibold) : .caption2.weight(.medium))
            .padding(.horizontal, prominent ? 8 : 6)
            .padding(.vertical, prominent ? 4 : 2)
            .background(color.opacity(prominent ? 0.18 : 0.12), in: Capsule())
            .foregroundStyle(color)
            .accessibilityLabel(label)
    }
}

// MARK: - RoundedCorner

/// Clips a view to a rounded rectangle where only specified corners are rounded.
/// Used for asymmetric chat bubbles (user vs. assistant).
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
