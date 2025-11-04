# GreenWise Architecture Optimization Plan
**Date:** November 4, 2025  
**Goal:** Reorganize lib/ folder following Clean Architecture principles for better maintainability

## 📊 Current Structure Analysis

### Issues Identified:

#### 1. **Unused/Empty Files & Folders**
- ❌ `services/ai/ai_service.dart` - Empty placeholder, never imported
- ❌ `data/tips_database.dart` - Empty file
- ❌ `features/onboarding/widgets/particle_background.dart` - Duplicate, unused
- ❌ `features/onboarding/widgets/eco_particle_background.dart` - Unused
- ❌ `features/onboarding/widgets/web_wires_background.dart` - Unused (complex animation, never imported)
- ❌ `features/common/widgets/particle_background.dart` - Duplicate
- ❌ `features/settings/presentation/` - Empty folder
- ❌ `features/tips/data/` - Empty folder  
- ❌ `services/storage/` - Empty folder

#### 2. **Inconsistent Feature Structure**
```
❌ Current (inconsistent):
lib/
├── settings/           # Root level (should be in features/)
│   ├── settings_provider.dart
│   └── settings_screen.dart
├── splash/             # Root level (should be in features/)
│   └── splash_screen.dart
└── features/
    ├── tips/           # Has application/ + presentation/
    ├── progress/       # Has application/ + presentation/
    ├── resources/      # Missing proper structure
    └── habit/          # Only has presentation/
```

#### 3. **Repository Duplication**
- ✅ `TipRepositorySqlite` - USED (main implementation)
- ❌ `LocalTipRepository` - UNUSED (legacy, never imported)
- ✅ `LocalRecyclingRepository` - USED
- ✅ `TipRepository` - USED (interface)

---

## 🎯 Proposed Clean Architecture Structure

### Target Structure:
```
lib/
├── main.dart
├── app_shell.dart
│
├── core/                          # Shared utilities (no business logic)
│   ├── theme/
│   │   └── app_theme.dart
│   ├── design/
│   │   └── design_system.dart    # GWDs, GWCard
│   └── constants/
│       └── app_colors.dart
│
├── data/                          # Data layer (repositories, models, sources)
│   ├── models/
│   │   ├── eco_tip.dart
│   │   ├── recycling_resource.dart
│   │   └── streak.dart
│   └── repositories/
│       ├── tip_repository.dart           # Interface
│       ├── tip_repository_impl.dart      # SQLite implementation (RENAMED)
│       └── recycling_repository.dart     # Merged interface + impl
│
├── domain/                        # Business logic (providers, use cases)
│   ├── providers/
│   │   ├── tip_provider.dart            # Daily tip + infinite feed
│   │   ├── progress_provider.dart       # Progress stats + streak
│   │   ├── settings_provider.dart       # Settings state
│   │   └── recycling_provider.dart      # Recycling resources
│   └── entities/                         # (Optional: if different from models)
│
├── presentation/                  # UI layer (all features)
│   ├── common/
│   │   └── widgets/
│   │       ├── eco_app_bar.dart
│   │       ├── eco_nav_bar.dart
│   │       └── static_grid_bubbles_background.dart
│   │
│   ├── splash/
│   │   └── splash_screen.dart
│   │
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   │
│   ├── tips/
│   │   └── widgets/
│   │       ├── daily_tip_card_modern.dart
│   │       ├── daily_tip_card.dart      # Legacy (consider removing)
│   │       └── tip_hero_stats.dart
│   │
│   ├── progress/
│   │   └── progress_screen.dart
│   │
│   ├── recycling/
│   │   └── recycling_directory_screen.dart
│   │
│   └── settings/
│       └── settings_screen.dart
│
└── services/                      # External services (notifications, etc.)
    └── notifications/
        └── notification_service.dart
```

### Key Improvements:
1. ✅ **Clear separation of concerns**: Data → Domain → Presentation
2. ✅ **Consistent feature organization**: All features follow same structure
3. ✅ **Removed duplication**: One background widget, one tip repository
4. ✅ **Flat presentation layer**: Easier navigation
5. ✅ **Domain layer**: Centralized providers for business logic

---

## 🔄 Migration Plan

### Phase 1: Remove Unused Files ✅
```powershell
# Delete unused files
Remove-Item lib/services/ai/ai_service.dart
Remove-Item lib/data/tips_database.dart
Remove-Item lib/features/onboarding/widgets/particle_background.dart
Remove-Item lib/features/onboarding/widgets/eco_particle_background.dart
Remove-Item lib/features/onboarding/widgets/web_wires_background.dart
Remove-Item lib/features/common/widgets/particle_background.dart

# Remove empty folders
Remove-Item lib/features/settings/presentation -Recurse
Remove-Item lib/features/tips/data -Recurse
Remove-Item lib/services/storage -Recurse
Remove-Item lib/services/ai -Recurse
Remove-Item lib/features/onboarding/widgets -Recurse
```

### Phase 2: Reorganize Following Clean Architecture ✅

#### Option A: **Clean Architecture (Recommended)**
- Pros: Industry standard, scalable, testable
- Cons: More folders, slightly more complex for small apps
- Best for: Apps expected to grow, teams

#### Option B: **Feature-First (Current + Cleanup)**
- Pros: Simple, fast navigation
- Cons: Mixing concerns, harder to test in isolation
- Best for: Small apps, solo developers

**RECOMMENDATION:** **Option A (Clean Architecture)** because:
- GreenWise has 6 major features (tips, progress, settings, recycling, onboarding, splash)
- Already shows signs of growth (multiple tip repositories)
- Easier to test providers in isolation
- Industry-standard for Flutter apps

