import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var context
    let session: SessionModel

    @State private var messageText = ""
    @State private var isLoading = false
    @State private var showInsights = false
    @State private var showNotes = false
    @State private var showDreams = false
    @State private var showGraph = false
    @State private var errorMessage: String?

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
        .sheet(isPresented: $showInsights) { InsightsView(session: session) }
        .sheet(isPresented: $showNotes) { NotesView(session: session) }
        .sheet(isPresented: $showDreams) { DreamsView(session: session) }
        .sheet(isPresented: $showGraph) { GraphView(session: session) }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messageText = ""
        isLoading = true
        errorMessage = nil

        Task {
            do {
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
            }
            isLoading = false
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
