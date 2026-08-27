# Selfward — App Review & QA Notes

Guidance for App Store submission and for Apple reviewers. The app is **local-first
and BYOK** (bring-your-own-key): it does not collect user data itself; user text is
sent only to the cloud LLM provider the user configures (e.g. OpenRouter), and speech
may be sent to Apple's speech servers when transcription is on-device unsupported.

## What the app is (use this in the App Store listing)
Selfward is an **AI journaling and self-reflection companion**, not a licensed
therapist, psychologist, or medical provider. It cannot diagnose, treat, or manage any
medical or mental-health condition. The in-app personas ("AI Reflection Guide",
"Companion", "Spiritual Advisor") are prompt-driven reflection aids, not clinicians.

## How a reviewer can test without our keys
- **On-device path (no key needed):** On first launch, Onboarding → "On-Device Models"
  auto-selects a model sized to the device's RAM and downloads it (one-time network
  fetch from Hugging Face). After that, chat works fully offline.
- **Cloud path:** In Settings → AI & Models → Keys & Providers, paste an OpenRouter
  (or other) API key. Chat then uses that provider.
- **iOS 17 support:** The app targets iOS 17. On iOS 26+ devices with Apple
  Intelligence, an on-device Apple Foundation Models option appears; on iOS 17 the
  GGUF path is used instead. The app is fully usable without Apple Intelligence.
- **No forced login / account:** There is no account creation. Keys are stored in the
  device Keychain.

## Safety features (relevant to Guideline 1.4.1)
- Crisis-keyword detection replaces the assistant reply with resources (988, Crisis
  Text Line, emergency services) when self-harm/crisis language is detected; the event
  is also logged locally.
- Hard guardrails refuse diagnosis, prescription, or medical advice; boundary-violating
  replies are replaced with a safe, non-clinical response.
- Onboarding includes an explicit "What Selfward Is NOT" disclaimer and "Find a Real
  Therapist" links (Psychology Today, Open Path, SAMHSA, BetterHelp).

## Privacy nutrition labels (App Store Connect)
- **Data not collected by the developer:** the app stores everything on-device; no
  analytics, no ad identifiers, no tracking.
- **Data sent to third parties:** only the user's journal text/chat is transmitted to
  the user-chosen LLM provider (configured by the user). Disclose as "Data linked to
  you → Other Data (e.g. user content) — used to provide the app's core functionality;
  not used for tracking." Speech may be sent to Apple's servers for recognition.
- A privacy policy is linked in-app (`NSPrivacyPolicyURL`) and must be supplied in App
  Store Connect.

## Suggested age rating
Because the Companion persona has been softened to warm/platonically supportive (no
romantic or flirtatious framing) and all personas are explicit non-clinical
reflection aids, a **12+** rating is appropriate. Do not select "Made for Kids".

## Accessibility QA checklist (manual)
- [ ] VoiceOver navigates all primary screens (Onboarding, Chats, Narrative, Insights, Settings).
- [ ] Dynamic Type: bump font sizes in Settings → Accessibility and confirm no截断/clipping in
      ChatView, OnboardingView, SettingsView, DashboardView.
- [ ] VoiceOver labels present on persona/model pickers and the crisis resource links.
- [ ] Tint/contrast sufficient; no reliance on color alone for state.
- [ ] Voice conversation (mic) permission flow presents the usage explanation.

## Known limitations (not blockers)
- Personal Team builds run on simulator/device but **cannot be submitted** to the App
  Store — enrollment in the paid Apple Developer Program is required for distribution.
- No iCloud/CloudKit sync by design (privacy); backup is via local export only.
