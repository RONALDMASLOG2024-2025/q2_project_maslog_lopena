# GreenWise – Features Overview

This document highlights the key features currently implemented in the app and where they live in the codebase.

## Navigation & Shell
- EcoNavBar (frosted, animated labels) with 4 tabs: Tips, Progress, Recycle & Trade‑in, Settings.
  - Files: `lib/features/common/widgets/eco_nav_bar.dart`, wiring in `lib/main.dart`.

## Onboarding
- Green multi‑page onboarding with clickable page dots and eco‑leaf particle background (reduced motion aware).
  - Folder: `lib/features/onboarding/`

## Tips
- Daily Eco‑Tip card (GWCard), category tag, actionable chips: “Why it matters”, “Done today”.
- When available, a concise rationale appears below the card.
  - File: `lib/features/tips/presentation/widgets/daily_tip_card_modern.dart`.

## Progress
- Weekly completion ring with animated painter.
- Streak stats (current, longest).
- 30‑day heatmap of completions.
- Maintenance: Clear Progress (with confirm dialog and snackbar).
  - Files: `lib/features/progress/presentation/progress_screen.dart`, `lib/features/progress/application/progress_providers.dart`.

## Recycling & Trade‑in Directory
- Curated cards with name, short description, badge, and an “Open” button to launch websites externally.
- Sections for Philippines and Global resources.
  - File: `lib/features/resources/recycling_directory_screen.dart`.

### Philippines (examples)
- Globe E‑Waste Zero — Drop‑off map, drives, rewards.
- DENR — EPR/policy, events guidance.
- Envirocycle — Pickups & certified recycling.
- E‑Dispo — Collection & drives.
- SM Cares — Trash to Cash events.

### Global (examples)
- ERI — Certified global recycler.
- Sims Lifecycle Services — ITAD with site locator.
- ATRenew — Trade‑in network with incentives.
- PCs for People — Refurbish & drop‑offs.
- Best Buy Recycling — Store drop‑offs & trade‑in.
- Apple Trade In — Global program.
- Dell Reconnect — Drop‑offs via Goodwill.
- Google Sustainability — Guides and info.

## Settings
- Dark mode toggle (theme mode) and Reduce Motion (accessibility), persisted with Hive.
  - Files: `lib/settings/settings_screen.dart`, `lib/settings/settings_provider.dart`.

## Persistence & Data
- Tips/streaks/completions via repository + SharedPreferences.
- Settings via Hive store.
  - File: `lib/data/repositories/tip_repository.dart`, `lib/settings/settings_provider.dart`.

## Tests
- Widget test ensures daily tip card renders and animations don’t break tests.
  - File: `test/widget_test.dart`.

## Packages
- riverpod ^2.6.1, hive, shared_preferences, flutter_local_notifications, connectivity_plus, http, url_launcher, flutter_svg.

## Known Warnings (non‑blocking)
- Some file names not in snake_case (Mash suffix variants).
- A few deprecated APIs in legacy widgets; safe to refactor incrementally.
