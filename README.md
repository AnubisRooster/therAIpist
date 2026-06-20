# therAIpist

<p align="center">
  <img src="docs/icon.png" alt="therAIpist app icon" width="160" />
</p>

An AI-assisted self-reflection companion: a native **SwiftUI** iOS app that blends multiple therapeutic traditions, builds a personal knowledge graph across sessions, and can run entirely on-device with no internet connection.

> **Important disclaimer**
> therAIpist is **not** a licensed therapist, psychologist, or medical provider. It is a journaling and self-reflection tool only. It cannot diagnose, treat, or manage any mental health condition.
>
> **If you are in crisis, please reach out immediately:**
> - 🇺🇸 **988 Suicide & Crisis Lifeline** — call or text **988** — [988lifeline.org](https://988lifeline.org)
> - **Crisis Text Line** — text HOME to **741741** — [crisistextline.org](https://www.crisistextline.org)
> - **NAMI Helpline** — 1-800-950-6264 — [nami.org/help](https://www.nami.org/help)
> - **SAMHSA National Helpline** — 1-800-662-4357 — [samhsa.gov](https://www.samhsa.gov/find-help/national-helpline)
>
> Find a real therapist: [Psychology Today](https://www.psychologytoday.com/us/therapists) · [Open Path Collective](https://openpathcollective.org) · [BetterHelp](https://www.betterhelp.com)

---

## Features

### Therapy & conversation
- **13 modalities** — Integrated, Adlerian, Jungian, DBT, CBT, Humanistic, Existential, Gestalt, Somatic, Narrative, ACT, Psychodynamic, and IFS — selectable per session
- **Adaptive verbosity** — the assistant calibrates response length based on conversational context
- **Text-to-speech** — responses spoken aloud with configurable voice, rate, and pitch; natural-sounding system voices
- **Voice input** — tap-to-transcribe with the device microphone

### Memory & knowledge
- **Episodic / semantic memory** — each exchange is embedded with Apple's `NLEmbedding` and recalled semantically in future turns within and across sessions
- **Global memories** — therapeutically significant moments (trauma mentions, major insights, grief, relationship patterns) are automatically promoted to a cross-session memory store with a three-tier importance system
- **Knowledge graph** — extracts emotions, persons, beliefs, and wires edges between co-occurring entities (person → TRIGGERS → emotion, emotion → CAUSES → belief, etc.)
- **In-message insight badges** — pill-shaped indicators appear beneath assistant replies to show when memories, graph nodes, edges, or global insights were captured in that exchange

### Models
- **Cloud (OpenRouter)** — access 300+ models; free models are surfaced first; list refreshed every 24 hours
- **On-device (local)** — GGUF models via `LLM.swift` / `llama.cpp` with Metal GPU acceleration; no API key, no internet, fully private
  - Llama 3.2 1B (~800 MB) — recommended for devices with 4–6 GB RAM
  - Llama 3.2 3B (~2 GB) — recommended for 6–8 GB RAM
  - Phi-3.5 Mini (~2.2 GB) — recommended for 8 GB+ RAM
- **Per-session model selection** — tap the model chip in the chat nav bar to switch

### Data & sessions
- **SwiftData persistence** — all data (messages, memories, nodes, edges, notes, dreams) is stored locally in a SwiftData store
- **Archive sessions** — swipe to archive instead of delete; all underlying data is preserved; restore at any time from the Archive tab
- **Notes & dreams** — record session notes and dream narratives per conversation
- **Dashboard** — aggregated stats across all sessions; tap any stat (nodes, edges, memories, notes, dreams, global memories) to drill into the full list

### Safety
- **Crisis detection** — every user message is checked with negation-aware keyword matching; crisis resources are surfaced automatically
- **Boundary enforcement** — diagnostic or prescriptive assistant responses are intercepted and replaced before reaching the user
- **Safety event log** — all flagged exchanges are recorded per session

### Onboarding
- **8-step setup** — welcome → disclaimer acknowledgment → OpenRouter API key → on-device model guide → personal intake → concerns → therapy background → goals
- **Device-aware model recommendation** — the on-device setup step reads actual device RAM and recommends the appropriate model
- **Full crisis resource list** during onboarding (before the user ever starts a session)

---

## Architecture

```
ios/Therapist/
├── Services/
│   ├── ChatService.swift          # Core turn orchestrator: memory, graph, LLM, safety
│   ├── LLMService.swift           # Routes to OpenRouter or local engine
│   ├── LocalLLMEngine.swift       # llama.cpp inference via LLM.swift; stop-sequence,
│   │                              #   timeout, concurrent-generation guards
│   ├── LocalModelService.swift    # Catalog, download management, progress tracking
│   ├── MemoryService.swift        # Episodic/semantic embedding + recall
│   ├── GlobalMemoryService.swift  # Cross-session significant memory promotion
│   ├── GraphService.swift         # Entity extraction + edge wiring
│   ├── TherapyService.swift       # Modality prompts + system prompt assembly
│   ├── SpeechService.swift        # AVSpeechSynthesizer TTS wrapper
│   ├── SafetyService.swift        # Crisis + boundary detection
│   └── AgentOrchestrator.swift    # Specialized sub-agents (notes, dreams, graph)
│
├── Models/
│   └── SwiftDataModels.swift      # SessionModel, MessageModel, MemoryModel,
│                                  #   GraphNodeModel, GraphEdgeModel, NoteModel,
│                                  #   DreamModel, GlobalMemoryModel, SafetyEventModel
│
└── Views/
    ├── ContentView.swift          # Session list (archive-aware @Query)
    ├── ChatView.swift             # Chat UI + MessageBubble with insight badges
    ├── OnboardingView.swift       # 8-step first-launch flow
    ├── DashboardView.swift        # Stats + drill-down detail sheets
    ├── SettingsView.swift         # API key, TTS, defaults, on-device model manager
    ├── ModelPickerView.swift      # Per-session cloud / on-device model picker
    ├── InsightsView.swift
    ├── NotesView.swift
    ├── DreamsView.swift
    └── GraphView.swift
```

---

## Getting Started

### Requirements

- Xcode 16+
- iOS 17+ device or simulator
- (Optional) [OpenRouter](https://openrouter.ai) API key for cloud models
- (Optional) 4–8 GB device RAM for on-device models

### Build

```bash
cd ios
xcodegen generate          # regenerates Therapist.xcodeproj from project.yml
open Therapist.xcodeproj
```

Build and run on your device or simulator. Swift Package Manager will resolve `LLM.swift` automatically on first build.

### First launch

The onboarding flow walks you through:

1. **Disclaimer** — read and acknowledge the app's limitations and crisis resources (required)
2. **OpenRouter API key** — skip this step if you only want on-device models
3. **On-device models** — device-personalised model recommendation; download from **Settings → On-Device Models** after setup
4. **Intake** — optional personal context (name, concerns, therapy history, goals) that shapes every session's system prompt

### On-device models

1. Open **Settings** (gear icon on the sessions screen)
2. Scroll to **On-Device Models**
3. Tap **Download** next to your chosen model (your device's RAM determines the recommendation)
4. Once downloaded, open any chat → tap the model chip → select **On-Device**

> **Note:** First inference after loading a model may take 10–30 seconds. Subsequent turns are faster. Keep the device plugged in during long sessions.

---

## Knowledge graph

Each user message is processed for entities:

| Entity type | Examples |
|-------------|---------|
| **Emotion** | anger, shame, grief, anxiety, loneliness |
| **Person** | Mother, Father, Partner, Ex-partner, Boss |
| **Belief** | "I always…", "I can't…", "I don't deserve…" |

Edges are wired between co-occurring entities in the same message:

| Edge | Meaning |
|------|---------|
| `Person → TRIGGERS → Emotion` | A relationship figure is mentioned alongside a feeling |
| `Emotion → CAUSES → Belief` | A feeling driving a cognitive pattern |
| `Belief → ASSOCIATED_WITH → Emotion` | Reciprocal link |
| `Emotion → ASSOCIATED_WITH → Emotion` | Co-occurring feelings |

View the graph any time via **Graph** in the chat toolbar.

---

## Memory system

| Layer | Scope | How triggered |
|-------|-------|---------------|
| **Episodic memory** | Per-session | Every exchange; embedded with NLEmbedding |
| **Semantic memory** | Per-session | Consolidated from recent messages |
| **Global memory** | Cross-session | Tier-3: any trauma/crisis word; Tier-2: 2+ relationship/shame/grief words; Tier-1: 3+ distress words |

Global memories and cross-session episodic recall are injected into every new session's system prompt, giving the assistant continuity without requiring the user to repeat themselves.

---

## Session archive

Sessions are never hard-deleted by default:
- Swipe left → **Archive** (orange) — preserves all messages, memories, graph, notes, dreams
- Tap **Archive** in the toolbar → restore any session or permanently delete it

---

## Safety & ethics

- Crisis detection runs on every user message with negation handling ("I don't want to die" is not flagged)
- The app provides 988 and Crisis Text Line resources automatically when crisis signals are detected
- Boundary enforcement intercepts assistant responses containing diagnostic or prescriptive language
- All safety events are logged per session
- This project is for research and personal use only; it must not be presented as professional therapy

---

## License

No license file is currently included; treat this repository as all-rights-reserved unless a license is added.
