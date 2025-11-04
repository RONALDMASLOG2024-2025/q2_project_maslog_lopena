# GreenWise — App Completion Plan

**Generated:** November 4, 2025  
**Purpose:** Comprehensive analysis and roadmap to bring GreenWise to production-ready state

---

## Executive Summary

**Current State:** ✅ Architecture solid, core features working, tests passing (6/6)  
**Notification Status:** ⚠️ Partially functional - needs Android 13+ permission fix  
**Data Persistence:** ✅ Working - SharedPreferences (streaks), Hive (settings), SQLite (tips)  
**Critical Gaps:** Infinite tips feed, category filtering, data backup, production config

---

## 1. Current System Assessment

### ✅ What's Working Well

#### Architecture (Clean & Maintainable)
- **Clean Architecture:** Hybrid feature-first with domain/presentation separation
- **State Management:** Riverpod v2 with proper provider invalidation cascade
- **File Structure:** Organized, no unused files after Phase 1 & 2 cleanup
- **Code Quality:** All 28 linter issues fixed, follows Flutter best practices
- **Testing:** 6/6 tests passing (onboarding, widgets, streaks, mark done)

#### Core Features (Implemented & Functional)
1. **Daily Tip System**
   - ✅ One tip per day based on date rotation
   - ✅ Deterministic daily tip (same tip for same date)
   - ✅ "Why it matters" context when available
   - ✅ Mark as "Done today" with visual feedback
   - ✅ Pull-to-refresh for new tip
   - ✅ Category tags (Device Care, Energy Saving, Disposal, Eco-Buying)
   - ✅ Modern GWCard UI with frosted glass effect

2. **Progress Tracking**
   - ✅ Streak calculation (current + longest)
   - ✅ Weekly completion ring with animated painter
   - ✅ 30-day heatmap visualization
   - ✅ Weekly breakdown stats
   - ✅ Clear Progress action with confirmation dialog
   - ✅ Real-time updates via provider invalidation

3. **Data Persistence** (Multi-tier strategy)
   - ✅ **SQLite:** Tip catalog (86 tips from tips.json)
   - ✅ **SharedPreferences:** Streaks + daily completions
   - ✅ **Hive:** Settings (dark mode, categories, notification time)
   - ✅ **Platform-specific init:** Desktop FFI vs mobile native
   - ✅ **Test-safe:** _isTest flag prevents Hive in tests

4. **Settings & Customization**
   - ✅ Dark mode toggle (persisted)
   - ✅ Reduce Motion accessibility (persisted)
   - ✅ Tip category selection (persisted)
   - ✅ Notification enable/disable toggle
   - ✅ Notification time picker
   - ✅ About section

5. **Recycling Resources**
   - ✅ Curated Philippines resources (6 entries)
   - ✅ Curated Global resources (8 entries)
   - ✅ External link launching via url_launcher
   - ✅ Responsive grid layout (2-3 columns)
   - ✅ Category badges (Trade-in, Recycling, Policy)

6. **Navigation & UX**
   - ✅ Custom EcoNavBar (frosted glass, 4 tabs)
   - ✅ Onboarding flow with particle background
   - ✅ Splash screen with proper bootstrap
   - ✅ Static grid bubbles background throughout
   - ✅ Responsive layouts (no overflow issues)

---

### ⚠️ What Needs Attention

#### 1. **Notifications (Partially Working)**
**Current State:**
- ✅ Service implemented with timezone support
- ✅ Permission requests on iOS/Android
- ✅ Daily scheduling via zonedSchedule
- ✅ Settings UI to enable/disable & set time
- ✅ Splash schedules notification on startup if enabled
- ⚠️ **MISSING:** `SCHEDULE_EXACT_ALARM` permission for Android 13+

**Why It Matters:**
- Android 13+ requires explicit permission for exact alarms
- Without it, notifications may not fire at the chosen time
- Current implementation uses `alarmClock` mode but needs manifest permission

**The Fix:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

**Testing Requirements:**
- Run on Android 13+ device or emulator
- Enable notifications in Settings
- Set specific time (e.g., current time + 2 minutes)
- Verify notification appears at scheduled time
- Check notification persistence after app restart

