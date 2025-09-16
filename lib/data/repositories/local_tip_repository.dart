import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:greenwise/data/models/eco_tip.dart';
import 'package:greenwise/data/models/streak.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tip_repository.dart';

class LocalTipRepository implements TipRepository {
  LocalTipRepository();

  List<EcoTip>? _cache;

  Future<List<EcoTip>> _load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/tips.json');
    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    _cache = jsonList.map((e) {
      final m = e as Map<String, dynamic>;
      return EcoTip(
        id: m['id'] as String,
        text: m['text'] as String,
        category: EcoTipCategory.values.firstWhere((c) => c.name == (m['category'] as String)),
        explanation: m['explanation'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
    }).toList(growable: false);
    return _cache!;
  }

  @override
  Future<EcoTip> getDailyTip(DateTime date) async {
    final tips = await _load();
    // rotate by day-of-year across full list length
    final startOfYear = DateTime(date.year, 1, 1);
    final idx = date.difference(startOfYear).inDays % tips.length;
    return tips[idx];
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
    await prefs.remove(_streakKey);
    final now = DateTime.now();
    for (int i = 0; i < 500; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = _completionKey(day);
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }
  }
}
