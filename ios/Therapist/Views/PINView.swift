import SwiftUI

// MARK: - Mode

private enum PINMode {
    case setup            // first-time: choose a PIN
    case confirm(String)  // second step: re-enter to confirm
    case unlock           // subsequent launches: verify PIN
}

// MARK: - PINView

/// Shown as the app root when the user isn't yet authenticated.
/// Pass `forceSetup: true` from Settings to let the user change their PIN.
struct PINView: View {
    let onSuccess: () -> Void
    var forceSetup: Bool = false

    @State private var mode: PINMode
    @State private var entered  = ""
    @State private var shaking  = false
    @State private var errorMsg = ""

    private let length = 6

    init(onSuccess: @escaping () -> Void, forceSetup: Bool = false) {
        self.onSuccess  = onSuccess
        self.forceSetup = forceSetup
        _mode = State(initialValue: (forceSetup || !PINService.shared.isPINSetup) ? .setup : .unlock)
    }

    // MARK: Computed

    private var heading: String {
        switch mode {
        case .setup:   return forceSetup ? "Create new PIN" : "Create a PIN"
        case .confirm: return "Confirm your PIN"
        case .unlock:  return "Enter your PIN"
        }
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 56))
                .foregroundStyle(.tint)

            Text(heading)
                .font(.title2.bold())

            dotRow
                .modifier(ShakeEffect(active: shaking))

            if !errorMsg.isEmpty {
                Text(errorMsg)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
            }

            Spacer()

            numPad
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
        }
        .animation(.default, value: errorMsg)
    }

    // MARK: Sub-views

    private var dotRow: some View {
        HStack(spacing: 16) {
            ForEach(0..<length, id: \.self) { i in
                Circle()
                    .fill(i < entered.count ? Color.primary : Color.secondary.opacity(0.25))
                    .frame(width: 13, height: 13)
            }
        }
    }

    private var numPad: some View {
        VStack(spacing: 14) {
            ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(row, id: \.self) { n in
                        PINKey(label: "\(n)") { tap("\(n)") }
                    }
                }
            }
            HStack(spacing: 20) {
                Color.clear.frame(width: 76, height: 76)
                PINKey(label: "0") { tap("0") }
                PINKey(label: "delete.left", isSymbol: true, accent: true) {
                    guard !entered.isEmpty else { return }
                    entered.removeLast()
                    errorMsg = ""
                }
            }
        }
    }

    // MARK: Logic

    private func tap(_ digit: String) {
        guard entered.count < length else { return }
        entered.append(digit)
        errorMsg = ""
        if entered.count == length { commit() }
    }

    private func commit() {
        switch mode {
        case .setup:
            mode    = .confirm(entered)
            entered = ""

        case .confirm(let first):
            if entered == first {
                PINService.shared.save(entered)
                onSuccess()
            } else {
                bounce("PINs don't match — try again")
                mode = .setup
            }

        case .unlock:
            if PINService.shared.verify(entered) {
                onSuccess()
            } else {
                bounce("Incorrect PIN")
            }
        }
    }

    private func bounce(_ message: String) {
        entered  = ""
        errorMsg = message
        shaking  = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shaking = false }
    }
}

// MARK: - PINKey

private struct PINKey: View {
    let label: String
    var isSymbol = false
    var accent = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isSymbol {
                    Image(systemName: label)
                } else {
                    Text(label)
                }
            }
            .font(.title2.weight(.medium))
            .frame(width: 76, height: 76)
            .background(Color.secondary.opacity(0.12))
            .clipShape(Circle())
            .foregroundStyle(accent ? Color.red : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ShakeEffect

private struct ShakeEffect: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        content
            .offset(x: active ? -8 : 0)
            .animation(
                active
                    ? .easeInOut(duration: 0.06).repeatCount(5, autoreverses: true)
                    : .default,
                value: active
            )
    }
}