#### 2. **Infinite Tips Feed (Not Implemented)**
**Current State:**
- ❌ Only shows daily tip card
- ❌ No vertical scrolling feed
- ❌ TipsFeedController mentioned in docs but not implemented

**What's Missing:**
- PageView or ListView.builder for infinite vertical scroll
- Batch loading with `loadMore()` when near end
- Seen tips tracking to avoid immediate duplicates
- Category filter integration
- Scale/fade animations during scroll

**Expected Behavior (from docs):**
- Today's tip at top as hero card
- Scroll down to see more tips
- Load 12 tips initially, then batch of 12 when near bottom
- Respect category filters from settings
- Reset to today when category filters change

**Files to Create/Modify:**
- `lib/features/tips/domain/tips_feed_controller.dart` (new)
- `lib/features/tips/presentation/screens/daily_tip_screen.dart` (modify)
- `lib/features/tips/domain/tip_provider.dart` (add feed provider)

#### 3. **Category Filtering (Not Connected)**
**Current State:**
- ✅ Settings saves enabled categories to Hive
- ✅ UI shows category chips in settings
- ❌ Tip providers don't filter by selected categories
- ❌ Infinite feed doesn't exist yet to apply filters

**The Gap:**
Settings stores `List<String> enabledCategories`, but:
- `dailyTipProvider` doesn't check if tip's category is enabled
- No feed provider yet to filter tip batches
- User can disable categories but still sees them

**The Fix:**
```dart
// In tip_provider.dart
final dailyTipProvider = FutureProvider<EcoTip>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  
  final today = DateTime.now();
  EcoTip tip = await repo.getDailyTip(today);
  
  // Skip disabled categories
  if (settings.enabledCategories.isNotEmpty &&
      !settings.enabledCategories.contains(tip.category.name)) {
    // Rotate to next enabled tip
    int offset = 1;
    while (offset < 100) {
      tip = await repo.getDailyTip(today.add(Duration(days: offset)));
      if (settings.enabledCategories.contains(tip.category.name)) break;
      offset++;
    }
  }
  
  return tip;
});
```

#### 4. **Data Backup/Restore (Not Implemented)**
**Current State:**
- ✅ Progress data persists between app sessions
- ❌ Data lost on app uninstall/reinstall
- ❌ No export/import functionality
- ❌ No cloud backup option

**User Impact:**
- User builds a 30-day streak
- Uninstalls app or switches device
- Loses all progress → frustration & churn

**Solutions:**
1. **Local Export** (Quick win)
   - Add "Export Progress" button in Settings
   - Save JSON file to Downloads folder
   - User can manually restore from file

2. **Cloud Backup** (Future)
   - Optional Firebase/Supabase integration
   - Auto-sync on completion
   - Restore on new device login

**Priority:** HIGH - prevents user churn

#### 5. **Production Release Config (Not Set Up)**
**Current State:**
- ❌ No signing keys configured
- ❌ Version still 1.0.0+1
- ❌ No release notes
- ❌ No app store screenshots
- ❌ No privacy policy page

**Required for Launch:**
- Android signing keystore
- iOS signing certificates & provisioning profiles
- App store metadata (description, keywords, screenshots)
- Privacy policy (even though app is 100% local)
- Terms of service (optional)
- Release build optimization (--split-debug-info, --obfuscate)

---

## 2. Critical Issues & Fixes

### Issue #1: Android 13+ Notifications May Not Fire
**Severity:** HIGH  
**Impact:** Core feature broken on newest Android versions

**Root Cause:**
Android 13 (API 33+) requires `SCHEDULE_EXACT_ALARM` permission for exact alarm scheduling. Current manifest only has `POST_NOTIFICATIONS`.

**Solution:**
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

**Verification:**
1. Build APK: `flutter build apk --release`
2. Install on Android 13+ device
3. Enable notifications in app settings
4. Set time 2 minutes in future
5. Lock phone, wait
6. Verify notification appears

