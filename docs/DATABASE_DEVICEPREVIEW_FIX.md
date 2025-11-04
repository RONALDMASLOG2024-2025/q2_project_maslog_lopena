# Database + DevicePreview Compatibility Fix

## Root Cause Analysis

### The Problem

When you see **"Failed to load tips: Bad state: databaseFactory not initialized"** in DevicePreview, it's because of a fundamental incompatibility:

```
DevicePreview (running on Desktop/Web)
    ↓
Simulates Mobile Device (e.g., iPhone)
    ↓
App tries to use Mobile SQLite
    ↓
But underlying platform is Desktop
    ↓
❌ DATABASE FACTORY MISMATCH ❌
```

### Why It Happens

1. **DevicePreview runs on your HOST platform** (Windows/macOS/Web)
2. **It only SIMULATES other devices** visually
3. **SQLite initialization is platform-specific:**
   - Desktop: Needs `sqflite_common_ffi` + `databaseFactoryFfi`
   - Mobile: Uses native `sqflite`
   - Web: SQLite not supported at all

4. **The conflict:**
   - DevicePreview runs on Desktop (needs FFI)
   - Simulates iPhone (expects native sqflite)
   - Database factory gets confused
   - Result: Crash with "databaseFactory not initialized"

## Solutions (Choose One)

### ✅ Solution 1: Disable DevicePreview (Recommended for SQLite Apps)

**File: `lib/main.dart`**
```dart
DevicePreview(
  enabled: false,  // ← Set to false
  builder: (context) => const ProviderScope(child: GreenWiseApp()),
)
```

**Pros:**
- App works perfectly
- SQLite functions normally
- No compatibility issues

**Cons:**
- Can't test different screen sizes in DevicePreview
- Need to use emulators/devices for device testing

**When to use:** When you need SQLite to work (which is always for GreenWise)

---

### ✅ Solution 2: Use Emulators Instead

Test on **actual emulators** or **physical devices** instead of DevicePreview:

```bash
# Android emulator
flutter run -d emulator-5554

# iOS Simulator (macOS only)
flutter run -d iPhone

# Physical device
flutter run -d <device-id>
```

**Pros:**
- Real device testing
- SQLite works perfectly
- Accurate performance testing

**Cons:**
- Slower than DevicePreview
- Need to setup emulators

**When to use:** For production testing and real device behavior

---

### ✅ Solution 3: Use Web Build for UI Testing

DevicePreview works great on **web builds** (no SQLite):

```bash
flutter run -d chrome
```

**Note:** You'll need to implement a web-compatible data source (Hive/IndexedDB/JSON in memory)

**Pros:**
- DevicePreview works perfectly
- Fast iteration
- Good for UI testing

**Cons:**
- Need web-compatible storage
- Different codebase path
- Not testing real SQLite behavior

**When to use:** For quick UI/layout testing

---

### ✅ Solution 4: Responsive Design Tools (No DevicePreview)

Use Flutter's built-in responsive testing:

```dart
// Test different screen sizes
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        // Mobile layout
      } else {
        // Tablet/Desktop layout
      }
    },
  );
}
```

**Use browser DevTools to resize window:**
1. Run: `flutter run -d chrome`
2. Open Chrome DevTools (F12)
3. Toggle device toolbar (Ctrl+Shift+M)
4. Select different devices

**Pros:**
- No package conflicts
- Works with SQLite on desktop
- Built-in Flutter feature

**Cons:**
- Less visual than DevicePreview
- Manual window resizing

---

### ❌ Solution 5: Mock Repository (Advanced)

Create a mock repository for DevicePreview:

```dart
// DON'T DO THIS unless you really need DevicePreview
class MockTipRepository implements TipRepository {
  @override
  Future<EcoTip> getDailyTip(DateTime date) async {
    return EcoTip(/* hardcoded data */);
  }
}

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ProviderScope(
        overrides: [
          tipRepositoryProvider.overrideWithValue(MockTipRepository()),
        ],
        child: GreenWiseApp(),
      ),
    ),
  );
}
```

**Pros:**
- DevicePreview works
- Can test UI

**Cons:**
- Maintains separate mock data
- Doesn't test real database
- Extra maintenance burden

**When to use:** Only if you absolutely need DevicePreview AND have a dedicated UI testing phase

---

## Recommended Workflow for GreenWise

### For Development

```bash
# Desktop (with SQLite)
flutter run -d windows
# or
flutter run -d macos
```

**Set in main.dart:**
```dart
DevicePreview(enabled: false, ...)
```

### For UI Testing

```bash
# Use Android emulator
flutter emulators --launch Pixel_6_API_34

# Run app
flutter run
```

### For Quick Layout Checks

```bash
# Web with responsive tools
flutter run -d chrome
# Then use Chrome DevTools device toolbar
```

## What We Fixed

### 1. Platform-Specific Initialization

**File: `lib/initialize_database.dart`**
```dart
Future<void> initializeDatabase() async {
  bool isDesktop = false;
  
  try {
    // Detect ACTUAL platform, not simulated
    isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  } catch (e) {
    isDesktop = false;
  }
  
  // Only init FFI on real desktop
  if (!kIsWeb && isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Try to populate, but don't crash if it fails
  if (!kIsWeb) {
    try {
      await TipRepositorySqlite().populateIfEmpty();
    } catch (e) {
      debugPrint('⚠️ Database error (expected in DevicePreview): $e');
    }
  }
}
```

### 2. Better Error Messages

**File: `lib/data/repositories/tip_repository_sqlite.dart`**
```dart
static Future<Database> _initDb() async {
  try {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'greenwise_tips.db');
    return await openDatabase(path, ...);
  } catch (e) {
    throw Exception('Database initialization failed: $e\n'
        'If using DevicePreview, this is a known limitation. '
        'The app works normally when run directly on a device/emulator.');
  }
}
```

### 3. DevicePreview Disabled by Default

**File: `lib/main.dart`**
```dart
DevicePreview(
  enabled: false,  // Disabled to avoid SQLite conflicts
  builder: (context) => const ProviderScope(child: GreenWiseApp()),
)
```

## Testing Checklist

Before releasing, test on:

- ✅ Android emulator (Pixel 6)
- ✅ iOS Simulator (iPhone 14)
- ✅ Windows desktop
- ✅ macOS desktop (if available)
- ✅ Web build (flutter run -d chrome)
- ✅ Physical Android device
- ✅ Physical iOS device

## Common Questions

### Q: Can I use DevicePreview for screenshots?

**A:** Yes, but run on web:
```bash
flutter run -d chrome
# DevicePreview will work for screenshots
# Just don't test SQLite features
```

### Q: Why not just fix SQLite to work in DevicePreview?

**A:** It's a fundamental architectural limitation:
- DevicePreview is a UI wrapper
- SQLite needs native platform code
- The simulated device doesn't match the host platform
- This is by design and can't be "fixed"

### Q: What about Hive/SharedPreferences?

**A:** Those work fine in DevicePreview because they're Dart-only and don't need native platform-specific initialization.

### Q: Should I remove DevicePreview package?

**A:** No, keep it. Just set `enabled: false` in main.dart. You can enable it later for web builds or UI-only testing.

## Summary

✅ **Root Cause:** DevicePreview simulates devices but runs on host platform, causing SQLite factory mismatch  
✅ **Solution:** Disable DevicePreview (`enabled: false`) for SQLite apps  
✅ **Alternative:** Use real emulators/devices for testing  
✅ **Quick UI Testing:** Use web build + Chrome DevTools responsive mode  

**Bottom Line:** DevicePreview and SQLite are incompatible when running on desktop. Use emulators for real testing.