---

## 📋 Detailed Refactor Steps

### Step 1: Create New Folder Structure
```powershell
New-Item -ItemType Directory lib/domain/providers
New-Item -ItemType Directory lib/presentation/common/widgets
New-Item -ItemType Directory lib/presentation/splash
New-Item -ItemType Directory lib/presentation/onboarding
New-Item -ItemType Directory lib/presentation/tips/widgets
New-Item -ItemType Directory lib/presentation/progress
New-Item -ItemType Directory lib/presentation/recycling
New-Item -ItemType Directory lib/presentation/settings
```

### Step 2: Move Files to New Structure

#### Data Layer (Already Good)
- ✅ Keep `data/models/` as-is
- ✅ Keep `data/repositories/` but rename:
  - `tip_repository_sqlite.dart` → `tip_repository_impl.dart`
  - Delete `local_tip_repository.dart` (unused)
  - Merge `local_recycling_repository.dart` interface + impl

#### Domain Layer (New)
Move providers from features to centralized location:
- `features/tips/application/daily_tip_provider.dart` → `domain/providers/tip_provider.dart`
- `features/progress/application/progress_providers.dart` → `domain/providers/progress_provider.dart`
- `features/habit/presentation/streak_provider.dart` → `domain/providers/progress_provider.dart` (merge)
- `features/resources/recycling_provider.dart` → `domain/providers/recycling_provider.dart`
- `settings/settings_provider.dart` → `domain/providers/settings_provider.dart`

#### Presentation Layer (New)
Move all screens/widgets:
- `splash/splash_screen.dart` → `presentation/splash/splash_screen.dart`
- `features/onboarding/onboarding_screen.dart` → `presentation/onboarding/onboarding_screen.dart`
- `features/tips/presentation/widgets/*` → `presentation/tips/widgets/*`
- `features/progress/presentation/progress_screen.dart` → `presentation/progress/progress_screen.dart`
- `features/resources/recycling_directory_screen.dart` → `presentation/recycling/recycling_directory_screen.dart`
- `settings/settings_screen.dart` → `presentation/settings/settings_screen.dart`
- `features/common/widgets/*` → `presentation/common/widgets/*`

### Step 3: Update Import Paths
Use find/replace across all files:
```dart
// Old → New
import 'package:greenwise/features/tips/application/daily_tip_provider.dart'
→ import 'package:greenwise/domain/providers/tip_provider.dart'

import 'package:greenwise/settings/settings_provider.dart'
→ import 'package:greenwise/domain/providers/settings_provider.dart'

import 'package:greenwise/splash/splash_screen.dart'
→ import 'package:greenwise/presentation/splash/splash_screen.dart'

// ... etc
```

### Step 4: Verify & Test
```powershell
flutter analyze
flutter test
flutter run
```

---

## ⚖️ Decision: Clean Arch vs Feature-First?

### Evaluation Criteria

| Criterion | Clean Architecture | Feature-First (Current) |
|-----------|-------------------|------------------------|
| **Testability** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐ Good |
| **Scalability** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐ Moderate |
| **Learning Curve** | ⭐⭐⭐ Moderate | ⭐⭐⭐⭐⭐ Easy |
| **Navigation Speed** | ⭐⭐⭐ Good | ⭐⭐⭐⭐ Better |
| **Code Clarity** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐ Good |
| **Industry Standard** | ⭐⭐⭐⭐⭐ Yes | ⭐⭐ Not common |

### **FINAL DECISION: Hybrid Approach** ✅

Keep **feature-first** structure but with **clean architecture principles within each feature**:

```
lib/
├── core/              # Shared utilities
├── data/              # Models + Repositories (infrastructure)
├── features/          # Feature modules (domain + presentation together)
│   ├── tips/
│   │   ├── domain/        # Providers (business logic)
│   │   └── presentation/  # Screens + Widgets (UI)
│   ├── progress/
│   │   ├── domain/
│   │   └── presentation/
│   ├── settings/
│   │   ├── domain/
│   │   └── presentation/
│   └── ... (other features)
└── services/          # External integrations
```

**Why Hybrid?**
- ✅ Keeps related code together (easier navigation)
- ✅ Clean separation of domain/presentation within features
- ✅ Testable (domain layer can be tested independently)
- ✅ Familiar to most Flutter developers
- ✅ Less import path changes

---

## 🚀 Execution Plan (Conservative Approach)

### Immediate Actions (Low Risk):
1. ✅ Delete unused files (ai_service, tips_database, particle backgrounds)
2. ✅ Delete empty folders
3. ✅ Delete unused LocalTipRepository

### Next Actions (Medium Risk):
4. ✅ Move settings into features/settings/
5. ✅ Move splash into features/splash/
6. ✅ Rename tip_repository_sqlite → tip_repository_impl
7. ✅ Create domain/ folders within each feature
8. ✅ Move providers into domain/ subfolders

### Final Actions (Update imports):
9. ✅ Update all import paths
10. ✅ Run tests & analyzer
11. ✅ Manual smoke test

---

## 📝 Estimated Impact

- **Files Deleted:** 9
- **Files Moved:** ~15
- **Folders Created:** ~8
- **Import Updates:** ~40-50
- **Time Estimate:** 30-45 minutes
- **Risk Level:** Medium (requires careful import updates)

---

## ✅ Success Criteria

1. All tests pass (6/6)
2. No analyzer errors
3. App builds and runs successfully
4. All features work (manual testing)
5. Cleaner, more organized structure
6. Better aligned with Flutter best practices