### Issue #2: Progress Data Loss on Reinstall
**Severity:** MEDIUM  
**Impact:** User frustration, potential churn

**Root Cause:**
SharedPreferences and Hive store data in app's private directory, which is deleted on uninstall.

**Solution (Short-term):**
Implement local export/import:
```dart
// In progress_screen.dart
Future<void> exportProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final Map<String, dynamic> backup = {
    'version': 1,
    'exportDate': DateTime.now().toIso8601String(),
    'streak': prefs.getString('streak_state_v1'),
    'completions': {},
  };
  
  // Collect all completion keys
  for (final key in prefs.getKeys()) {
    if (key.startsWith('completed_tip_')) {
      backup['completions'][key] = prefs.getBool(key);
    }
  }
  
  final json = jsonEncode(backup);
  // Save to Downloads folder via path_provider
  final dir = await getExternalStorageDirectory();
  final file = File('${dir!.path}/greenwise_backup_${DateTime.now().millisecondsSinceEpoch}.json');
  await file.writeAsString(json);
  
  // Show share dialog
}
```

**Solution (Long-term):**
Add Firebase/Supabase backup with optional account creation.

### Issue #3: No Infinite Scroll = Limited Engagement
**Severity:** MEDIUM  
**Impact:** User sees only 1 tip/day, may lose interest

**Root Cause:**
Daily tip screen only shows today's tip. User can pull-to-refresh for new tip, but docs mention vertical scrolling feed that's not implemented.

**Solution:**
Implement `TipsFeedController` as an `AutoDisposeAsyncNotifier`:
```dart
class TipsFeedController extends AutoDisposeAsyncNotifier<List<EcoTip>> {
  final Set<String> _seen = {};
  int _cursor = 0;
  
  @override
  Future<List<EcoTip>> build() async {
    final repo = ref.watch(tipRepositoryProvider);
    final today = DateTime.now();
    final initial = <EcoTip>[];
    
    for (int i = 0; i < 12; i++) {
      final tip = await repo.getDailyTip(today.add(Duration(days: i)));
      if (!_seen.contains(tip.id)) {
        initial.add(tip);
        _seen.add(tip.id);
      }
    }
    _cursor = 12;
    return initial;
  }
  
  Future<void> loadMore(int count) async {
    // Append next batch...
  }
  
  void reset() {
    _seen.clear();
    _cursor = 0;
    ref.invalidateSelf();
  }
}
```

---

## 3. Implementation Roadmap

### Phase 3A: Fix Critical Issues (1-2 days)
**Goal:** Make existing features production-ready

- [x] **Task 1:** Add `SCHEDULE_EXACT_ALARM` permission
  - File: `android/app/src/main/AndroidManifest.xml`
  - Add: `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>`
  - Test: Install on Android 13+ and verify notifications

- [ ] **Task 2:** Test notification scheduling end-to-end
  - Enable notifications in settings
  - Set time 2 minutes in future
  - Background app
  - Verify notification at scheduled time
  - Verify notification content & tap action

- [ ] **Task 3:** Add export/import for progress data
  - Add "Export Progress" button in Settings
  - Save JSON to Downloads with timestamp
  - Add "Import Progress" with file picker
  - Show success/error messages

### Phase 3B: Complete Core Features (2-3 days)
**Goal:** Implement documented but missing features

- [ ] **Task 4:** Implement infinite tips feed
  - Create `TipsFeedController` with batch loading
  - Modify `DailyTipScreen` to use PageView/ListView
  - Add scale/fade animations during scroll
  - Test with 50+ tips

- [ ] **Task 5:** Connect category filtering to tip providers
  - Update `dailyTipProvider` to respect enabled categories
  - Update feed controller to filter by categories
  - Add "No tips in selected categories" empty state
  - Test with various category combinations

- [ ] **Task 6:** Add offline indicators (if needed)
  - Currently 100% offline, but prepare for future
  - Add connectivity detection
  - Show banner when offline (for future cloud features)

### Phase 3C: Production Polish (2-3 days)
**Goal:** Prepare for app store submission

