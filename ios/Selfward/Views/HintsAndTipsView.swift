import SwiftUI

// MARK: - Hints & Tips (root list)

/// A guide for people unfamiliar with AI tooling: how to pick a model for
/// their device, where to get API keys, how to pick a voice, and what each
/// therapy modality / companion personality / spiritual tradition means.
/// Pushed from `SettingsView`'s root form.
struct HintsAndTipsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink {
                    ModelHintsView()
                } label: {
                    Label("Choosing a Model", systemImage: "cpu")
                }
                NavigationLink {
                    APIKeyHintsView()
                } label: {
                    Label("Getting API Keys", systemImage: "key")
                }
                NavigationLink {
                    VoiceHintsView()
                } label: {
                    Label("Picking a Voice", systemImage: "speaker.wave.2")
                }
            } header: {
                Text("Setup")
            }

            Section {
                NavigationLink {
                    ModalityHintsView()
                } label: {
                    Label("Therapy Modalities Explained", systemImage: "brain.head.profile")
                }
                NavigationLink {
                    CompanionPersonalityHintsView()
                } label: {
                    Label("Companion Personalities Explained", systemImage: "heart.fill")
                }
                NavigationLink {
                    SpiritualTraditionHintsView()
                } label: {
                    Label("Spiritual Traditions Explained", systemImage: "sparkles")
                }
            } header: {
                Text("Personas")
            }
        }
        .navigationTitle("Hints & Tips")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Model hints

struct ModelHintsView: View {
    @EnvironmentObject private var localModelService: LocalModelService

    private var ramGB: Int {
        Int(ProcessInfo.processInfo.physicalMemory / 1_073_741_824)
    }

    private var recommended: LocalModel? {
        let id = localModelService.recommendedModelID(ramGB: ramGB)
        return localModelService.catalog.first(where: { $0.id == id })
    }

    var body: some View {
        Form {
            Section("On-Device vs. Cloud") {
                Text("On-device models run entirely on your phone: private, free, work offline — but need a one-time download and reply more slowly.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Cloud models run on a provider's servers via an API key: fastest and most capable, but need internet, and your conversation is sent to that provider.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let recommended {
                Section("For Your Device") {
                    Text("Your device has about \(ramGB) GB of RAM — we'd recommend **\(recommended.name)**.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                ForEach(localModelService.catalog) { model in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.name)
                            .font(.subheadline.weight(.medium))
                        Text(model.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                Text("On-Device Catalog")
            } footer: {
                Text("A \"Recommended\" badge means it's a solid default for most devices. \"Built-in\" means it ships with iOS and needs no download.")
                    .font(.caption)
            }
        }
        .navigationTitle("Choosing a Model")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - API key hints

struct APIKeyHintsView: View {
    var body: some View {
        Form {
            Section {
                ForEach(LLMProvider.allCases.filter { $0 != .local }) { provider in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(provider.displayName)
                            .font(.subheadline.weight(.medium))
                        Text(provider.tipBlurb)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Get a key: \(provider.keyHint)")
                            .font(.caption2)
                            .foregroundColor(Color.secondary.opacity(0.8))
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                Text("Cloud Providers")
            }

            Section {
                Text("API keys are stored only in this device's Keychain — never on Selfward's servers, and never sent anywhere but the provider you're talking to.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("OpenRouter's \":free\" model variants — including the one Selfward uses by default — don't require any payment info at all.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Don't want to sign up anywhere? Skip this entirely — On-Device models need no key, no internet, and no account.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } header: {
                Text("Tips")
            }
        }
        .navigationTitle("Getting API Keys")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Voice hints

struct VoiceHintsView: View {
    var body: some View {
        Form {
            Section("On-Device vs. Cloud Voices") {
                Text("On-device voices are free, private, and work offline.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Cloud voices (OpenAI or ElevenLabs) sound more natural but need an API key, and the text you're replying to is sent to that provider to synthesize speech.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Section("Better On-Device Voices") {
                Text("iOS ships several \"Standard\" voices that can sound robotic. Better ones — \"Premium\" and \"Enhanced\" — are free but need a one-time download: Settings → Accessibility → Spoken Content → Voices → English → tap a voice marked Premium.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Good picks: Ava, Evan, Zoe, Nathan (US) · Serena, Stephanie (UK).")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Section("Per-Persona Voices") {
                Text("Each persona — Therapist, Companion, Spiritual Advisor — can have its own voice, overriding the default, from Settings → Personas.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Picking a Voice")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Modality hints

struct ModalityHintsView: View {
    var body: some View {
        Form {
            Section {
                ForEach(allModalities, id: \.self) { modality in
                    VStack(alignment: .leading, spacing: 4) {
                        Label {
                            Text(modality.replacingOccurrences(of: "_", with: " ").capitalized)
                        } icon: {
                            Image(systemName: modalityIcons[modality] ?? "sparkles")
                                .foregroundColor(Theme.modalityColor(modality))
                        }
                        .font(.subheadline.weight(.medium))
                        Text(modalityLongDescriptions[modality] ?? modalityDescriptions[modality] ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } footer: {
                Text("Pick a modality per session from New Session → Therapist.")
                    .font(.caption)
            }
        }
        .navigationTitle("Therapy Modalities")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Companion personality hints

struct CompanionPersonalityHintsView: View {
    var body: some View {
        Form {
            Section {
                ForEach(CompanionPersonality.allCases) { personality in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(personality.label)
                            .font(.subheadline.weight(.medium))
                        Text(personality.tipBlurb)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } footer: {
                Text("Choose a personality from Settings → Personas, or when starting a new Companion session.")
                    .font(.caption)
            }
        }
        .navigationTitle("Companion Personalities")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Spiritual tradition hints

struct SpiritualTraditionHintsView: View {
    var body: some View {
        Form {
            Section {
                ForEach(SpiritualTradition.allCases) { tradition in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tradition.label)
                            .font(.subheadline.weight(.medium))
                        Text(tradition.tipBlurb)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } footer: {
                Text("Choose a tradition from Settings → Personas, or when starting a new Spiritual Advisor session.")
                    .font(.caption)
            }
        }
        .navigationTitle("Spiritual Traditions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
