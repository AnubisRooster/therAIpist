import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var modelService:      ModelService
    @EnvironmentObject private var speech:            SpeechService
    @EnvironmentObject private var localModelService: LocalModelService
    @ObservedObject private var localEngine = LocalLLMEngine.shared
    @StateObject private var voice = VoiceConversationController()
    let session: SessionModel
    @State private var showInsights    = false
    @State private var showNotes       = false
    @State private var showDreams      = false
    @State private var showGraph       = false
    @State private var showModelPicker = false

    @AppStorage("tts_enabled")  private var ttsEnabled = false
    @AppStorage("tts_rate")     private var ttsRate: Double  = 0.5
    @AppStorage("tts_pitch")    private var ttsPitch: Double = 1.0
    @AppStorage("tts_voice_id") private var ttsVoiceID      = ""

    @State private var messageText    = ""
    @State private var isLoading      = false
    @State private var errorMessage: String?
    @State private var generationStart: Date?
    @State private var elapsedSeconds = 0
    @State private var elapsedTimer: Timer?

    /// True while input should be blocked: cloud request in flight OR local model is generating.
    private var isBusy: Bool {
        isLoading || (session.resolvedProvider == "local" && localEngine.isGenerating)
    }

    private var modelLabel: String { session.modelLabel }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(session.messages.sorted(by: { $0.createdAt < $1.createdAt })) { msg in
                            MessageBubble(message: msg)
                                .id(msg.id)
                        }
                        if isLoading {
                            HStack(spacing: 8) {
                                Spacer()
                                ProgressView()
                                Text("Therapist is thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: session.messages.count) { _, _ in
                    if let last = session.messages.sorted(by: { $0.createdAt < $1.createdAt }).last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Status bar: model loading / generation timer / errors
            if localEngine.isLoading {
                Label("Loading model…", systemImage: "cpu")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else if localEngine.isGenerating && session.resolvedProvider == "local" {
                HStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text(elapsedSeconds < 5
                         ? "Thinking…"
                         : "Thinking… \(elapsedSeconds)s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Stop") {
                        LocalLLMEngine.shared.stopGeneration()
                        isLoading = false
                        stopElapsedTimer()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            } else if let loadError = localEngine.loadError {
                Text(loadError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            } else if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            } else if !voice.isActive, let voiceError = voice.errorMessage {
                // Surface voice-start failures (permissions, availability) even
                // though the active status bar isn't shown.
                Text(voiceError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            if voice.isActive {
                VoiceStatusBar(voice: voice)
            }

            HStack(spacing: 8) {
                Button {
                    toggleVoiceMode()
                } label: {
                    Image(systemName: voice.isActive ? "waveform.circle.fill" : "mic.circle")
                        .font(.title2)
                        .foregroundColor(voice.isActive ? .teal : .secondary)
                        .symbolEffect(.pulse, isActive: voice.phase == .listening)
                }

                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(voice.isActive)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty || isBusy || voice.isActive)
            }
            .padding()
            .background(.bar)
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Image(systemName: modalityIcons[session.modality] ?? "sparkles")
                        .font(.caption2)
                        .foregroundColor(modalityColor(session.modality))
                    Text(session.modality.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.secondary)
                    Button {
                        showModelPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: session.resolvedProvider == "local" ? "cpu" : "cloud")
                                .font(.caption2)
                            Text(modelLabel)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if voice.isActive {
                        // In hands-free mode, skip the spoken reply and return to
                        // listening instead of stalling the loop in `.speaking`.
                        voice.skipSpeaking()
                    } else if speech.isSpeaking {
                        speech.stop()
                    } else {
                        ttsEnabled.toggle()
                    }
                } label: {
                    Image(systemName: ttsEnabled
                          ? (speech.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                          : "speaker.slash")
                    .foregroundColor(ttsEnabled ? .teal : .secondary)
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Insights", systemImage: "lightbulb") { showInsights = true }
                Spacer()
                Button("Notes", systemImage: "note.text") { showNotes = true }
                Spacer()
                Button("Dreams", systemImage: "moon") { showDreams = true }
                Spacer()
                Button("Graph", systemImage: "circle.hexagongrid") { showGraph = true }
            }
        }
        .sheet(isPresented: $showModelPicker) {
            ModelPickerView(session: session)
                .environmentObject(modelService)
                .environmentObject(localModelService)
        }
        .sheet(isPresented: $showInsights) { InsightsView(session: session) }
        .sheet(isPresented: $showNotes) { NotesView(session: session) }
        .sheet(isPresented: $showDreams) { DreamsView(session: session) }
        .sheet(isPresented: $showGraph) { GraphView(session: session) }
        .onChange(of: voice.pendingUtterance) { _, newValue in
            guard let newValue else { return }
            handleVoiceUtterance(newValue.text)
        }
        .onDisappear { voice.stop() }
    }

    private func modalityColor(_ modality: String) -> Color {
        switch modality {
        case "adlerian": return .blue
        case "jungian": return .purple
        case "dbt": return .green
        case "integrated": return .orange
        case "free_form": return .teal
        case "cbt": return .indigo
        case "humanistic": return .pink
        case "existential": return .gray
        case "gestalt": return .yellow
        case "somatic": return .mint
        case "narrative": return .brown
        case "act": return .cyan
        case "psychodynamic": return .red
        case "ifs": return .primary
        default: return .secondary
        }
    }

    private func toggleVoiceMode() {
        if voice.isActive {
            voice.stop()
            return
        }
        // Voice mode implies spoken replies.
        ttsEnabled = true
        voice.start()
    }

    /// Processes a spoken turn on the view's live ModelContext — exactly like a
    /// typed message — so the user + assistant bubbles render immediately, then
    /// hands the reply back to the voice loop to be spoken aloud.
    private func handleVoiceUtterance(_ text: String) {
        isLoading = true
        errorMessage = nil
        if session.resolvedProvider == "local" {
            startElapsedTimer()
        }
        Task {
            let result = await ChatService.shared.processMessage(
                session: session,
                userMessage: text,
                context: context
            )
            session.updatedAt = Date()
            try? context.save()
            isLoading = false
            stopElapsedTimer()
            voice.deliverResponse(result.response)
        }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messageText = ""
        isLoading = true
        errorMessage = nil

        if session.resolvedProvider == "local" {
            startElapsedTimer()
        }

        Task {
            let result = await ChatService.shared.processMessage(
                session: session,
                userMessage: text,
                context: context
            )
            if result.isCrisis {
                errorMessage = "Crisis resources have been shared above."
            }
            session.updatedAt = Date()
            try? context.save()
            isLoading = false
            stopElapsedTimer()
            if ttsEnabled && !result.response.isEmpty {
                speech.speak(result.response,
                             rate: Float(ttsRate),
                             pitch: Float(ttsPitch),
                             voiceID: ttsVoiceID)
            }
        }
    }

    private func startElapsedTimer() {
        elapsedSeconds = 0
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
        elapsedSeconds = 0
    }
}

/// Compact status strip shown above the input bar while hands-free voice mode
/// is active. Surfaces the current phase and a live partial transcript.
struct VoiceStatusBar: View {
    @ObservedObject var voice: VoiceConversationController

    private var label: String {
        switch voice.phase {
        case .idle:      return ""
        case .listening: return "Listening… (pause or say \u{201C}send\u{201D})"
        case .thinking:  return "Thinking…"
        case .speaking:  return "Speaking…"
        }
    }

    private var icon: String {
        switch voice.phase {
        case .idle:      return "mic.slash"
        case .listening: return "waveform"
        case .thinking:  return "ellipsis"
        case .speaking:  return "speaker.wave.2.fill"
        }
    }

    private var tint: Color {
        switch voice.phase {
        case .listening: return .teal
        case .thinking:  return .orange
        case .speaking:  return .blue
        case .idle:      return .secondary
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                    .symbolEffect(.variableColor, isActive: voice.phase == .listening || voice.phase == .speaking)
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(tint)
                Spacer()
                if let err = voice.errorMessage {
                    Text(err)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .lineLimit(2)
                }
            }
            if voice.phase == .listening && !voice.partialText.isEmpty {
                Text(voice.partialText)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(tint.opacity(0.08))
    }
}

struct MessageBubble: View {
    let message: MessageModel

    private var hasBadges: Bool {
        message.role == "assistant" && (
            message.capturedNodeCount > 0 ||
            message.capturedEdgeCount > 0 ||
            message.capturedMemoryCount > 0 ||
            message.capturedGlobalMemory
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if message.role == "user" {
                    Spacer(minLength: 60)
                    Text(message.content)
                        .padding(12)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
                } else {
                    Text(message.content)
                        .padding(12)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
                    Spacer(minLength: 60)
                }
            }

            if hasBadges {
                CapturedBadgeRow(message: message)
                    .padding(.leading, 12)
            }
        }
        .padding(.horizontal)
    }
}

/// Small pill badges shown below an assistant message when the exchange
/// triggered memory storage, graph node creation, or edge wiring.
private struct CapturedBadgeRow: View {
    let message: MessageModel

    var body: some View {
        HStack(spacing: 6) {
            if message.capturedMemoryCount > 0 {
                BadgePill(
                    icon: "brain",
                    label: "\(message.capturedMemoryCount) \(message.capturedMemoryCount == 1 ? "memory" : "memories")",
                    color: .teal
                )
            }
            if message.capturedNodeCount > 0 {
                BadgePill(
                    icon: "circle.hexagongrid",
                    label: "\(message.capturedNodeCount) \(message.capturedNodeCount == 1 ? "node" : "nodes")",
                    color: .purple
                )
            }
            if message.capturedEdgeCount > 0 {
                BadgePill(
                    icon: "link",
                    label: "\(message.capturedEdgeCount) \(message.capturedEdgeCount == 1 ? "edge" : "edges")",
                    color: .indigo
                )
            }
            if message.capturedGlobalMemory {
                BadgePill(
                    icon: "star.fill",
                    label: "insight saved",
                    color: .orange
                )
            }
        }
    }
}

private struct BadgePill: View {
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
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

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
