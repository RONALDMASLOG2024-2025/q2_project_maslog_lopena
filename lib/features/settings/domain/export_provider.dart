import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../progress/domain/progress_provider.dart';
import '../../progress/domain/streak_provider.dart';
import '../../settings/domain/settings_provider.dart';

/// Data export/import service for offline backup/restore
class ExportData {
  final Map<String, String> completions; // completed_tip_YYYY-MM-DD -> tipId
  final StreakData? streak;
  final SettingsData settings;
  final String exportedAt;
  final String appVersion;

  const ExportData({
    required this.completions,
    this.streak,
    required this.settings,
    required this.exportedAt,
    this.appVersion = '1.0.0',
  });

  Map<String, dynamic> toJson() => {
        'completions': completions,
        'streak': streak?.toJson(),
        'settings': settings.toJson(),
        'exported_at': exportedAt,
        'app_version': appVersion,
      };

  factory ExportData.fromJson(Map<String, dynamic> json) {
    return ExportData(
      completions: Map<String, String>.from(json['completions'] ?? {}),
      streak: json['streak'] != null ? StreakData.fromJson(json['streak']) : null,
      settings: SettingsData.fromJson(json['settings'] ?? {}),
      exportedAt: json['exported_at'] ?? DateTime.now().toIso8601String(),
      appVersion: json['app_version'] ?? '1.0.0',
    );
  }
}

class StreakData {
  final int current;
  final int longest;
  final String? lastCompletionDate;

  const StreakData({
    required this.current,
    required this.longest,
    this.lastCompletionDate,
  });

  Map<String, dynamic> toJson() => {
        'current': current,
        'longest': longest,
        'last_completion_date': lastCompletionDate,
      };

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      current: json['current'] ?? 0,
      longest: json['longest'] ?? 0,
      lastCompletionDate: json['last_completion_date'],
    );
  }
}

class SettingsData {
  final bool darkMode;
  final bool notificationsEnabled;
  final String notificationTime;
  final List<String> enabledCategories;

  const SettingsData({
    required this.darkMode,
    required this.notificationsEnabled,
    required this.notificationTime,
    required this.enabledCategories,
  });

  Map<String, dynamic> toJson() => {
        'dark_mode': darkMode,
        'notifications_enabled': notificationsEnabled,
        'notification_time': notificationTime,
        'enabled_categories': enabledCategories,
      };

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      darkMode: json['dark_mode'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      notificationTime: json['notification_time'] ?? '09:00',
      enabledCategories: List<String>.from(json['enabled_categories'] ?? []),
    );
  }
}

/// Provider for exporting progress data
final exportProgressProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final settings = ref.read(settingsProvider);

  // Get all completions
  final allKeys = prefs.getKeys();
  final completions = <String, String>{};
  for (final key in allKeys) {
    if (key.startsWith('completed_tip_')) {
      final tipId = prefs.getString(key);
      if (tipId != null) {
        completions[key] = tipId;
      }
    }
  }

  // Get streak data
  final streakJson = prefs.getString('streak_state_v1');
  StreakData? streak;
  if (streakJson != null) {
    try {
      final map = jsonDecode(streakJson) as Map<String, dynamic>;
      streak = StreakData(
        current: map['current'] ?? 0,
        longest: map['longest'] ?? 0,
        lastCompletionDate: map['lastDate'],
      );
    } catch (_) {}
  }

  // Create export data
  final exportData = ExportData(
    completions: completions,
    streak: streak,
    settings: SettingsData(
      darkMode: settings.darkMode,
      notificationsEnabled: settings.notificationsEnabled,
      notificationTime: '${settings.notificationTime.hour.toString().padLeft(2, '0')}:${settings.notificationTime.minute.toString().padLeft(2, '0')}',
      enabledCategories: settings.enabledCategories.toList(),
    ),
    exportedAt: DateTime.now().toIso8601String(),
  );

  return jsonEncode(exportData.toJson());
});

/// Provider for importing progress data
final importProgressProvider = FutureProvider.family<bool, String>((ref, jsonString) async {
  try {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final exportData = ExportData.fromJson(json);
    final prefs = await SharedPreferences.getInstance();

    // Import completions
    for (final entry in exportData.completions.entries) {
      await prefs.setString(entry.key, entry.value);
    }

    // Import streak
    if (exportData.streak != null) {
      final streakJson = jsonEncode({
        'current': exportData.streak!.current,
        'longest': exportData.streak!.longest,
        'lastDate': exportData.streak!.lastCompletionDate,
      });
      await prefs.setString('streak_state_v1', streakJson);
    }

    // Import settings (merge with current)
    final currentSettings = ref.read(settingsProvider);
    final newSettings = currentSettings.copyWith(
      darkMode: exportData.settings.darkMode,
      notificationsEnabled: exportData.settings.notificationsEnabled,
      enabledCategories: exportData.settings.enabledCategories.isEmpty
          ? currentSettings.enabledCategories
          : exportData.settings.enabledCategories.toSet(),
    );
    ref.read(settingsProvider.notifier).replace(newSettings);

    // Invalidate all providers to reload data
    ref.invalidate(streakProvider);
    ref.invalidate(weeklyCompletionProvider);
    ref.invalidate(recentCompletionsProvider);
    ref.invalidate(last30StatsProvider);
    ref.invalidate(weeklyDaysProvider);

    return true;
  } catch (e) {
    return false;
  }
});
