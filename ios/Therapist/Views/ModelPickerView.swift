import SwiftUI

struct ModelPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var modelService: ModelService
    @AppStorage("openrouter_key") private var apiKey = ""

    /// The session whose `model` property is updated on selection.
    let session: SessionModel

    @State private var query = ""

    // MARK: Filtered lists

    private var freeSorted: [OpenRouterModel] { filter(modelService.freeModels) }
    private var paidSorted: [OpenRouterModel] { filter(modelService.paidModels) }

    // MARK: Body

    var body: some View {
        NavigationStack {
            Group {
                if modelService.isLoading && modelService.models.isEmpty {
                    ProgressView("Fetching models…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if modelService.models.isEmpty {
                    ContentUnavailableView(
                        "No Models",
                        systemImage: "antenna.radiowaves.left.and.right.slash",
                        description: Text(modelService.lastError
                            ?? "Add your OpenRouter API key in Settings to load the model list.")
                    )
                } else {
                    List {
                        if !freeSorted.isEmpty {
                            Section {
                                ForEach(freeSorted) { model in modelRow(model) }
                            } header: {
                                Label("Free Models", systemImage: "gift")
                            }
                        }
                        if !paidSorted.isEmpty {
                            Section("Paid Models") {
                                ForEach(paidSorted) { model in modelRow(model) }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $query,
                                placement: .navigationBarDrawer(displayMode: .always),
                                prompt: "Search models")
                }
            }
            .navigationTitle("Choose Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await modelService.refresh(apiKey: apiKey) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(modelService.isLoading)
                }
            }
        }
        .task { await modelService.refreshIfNeeded(apiKey: apiKey) }
    }

    // MARK: Row

    @ViewBuilder
    private func modelRow(_ model: OpenRouterModel) -> some View {
        Button {
            session.model = model.id
            session.updatedAt = Date()
            dismiss()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(model.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(contextLabel(model.contextLength))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if model.isFree {
                    Text("FREE")
                        .font(.caption2.bold())
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }

                if session.model == model.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: Helpers

    private func filter(_ list: [OpenRouterModel]) -> [OpenRouterModel] {
        guard !query.isEmpty else { return list }
        let q = query.lowercased()
        return list.filter { $0.name.lowercased().contains(q) || $0.id.lowercased().contains(q) }
    }

    private func contextLabel(_ tokens: Int) -> String {
        if tokens >= 1_000_000 { return "\(tokens / 1_000_000)M context" }
        if tokens >= 1_000 { return "\(tokens / 1_000)K context" }
        return "\(tokens) tokens"
    }
}
