# GreenWise — Data Storage Locations

**Last Updated:** November 4, 2025

This document explains where all app data is stored on different platforms and how to access it.

---

## Overview

GreenWise uses a **multi-tier storage strategy** with three different storage mechanisms:

| Data Type | Storage | Location | Survives Restart | Survives Uninstall |
|-----------|---------|----------|-----------------|-------------------|
| **Eco Tips Catalog** | SQLite | App Database Directory | ✅ | ❌ |
| **Streaks & Completions** | SharedPreferences | Platform-specific | ✅ | ❌ |
| **Settings** | Hive | App Documents Directory | ✅ | ❌ |
| **Backup Files** | JSON Files | App Documents Directory | ✅ | ✅ (if manually saved) |

---

## 1. SQLite Database (Tips Catalog)

### What's Stored
- 86 eco tips with text, category, explanation, creation date
- Database file: `greenwise_tips.db`
- Table: `tips` with columns: id, text, category, createdAt, why, isActive

### File Location by Platform

#### Android
```
/data/data/com.example.greenwise/databases/greenwise_tips.db
```
- Path obtained via: `getDatabasesPath()` from `sqflite` package
- Full path example: `/data/data/com.example.greenwise/databases/greenwise_tips.db`
- **Access:** Requires root access or Android Debug Bridge (adb)
- **View with adb:**
  ```bash
  adb shell
  run-as com.example.greenwise
  cd databases
  ls -la greenwise_tips.db
  ```

#### iOS
```
/var/mobile/Containers/Data/Application/<UUID>/Library/Application Support/greenwise_tips.db
```
- UUID changes per app installation
- **Access:** Requires jailbroken device or iTunes backup extraction

