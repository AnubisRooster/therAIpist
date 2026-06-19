import SwiftUI

struct ModelPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var modelService: ModelService
    @EnvironmentObject private var localModelService: LocalModelService
    @AppStorage("openrouter_key") private var apiKey = ""

    let session: SessionModel

    @State private var query = ""

    // MARK: - Filtered cloud lists

    private var freeSorted: [OpenRouterModel] { filterCloud(modelService.freeModels) }
    private var paidSorted: [OpenRouterModel] { filterCloud(modelService.paidModels) }

    private var downloadedLocalModels: [LocalModel] {
        localModelService.catalog.filter { localModelService.isDownloaded($0.id) }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if modelService.isLoading && modelService.models.isEmpty {
                    ProgressView("Fetching models…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // On-Device section (only shows downloaded models)
                        if !downloadedLocalModels.isEmpty {
                            Section {
                                ForEach(downloadedLocalModels) { model in
                                    localModelRow(model)
                                }
                            } header: {
                                Label("On-Device", systemImage: "iphone")
                            } footer: {
                                Text("Runs entirely on this device. No internet required.")
                                    .font(.caption)
                            }
                        }

                        // Cloud models
                        if !freeSorted.isEmpty {
                            Section {
                                ForEach(freeSorted) { model in cloudModelRow(model) }
                            } header: {
                                Label("Free Models", systemImage: "gift")
                            }
                        }
                        if !paidSorted.isEmpty {
                            Section("Paid Models") {
                                ForEach(paidSorted) { model in cloudModelRow(model) }
                            }
                        }

                        if modelService.models.isEmpty && downloadedLocalModels.isEmpty {
                            ContentUnavailableView(
                                "No Models",
                                systemImage: "antenna.radiowaves.left.and.right.slash",
                                description: Text(modelService.lastError
                                    ?? "Add your OpenRouter API key in Settings or download a local model.")
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $query,
                                placement: .navigationBarDrawer(displayMode: .always),
                                prompt: "Search cloud models")
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

    // MARK: - Local model row

    @ViewBuilder
    private func localModelRow(_ model: LocalModel) -> some View {
        let isSelected = session.resolvedProvider == "local" && session.localModel == model.id

        Button {
            session.provider = "local"
            session.localModel = model.id
            session.model = ""
            session.updatedAt = Date()
            dismiss()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "cpu")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text(model.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(model.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if model.isRecommended {
                    Text("Recommended")
                        .font(.caption2.bold())
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.blue.opacity(0.12))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Cloud model row

    @ViewBuilder
    private func cloudModelRow(_ model: OpenRouterModel) -> some View {
        let isSelected = session.resolvedProvider == "openrouter" && session.model == model.id

        Button {
            session.provider = "openrouter"
            session.model = model.id
            session.localModel = ""
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

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func filterCloud(_ list: [OpenRouterModel]) -> [OpenRouterModel] {
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
