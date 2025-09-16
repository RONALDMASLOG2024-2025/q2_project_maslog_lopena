import 'package:flutter_test/flutter_test.dart';
import 'package:greenwise/data/repositories/tip_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Streak increments on consecutive days', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = InMemoryTipRepository();
    final today = DateTime(2025, 8, 29);
    await repo.markCompleted(today);
    final s1 = await repo.getStreak();
    expect(s1.currentStreak, 1);

    await repo.markCompleted(today.add(const Duration(days: 1)));
    final s2 = await repo.getStreak();
    expect(s2.currentStreak, 2);
    expect(s2.longestStreak, 2);
  });

  test('Streak resets after a gap', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = InMemoryTipRepository();
    final day1 = DateTime(2025, 8, 1);
    await repo.markCompleted(day1);
    await repo.markCompleted(day1.add(const Duration(days: 2))); // gap
    final s = await repo.getStreak();
    expect(s.currentStreak, 1);
    expect(s.longestStreak, 1);
  });
}
