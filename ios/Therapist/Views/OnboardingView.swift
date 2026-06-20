import SwiftUI

/// Multi-step first-launch onboarding.
/// Steps: 0=welcome, 1=disclaimer, 2=api key, 3=on-device models,
///        4=about you, 5=concerns, 6=history, 7=goals
struct OnboardingView: View {
    @AppStorage("openrouter_key")      private var openrouterKey      = ""
    @AppStorage("user_name")           private var userName           = ""
    @AppStorage("user_pronouns")       private var userPronouns       = ""
    @AppStorage("user_age")            private var userAge            = ""
    @AppStorage("intake_concerns")     private var intakeConcerns     = ""
    @AppStorage("intake_history")      private var intakeHistory      = ""
    @AppStorage("intake_goals")        private var intakeGoals        = ""
    @AppStorage("onboarding_complete") private var onboardingComplete = false

    @State private var step                    = 0
    @State private var disclaimerAcknowledged  = false

    private let totalSteps = 8   // indices 0–7

    /// "Continue" is disabled when:
    ///  - step 1 (disclaimer) and user hasn't ticked the checkbox, OR
    ///  - step 2 (api key) and the key is empty AND the user hasn't explicitly skipped
    ///    (we allow skip so local-only users aren't blocked)
    private var continueDisabled: Bool {
        switch step {
        case 1: return !disclaimerAcknowledged
        default: return false
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                if step > 0 && step < totalSteps - 1 {
                    ProgressView(value: Double(step), total: Double(totalSteps - 2))
                        .tint(.teal)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                TabView(selection: $step) {
                    WelcomeStep().tag(0)
                    DisclaimerStep(acknowledged: $disclaimerAcknowledged).tag(1)
                    APIKeyStep(key: $openrouterKey).tag(2)
                    OnDeviceModelsStep().tag(3)
                    AboutYouStep(name: $userName, pronouns: $userPronouns, age: $userAge).tag(4)
                    ConcernsStep(concerns: $intakeConcerns).tag(5)
                    HistoryStep(history: $intakeHistory).tag(6)
                    GoalsStep(goals: $intakeGoals).tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)

                HStack {
                    if step > 0 {
                        Button("Back") { withAnimation { step -= 1 } }
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    // On-device models step can be skipped
                    if step == 3 {
                        Button("Skip") { withAnimation { step += 1 } }
                            .foregroundColor(.secondary)
                            .padding(.trailing, 8)
                    }
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
                    .disabled(continueDisabled)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 32)
                .padding(.top, 16)
            }
        }
    }
}

// MARK: - Step 0: Welcome

private struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 72))
                .foregroundStyle(.teal)
            Text("Welcome to therAIpist")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("A private, AI-assisted space to explore your thoughts and feelings.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Prominent disclaimer banner
            VStack(alignment: .leading, spacing: 8) {
                Label("Important Notice", systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
                Text("therAIpist is **not** a licensed therapist, psychologist, or medical provider. It is a journaling and self-reflection tool only. It cannot diagnose, treat, or manage any mental health condition.")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Divider()

                Text("**If you are in crisis**, please reach out to a real person immediately:")
                    .font(.subheadline.bold())
                    .foregroundColor(.red)
                Link("988 Suicide & Crisis Lifeline — call or text 988", destination: URL(string: "https://988lifeline.org")!)
                    .font(.subheadline)
                Link("Crisis Text Line — text HOME to 741741", destination: URL(string: "https://www.crisistextline.org")!)
                    .font(.subheadline)
            }
            .padding(16)
            .background(Color.orange.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
            .cornerRadius(12)
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - Step 1: Disclaimer (must acknowledge to continue)

private struct DisclaimerStep: View {
    @Binding var acknowledged: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StepHeader(
                    icon: "shield.fill",
                    title: "Before You Begin",
                    subtitle: "Please read and acknowledge the following. This only takes a moment."
                )

                // What this app is
                DisclaimerSection(title: "What therAIpist Is", icon: "checkmark.circle", color: .teal) {
                    BulletRow("A private journaling and self-reflection space")
                    BulletRow("A tool to help you notice patterns in your thoughts and feelings")
                    BulletRow("A supplement to, not a replacement for, professional care")
                }

                // What it isn't
                DisclaimerSection(title: "What therAIpist Is NOT", icon: "xmark.circle", color: .red) {
                    BulletRow("Not a licensed therapist, counselor, or psychologist")
                    BulletRow("Not a crisis intervention service")
                    BulletRow("Not a substitute for medication or clinical treatment")
                    BulletRow("Not equipped to provide diagnoses or medical advice")
                }

                // Crisis resources
                DisclaimerSection(title: "Crisis Resources", icon: "phone.fill", color: .orange) {
                    CrisisLink(label: "988 Suicide & Crisis Lifeline", subtitle: "Call or text 988 (US)", url: "https://988lifeline.org")
                    CrisisLink(label: "Crisis Text Line", subtitle: "Text HOME to 741741", url: "https://www.crisistextline.org")
                    CrisisLink(label: "NAMI Helpline", subtitle: "1-800-950-NAMI (6264)", url: "https://www.nami.org/help")
                    CrisisLink(label: "International Association for Suicide Prevention", subtitle: "Global crisis centre directory", url: "https://www.iasp.info/resources/Crisis_Centres/")
                }

                // Find a therapist
                DisclaimerSection(title: "Find a Real Therapist", icon: "person.fill.checkmark", color: .blue) {
                    CrisisLink(label: "Psychology Today Therapist Finder", subtitle: "Search by location, specialty, insurance", url: "https://www.psychologytoday.com/us/therapists")
                    CrisisLink(label: "Open Path Collective", subtitle: "Reduced-cost therapy ($30–$80/session)", url: "https://openpathcollective.org")
                    CrisisLink(label: "SAMHSA National Helpline", subtitle: "Free, confidential treatment referrals — 1-800-662-4357", url: "https://www.samhsa.gov/find-help/national-helpline")
                    CrisisLink(label: "BetterHelp", subtitle: "Online therapy matching", url: "https://www.betterhelp.com")
                }

                // Acknowledgment toggle
                Toggle(isOn: $acknowledged) {
                    Text("I understand that therAIpist is not a licensed therapist and is not a substitute for professional mental health care.")
                        .font(.subheadline)
                }
                .tint(.teal)
                .padding(14)
                .background(acknowledged ? Color.teal.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            .padding(24)
        }
    }
}

private struct DisclaimerSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundColor(color)
            content()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

private struct BulletRow: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").foregroundColor(.secondary)
            Text(text).font(.subheadline)
        }
    }
}

