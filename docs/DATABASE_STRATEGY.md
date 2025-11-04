# GreenWise Database Strategy & Recommendations

## The Problem (Fixed ✅)

**Error:** `Bad state: databaseFactory not initialized`

**Cause:** The app was trying to initialize SQLite FFI for all non-web platforms, but mobile platforms (Android/iOS) use native SQLite and don't need FFI initialization.

**Fix Applied:** Updated `main.dart` to only initialize FFI for desktop platforms (Windows, macOS, Linux).

```dart
// ✅ CORRECT - Platform-specific initialization
if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
```

## Current Database Architecture

### SQLite for Tips (Read-Heavy)
- **Package:** `sqflite` (mobile) + `sqflite_common_ffi` (desktop)
- **Database:** `greenwise_tips.db`
- **Purpose:** Store eco-tips catalog
- **Why SQLite?** 
  - ✅ Efficient for 100+ tips with complex queries
  - ✅ Supports filtering by category
  - ✅ Deterministic daily rotation (`dayOfYear % totalTips`)
  - ✅ Works offline on all platforms (mobile + desktop)

### SharedPreferences for Completions/Streaks (Simple Key-Value)
- **Package:** `shared_preferences`
- **Purpose:** Track daily completions and streak state
- **Why SharedPreferences?**
  - ✅ Simple key-value pairs (`completed_tip_2025-11-04: true`)
  - ✅ Fast access for small data
  - ✅ Perfect for boolean flags and simple state

### Hive for Settings (Structured Offline Storage)
- **Package:** `hive`
- **Database:** `settings_box`
- **Purpose:** App settings (theme, categories, notifications)
- **Why Hive?**
  - ✅ No-SQL, type-safe
  - ✅ Faster than SQLite for small structured data
  - ✅ No boilerplate (no schemas, migrations)
  - ✅ Works identically on all platforms

## Is This the Best Database Strategy?

**Yes, the current multi-tier approach is excellent for your use case.** Here's why:

### ✅ Current Strategy (Hybrid - RECOMMENDED)
```
SQLite         → Tips catalog (read-heavy, complex queries)
SharedPrefs    → Completions/streaks (simple flags)
Hive           → Settings (structured objects)
```

**Pros:**
- ✅ Each storage type optimized for its use case
- ✅ Excellent offline support
- ✅ Fast performance (right tool for each job)
- ✅ Easy to maintain
- ✅ Works on mobile, desktop, and web (with fallbacks)

**Cons:**
- ⚠️ Slightly more complex (3 storage systems)
- ⚠️ Need to manage initialization for each

## Alternative Database Options

### 1. **Drift (formerly Moor)** - SQLite Wrapper
```dart
// Type-safe SQLite with code generation
@DriftDatabase(tables: [Tips, Completions])
class AppDatabase extends _$AppDatabase {}
```

**Pros:**
- ✅ Type-safe queries
- ✅ Reactive streams (watch data changes)
- ✅ Migration support
- ✅ Single database for all data

**Cons:**
- ❌ More boilerplate (code generation)
- ❌ Overkill for simple key-value data
- ❌ Steeper learning curve

**Verdict:** Good for complex apps, but your current approach is simpler.

---

### 2. **Isar** - High-Performance NoSQL
```dart
// Fast NoSQL database
final isar = await Isar.open([TipSchema, StreakSchema]);
final tips = await isar.tips.filter().categoryEqualTo('energySaving').findAll();
```

**Pros:**
- ✅ Extremely fast (faster than SQLite)
- ✅ Type-safe with code generation
- ✅ Reactive queries
- ✅ Full-text search built-in
- ✅ Cross-platform (mobile, desktop, web via IndexedDB)

**Cons:**
- ❌ Requires code generation
- ❌ Larger library size
- ❌ Newer library (less mature than SQLite)

**Verdict:** Excellent choice if you need more performance or want a single database solution.

---

### 3. **ObjectBox** - NoSQL with Relations
```dart
// Object-oriented database
final store = Store(getObjectBoxModel());
final box = store.box<Tip>();
await box.put(tip);
```

**Pros:**
- ✅ Very fast
- ✅ Supports relationships
- ✅ Reactive queries
- ✅ Cross-platform

**Cons:**
- ❌ Commercial license required for some use cases
- ❌ Requires code generation
- ❌ Limited web support

**Verdict:** Good for complex data models, but not needed for your app.

---

### 4. **Sembast** - Simple NoSQL
```dart
// Simple key-value store with queries
final db = await sembastFactory.openDatabase('app.db');
final store = intMapStoreFactory.store('tips');
await store.add(db, {'text': 'Turn off lights', 'category': 'energy'});
```

