import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenwise/data/models/streak.dart';
import 'package:greenwise/features/progress/domain/progress_provider.dart';
import 'package:greenwise/features/tips/domain/tip_provider.dart';

final streakProvider = FutureProvider<StreakState>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  return repo.getStreak();
});

/// Check if today's tip has been completed
final isTodayCompletedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final completions = await repo.getCompletions(1);
  return completions[today] ?? false;
});

final completeTodayProvider = FutureProvider.autoDispose<void>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final now = DateTime.now();
  await repo.markCompleted(DateTime(now.year, now.month, now.day));
  ref.invalidate(streakProvider);
  ref.invalidate(weeklyCompletionProvider);
  ref.invalidate(recentCompletionsProvider);
  ref.invalidate(last30StatsProvider);
  ref.invalidate(weeklyDaysProvider);
  ref.invalidate(isTodayCompletedProvider); // Invalidate the completion check
});
