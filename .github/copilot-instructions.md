
# GreenWise — Copilot Guide

>This guide is for AI coding agents working in the GreenWise Flutter app. It summarizes essential architecture, workflows, and project-specific conventions for immediate productivity.

## Architecture & Data Flow

### Application Bootstrap
- **Entry:** `lib/main.dart` → `GreenWiseApp` → `splash/splash_screen.dart` → `AppShell` or `OnboardingScreen`
- **Desktop-only init:** SQLite FFI is initialized in `main()` with `sqfliteFfiInit()` and database seeded via `TipRepositorySqlite().populateIfEmpty()`
- **Splash responsibilities:** 
  - Initializes Hive (`SettingsStore.ensureInitialized()`)
  - Loads settings from disk, merges with provider state
  - Schedules notifications if enabled
  - Enforces minimum 3s display time
  - Detects test environment (`TestWidgetsFlutterBinding`) and skips heavy initialization

### Navigation
- **Shell:** 4-tab PageView in `lib/app_shell.dart` using custom `EcoNavBar` (`lib/features/common/widgets/eco_nav_bar.dart`)
- **Tabs:** Tips (infinite feed), Progress (stats + heatmap), Recycling Directory, Settings
- **Vertical scrolling tip feed:** Uses PageController with viewport fraction (0.86) for parallax card scaling

### State Management (Riverpod v2)
- **No singletons.** All state lives in providers.
- **Provider pattern:** Repository → Provider → UI
  ```dart
  final tipRepositoryProvider = Provider<TipRepositorySqlite>((ref) => TipRepositorySqlite());
  final dailyTipProvider = FutureProvider<EcoTip>((ref) async {
    final repo = ref.watch(tipRepositoryProvider);
    // ... logic
  });
  ```
- **Invalidation cascade:** Mutations MUST invalidate all dependent providers. Example from `completeTodayProvider`:
  ```dart
  await repo.markCompleted(date);
  ref.invalidate(streakProvider);
  ref.invalidate(weeklyCompletionProvider);
  ref.invalidate(recentCompletionsProvider);
  ref.invalidate(last30StatsProvider);
  ref.invalidate(weeklyDaysProvider);
  ```

### Data Layer
- **Tips:** SQLite (`TipRepositorySqlite`) seeded from `assets/data/tips.json` on first run
  - Daily tip = deterministic date-based rotation (`date.dayOfYear % totalTips`)
  - Infinite feed via `TipsFeedController` (AutoDisposeAsyncNotifier) with category filtering
- **Completions/Streaks:** `SharedPreferences` with keys like `completed_tip_2025-11-04`, `streak_state_v1`
- **Settings:** Hive box (`settings_box`) with `SettingsStore` wrapper
- **Categories:** Stored as enum name strings (`EcoTipCategory.name`) in settings, filtered in providers

### Persistence Strategy
- **Why mixed storage?** SQLite for read-heavy tip catalog; SharedPreferences for simple key-value (streaks); Hive for structured settings with async writes
- **Date normalization:** Always use `DateTime(year, month, day)` for completion keys to ensure day-level granularity

## Key Conventions & Patterns

### Design System
- **Spacing:** `GWDs.s1` through `GWDs.s8` (4px increments), `GWDs.cornerL/M/S` for radii
- **Cards:** `GWCard` widget with frosted glass gradient, accepts `onTap`, `padding`, `radius`
- **Theme:** Defined in `core/theme/app_theme.dart`, consumed via `Theme.of(context).colorScheme`
- **Accessibility:** Respect `settings.reduceMotion` for animations

### Provider Patterns
- **Repository injection:** Always expose repositories via providers, never construct directly in UI
- **Category filtering:** Filter tips at provider level, not UI. Check `settings.enabledCategories.isEmpty || categories.contains(tip.category.name)`
- **Infinite feed:** `TipsFeedController` tracks `_cursor`, `_seen` set, and `_categoriesSig` for filter change detection

### Settings & Bootstrap
- **Never call `Hive.initFlutter()` in tests.** Use `SettingsNotifier.test(initialState)` instead
- **Splash detection:** Tests use `WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding')`
- **Settings merge:** Splash merges disk settings with provider overrides (for tests to inject state like `hasOnboarded: true`)