#### Windows (Desktop)
```
C:\Users\<YourUsername>\AppData\Roaming\com.example\greenwise\databases\greenwise_tips.db
```
- Actual path on your PC: `C:\Users\hp\AppData\Roaming\com.example\greenwise\databases\greenwise_tips.db`
- **Access:** Navigate directly in File Explorer (AppData is hidden by default)
- **View:** Use SQLite browser like [DB Browser for SQLite](https://sqlitebrowser.org/)

#### macOS
```
~/Library/Containers/com.example.greenwise/Data/Library/Application Support/greenwise_tips.db
```

#### Linux
```
~/.local/share/com.example.greenwise/databases/greenwise_tips.db
```

### How to View/Export SQLite Data

**On Windows (Desktop):**
1. Show hidden files in File Explorer
2. Navigate to: `C:\Users\hp\AppData\Roaming\com.example\greenwise\databases\`
3. Copy `greenwise_tips.db` to your desktop
4. Open with DB Browser for SQLite or any SQLite viewer

**On Android (with adb):**
```bash
# Pull database from device
adb pull /data/data/com.example.greenwise/databases/greenwise_tips.db ./greenwise_tips.db

# View with sqlite3
sqlite3 greenwise_tips.db
.tables
SELECT * FROM tips LIMIT 10;
```

**Code Reference:**
- File: `lib/data/repositories/tip_repository_sqlite.dart`
- Line 142: `final dbPath = await getDatabasesPath();`
- Line 143: `final path = join(dbPath, 'greenwise_tips.db');`

---

## 2. SharedPreferences (Streaks & Completions)

### What's Stored
- Daily completion flags: `completed_tip_2025-11-04: true`
- Streak state: `streak_state_v1: {"currentStreak":5,"longestStreak":12,"lastCompletionDate":"2025-11-04T00:00:00.000"}`
- Simple key-value pairs (no complex objects)

### File Location by Platform

#### Android
```
/data/data/com.example.greenwise/shared_prefs/FlutterSharedPreferences.xml
```
- XML file with all SharedPreferences data
- **Access with adb:**
  ```bash
  adb shell
  run-as com.example.greenwise
  cat shared_prefs/FlutterSharedPreferences.xml
  ```

#### iOS
```
/var/mobile/Containers/Data/Application/<UUID>/Library/Preferences/com.example.greenwise.plist
```
- Property list (plist) format

#### Windows
```
C:\Users\<YourUsername>\AppData\Roaming\com.example\greenwise\shared_preferences.json
```
- JSON file with all preferences
- Actual path: `C:\Users\hp\AppData\Roaming\com.example\greenwise\shared_preferences.json`

#### macOS
```
~/Library/Containers/com.example.greenwise/Data/Library/Preferences/com.example.greenwise.plist
```

#### Linux
```
~/.config/com.example.greenwise/shared_preferences.json
```

### Example Data
```json
{
  "flutter.streak_state_v1": "{\"currentStreak\":5,\"longestStreak\":12,\"lastCompletionDate\":\"2025-11-04T00:00:00.000\"}",
  "flutter.completed_tip_2025-11-04": true,
  "flutter.completed_tip_2025-11-03": true,
  "flutter.completed_tip_2025-11-02": true
}
```

**Code Reference:**
- File: `lib/data/repositories/tip_repository.dart`
- Line 46: `Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();`
- Line 48: `String _completionKey(DateTime date) => '$_completedKeyPrefix${date.toIso8601String().substring(0, 10)}';`

---

## 3. Hive (Settings)

### What's Stored
- Dark mode preference
- Enabled tip categories
- Notification time (hour, minute)
- Notifications enabled flag
- Has onboarded flag
- Reduce motion setting

### File Location by Platform

#### Android
```
/data/data/com.example.greenwise/app_flutter/settings_box.hive
```
- Binary file in Hive's proprietary format

#### iOS
```
/var/mobile/Containers/Data/Application/<UUID>/Documents/settings_box.hive
```

#### Windows
```
C:\Users\<YourUsername>\AppData\Roaming\com.example\greenwise\settings_box.hive
```
- Actual path: `C:\Users\hp\AppData\Roaming\com.example\greenwise\settings_box.hive`

#### macOS
```
~/Library/Containers/com.example.greenwise/Data/Documents/settings_box.hive
```

#### Linux
```
~/.local/share/com.example.greenwise/settings_box.hive
```

### Note on Hive Format
- Hive stores data in a binary format (not human-readable)
- To view: Use Hive's API or export via app functionality
- Settings are loaded during splash screen initialization

**Code Reference:**
- File: `lib/settings/settings_provider.dart`
- Line 6: `const _settingsBox = 'settings_box';`
- Initialization: `lib/splash/splash_screen.dart` calls `SettingsStore.ensureInitialized()`

---

## 4. Backup Files (Export)

### What's Stored
- Complete snapshot of progress data (streaks + completions)
- JSON format (human-readable)
- Metadata: version, export date, platform

### File Location

#### Android
```
/storage/emulated/0/Android/data/com.example.greenwise/files/greenwise_backup_<timestamp>.json
```
- External storage (user-accessible)
- Shows in Files app under "GreenWise" folder

#### iOS
```
/var/mobile/Containers/Data/Application/<UUID>/Documents/greenwise_backup_<timestamp>.json
```
- App's documents directory
- Accessible via iTunes/Finder file sharing

#### Windows
```
C:\Users\<YourUsername>\AppData\Roaming\com.example\greenwise\greenwise_backup_<timestamp>.json
```
- Actual path: `C:\Users\hp\AppData\Roaming\com.example\greenwise\greenwise_backup_<timestamp>.json`
- Easy to navigate in File Explorer

#### macOS
```
~/Library/Containers/com.example.greenwise/Data/Documents/greenwise_backup_<timestamp>.json
```

#### Linux
```
~/.local/share/com.example.greenwise/greenwise_backup_<timestamp>.json
```

### Example Backup File
```json
{
  "version": 1,
  "exportDate": "2025-11-04T14:30:00.000",
  "appName": "GreenWise",
  "streak": "{\"currentStreak\":5,\"longestStreak\":12,\"lastCompletionDate\":\"2025-11-04T00:00:00.000\"}",
  "completions": {
    "completed_tip_2025-11-04": true,
    "completed_tip_2025-11-03": true,
    "completed_tip_2025-11-02": true
  },
  "metadata": {
    "totalCompletions": 3,
    "platform": "windows"
  }
}
```

**Code Reference:**
- File: `lib/services/backup/backup_service.dart`
- Line 106: `final directory = await getApplicationDocumentsDirectory();`
- Line 108: `final fileName = 'greenwise_backup_$timestamp.json';`

---

## How to Access Your Data

### On Windows (Easiest)

1. **Show Hidden Files:**
   - Open File Explorer
   - Click View → Show → Hidden items

2. **Navigate to App Data:**
   ```
   C:\Users\hp\AppData\Roaming\com.example\greenwise\
   ```

3. **Files You'll Find:**
   - `databases/greenwise_tips.db` - SQLite database with all tips
   - `shared_preferences.json` - Streaks and completions
   - `settings_box.hive` - Settings (binary format)
   - `greenwise_backup_*.json` - Any exported backups

### On Android (Requires ADB)

1. **Enable USB Debugging** on your device
2. **Connect to PC** with USB cable
3. **Run commands:**
   ```bash
   # List all app data
   adb shell run-as com.example.greenwise ls -la
   
   # Pull database
   adb pull /data/data/com.example.greenwise/databases/greenwise_tips.db
   
   # View SharedPreferences
   adb shell run-as com.example.greenwise cat shared_prefs/FlutterSharedPreferences.xml
   ```

### Via App Export Feature ✅ RECOMMENDED

1. Open GreenWise app
2. Go to **Progress** tab
3. Scroll to **Maintenance** section
4. Tap **Export** button
5. File saved to app documents directory
6. On Android: Check "GreenWise" folder in Files app
7. On Windows: Navigate to `C:\Users\hp\AppData\Roaming\com.example\greenwise\`

---

## Data Backup Strategy

### Current Implementation ✅

1. **Automatic Persistence:**
   - All data auto-saves on every change
   - No manual save needed
   - Survives app restarts

2. **Manual Export:**
   - Tap "Export" in Progress screen
   - Creates timestamped JSON backup
   - User can save to cloud (Google Drive, Dropbox, etc.)

3. **Manual Import:**
   - Tap "Import" in Progress screen
   - Select backup JSON file
   - Restores all progress data

### Best Practices for Users

1. **Export Weekly:**
   - Especially if you have a long streak
   - Keep backup in cloud storage
   - Multiple backups recommended

2. **Before Uninstall:**
   - ALWAYS export first
   - App uninstall = permanent data loss without export

3. **Device Switch:**
   - Export on old device
   - Install app on new device
   - Import backup file
   - All progress restored!

---

## Developer Notes

### Testing Database Locally

**On Windows (during development):**
```bash
# Run app
flutter run -d windows

# Find database
cd C:\Users\hp\AppData\Roaming\com.example\greenwise\databases\

# View with sqlite3
sqlite3 greenwise_tips.db
.tables
SELECT COUNT(*) FROM tips;
SELECT * FROM tips WHERE category='energySaving' LIMIT 5;
```

### Clearing All Data (for testing)

**Windows:**
```bash
# Stop app first
flutter run -d windows --quit

# Delete all data
rm -Recurse C:\Users\hp\AppData\Roaming\com.example\greenwise\
```

**Android:**
```bash
# Uninstall and reinstall
adb uninstall com.example.greenwise
flutter install
```

### Database Seeding

- Tips are seeded from `assets/data/tips.json` on first run
- File: `lib/data/repositories/tip_repository_sqlite.dart`
- Method: `populateIfEmpty()` called in `main.dart` (desktop only)

---

## Troubleshooting

### "Database not found"
- First run: Database created automatically
- Subsequent runs: Loads from saved location
- If missing: App recreates and reseeds from assets

### "Streak reset unexpectedly"
- SharedPreferences cleared (rare)
- Device storage full
- Solution: Use Export feature regularly

### "Settings not saving"
- Hive initialization failed
- Check storage permissions
- Try clearing app data and restarting

### "Can't find backup file"
- Check app documents directory (paths above)
- Windows: Show hidden files
- Android: Check "GreenWise" folder in Files app
- iOS: Check Files app → On My iPhone → GreenWise

---

## Summary

**Quick Reference:**

| What | Where (Windows) |
|------|----------------|
| Tips Database | `C:\Users\hp\AppData\Roaming\com.example\greenwise\databases\greenwise_tips.db` |
| Streaks/Completions | `C:\Users\hp\AppData\Roaming\com.example\greenwise\shared_preferences.json` |
| Settings | `C:\Users\hp\AppData\Roaming\com.example\greenwise\settings_box.hive` |
| Backups | `C:\Users\hp\AppData\Roaming\com.example\greenwise\greenwise_backup_*.json` |

**Important:**
- ❌ Uninstall = ALL DATA LOST (except manual backups)
- ✅ Export regularly to prevent data loss
- ✅ Backups are portable across devices
- ✅ All data stored locally (no cloud, 100% private)

---

**Last Updated:** November 4, 2025  
**App Version:** 1.0.0+1
