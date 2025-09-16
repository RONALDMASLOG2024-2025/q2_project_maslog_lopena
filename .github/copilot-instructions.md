# GreenWise — Copilot Guide

Targeted context for AI agents working in this Flutter app.

## Architecture
- Entry: `lib/main.dart` → `GreenWiseApp` → `splash/splash_screen.dart` → `AppShell`.
- Tabs: Tips, Progress, Recycling, Settings in `lib/app_shell.dart` (custom `EcoNavBar`).
- State: Riverpod v2. Use providers (no singletons). Mutations should `ref.invalidate(...)` dependents.
- Data: Tips from `assets/data/tips.json` via `LocalTipRepository` → `dailyTipProvider`.
- Persistence: `SharedPreferences` for completions/streak, Hive (`SettingsStore`) for settings.
- Notifications: `NotificationService` schedules daily reminders (timezone-aware), triggered in Splash.

## Conventions
- Dates: Always normalize to day granularity `DateTime(y,m,d)` for completion/streak.
- Categories: Store as enum name strings in settings (`settingsProvider.state.enabledCategories`).
- Providers: Define repos behind providers, e.g. `tipRepositoryProvider` in `features/tips/application/daily_tip_provider.dart`.
- Design tokens: Use `core/design/design_system.dart` (`GWDs`, `GWCard`). Theme in `core/theme/app_theme.dart`.

## Key Flows
- Daily tip: `LocalTipRepository.getDailyTip(date)` rotates by day-of-year; category filtering happens in `dailyTipProvider`.
- Complete tip: call `ref.read(completeTodayProvider.future)` → writes completion, invalidates `streakProvider` and progress providers.
- Splash bootstrap: Init Hive, load settings, optionally schedule notifications, then `replace(...)` settings and navigate.

## Build & Test
- Prereqs: Dart `^3.9.0`, Flutter 3.9+; assets declared in `pubspec.yaml`.
- Run:
  - `flutter pub get`
  - `flutter run` (use `-d chrome` for web)
- Lints: `flutter analyze` (rules set in `analysis_options.yaml`).
- Tests: Prefer provider overrides over touching Hive:
  - `SettingsNotifier.test(...)` with `ProviderScope(overrides: [...])`.
  - `SharedPreferences.setMockInitialValues({})` for streak/completions.

## Landmarks
- Tips UI: `features/tips/presentation/widgets/daily_tip_card_modern.dart`, stats: `tip_hero_stats.dart`.
- Progress: `features/progress/presentation/progress_screen.dart` with `recentCompletionsProvider`/`weeklyCompletionProvider`.
- Settings: `settings/settings_screen.dart`, state: `settings/settings_provider.dart`.
- Notifications: `services/notifications/notification_service.dart`.

## Gotchas
- Don’t initialize Hive in tests; seed state with `SettingsNotifier.test`.
- `SplashScreen` enforces ≥1s display and detects tests; avoid navigation elsewhere during bootstrap.
- Update `pubspec.yaml` when adding assets under `assets/`.
- Respect `settings.reduceMotion` for animations.

## Examples
- Add a tip:
  - Append to `assets/data/tips.json` with `{ id, text, category: EcoTipCategory name, createdAt }`.
- New category:
  - Extend `EcoTipCategory` → add color in `core/constants/app_colors.dart` → ensure settings filter uses `category.name`.

Unclear areas or missing rules? Open an issue/PR and we’ll refine this guide.
