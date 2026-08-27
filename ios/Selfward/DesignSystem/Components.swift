import SwiftUI
import UIKit

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

// MARK: - PersonaAvatar

/// A circular avatar for an AI persona. Prefers a bundled illustrated avatar
/// image; if the asset is missing it falls back to a gradient circle with the
/// persona's SF Symbol icon. Used in the Chats list, chat header, and anywhere
/// a persona identity needs a visual anchor.
struct PersonaAvatar: View {
    let kind: PersonaKind
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let image = UIImage(named: kind.avatarAssetName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Theme.personaColor(kind).opacity(0.25), lineWidth: 1)
                    )
            } else {
                ZStack {
                    Circle()
                        .fill(Theme.personaGradient(kind))
                        .frame(width: size, height: size)
                    Image(systemName: kind.icon)
                        .font(.system(size: size * 0.42, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - AnimatedEmptyState

/// An animated empty-state view with a pulsing SF Symbol icon, title, and
/// optional description and action button. Replaces the plain
/// `ContentUnavailableView` where extra visual character is needed.
struct AnimatedEmptyState<Actions: View>: View {
    let icon: String
    let title: String
    var description: String = ""
    var iconColor: Color = .secondary
    @ViewBuilder var actions: () -> Actions

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(iconColor.opacity(0.7))
                .scaleEffect(pulse ? 1.06 : 0.96)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                            value: pulse)
                .onAppear { pulse = true }

            VStack(spacing: 6) {
                Text(title)
                    .font(Theme.roundedFont(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                if !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            actions()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - GradientHeader

/// A decorative gradient strip with a title and optional subtitle.
/// Used at the top of the Narrative tab to give it a journal-header feel.
struct GradientHeader: View {
    let title: String
    var subtitle: String = ""
    var gradient: LinearGradient = LinearGradient(
        colors: [Color.teal.opacity(0.7), Color.teal.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(gradient)
                .ignoresSafeArea(edges: .top)
                .frame(height: subtitle.isEmpty ? 56 : 72)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.narrativeFont(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
}
