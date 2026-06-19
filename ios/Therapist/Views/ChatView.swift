import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var modelService: ModelService
    @EnvironmentObject private var speech: SpeechService
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

    @State private var messageText  = ""
    @State private var isLoading    = false
    @State private var errorMessage: String?

    private var modelLabel: String {
        let id = session.resolvedModel
        return id.components(separatedBy: "/").last ?? id
    }

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

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            HStack(spacing: 8) {
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
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
                            Image(systemName: "cpu")
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
                    if speech.isSpeaking {
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
            ModelPickerView(session: session).environmentObject(modelService)
        }
        .sheet(isPresented: $showInsights) { InsightsView(session: session) }
        .sheet(isPresented: $showNotes) { NotesView(session: session) }
        .sheet(isPresented: $showDreams) { DreamsView(session: session) }
        .sheet(isPresented: $showGraph) { GraphView(session: session) }
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

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messageText = ""
        isLoading = true
        errorMessage = nil

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
            if ttsEnabled && !result.response.isEmpty {
                speech.speak(result.response,
                             rate: Float(ttsRate),
                             pitch: Float(ttsPitch),
                             voiceID: ttsVoiceID)
            }
        }
    }
}

struct MessageBubble: View {
    let message: MessageModel

    var body: some View {
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
        .padding(.horizontal)
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