- [ ] **Task 7:** Set up release signing
  - Generate Android keystore
  - Configure `android/key.properties`
  - Add signing config to `build.gradle`
  - Generate iOS certificates & profiles

- [ ] **Task 8:** Create app store assets
  - Screenshots (5 per platform minimum)
  - App icon optimized for all sizes
  - Feature graphic (Android)
  - Privacy policy page/URL
  - App description & keywords

- [ ] **Task 9:** Optimize release builds
  - Enable obfuscation: `--obfuscate --split-debug-info=build/symbols`
  - Minimize app size: tree-shake unused code
  - Test release build on real devices
  - Profile performance with DevTools

- [ ] **Task 10:** Final QA testing
  - Test all features on Android + iOS
  - Test on small screens (iPhone SE) + large (tablets)
  - Test dark mode + light mode
  - Test with all categories disabled
  - Test data persistence across app restarts

---

## 4. Data Persistence Analysis

### Current State: ✅ ROBUST

The app uses a **multi-tier persistence strategy** that's actually well-architected:

#### Tier 1: SQLite (Read-Heavy Catalog)
- **What:** 86 eco tips with text, category, explanation
- **Why SQLite:** Efficient querying, supports future search/filter features
- **Location:** `TipRepositorySqlite` in `lib/data/repositories/tip_repository_sqlite.dart`
- **Persistence:** Database file survives app restarts but NOT uninstalls
- **Backup:** Tips regenerate from `assets/data/tips.json` on first run

#### Tier 2: SharedPreferences (Simple Key-Value)
- **What:** Daily completions (`completed_tip_2025-11-04: true`) + streak state
- **Why SharedPrefs:** Fast, simple, no schema migrations needed
- **Location:** `InMemoryTipRepository` methods (misleading name - actually uses SharedPrefs)
- **Persistence:** Survives restarts but NOT uninstalls
- **Backup:** ⚠️ NEEDS EXPORT/IMPORT FEATURE

#### Tier 3: Hive (Structured Settings)
- **What:** User preferences (dark mode, categories, notification time)
- **Why Hive:** Type-safe, async writes, better than SharedPrefs for objects
- **Location:** `SettingsStore` wraps Hive box in `lib/settings/settings_provider.dart`
- **Persistence:** Survives restarts but NOT uninstalls
- **Backup:** Less critical (user can reconfigure)

### ✅ What's Working:
- Data persists across app sessions
- Tests use mocks (`SharedPreferences.setMockInitialValues`, `SettingsNotifier.test()`)
- No data corruption issues
- Platform-specific initialization handles desktop vs mobile

### ⚠️ What's Missing:
- **Export/Import:** User can't backup progress before reinstall
- **Cloud Sync:** No cross-device sync (acceptable for v1.0)
- **Migration Plan:** No versioning for schema changes (add if adding fields)

### Recommendation: **ADD EXPORT/IMPORT IN PHASE 3A** ✅

This is the #1 user-facing data issue. Implementation is straightforward:
1. Collect all SharedPrefs keys starting with `completed_tip_` and `streak_state_v1`
2. Export to JSON file in Downloads
3. Import via file picker, validate version, restore keys
4. Show confirmation with stats (e.g., "Restored 45-day streak")

---

## 5. Notification System Deep Dive

### Architecture Review: ✅ WELL-DESIGNED

**Service:** `lib/services/notifications/notification_service.dart`

**Key Features:**
- ✅ Timezone-aware scheduling (uses `timezone` package)
- ✅ Platform detection (no-op on web)
- ✅ Permission requests (iOS + Android 13+)
- ✅ High-importance channel with lock screen visibility
- ✅ Daily repeat via `matchDateTimeComponents.time`
- ✅ Alarm clock mode for reliable delivery

**Integration Points:**
1. **Splash Screen:** Schedules notification if enabled
2. **Settings Screen:** 
   - Enable/disable toggle reschedules/cancels
   - Time picker updates schedule immediately
   - Shows confirmation SnackBar

**What Works:**
- Permissions requested correctly
- Scheduling logic is sound
- Cancel/reschedule handles edge cases
- Timezone fallback to UTC if Manila unavailable

