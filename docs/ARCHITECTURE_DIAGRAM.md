# GreenWise Architecture Diagram

## 📁 Complete Folder Structure

```
greenwise/
│
├── lib/
│   ├── main.dart                                    # 🚀 App Entry Point
│   ├── app_shell.dart                              # 🏠 4-tab Navigation Shell
│   │
│   ├── core/                                        # 🎨 Shared Utilities
│   │   ├── design/
│   │   │   └── design_system.dart                  # GWDs spacing, GWCard
│   │   ├── theme/
│   │   │   └── app_theme.dart                      # Light/dark themes
│   │   └── constants/
│   │       └── app_colors.dart                     # Color palette
│   │
│   ├── data/                                        # 💾 Data Layer
│   │   ├── models/
│   │   │   ├── eco_tip.dart                        # Tip model + EcoTipCategory enum
│   │   │   ├── recycling_resource.dart             # RecyclingResource + RecyclingDirectory
│   │   │   └── settings_state.dart                 # Settings model
│   │   └── repositories/
│   │       ├── tip_repository.dart                 # Abstract repository interface
│   │       ├── tip_repository_sqlite.dart          # SQLite implementation
│   │       ├── recycling_repository.dart           # Abstract interface
│   │       └── local_recycling_repository.dart     # JSON asset loader
│   │
│   ├── features/                                    # 🎯 Feature Modules
│   │   │
│   │   ├── common/                                  # Shared UI Components
│   │   │   └── widgets/
│   │   │       ├── eco_nav_bar.dart                # Frosted bottom nav
│   │   │       ├── eco_app_bar.dart                # Custom app bar
│   │   │       └── static_grid_bubbles_background.dart
│   │   │
│   │   ├── onboarding/                              # 👋 Onboarding Flow
│   │   │   └── presentation/
│   │   │       └── onboarding_screen.dart          # Multi-page onboarding
│   │   │
│   │   ├── progress/                                # 📊 Progress & Streaks
│   │   │   ├── domain/                             # Business Logic
│   │   │   │   ├── progress_provider.dart          # Weekly/30-day stats
│   │   │   │   └── streak_provider.dart            # Streak calculations
│   │   │   └── presentation/                       # UI Layer
│   │   │       ├── progress_screen.dart            # Main progress screen
│   │   │       └── widgets/
│   │   │           ├── tip_hero_stats.dart         # Stats display
│   │   │           └── weekly_ring_painter.dart    # Custom ring chart
│   │   │
│   │   ├── recycling/                               # ♻️ Recycling Directory
│   │   │   ├── domain/
│   │   │   │   └── recycling_provider.dart         # Directory data provider
│   │   │   └── presentation/
│   │   │       └── recycling_directory_screen.dart # PH & Global resources
│   │   │
│   │   ├── settings/                                # ⚙️ App Settings
│   │   │   ├── domain/
│   │   │   │   └── settings_provider.dart          # Settings state (Hive)
│   │   │   └── presentation/
│   │   │       └── settings_screen.dart            # Settings UI
│   │   │
│   │   ├── splash/                                  # 🌟 Splash Screen
│   │   │   └── splash_screen.dart                  # Bootstrap & initialization
│   │   │
│   │   └── tips/                                    # 💡 Daily Tips & Feed
│   │       ├── domain/
│   │       │   └── tip_provider.dart               # Daily tip + infinite feed
│   │       └── presentation/
│   │           ├── daily_tip_screen.dart           # Tip feed screen
│   │           └── widgets/
│   │               ├── daily_tip_card_modern.dart  # Today's tip card
│   │               └── tip_hero_stats.dart         # Stats display
│   │
│   └── services/                                    # 🔔 Platform Services
│       └── notifications/
│           └── notification_service.dart           # Daily reminder scheduler
│
├── test/                                            # ✅ Tests (6/6 passing)
│   ├── ai_service_test.dart                        # Placeholder test
│   ├── mark_done_progress_test.dart                # Progress invalidation test
│   ├── onboarding_navigation_test.dart             # Navigation test
│   ├── streak_repository_test.dart                 # Streak logic tests
│   └── widget_test.dart                            # Widget rendering test
│
├── assets/                                          # 🖼️ Static Assets
│   ├── data/
│   │   ├── tips.json                               # Tip database (seeded to SQLite)
│   │   └── recycling_resources.json               # Directory data
│   └── images/
│       └── GW_Logo.png                             # App logo
│
├── docs/                                            # 📚 Documentation
│   ├── APP_GUIDE.md                                # User flows & dev setup
│   ├── FEATURES.md                                 # Feature breakdown
│   ├── ARCHITECTURE_OPTIMIZATION_PLAN.md           # Phase 2 plan
│   └── PHASE2_ARCHITECTURE_COMPLETE.md             # This completion report
│
└── .github/
    └── copilot-instructions.md                     # AI agent guide

```

