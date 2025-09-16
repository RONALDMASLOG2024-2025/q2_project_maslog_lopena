import 'dart:convert';
import 'package:greenwise/data/models/eco_tip.dart';
import 'package:greenwise/data/models/streak.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TipRepository {
  Future<EcoTip> getDailyTip(DateTime date);
  Future<void> markCompleted(DateTime date);
  Future<StreakState> getStreak();
  Future<Map<DateTime, bool>> getCompletions(int days); // returns map of date->completed for last `days` days (inclusive of today)
  Future<void> clearProgress(); // clears streak + completion history
}

class InMemoryTipRepository implements TipRepository {
  final List<EcoTip> _tips = [
    EcoTip(
      id: '1',
      text: 'Unplug idle chargers to reduce phantom energy load.',
      category: EcoTipCategory.energySaving,
      createdAt: DateTime.now(),
    ),
    EcoTip(
      id: '2',
      text: 'Dust your laptop vents to improve cooling efficiency.',
      category: EcoTipCategory.deviceCare,
      createdAt: DateTime.now(),
    ),
    EcoTip(
      id: '3',
      text: 'Collect old phones for an e-waste drop-off day.',
      category: EcoTipCategory.disposal,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<EcoTip> getDailyTip(DateTime date) async {
    // simple deterministic rotation
    final idx = date.difference(DateTime(date.year, 1, 1)).inDays % _tips.length;
    return _tips[idx];
  }

  static const _streakKey = 'streak_state_v1';
  static const _completedKeyPrefix = 'completed_tip_';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  String _completionKey(DateTime date) =>
      '$_completedKeyPrefix${date.toIso8601String().substring(0, 10)}';

  @override
  Future<void> markCompleted(DateTime date) async {
    final prefs = await _prefs;
    await prefs.setBool(_completionKey(date), true);

    final current = await getStreak();
    final today = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final continued = current.lastCompletionDate != null &&
        DateTime(current.lastCompletionDate!.year, current.lastCompletionDate!.month,
                current.lastCompletionDate!.day) ==
            yesterday;
    final newCurrent = continued ? current.currentStreak + 1 : 1;
    final newLongest = newCurrent > current.longestStreak ? newCurrent : current.longestStreak;
    final updated = StreakState(
        currentStreak: newCurrent, longestStreak: newLongest, lastCompletionDate: today);
    await prefs.setString(_streakKey, jsonEncode(updated.toJson()));
  }

  @override
  Future<StreakState> getStreak() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_streakKey);
    if (raw == null) return StreakState.empty;
    try {
      return StreakState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return StreakState.empty;
    }
  }

  @override
  Future<Map<DateTime, bool>> getCompletions(int days) async {
    final prefs = await _prefs;
    final now = DateTime.now();
    final Map<DateTime, bool> result = {};
    for (int i = 0; i < days; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = _completionKey(day);
      result[day] = prefs.getBool(key) ?? false;
    }
    return result;
  }

  @override
  Future<void> clearProgress() async {
    final prefs = await _prefs;
    // Remove streak
    await prefs.remove(_streakKey);
    // Remove completion keys (scan limited window for safety)
    final now = DateTime.now();
    for (int i = 0; i < 400; i++) { // ~ last 400 days
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = _completionKey(day);
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }
  }
}
