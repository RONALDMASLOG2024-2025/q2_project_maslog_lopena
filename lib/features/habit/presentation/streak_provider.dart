import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenwise/data/models/streak.dart';
import 'package:greenwise/features/tips/application/daily_tip_provider.dart';
import 'package:greenwise/features/progress/application/progress_providers.dart';

final streakProvider = FutureProvider<StreakState>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  return repo.getStreak();
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
});
