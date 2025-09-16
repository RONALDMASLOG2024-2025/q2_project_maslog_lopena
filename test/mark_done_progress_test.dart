import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greenwise/features/tips/application/daily_tip_provider.dart';
import 'package:greenwise/features/progress/application/progress_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Mark as done updates progress providers', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initially, weekly completion should be 0
    final initialWeekly = await container.read(weeklyCompletionProvider.future);
    expect(initialWeekly, 0);

    // Mark today as done via repository
    final repo = container.read(tipRepositoryProvider);
    final now = DateTime.now();
    await repo.markCompleted(DateTime(now.year, now.month, now.day));

    // Invalidate and re-read
    container.invalidate(weeklyCompletionProvider);
    container.invalidate(recentCompletionsProvider);

    final updatedWeekly = await container.read(weeklyCompletionProvider.future);
    expect(updatedWeekly > 0, true);

    final map = await container.read(recentCompletionsProvider.future);
    final todayKey = DateTime(now.year, now.month, now.day);
    expect(map[todayKey], true);
  });
}
