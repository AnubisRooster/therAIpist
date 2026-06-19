import AVFoundation
import SwiftUI

/// Lists every English voice installed on the device, grouped by quality tier.
/// Tapping a row selects it and plays a short preview.
struct VoicePickerView: View {
    @AppStorage("tts_voice_id") private var selectedVoiceID = ""
    @AppStorage("tts_rate")     private var ttsRate: Double  = 0.5
    @AppStorage("tts_pitch")    private var ttsPitch: Double = 1.0
    @EnvironmentObject          private var speech: SpeechService

    // All English voices installed on this device, best quality first.
    private let voices: [AVSpeechSynthesisVoice] = {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted {
                if $0.quality.rawValue != $1.quality.rawValue {
                    return $0.quality.rawValue > $1.quality.rawValue   // higher = better
                }
                return $0.name < $1.name
            }
    }()

    // Voices grouped: Premium → Enhanced → Default
    private var premiumVoices:  [AVSpeechSynthesisVoice] { voices.filter { $0.quality == .premium } }
    private var enhancedVoices: [AVSpeechSynthesisVoice] { voices.filter { $0.quality == .enhanced } }
    private var defaultVoices:  [AVSpeechSynthesisVoice] { voices.filter { $0.quality == .default } }

    var body: some View {
        List {
            if SpeechService.hasOnlyCompactVoices() {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Voices sound robotic?", systemImage: "exclamationmark.bubble")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                        Text("Your device only has the basic built-in voices. For natural, human-like speech, download a Premium or Enhanced voice:")
                            .font(.caption)
                        Text("Settings → Accessibility → Spoken Content → Voices → English → tap a voice marked “Premium” to download it.")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        Text("Good picks: Ava, Evan, Zoe, Nathan (US) · Serena, Stephanie (UK).")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            if !premiumVoices.isEmpty {
                Section {
                    ForEach(premiumVoices, id: \.identifier) { voice in
                        VoiceRow(voice: voice, selectedID: $selectedVoiceID,
                                 rate: ttsRate, pitch: ttsPitch, speech: speech)
                    }
                } header: {
                    Label("Premium", systemImage: "sparkles")
                } footer: {
                    Text("Premium voices sound the most natural. Download more in Settings → Accessibility → Spoken Content → Voices.")
                        .font(.caption)
                }
            }

            if !enhancedVoices.isEmpty {
                Section("Enhanced") {
                    ForEach(enhancedVoices, id: \.identifier) { voice in
                        VoiceRow(voice: voice, selectedID: $selectedVoiceID,
                                 rate: ttsRate, pitch: ttsPitch, speech: speech)
                    }
                }
            }

            if !defaultVoices.isEmpty {
                Section("Standard") {
                    ForEach(defaultVoices, id: \.identifier) { voice in
                        VoiceRow(voice: voice, selectedID: $selectedVoiceID,
                                 rate: ttsRate, pitch: ttsPitch, speech: speech)
                    }
                }
            }

            Section {
                Text("To get more voices go to:\nSettings → Accessibility → Spoken Content → Voices → English")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Choose Voice")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Row

private struct VoiceRow: View {
    let voice: AVSpeechSynthesisVoice
    @Binding var selectedID: String
    let rate:   Double
    let pitch:  Double
    let speech: SpeechService

    private var isSelected: Bool { selectedID == voice.identifier }

    var body: some View {
        Button {
            selectedID = voice.identifier
            speech.speak(
                "Hi, I'm \(voice.name). I'll be your voice today.",
                rate: Float(rate), pitch: Float(pitch),
                voiceID: voice.identifier
            )
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(voice.name)
                            .foregroundColor(.primary)
                            .fontWeight(isSelected ? .semibold : .regular)
                        qualityBadge(voice.quality)
                    }
                    Text(localizedLanguage(voice.language))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.teal)
                }
            }
        }
    }

    @ViewBuilder
    private func qualityBadge(_ quality: AVSpeechSynthesisVoiceQuality) -> some View {
        switch quality {
        case .premium:
            badge("Premium", color: .orange)
        case .enhanced:
            badge("Enhanced", color: .teal)
        default:
            EmptyView()
        }
    }

    private func badge(_ label: String, color: Color) -> some View {
        Text(label)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 5).padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private func localizedLanguage(_ code: String) -> String {
        let map: [String: String] = [
            "en-US": "English · United States",
            "en-GB": "English · United Kingdom",
            "en-AU": "English · Australia",
            "en-IE": "English · Ireland",
            "en-ZA": "English · South Africa",
            "en-IN": "English · India",
            "en-NZ": "English · New Zealand",
            "en-CA": "English · Canada",
        ]
        return map[code] ?? code
    }
}
