<div align="center">

# 🌱 GreenWise
Daily eco-tips and habit tracking for sustainable electronics use

![Platform](https://img.shields.io/badge/platform-Android%20|%20iOS%20|%20Web%20|%20Desktop-brightgreen) ![Flutter](https://img.shields.io/badge/Flutter-3.x-blue) ![License](https://img.shields.io/badge/license-TBD-lightgrey)

</div>

---

## 📘 1. Introduction
The rapid advancement of technology has resulted in a surge of electronic devices in households, schools, and workplaces. While these innovations improve lives, they also contribute to one of the fastest-growing waste streams in the world: electronic waste (e-waste). Mismanagement of e-waste leads to harmful environmental and health consequences due to the improper disposal of hazardous materials.

Green computing and sustainable electronics usage are emerging as critical practices in addressing this challenge. However, many users lack awareness or daily actionable habits to reduce their personal e-waste footprint.

**GreenWise** addresses this gap by serving as a friendly eco-companion that encourages small, daily actions toward sustainable electronics use. Through habit formation and clear, concise guidance, it empowers individuals to make informed eco-friendly choices that accumulate into long-term impact.

## 🧪 2. Background of the Study
According to the Global E-Waste Monitor, over **53 million metric tons** of e-waste were generated worldwide in 2019, with only **17.4%** properly collected and recycled. The Philippines, like many developing countries, faces challenges in electronic waste management due to lack of awareness, limited recycling infrastructure, and weak enforcement of policies.

At the individual level, simple actions such as proper charging habits, device maintenance, reusing old gadgets, and correct disposal practices can significantly reduce e-waste generation. However, such practices are rarely encouraged in a structured, accessible, and engaging manner.

**GreenWise** leverages curated learning, gamified daily eco-tips, and habit-building features to instill green computing behaviors in users’ everyday lives.

## ❗ 3. Problem Statement
Despite the growing urgency of e-waste management, most individuals lack awareness and actionable daily habits to minimize their electronic footprint. Educational campaigns exist, but they are often generic, passive, and fail to engage users long-term.

This leads to several issues:
- Improper disposal of electronics, causing toxic leaks into soil and water.
- Shortened device lifespans due to poor usage and care practices.
- Continued purchase of non-sustainable devices without awareness of alternatives.
- Lack of habit formation, as existing efforts do not encourage sustained behavioral change.

> There is a need for a personalized, interactive, habit-forming solution that educates individuals on sustainable electronic practices in a simple and actionable way.

## 🎯 4. Objectives of the Study
**General Objective**: Design and develop GreenWise, a mobile application that promotes sustainable electronic practices through daily eco-tips and habit-forming interactions.

**Specific Objectives:**
1. Provide daily eco-friendly tips focused on electronics usage, care, and disposal.
2. Provide short, curated context on why each tip matters.
3. Allow users to customize eco-tip categories (Device Care, Energy Saving, Disposal, Eco-Buying).
4. Promote habit formation through small, repeatable actions.
5. Measure and highlight users’ progress and environmental impact over time.

## 📌 5. Scope and Limitations
**Scope:**
- Cross-platform mobile application (Android/iOS) with optional Web/Desktop via Flutter.
- Core: daily eco-tip notifications, clear guidance, customizable categories, habit tracking.
- Focus strictly on electronics-related sustainability.
- Uses an LLM (Large Language Model) for natural language explanations.

**Limitations:**
- No direct physical recycling logistics (guidance only).
- All content works offline; explanations are local when present.
- Tip dataset is curated and expandable.

## 🧩 6. Core Features (Implemented)
- Daily Eco‑Tip card
	- One actionable sustainable tip per day with a modern GWCard UI ("Today’s Eco‑Tip").
	- Mark as “Done today” to build streaks; pull‑to‑refresh for a new tip.
	- File: `lib/features/tips/presentation/widgets/daily_tip_card_modern.dart`.
- “Why it matters” context
	- When available, shows concise rationale for the tip’s impact.
- Tip categories
	- Device Care, Energy Saving, Responsible Disposal, Eco‑Buying with colored tags.
	- File: `lib/data/models/eco_tip.dart` (category), UI in the daily card.
- Progress dashboard
	- Weekly completion ring, streak stats, and a 30‑day heatmap of completions.
	- Clear Progress action with confirmation dialog.
	- Files: `lib/features/progress/presentation/progress_screen.dart`, `lib/features/progress/application/progress_providers.dart`.
- Organized Settings
	- Dark mode (theme), Reduce Motion accessibility toggle, persisted via Hive.
	- File: `lib/settings/settings_screen.dart`, provider in `lib/settings/settings_provider.dart`.
- Onboarding with particles
	- Green multi‑page onboarding with clickable dots and subtle eco‑leaf particle background.
	- Files: `lib/features/onboarding/`.
- Custom Navigation shell
	- Frosted EcoNavBar with 4 tabs: Tips, Progress, Recycle & Trade‑in, Settings.
	- File: `lib/features/common/widgets/eco_nav_bar.dart`, wired in `lib/main.dart`.
- Recycling & Trade‑in directory (New)
	- Curated PH and Global resources with cards and external “Open” buttons.
	- Launches links in the system browser via `url_launcher`.
	- File: `lib/features/resources/recycling_directory_screen.dart`.

## 🌍 7. Impact of the Study
**Environmental:** Reduces e-waste via improved device care, disposal awareness, and sustainable purchasing.

**Social:** Builds eco-awareness culture; encourages collective participation.

**Educational:** Functions as a green computing learning aid for students, households, and professionals.

## 🔧 8. Feasibility
**Technical:** Flutter cross-platform stack; local data; optional backend via Firebase/Supabase for tips, users, streaks.

**Operational:** Low-friction engagement (single daily notification); scalable feature layering (gamification, social).

**Economic:** Low infrastructure costs; potential NGO / sustainability grants; future eco-partnerships and sponsorships.

## ✅ 9. Conclusion
GreenWise addresses e-waste and unsustainable electronics practices by pairing habit formation with simple micro-learning. Rather than passive awareness, it delivers curated eco-tips, clear explanations, and progress tracking—turning small actions into cumulative environmental impact.

> Small, consistent steps empower individuals to embrace sustainable electronics usage and reduce their e-waste footprint.

---

## 🗂️ 10. Project Structure (Current Snapshot)
```
lib/
	main.dart               # App entry point
android/, ios/, web/, macos/, linux/, windows/  # Platform scaffolding
test/                     # Widget / unit tests
```

Planned (proposed) structure as features mature:
```
lib/
	core/          # Theme, constants, utilities
	data/          # Models, repositories, local/remote sources
	domain/        # Entities, use-cases (if adopting clean arch)
	features/
		tips/        # Tip feed, categories, completion logic
		habit/       # Streaks, badges, progress metrics
		settings/    # Preferences, notifications, category filters
	services/      # Notification scheduling
```

## 🧱 11. Tech Stack (Current)
- Flutter (Dart ^3.9) – cross‑platform UI
- State: Riverpod ^2.6.1
- Persistence: Hive (settings), SharedPreferences (completions/streaks)
- Notifications: `flutter_local_notifications` (local scheduling)
- Links: `url_launcher` for external browser redirects
- Utilities: `connectivity_plus`, `http`, `flutter_svg`

## 📘 12. Content Notes
- Tips are curated and categorized (Device Care, Energy Saving, Disposal, Eco‑Buying).
- “Why it matters” copy is concise and educational when present.

## 🔐 13. Privacy & Data Handling
- No sensitive personal data stored beyond minimal profile prefs.
- Tip interactions & streak metrics anonymized for aggregated insights (future enhancement).
- Provide in-app privacy notice + opt-out for analytics.
- No network calls for explanations; all content is local and privacy‑friendly.

## 🚀 14. Getting Started (Development)
Prerequisites:
- Flutter SDK 3.9.0+ (match `environment` in `pubspec.yaml`)
- Dart enabled in PATH
- Android Studio / Xcode for platform builds

Steps:
1. Clone the repository.
2. Run: `flutter pub get`
3. Launch an emulator or connect a device.
4. Run: `flutter run`

Optional Web: `flutter run -d chrome`

## 🧪 15. Testing
- Add widget tests in `test/` (example scaffold present).
- Future: add unit tests for tip scheduling and streak increments.

## 🗺️ 16. Roadmap (Updated)
- [x] Base UI shell & navigation (EcoNavBar)
- [x] Daily tip provider and modern card UI
- [x] Tip completion + streak logic
- [x] Progress dashboard (weekly ring + 30‑day heatmap)
- [x] Settings (Dark mode, Reduce Motion)
- [x] Recycling/Trade‑in directory with external links
- [ ] Notification scheduling polish and UX
- [ ] Optional expanded explanations (local copy)
- [ ] Tip category filters UI
- [ ] Gamification (badges)
- [ ] Community/social sharing
- [ ] Accessibility audit
- [ ] Multi‑language support (i18n)

## 🤝 17. Contributing
1. Fork & branch: `feature/<short-description>`
2. Ensure lint passes: `flutter analyze`
3. Add/Update tests where relevant
4. Open PR with concise description & screenshots (if UI)

## 📄 18. License
License to be determined (MIT / Apache-2.0 recommended for openness). Add a `LICENSE` file before public release.

## 🙋 19. FAQs
**Why only one tip per day?** Encourages focus & habit formation (behavioral science: reduce overload).

**Can users request more tips?** Future enhancement: “Explore More” secondary feed not tied to streaks.

How is content verified? Tips are curated and can be reviewed like documentation. Contributions are welcome via PRs.

## 🔄 20. Future Enhancements
- Carbon impact estimation per action
- Localized e-waste drop-off map integration
- Device lifecycle tracker (e.g., battery health reminders)
- In-app challenges (household / classroom mode)
- Optional personalized weekly sustainability summaries (local copy)

## 🙌 Acknowledgments
Inspired by global e-waste reduction initiatives and green computing advocacy efforts.

---

> Made with Flutter and a mission for sustainable digital living.