private struct CrisisLink: View {
    let label: String
    let subtitle: String
    let url: String

    var body: some View {
        Link(destination: URL(string: url)!) {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text(label).font(.subheadline.bold())
                    Image(systemName: "arrow.up.right").font(.caption)
                }
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Step 2: API Key

private struct APIKeyStep: View {
    @Binding var key: String
    @State private var isSecure = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StepHeader(
                    icon: "key.fill",
                    title: "Connect to OpenRouter",
                    subtitle: "therAIpist uses OpenRouter to access cloud AI models. A free account gives you several no-cost models. You can also use on-device models without an API key."
                )

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

                if key.trimmingCharacters(in: .whitespaces).isEmpty {
                    Label("You can skip this and use on-device models instead (see next step).", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("Your key is stored only on this device and is never transmitted except to OpenRouter when making requests.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(28)
        }
    }
}

// MARK: - Step 3: On-Device Models

private struct OnDeviceModelsStep: View {
    private var ramGB: Int {
        Int(ProcessInfo.processInfo.physicalMemory / 1_073_741_824)
    }

    private var recommendation: (model: String, reason: String, suitable: Bool) {
        switch ramGB {
        case ..<4:
            return (
                "Not recommended on this device",
                "Your device has less than 4 GB of RAM. On-device models require at least 4 GB to run without errors. Use OpenRouter cloud models instead.",
                false
            )
        case 4..<6:
            return (
                "Llama 3.2 1B (recommended)",
                "Your device has \(ramGB) GB RAM. The 1B model is the safest choice — it loads quickly and fits comfortably in memory.",
                true
            )
        case 6..<8:
            return (
                "Llama 3.2 3B (recommended)",
                "Your device has \(ramGB) GB RAM. The 3B model gives noticeably better answers than the 1B and should run well.",
                true
            )
        default:
            return (
                "Llama 3.2 3B or Phi-3.5 Mini",
                "Your device has \(ramGB) GB RAM. You can run any model in the catalog. The 3B model is the fastest; Phi-3.5 Mini tends to give more nuanced responses.",
                true
            )
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StepHeader(
                    icon: "cpu",
                    title: "On-Device AI Models",
                    subtitle: "Run AI entirely on your iPhone — no internet, no API key, and completely private."
                )

                // Device recommendation card
                VStack(alignment: .leading, spacing: 10) {
                    Label("Your Device", systemImage: "iphone")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: recommendation.suitable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(recommendation.suitable ? .teal : .orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recommendation.model)
                                .font(.subheadline.bold())
                            Text(recommendation.reason)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)

                // Model comparison
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Models").font(.subheadline.bold())

                    ModelInfoRow(
                        name: "Llama 3.2 1B",
                        size: "~800 MB",
                        speed: "Fast",
                        quality: "Good",
                        minRAM: "4 GB",
                        color: .green
                    )
                    ModelInfoRow(
                        name: "Llama 3.2 3B",
                        size: "~2 GB",
                        speed: "Medium",
                        quality: "Better",
                        minRAM: "6 GB",
                        color: .blue
                    )
                    ModelInfoRow(
                        name: "Phi-3.5 Mini",
                        size: "~2.2 GB",
                        speed: "Medium",
                        quality: "Best",
                        minRAM: "8 GB",
                        color: .purple
                    )
                }

                // How to download
                VStack(alignment: .leading, spacing: 10) {
                    Text("How to Download Models").font(.subheadline.bold())
                    StepInstruction(number: "1", text: "Go to **Settings** (gear icon on the main screen)")
                    StepInstruction(number: "2", text: "Scroll to **On-Device Models**")
                    StepInstruction(number: "3", text: "Tap **Download** next to your chosen model")
                    StepInstruction(number: "4", text: "Once downloaded, start a new session and tap the model chip to switch to **On-Device**")
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)

                // Caveats
                VStack(alignment: .leading, spacing: 6) {
                    Label("Things to Know", systemImage: "info.circle")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                    BulletRow2("Responses take 10–60 seconds depending on your device")
                    BulletRow2("Keep your phone plugged in during long sessions")
                    BulletRow2("The app may use significant battery and generate heat")
                    BulletRow2("Models are stored in your app's Documents folder and can be deleted anytime")
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
            }
            .padding(24)
        }
    }
}

private struct ModelInfoRow: View {
    let name: String
    let size: String
    let speed: String
    let quality: String
    let minRAM: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "cpu")
                        .font(.caption)
                        .foregroundColor(color)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.bold())
                Text("\(size)  ·  Speed: \(speed)  ·  Quality: \(quality)  ·  Min \(minRAM) RAM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(color.opacity(0.06))
        .cornerRadius(8)
    }
}

private struct StepInstruction: View {
    let number: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.teal)
                .clipShape(Circle())
            Text(text).font(.subheadline)
        }
    }
}

private struct BulletRow2: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").foregroundColor(.secondary)
            Text(text).font(.caption).foregroundColor(.secondary)
        }
    }
}

// MARK: - Step 4: About You

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

// MARK: - Step 5: Concerns

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

// MARK: - Step 6: History

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

                // Reminder for people currently in therapy
                Label("If you're currently seeing a therapist, consider sharing your therAIpist reflections with them.", systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(Color.teal.opacity(0.06))
                    .cornerRadius(8)
            }
            .padding(28)
        }
    }
}

// MARK: - Step 7: Goals

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

                // Final reassurance note
                VStack(alignment: .leading, spacing: 6) {
                    Label("You're all set", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(.teal)
                    Text("Remember: therAIpist works best as a complement to real human support. If you ever feel overwhelmed, please reach out to a professional or call 988.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.teal.opacity(0.06))
                .cornerRadius(8)
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