## 🔄 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                       │
│  (Screens, Widgets - UI components with ConsumerWidget/State)   │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Tips Screen  │  │Progress Screen│  │Settings Screen│         │
│  │              │  │              │  │              │         │
│  │ • Daily Card │  │ • Weekly Ring│  │ • Dark Mode  │         │
│  │ • Feed List  │  │ • Heatmap    │  │ • Categories │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                  │                  │                  │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │ ref.watch()      │ ref.watch()      │ ref.watch()
          ↓                  ↓                  ↓
┌─────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                            │
│          (Business Logic - Riverpod Providers)                   │
│                                                                  │
│  ┌──────────────────┐  ┌───────────────────┐  ┌──────────────┐ │
│  │ tipProvider      │  │ progressProvider  │  │ settings     │ │
│  │                  │  │                   │  │ Provider     │ │
│  │ • dailyTipProv.  │  │ • weeklyCompletion│  │              │ │
│  │ • feedProvider   │  │ • streakProvider  │  │ • Hive store │ │
│  │                  │  │ • last30Stats     │  │ • Notifier   │ │
│  └────────┬─────────┘  └─────────┬─────────┘  └──────┬───────┘ │
│           │                      │                    │         │
└───────────┼──────────────────────┼────────────────────┼─────────┘
            │ ref.watch()          │ ref.watch()        │
            ↓                      ↓                    ↓
┌─────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                              │
│              (Models & Repository Implementations)               │
│                                                                  │
│  ┌─────────────────────┐  ┌──────────────────┐  ┌────────────┐ │
│  │ TipRepositorySqlite │  │ SharedPreferences│  │ SettingsStore│
│  │                     │  │                  │  │ (Hive)     │ │
│  │ • SQLite queries    │  │ • Completion keys│  │            │ │
│  │ • Date rotation     │  │ • Streak data    │  │ • Settings │ │
│  │ • Category filter   │  │                  │  │ • Theme    │ │
│  └──────────┬──────────┘  └────────┬─────────┘  └─────┬──────┘ │
│             │                      │                   │        │
└─────────────┼──────────────────────┼───────────────────┼────────┘
              ↓                      ↓                   ↓
         ┌─────────┐           ┌──────────┐        ┌─────────┐
         │ SQLite  │           │SharedPref│        │  Hive   │
         │Database │           │   JSON   │        │   Box   │
         └─────────┘           └──────────┘        └─────────┘
```

## 🎯 Dependency Rules

### Clean Architecture Principles

1. **Dependencies flow inward:**
   - Presentation → Domain → Data
   - Never the reverse!

2. **Feature isolation:**
   - Features communicate via domain providers
   - No direct widget-to-widget dependencies across features

3. **Shared utilities:**
   - `core/` - Design tokens, theme, constants
   - `features/common/widgets/` - Reusable UI components
   - `services/` - Platform integrations

### Import Patterns

```dart
// ✅ GOOD - Within same feature (relative)
import '../domain/settings_provider.dart';
import '../../common/widgets/eco_app_bar.dart';

// ✅ GOOD - Cross-feature (absolute package imports)
import 'package:greenwise/features/settings/domain/settings_provider.dart';
import 'package:greenwise/core/design/design_system.dart';

// ❌ BAD - Deep coupling
import '../../tips/presentation/widgets/daily_tip_card.dart'; // in progress screen
```

## 🧪 Testing Strategy

```
test/
├── Unit Tests
│   └── streak_repository_test.dart      # Business logic tests
│
├── Widget Tests
│   ├── widget_test.dart                 # UI component rendering
│   └── mark_done_progress_test.dart     # State management tests
│
└── Integration Tests
    └── onboarding_navigation_test.dart  # User flow tests
```

**Coverage:** 6/6 tests passing ✅

## 🚀 Quick Reference

### Adding a New Feature

```bash
# 1. Create folder structure
mkdir -p lib/features/my_feature/domain
mkdir -p lib/features/my_feature/presentation

# 2. Create provider (domain layer)
touch lib/features/my_feature/domain/my_feature_provider.dart

# 3. Create screen (presentation layer)
touch lib/features/my_feature/presentation/my_feature_screen.dart
```

### Provider Template

```dart
// lib/features/my_feature/domain/my_feature_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/my_feature_repository.dart';

final myFeatureRepositoryProvider = Provider<MyFeatureRepository>((ref) {
  return MyFeatureRepositoryImpl();
});

final myFeatureDataProvider = FutureProvider<MyData>((ref) async {
  final repo = ref.watch(myFeatureRepositoryProvider);
  return repo.loadData();
});
```

### Screen Template

```dart
// lib/features/my_feature/presentation/my_feature_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/my_feature_provider.dart';

class MyFeatureScreen extends ConsumerWidget {
  const MyFeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(myFeatureDataProvider);
    
    return dataAsync.when(
      data: (data) => Scaffold(/* ... */),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

---

**Architecture Version:** 2.0 (Clean Architecture + Feature-First)  
**Last Updated:** Phase 2 Completion  
**Status:** ✅ Production Ready
