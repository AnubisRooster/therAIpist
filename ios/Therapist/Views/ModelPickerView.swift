import SwiftUI

struct ModelPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var modelService: ModelService
    @EnvironmentObject private var localModelService: LocalModelService

    let session: SessionModel

    @State private var query = ""
    /// Free-text model IDs entered for each BYOK provider (keyed by rawValue).
    @State private var byokModelIDs: [String: String] = [:]

    // MARK: - Filtered cloud lists

    private var freeSorted: [OpenRouterModel] { filterCloud(modelService.freeModels) }
    private var paidSorted: [OpenRouterModel] { filterCloud(modelService.paidModels) }

    private var downloadedLocalModels: [LocalModel] {
        localModelService.catalog.filter { localModelService.isDownloaded($0.id) }
    }

    /// Cloud providers (other than OpenRouter) that have a key set — these are
    /// offered as "bring your own key" options with a free-text model field.
    private var byokProviders: [LLMProvider] {
        LLMProvider.allCases.filter {
            $0.baseURL != nil && $0 != .openrouter && KeychainService.shared.hasKey(for: $0)
        }
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

                        // Bring-your-own-key providers
                        if !byokProviders.isEmpty {
                            Section {
                                ForEach(byokProviders) { provider in
                                    byokRow(provider)
                                }
                            } header: {
                                Label("Bring Your Own Key", systemImage: "key")
                            } footer: {
                                Text("Uses your own API key for these providers. Enter the exact model ID (e.g. \(LLMProvider.anthropic.exampleModelID)). Add keys in Settings → Keys & Providers.")
                                    .font(.caption)
                            }
                        }

                        // Cloud models (OpenRouter catalogue)
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

                        if modelService.models.isEmpty && downloadedLocalModels.isEmpty && byokProviders.isEmpty {
                            ContentUnavailableView(
                                "No Models",
                                systemImage: "antenna.radiowaves.left.and.right.slash",
                                description: Text(modelService.lastError
                                    ?? "Add an API key in Settings → Keys & Providers or download a local model.")
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
                        Task { await modelService.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(modelService.isLoading)
                    .accessibilityLabel("Refresh model list")
                }
            }
        }
        .task { await modelService.refreshIfNeeded() }
    }

    // MARK: - Local model row

    @ViewBuilder
    private func localModelRow(_ model: LocalModel) -> some View {
        let isSelected = session.resolvedProvider == "local" && session.localModel == model.id
        let icon = model.kind == .appleFoundation ? "apple.logo" : "cpu"

        Button {
            session.provider = "local"
            session.localModel = model.id
            session.model = ""
            session.updatedAt = Date()
            dismiss()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
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
                    TagCapsule(label: "Recommended", color: .blue)
                }
                if model.kind == .appleFoundation {
                    TagCapsule(label: "Built-in", color: .indigo)
                }

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - BYOK provider row

    @ViewBuilder
    private func byokRow(_ provider: LLMProvider) -> some View {
        let isSelected = session.resolvedProvider == provider.rawValue
        let binding = Binding(
            get: { byokModelIDs[provider.rawValue] ?? (isSelected ? session.model : "") },
            set: { byokModelIDs[provider.rawValue] = $0 }
        )
        let trimmed = binding.wrappedValue.trimmingCharacters(in: .whitespaces)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cloud")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .frame(width: 24)
                Text(provider.displayName)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
            HStack {
                TextField(provider.exampleModelID, text: binding)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Button("Use") {
                    session.provider = provider.rawValue
                    session.model = trimmed
                    session.localModel = ""
                    session.updatedAt = Date()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .disabled(trimmed.isEmpty)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Cloud model row (OpenRouter)

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
                    TagCapsule(label: "FREE", color: .green)
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