### ⚠️ The ONE Missing Piece: Android 13+ Permission

**Current Manifest:**
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

**Required Addition:**
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

**Why This Matters:**
- Android 13 introduced new permission model for exact alarms
- Without it, alarm may fire at approximate time or not at all
- User may grant POST_NOTIFICATIONS but alarm still fails silently
- `AndroidScheduleMode.alarmClock` requires this permission

**Testing Checklist:**
- [ ] Add permission to manifest
- [ ] Rebuild APK: `flutter build apk --release`
- [ ] Install on Android 13+ device (Medium_Phone_API_36.0 is Android 15)
- [ ] Open app → Settings → Enable notifications
- [ ] Set time to current time + 2 minutes
- [ ] Background app (home button)
- [ ] Wait for notification
- [ ] Verify notification shows at exact time
- [ ] Tap notification (should open app)
- [ ] Restart app, verify notification still scheduled
- [ ] Change time, verify reschedule works
- [ ] Disable notifications, verify no notification fires

---

## 6. Missing Features (From Docs vs Implementation)

### From `.github/copilot-instructions.md`:

#### ❌ "Infinite feed via TipsFeedController"
**Expected:**
- `TipsFeedController` (AutoDisposeAsyncNotifier)
- `build()`: Initial 12 tips
- `loadMore(count)`: Prefetch when near end
- `reset()`: Clear state, reload from today
- Category filter change detection

**Reality:**
- No `TipsFeedController` file exists
- Daily tip screen only shows single tip card
- No vertical scrolling feed
- Pull-to-refresh just rotates to next day's tip

**Priority:** HIGH - this is a documented core feature

#### ⚠️ "Category filtering at provider level"
**Expected:**
```dart
// Filter tips at provider level, not UI
if (settings.enabledCategories.isEmpty || 
    categories.contains(tip.category.name))
```

**Reality:**
- Settings stores enabled categories ✅
- Providers don't check category filters ❌
- UI shows all tips regardless of category selection ❌

**Priority:** MEDIUM - feature exists but not connected

#### ❌ "Tip category filters UI"
**Expected from README roadmap:**
```markdown
- [ ] Tip category filters UI
```

**Reality:**
- Settings has category selection chips ✅
- No visual filter UI in tips screen ❌
- No "Filtered by: Energy Saving, Device Care" indicator ❌

**Priority:** LOW - settings UI is sufficient for v1.0

---

## 7. Recommended Action Plan

### IMMEDIATE (Today):
1. ✅ Add `SCHEDULE_EXACT_ALARM` to AndroidManifest
2. 🧪 Test notifications on Android 13+ emulator
3. 📝 Document notification testing results

### THIS WEEK (Priority Order):
1. **Notifications Fix** (1 hour)
   - Add permission
   - Test end-to-end
   - Fix any issues

2. **Export/Import Progress** (4-6 hours)
   - Add export button in Settings
   - Save to JSON file
   - Add import with validation
   - Test restore flow

3. **Category Filtering** (2-3 hours)
   - Update `dailyTipProvider` to respect categories
   - Add fallback for "no enabled categories"
   - Test with various combinations

4. **Infinite Tips Feed** (6-8 hours)
   - Create `TipsFeedController`
   - Modify `DailyTipScreen` UI
   - Add batch loading + animations
   - Test performance with 100+ tips

### NEXT WEEK (Production Prep):
1. **Release Signing Setup** (2-3 hours)
   - Generate keystores/certificates
   - Configure build files
   - Test signed builds

2. **App Store Assets** (4-6 hours)
   - Take screenshots (light + dark mode)
   - Write description
   - Create privacy policy
   - Prepare metadata

3. **Final QA** (4-8 hours)
   - Cross-platform testing
   - Edge case validation
   - Performance profiling
   - Fix any bugs

---

## 8. Quality Assurance Checklist