**Pros:**
- ✅ Pure Dart (no native dependencies)
- ✅ Works everywhere including web
- ✅ Simple API
- ✅ No code generation

**Cons:**
- ❌ Slower than SQLite for large datasets
- ❌ No type safety
- ❌ Manual indexing

**Verdict:** Good for web-first apps, but SQLite is faster for your tip catalog.

---

### 5. **All SQLite** - Single Database
```dart
// Everything in SQLite
CREATE TABLE tips (...);
CREATE TABLE completions (...);
CREATE TABLE settings (...);
```

**Pros:**
- ✅ Single database file
- ✅ ACID transactions
- ✅ Relational queries
- ✅ Battle-tested

**Cons:**
- ❌ Overkill for simple key-value data
- ❌ More boilerplate for settings
- ❌ Slower than Hive for small objects

**Verdict:** Valid approach, but your hybrid strategy is more optimized.

---

### 6. **All Hive** - Single NoSQL Database
```dart
// Everything in Hive
@HiveType(typeId: 0)
class Tip extends HiveObject { ... }
```

**Pros:**
- ✅ Simplest approach
- ✅ Fast for small datasets
- ✅ No code generation (for simple types)

**Cons:**
- ❌ No complex queries (can't filter efficiently)
- ❌ Slower than SQLite for large datasets
- ❌ Manual filtering required

**Verdict:** Too limiting for 100+ tips with category filtering.

## Recommendation: Keep Current Hybrid Approach ✅

Your current setup is **optimal** for GreenWise because:

1. **SQLite for Tips**: Perfect for the read-heavy tip catalog with filtering
2. **SharedPreferences for Completions**: Ideal for simple daily flags
3. **Hive for Settings**: Best for structured settings objects

### When to Consider Alternatives

**Switch to Isar if:**
- You add many more features (challenges, community, analytics)
- You need full-text search across tips
- You want reactive UI updates
- You want a single unified database

**Switch to Drift if:**
- You need complex relational queries
- You want type-safe SQL
- You prefer traditional SQL syntax

**For now: Keep current architecture** - it's clean, performant, and easy to maintain.

## Platform Support Matrix

| Database | Mobile | Desktop | Web |
|----------|--------|---------|-----|
| SQLite (current) | ✅ | ✅ | ❌ |
| SharedPreferences (current) | ✅ | ✅ | ✅ |
| Hive (current) | ✅ | ✅ | ✅ |
| Isar | ✅ | ✅ | ✅ (IndexedDB) |
| Drift | ✅ | ✅ | ✅ (sql.js) |
| Sembast | ✅ | ✅ | ✅ |

**Note:** For web, you'd need to migrate from SQLite to Hive or Isar for the tips catalog.

## Migration Path (If Needed)

If you decide to unify databases later:

### Option 1: Migrate to Isar (Recommended for Growth)
```dart
// 1. Add isar dependencies
// 2. Create schemas
@collection
class Tip {
  Id id = Isar.autoIncrement;
  late String text;
  @enumerated
  late EcoTipCategory category;
}

// 3. Migrate data from SQLite
final sqliteTips = await TipRepositorySqlite().getAllTips();
final isar = await Isar.open([TipSchema, StreakSchema]);
await isar.writeTxn(() async {
  await isar.tips.putAll(sqliteTips);
});
```

### Option 2: Migrate to Drift (For SQL Lovers)
```dart
// 1. Define tables with code generation
class Tips extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get text => text()();
  TextColumn get category => text()();
}

// 2. Auto-generate type-safe queries
final energyTips = await db.select(db.tips)
  .where((t) => t.category.equals('energySaving'))
  .get();
```

## Web Strategy

Since SQLite doesn't work on web, you have two options:

### Option 1: Keep Hybrid (Current)
- **Mobile/Desktop:** SQLite for tips
- **Web:** Load tips from JSON and store in Hive or memory

### Option 2: Use Cross-Platform DB
- **All Platforms:** Migrate to Isar or Sembast for tips
- **Benefit:** Single codebase, works everywhere

For now, **Option 1** is fine since web is not your primary target.

## Summary

✅ **The SQLite initialization issue is fixed**  
✅ **Current database architecture is optimal for offline-first mobile/desktop app**  
✅ **No migration needed** - your hybrid approach is industry-standard  
✅ **Future-proof:** Easy to migrate to Isar/Drift if app grows significantly  

**Bottom line:** SQLite is excellent for your use case. The error was just a platform detection bug, not a fundamental design flaw.
