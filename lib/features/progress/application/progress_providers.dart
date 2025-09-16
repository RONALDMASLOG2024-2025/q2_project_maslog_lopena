import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../habit/presentation/streak_provider.dart';
import '../../tips/application/daily_tip_provider.dart'; // provides tipRepositoryProvider

// Map of last 30 days (DateTime -> completed?) newest to oldest keys when iterated by insertion order
final recentCompletionsProvider = FutureProvider<Map<DateTime, bool>>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  return repo.getCompletions(30);
});

// Weekly completion ratio (last 7 days including today)
final weeklyCompletionProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final map = await repo.getCompletions(7);
  if (map.isEmpty) return 0;
  final done = map.values.where((v) => v).length;
  return done / map.length;
});

// Clear all streak & completion progress
final clearProgressProvider = FutureProvider.autoDispose<void>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  await repo.clearProgress();
  ref.invalidate(recentCompletionsProvider);
  ref.invalidate(weeklyCompletionProvider);
  ref.invalidate(streakProvider); // from habit feature
});

class Last30Stats {
  final int total;
  final int completed;
  final DateTime? bestWeekStart;
  final int bestWeekCount;
  const Last30Stats({required this.total, required this.completed, required this.bestWeekStart, required this.bestWeekCount});
  double get rate => total == 0 ? 0 : completed / total;
  DateTime? get bestWeekEnd => bestWeekStart?.add(const Duration(days: 6));
}

final last30StatsProvider = FutureProvider<Last30Stats>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final map = await repo.getCompletions(30); // map of last 30 days newest->oldest
  if (map.isEmpty) return const Last30Stats(total: 0, completed: 0, bestWeekStart: null, bestWeekCount: 0);
  // Ensure ordered oldest->newest for windowing
  final days = map.keys.toList()..sort();
  final total = days.length;
  final completed = days.where((d) => map[d] == true).length;
  // Sliding 7-day window best count
  int bestCount = 0; DateTime? bestStart;
  for (int i = 0; i <= days.length - 7; i++) {
    final window = days.getRange(i, i + 7);
    final count = window.where((d) => map[d] == true).length;
    if (count > bestCount) { bestCount = count; bestStart = window.first; }
  }
  return Last30Stats(total: total, completed: completed, bestWeekStart: bestStart, bestWeekCount: bestCount);
});

/// Last 7 days oldest->newest list for rendering weekday chips
final weeklyDaysProvider = FutureProvider<List<({DateTime date, bool done})>>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final map = await repo.getCompletions(7);
  final days = map.keys.toList()..sort();
  return days.map((d) => (date: d, done: map[d] ?? false)).toList(growable: false);
});

/// Populate demo data across the last 45 days with ~60% completion
final populateDemoProgressProvider = FutureProvider.autoDispose<void>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final now = DateTime.now();
  final rnd = math.Random(42);
  for (int i = 0; i < 45; i++) {
    final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final shouldComplete = rnd.nextDouble() < 0.62;
    if (shouldComplete) {
      await repo.markCompleted(day);
    }
  }
  ref.invalidate(recentCompletionsProvider);
  ref.invalidate(weeklyCompletionProvider);
  ref.invalidate(streakProvider);
  ref.invalidate(last30StatsProvider);
  ref.invalidate(weeklyDaysProvider);
});