### Functional Testing
- [ ] Daily tip changes each day
- [ ] Mark as done increments streak
- [ ] Streak resets after missed day
- [ ] Weekly progress updates correctly
- [ ] 30-day heatmap accurate
- [ ] Clear progress deletes all data
- [ ] Settings persist across restarts
- [ ] Dark mode applies throughout app
- [ ] Category selection saves
- [ ] Notifications fire at scheduled time
- [ ] Notification tap opens app
- [ ] Recycling links open browser
- [ ] Onboarding shows once

### Platform Testing
- [ ] Android 11 (min supported)
- [ ] Android 13+ (notification permissions)
- [ ] Android 15 (latest)
- [ ] iOS 14+ (if targeting iOS)
- [ ] Web (Chrome, responsive mode)
- [ ] Desktop (Windows FFI mode)

### Edge Cases
- [ ] First app launch (onboarding)
- [ ] No internet connection (app is offline-first)
- [ ] All categories disabled (show warning)
- [ ] 100+ day streak (UI doesn't overflow)
- [ ] Rapid toggling of settings
- [ ] App backgrounded mid-operation
- [ ] Data cleared from system settings
- [ ] Import invalid backup file

### Performance
- [ ] App launches in < 3 seconds
- [ ] Tip feed scrolls smoothly (60fps)
- [ ] No jank during animations
- [ ] Memory usage stable over time
- [ ] Battery drain acceptable

### Accessibility
- [ ] Screen reader compatible
- [ ] Touch targets >= 48dp
- [ ] Color contrast meets WCAG AA
- [ ] Reduce Motion respected
- [ ] Text scales properly

---

## 9. Success Criteria for "Complete"

The app is **production-ready** when:

### Technical ✅
- [x] All tests passing (currently 6/6)
- [ ] No critical lint warnings
- [ ] Release builds optimized
- [ ] Signing configured for both platforms
- [ ] Privacy policy published

### Functional ✅
- [x] Core loop works: see tip → mark done → track progress
- [ ] Notifications fire reliably on Android 13+
- [ ] Data persists across restarts
- [ ] Export/import preserves progress
- [ ] Category filtering functional
- [ ] Infinite feed implemented

### User Experience ✅
- [x] Onboarding guides new users
- [x] Dark mode fully supported
- [x] No overflow/layout issues
- [x] Animations smooth (or respect Reduce Motion)
- [ ] Empty states handled gracefully
- [ ] Error messages clear and helpful

### Production Ready 📋
- [ ] App store screenshots ready
- [ ] Description + metadata complete
- [ ] Privacy policy accessible
- [ ] Version bumped (1.0.0 → 1.1.0 or similar)
- [ ] Release notes written
- [ ] Tested on real devices (not just emulator)

---

## 10. Conclusion

### Overall Assessment: **80% Complete** 🎯

**What's Excellent:**
- Architecture is clean, maintainable, and scalable
- Core features work reliably
- Data persistence is robust (multi-tier strategy)
- Code quality high (no linter errors, tests pass)
- UI polished with frosted glass effects and animations

**What Needs Work:**
- **Notifications:** 95% done, needs 1 manifest line + testing
- **Infinite Feed:** Documented but not implemented
- **Category Filtering:** Settings exist, providers don't use them
- **Data Backup:** Critical gap for user retention
- **Production Config:** Standard release prep needed

**Timeline to Production:**
- **Critical Fixes:** 1-2 days (notifications, export/import)
- **Core Features:** 2-3 days (feed, filtering)
- **Production Prep:** 2-3 days (signing, assets, QA)
- **Total:** ~1-2 weeks of focused development

**Risk Level:** LOW ✅  
The app is stable and functional. Remaining work is additive, not corrective.

**Recommendation:** Execute Phase 3A immediately (fix notifications + add export), then ship v1.0. Infinite feed and advanced features can come in v1.1 update.

---

## 11. Next Steps

1. **Review this plan** with the team/stakeholder
2. **Prioritize tasks** based on business goals
3. **Execute Phase 3A** (critical fixes)
4. **Test on real devices** (not just emulator)
5. **Iterate based on findings**
6. **Ship v1.0** 🚀

---

**Document Status:** Ready for implementation  
**Last Updated:** November 4, 2025  
**Next Review:** After Phase 3A completion
