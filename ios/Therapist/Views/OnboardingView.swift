import SwiftUI

/// Multi-step first-launch onboarding: API key setup + intake survey.
/// Writes all values to AppStorage; sets `onboarding_complete = true` at the end.
struct OnboardingView: View {
    @AppStorage("openrouter_key")      private var openrouterKey      = ""
    @AppStorage("user_name")           private var userName           = ""
    @AppStorage("user_pronouns")       private var userPronouns       = ""
    @AppStorage("user_age")            private var userAge            = ""
    @AppStorage("intake_concerns")     private var intakeConcerns     = ""
    @AppStorage("intake_history")      private var intakeHistory      = ""
    @AppStorage("intake_goals")        private var intakeGoals        = ""
    @AppStorage("onboarding_complete") private var onboardingComplete = false

    @State private var step = 0
    @State private var showKeyLink = false

    // Total steps: 0=welcome, 1=api key, 2=name/pronouns/age,
    //              3=concerns, 4=history, 5=goals, 6=done
    private let totalSteps = 6

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                if step > 0 && step < totalSteps {
                    ProgressView(value: Double(step), total: Double(totalSteps - 1))
                        .tint(.teal)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                TabView(selection: $step) {
                    WelcomeStep().tag(0)
                    APIKeyStep(key: $openrouterKey).tag(1)
                    AboutYouStep(name: $userName, pronouns: $userPronouns, age: $userAge).tag(2)
                    ConcernsStep(concerns: $intakeConcerns).tag(3)
                    HistoryStep(history: $intakeHistory).tag(4)
                    GoalsStep(goals: $intakeGoals).tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)

                // Navigation buttons
                HStack {
                    if step > 0 {
                        Button("Back") { withAnimation { step -= 1 } }
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(step == totalSteps - 1 ? "Get Started" : "Continue") {
                        withAnimation {
                            if step == totalSteps - 1 {
                                onboardingComplete = true
                            } else {
                                step += 1
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    .disabled(step == 1 && openrouterKey.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 32)
                .padding(.top, 16)
            }
        }
    }
}

// MARK: - Step views

private struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 72))
                .foregroundStyle(.teal)
            Text("Welcome to therAIpist")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("A private, AI-assisted space to explore your thoughts and feelings.\n\nWe'll take a few minutes to get you set up.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            Text("Not a replacement for professional mental health care.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}

private struct APIKeyStep: View {
    @Binding var key: String
    @State private var isSecure = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StepHeader(icon: "key.fill", title: "Connect to OpenRouter",
                           subtitle: "therAIpist uses OpenRouter to access AI models. A free account gives you access to several free models.")

                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key").font(.subheadline.bold())
                    HStack {
                        Group {
                            if isSecure {
                                SecureField("sk-or-v1-...", text: $key)
                            } else {
                                TextField("sk-or-v1-...", text: $key)
                            }
                        }
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(.system(.body, design: .monospaced))

                        Button(action: { isSecure.toggle() }) {
                            Image(systemName: isSecure ? "eye" : "eye.slash")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                }

                Link(destination: URL(string: "https://openrouter.ai/keys")!) {
                    Label("Get a free API key at openrouter.ai", systemImage: "arrow.up.right.square")
                        .font(.subheadline)
                }

                Text("Your key is stored only on this device and never sent anywhere except OpenRouter.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(28)
        }
    }
}

private struct AboutYouStep: View {
    @Binding var name: String
    @Binding var pronouns: String
    @Binding var age: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StepHeader(icon: "person.fill", title: "A little about you",
                           subtitle: "This helps the AI personalise the conversation. All fields are optional.")

                LabeledField(label: "First name", placeholder: "e.g. Alex", text: $name)
                LabeledField(label: "Pronouns", placeholder: "e.g. she/her, he/him, they/them", text: $pronouns)
                LabeledField(label: "Age", placeholder: "e.g. 28", text: $age)
                    .keyboardType(.numberPad)
            }
            .padding(28)
        }
    }
}

private struct ConcernsStep: View {
    @Binding var concerns: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StepHeader(icon: "text.bubble.fill", title: "What brings you here?",
                           subtitle: "You might mention stress, relationships, anxiety, a life transition — whatever feels relevant. This is just for you.")

                TextEditor(text: $concerns)
                    .frame(minHeight: 160)
                    .padding(10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .font(.body)

                Text("You can always update this later in Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(28)
        }
    }
}

private struct HistoryStep: View {
    @Binding var history: String
    private let options = [
        "This is my first time",
        "I've tried therapy briefly",
        "I've had ongoing therapy",
        "I'm currently in therapy",
        "Prefer not to say",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StepHeader(icon: "clock.arrow.circlepath", title: "Any therapy background?",
                           subtitle: "Knowing your experience helps the AI calibrate its approach.")

                VStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: { history = option }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.primary)
                                Spacer()
                                if history == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.teal)
                                }
                            }
                            .padding(14)
                            .background(history == option
                                ? Color.teal.opacity(0.12)
                                : Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(28)
        }
    }
}

private struct GoalsStep: View {
    @Binding var goals: String
    private let suggestions = [
        "Manage anxiety or stress",
        "Process a difficult experience",
        "Improve relationships",
        "Build self-awareness",
        "Work through grief or loss",
        "Just have a space to think",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StepHeader(icon: "target", title: "What are your goals?",
                           subtitle: "Select any that resonate, or write your own.")

                FlowLayout(spacing: 8) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        let selected = goals.contains(suggestion)
                        Button(action: {
                            if selected {
                                goals = goals
                                    .components(separatedBy: ", ")
                                    .filter { $0 != suggestion }
                                    .joined(separator: ", ")
                            } else {
                                goals = goals.isEmpty ? suggestion : "\(goals), \(suggestion)"
                            }
                        }) {
                            Text(suggestion)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selected ? Color.teal : Color(.secondarySystemGroupedBackground))
                                .foregroundColor(selected ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }

                TextField("Or describe your own goals…", text: $goals, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
            }
            .padding(28)
        }
    }
}

// MARK: - Shared helpers

private struct StepHeader: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(.teal)
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

private struct LabeledField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline.bold())
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
        }
    }
}

/// Wraps children into multiple rows, similar to a CSS flexbox wrap.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                height += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
