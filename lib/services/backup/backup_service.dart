import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for exporting and importing user progress data (streaks + completions).
class BackupService {
  static const int _currentVersion = 1;
  static const String _streakKey = 'streak_state_v1';
  static const String _completedKeyPrefix = 'completed_tip_';

  /// Export all progress data to a JSON string.
  static Future<Map<String, dynamic>> exportProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, dynamic> backup = {
      'version': _currentVersion,
      'exportDate': DateTime.now().toIso8601String(),
      'appName': 'GreenWise',
      'streak': prefs.getString(_streakKey),
      'completions': <String, bool>{},
    };

    // Collect all completion keys
    int completionCount = 0;
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_completedKeyPrefix)) {
        final value = prefs.getBool(key);
        if (value == true) {
          backup['completions'][key] = value;
          completionCount++;
        }
      }
    }

    backup['metadata'] = {
      'totalCompletions': completionCount,
      'platform': Platform.operatingSystem,
    };

    return backup;
  }

  /// Import progress data from a JSON backup.
  /// Returns a map with 'success' (bool) and 'message' (String).
  static Future<Map<String, dynamic>> importProgressData(Map<String, dynamic> backup) async {
    try {
      // Validate backup structure
      if (backup['version'] == null || backup['version'] != _currentVersion) {
        return {
          'success': false,
          'message': 'Invalid or unsupported backup version',
        };
      }

      if (backup['appName'] != 'GreenWise') {
        return {
          'success': false,
          'message': 'Backup file is not from GreenWise',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      int restored = 0;

      // Restore streak
      if (backup['streak'] != null) {
        await prefs.setString(_streakKey, backup['streak']);
        restored++;
      }

      // Restore completions
      final completions = backup['completions'] as Map<String, dynamic>?;
      if (completions != null) {
        for (final entry in completions.entries) {
          if (entry.key.startsWith(_completedKeyPrefix) && entry.value == true) {
            await prefs.setBool(entry.key, true);
            restored++;
          }
        }
      }

      return {
        'success': true,
        'message': 'Successfully restored $restored items',
        'itemsRestored': restored,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to import: ${e.toString()}',
      };
    }
  }

  /// Save backup to a file in the app's documents directory.
  /// Returns the file path if successful, or null if failed.
  static Future<String?> saveBackupToFile(Map<String, dynamic> backup) async {
    if (kIsWeb) {
      // Web doesn't support file system access in the same way
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'greenwise_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      debugPrint('Error saving backup file: $e');
      return null;
    }
  }

  /// Read backup from a file.
  static Future<Map<String, dynamic>?> readBackupFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return json;
    } catch (e) {
      debugPrint('Error reading backup file: $e');
      return null;
    }
  }

  /// Get a summary of the backup data without importing it.
  static Map<String, dynamic> getBackupSummary(Map<String, dynamic> backup) {
    final completions = backup['completions'] as Map<String, dynamic>?;
    final metadata = backup['metadata'] as Map<String, dynamic>?;
    
    return {
      'version': backup['version'],
      'exportDate': backup['exportDate'],
      'totalCompletions': metadata?['totalCompletions'] ?? completions?.length ?? 0,
      'platform': metadata?['platform'] ?? 'unknown',
      'hasStreak': backup['streak'] != null,
    };
  }
}
