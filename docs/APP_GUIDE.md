# GreenWise — App Guide

A friendly guide to what GreenWise is, how it’s structured, and how each screen works — plus how to build and ship it.

## Purpose
GreenWise helps people adopt sustainable electronics habits with a delightful daily tip, lightweight streak tracking, and curated recycling resources. It encourages small, consistent actions and celebrates progress.

- Daily eco tip with the “why it matters” context
- One‑tap completion to track a streak and weekly progress
- Infinite tips feed so you never run out of ideas
- Curated recycling/trade‑in resources (Local, PH, International)
- Gentle daily reminder notifications at your chosen time

## App Structure
- Entry: `lib/main.dart` → `splash/splash_screen.dart` → `AppShell`
- Navigation: `AppShell` holds a PageView with 4 tabs: Tips, Progress, Recycling, Settings (custom `EcoNavBar`).
- State: Riverpod v2. Providers orchestrate repositories and UI state.
- Data: Tips loaded from `assets/data/tips.json` via `LocalTipRepository`.
- Persistence: `SharedPreferences` for completions/streak; Hive `SettingsStore` for settings.
- Notifications: `NotificationService` schedules timezone‑aware daily reminders (mobile only).

## Pages
### Splash
- Bootstraps the app: initializes Hive, loads settings, optionally schedules notifications, then replaces settings state and navigates to the shell.
- Ensures a minimum splash display duration and avoids navigation elsewhere during bootstrap.

### Tips
- Shows Today’s Eco Tip as a prominent card with action buttons.
- Infinite vertical feed: smoothly scroll through more tips with scale/fade transitions.
- Category filter respected from Settings (only enabled categories appear).
- “Mark as done” updates completion for today, invalidates dependent providers, and advances your streak.

Key widgets/providers:
- `daily_tip_provider.dart`: `dailyTipProvider` (today’s tip), `tipsInfiniteFeedProvider` (batched feed controller with `loadMore`/`reset`).
- UI: `daily_tip_card_modern.dart`, `tip_hero_stats.dart`.

### Progress
- Weekly chips and a 30‑day summary to visualize consistency.
- Recent completions list and weekly breakdown via Riverpod providers.
- Responsive layouts ensure no overflow on narrow screens.

Key providers/screens:
- `features/progress/presentation/progress_screen.dart`
- `recentCompletionsProvider`, `weeklyCompletionProvider`, `streakProvider` (see `features/progress` and `features/habit`).

### Recycling
- Catchy hero + category grid (Local, PH, International) with expand/collapse sections.
- External links open in the device browser (via `url_launcher`).
- Responsive grid (2–3 columns) to avoid overflow on small screens.

File:
- `features/resources/recycling_directory_screen.dart`

### Settings
- Appearance: Dark Mode toggle powers `ThemeMode` in `main.dart`.
- Tip Categories: enable/disable categories; affects Today + Feed.
- Notifications: enable daily reminder and choose time; on change, schedules the next notification and shows a confirmation SnackBar (mobile only).
- About: high‑level app info.

Files:
- `settings/settings_screen.dart`, `settings/settings_provider.dart`

## Data & State
- Tips: `assets/data/tips.json` → `LocalTipRepository`.
- Providers: `tipRepositoryProvider`, `dailyTipProvider`, `tipsInfiniteFeedProvider`.
- Completions/Streak: `SharedPreferences` store per‑day completion at day granularity (`DateTime(y,m,d)` normalization), with helpers to compute streak and weekly/30‑day stats.
- Settings: persisted with Hive; during startup the app uses default settings and replaces them from Hive in Splash.

## Notifications
- `services/notifications/notification_service.dart`: requests permissions, schedules timezone‑aware daily reminders at the chosen time, reschedules on time or enable/disable changes.
- Platform notes: Works on Android/iOS; no web notifications. Operations no‑op on web.

## Tips Dataset
- Location: `assets/data/tips.json`.
- Format: `{ id, text, category: EcoTipCategory name, createdAt }`.
- Add a tip: append to the JSON; ensure `pubspec.yaml` includes `assets/data/` (it does).

## Design & Accessibility
- Design tokens: `core/design/design_system.dart` (`GWDs`, `GWCard`), theme in `core/theme/app_theme.dart`.
- Motion: A minimal, tasteful animation baseline. (The settings UI removed the previous “reduce motion” toggle; animations elsewhere already respect conservative defaults.)

## Build & Run
Prereqs: Flutter 3.35+, Dart 3.9+, assets declared in `pubspec.yaml`.

Common commands:
```bash
flutter pub get
flutter analyze
flutter run -d chrome   # web
```

### Web
```bash
flutter build web
# Output: build/web
```

### Android (local)
Requires Android Studio + SDK. On Windows:
```powershell
flutter config --android-sdk "C:\Users\hp\AppData\Local\Android\Sdk"
flutter doctor --android-licenses
flutter build apk --release
flutter build appbundle --release
# APK: build\app\outputs\flutter-apk\app-release.apk
# AAB: build\app\outputs\bundle\release\app-release.aab
```

### iOS (macOS only)
Requires macOS with Xcode + CocoaPods and signing.
```bash
flutter pub get
(cd ios && pod repo update && pod install)
flutter build ipa --no-codesign   # unsigned artifact at build/ios/ipa/*.ipa
```
For signed App Store/TestFlight uploads: open `ios/Runner.xcworkspace` in Xcode → set Team/Bundle ID → Archive via Organizer and Distribute.

### Windows (optional)
Enable Developer Mode (symlinks) then:
```powershell
start ms-settings:developers
flutter build windows
```

## CI (GitHub Actions)
Workflow at `.github/workflows/build-mobile.yml` builds and uploads:
- Android: release APK + AAB (Ubuntu runner)
- iOS: unsigned IPA (macOS runner)
Trigger on push/PR to main/master or workflow_dispatch.

## Troubleshooting
- Analyzer lints: non‑blocking (directive ordering, file naming for legacy files). Fix as time permits.
- Web Wasm warnings from `flutter_native_timezone_updated_gradle`: informational; build succeeds. To target Wasm, gate the web import.
- If you see RenderFlex overflows, verify responsive wrappers are in place (they are for Progress and Recycling).
