import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tips/domain/tip_provider.dart'; // provides tipRepositoryProvider
import 'streak_provider.dart';

// Map of last 30 days (DateTime -> completed?) newest to oldest keys when iterated by insertion order
final recentCompletionsProvider = FutureProvider<Map<DateTime, bool>>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  return repo.getCompletions(30);
});

// Weekly completion ratio for current week (Monday to Sunday)
final weeklyCompletionProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Calculate Monday of current week
  final daysSinceMonday = today.weekday - 1;
  final monday = today.subtract(Duration(days: daysSinceMonday));
  
  // Get completions for the current week (Mon-Sun)
  final allCompletions = await repo.getCompletions(30);
  int doneCount = 0;
  int totalDays = 0;
  
  for (int i = 0; i < 7; i++) {
    final date = monday.add(Duration(days: i));
    // Only count days up to and including today
    if (date.isAfter(today)) break;
    totalDays++;
    if (allCompletions[date] == true) {
      doneCount++;
    }
  }
  
  return totalDays == 0 ? 0 : doneCount / totalDays;
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

/// Current week (Mon-Sun) with completion status for rendering weekday chips
final weeklyDaysProvider = FutureProvider<List<({DateTime date, bool done})>>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Calculate Monday of current week (weekday 1 = Monday, 7 = Sunday)
  final daysSinceMonday = today.weekday - 1; // 0 = Monday, 6 = Sunday
  final monday = today.subtract(Duration(days: daysSinceMonday));
  
  // Get this week's 7 days (Monday through Sunday)
  final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
  
  // Fetch completion status for each day
  final Map<DateTime, bool> completions = {};
  final prefs = await repo.getCompletions(30); // Get last 30 days to cover the week
  
  for (final date in weekDates) {
    completions[date] = prefs[date] ?? false;
  }
  
  return weekDates.map((d) => (date: d, done: completions[d] ?? false)).toList(growable: false);
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