### Testing
- **Streak/completion tests:** Call `SharedPreferences.setMockInitialValues({})` before test
- **Settings tests:** Use `SettingsNotifier.test(SettingsState(...))` - this prevents Hive save operations in tests
- **Test mode detection:** `SettingsNotifier.test()` constructor sets `_isTest = true` flag that skips Hive persistence
- **Repository:** Use `InMemoryTipRepository` for unit tests (see `test/streak_repository_test.dart`)

## Developer Workflows

### Commands
```powershell
# Install dependencies
flutter pub get

# Run (mobile/desktop)
flutter run

# Run for web
flutter run -d chrome

# Lint
flutter analyze

# Test
flutter test

# Generate launcher icons (after modifying assets/images/GW_Logo.png)
flutter pub run flutter_launcher_icons
```

### Adding a Tip
1. Edit `assets/data/tips.json`: `{ "id": "unique", "text": "...", "category": "energySaving", "createdAt": "2025-11-04T10:00:00Z", "explanation": "..." }`
2. On next desktop/non-web run, `TipRepositorySqlite().populateIfEmpty()` will seed new tips
3. Web/mobile require database migration or manual seed logic

### Adding a Category
1. Extend `EcoTipCategory` enum in `lib/data/models/eco_tip.dart`
2. Add color mapping in `core/constants/app_colors.dart` (if exists) or in card UI
3. Ensure settings filter uses `category.name` (string comparison)

## Landmarks & Examples

### Key Files
- **Tips feed:** `lib/app_shell.dart` → `DailyTipScreen` (PageView with vertical scrolling)
- **Tip card:** `features/tips/presentation/widgets/daily_tip_card_modern.dart`
- **Progress screen:** `features/progress/presentation/progress_screen.dart` (weekly ring, 30-day heatmap)
- **Progress logic:** `features/progress/application/progress_providers.dart` (sliding window stats)
- **Settings:** `settings/settings_screen.dart` + `settings/settings_provider.dart`
- **Notification scheduling:** `services/notifications/notification_service.dart`

### Example: Provider Invalidation
After marking a tip complete, invalidate all computed state:
```dart
ref.invalidate(dailyTipProvider);       // refresh daily tip
ref.invalidate(tipsInfiniteFeedProvider); // reset feed from today
ref.invalidate(streakProvider);         // recompute streak
ref.invalidate(weeklyCompletionProvider); // update weekly stats
ref.invalidate(recentCompletionsProvider); // refresh 30-day data
```

## Gotchas & Project-Specific Rules

### Critical Rules
- **Hive in tests:** NEVER call `Hive.initFlutter()` in tests. Use `SettingsNotifier.test(SettingsState(...))` and provider overrides
- **Splash timing:** Enforces ≥3s display (changed from 1s in old docs). Test mode skips this via `TestWidgetsFlutterBinding` detection
- **Date keys:** Completion keys are ISO date strings truncated to 10 chars: `completed_tip_2025-11-04`
- **SQLite desktop-only:** Non-web platforms use SQLite; web would need IndexedDB or in-memory repository
- **Asset changes:** Update `pubspec.yaml` `assets:` section when adding files under `assets/`

### Animation Respect
Check `settings.reduceMotion` before applying animations:
```dart
final settings = ref.watch(settingsProvider);
if (!settings.reduceMotion) {
  // Apply animation
}
```

### Infinite Feed Pattern
`TipsFeedController` implements:
- `build()`: Initial load (12 tips)
- `loadMore(count)`: Prefetch when near end
- `reset()`: Clear state and reload from today
- Category filter change detection via signature comparison

## Further Reading
- [README.md](../README.md) — Project vision, e-waste impact, feature roadmap
- [docs/APP_GUIDE.md](../docs/APP_GUIDE.md) — User flows and developer setup
- [docs/FEATURES.md](../docs/FEATURES.md) — Detailed feature breakdown

---

**Questions or unclear patterns?** Open an issue/PR to refine this guide. This is a living document.
