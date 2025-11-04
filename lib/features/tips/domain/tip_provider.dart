import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenwise/data/models/eco_tip.dart';
import 'package:greenwise/data/repositories/tip_repository.dart';
import 'package:greenwise/data/repositories/tip_repository_sqlite.dart';
import 'package:greenwise/features/settings/domain/settings_provider.dart';

final tipRepositoryProvider = Provider<TipRepositorySqlite>((ref) {
  return TipRepositorySqlite();
});

final dailyTipProvider = FutureProvider<EcoTip>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final today = DateTime.now();
  final tip = await repo.getDailyTip(DateTime(today.year, today.month, today.day));
  if (settings.enabledCategories.isEmpty || settings.enabledCategories.contains(tip.category.name)) {
    return tip;
  }
  // Fallback: cycle forward until a matching category (simplistic approach)
  for (int i = 1; i < 7; i++) {
    final next = await repo.getDailyTip(DateTime(today.year, today.month, today.day + i));
    if (settings.enabledCategories.contains(next.category.name)) return next;
  }
  return tip; // fallback original if none found
});

/// Short list of upcoming tips (including today), filtered by enabled categories.
final tipsFeedProvider = FutureProvider<List<EcoTip>>((ref) async {
  final repo = ref.watch(tipRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final today = DateTime.now();
  final Set<String> seen = {};
  final List<EcoTip> out = [];
  var cursor = DateTime(today.year, today.month, today.day);
  int guard = 0; // safety to avoid infinite loops
  while (out.length < 10 && guard < 400) {
    final t = await repo.getDailyTip(cursor);
    final allowed = settings.enabledCategories.isEmpty || settings.enabledCategories.contains(t.category.name);
    if (allowed && seen.add(t.id)) {
      out.add(t);
    }
    cursor = cursor.add(const Duration(days: 1));
    guard++;
  }
  return out;
});

/// Infinite/paginated tips feed that never runs out. Respects category filters.
class TipsFeedController extends AutoDisposeAsyncNotifier<List<EcoTip>> {
  late TipRepository _repo;
  late String _categoriesSig;
  late DateTime _cursor;
  final Set<String> _seen = {};
  bool _loading = false;

  @override
  Future<List<EcoTip>> build() async {
    _repo = ref.watch(tipRepositoryProvider);
    final settings = ref.watch(settingsProvider);
    _categoriesSig = _sig(settings.enabledCategories);
    _cursor = _startOfToday();
    _seen.clear();
    return _loadBatch(settings, 12);
  }

  Future<void> reset() async {
    if (_loading) return;
    state = const AsyncLoading();
    final settings = ref.read(settingsProvider);
    _categoriesSig = _sig(settings.enabledCategories);
    _cursor = _startOfToday();
    _seen.clear();
    final items = await _loadBatch(settings, 12);
    state = AsyncData(items);
  }

  Future<void> loadMore([int count = 10]) async {
    if (_loading) return;
    final current = state.value ?? const <EcoTip>[];
    state = AsyncData(current);
    final settings = ref.read(settingsProvider);
    // If categories changed since build, reset first
    final sig = _sig(settings.enabledCategories);
    if (sig != _categoriesSig) {
      await reset();
      return;
    }
    final more = await _loadBatch(settings, count);
    if (more.isEmpty) return;
    state = AsyncData([...current, ...more]);
  }

  Future<List<EcoTip>> _loadBatch(SettingsState settings, int count) async {
    _loading = true;
    final List<EcoTip> out = [];
    int guard = 0; // safety
    while (out.length < count && guard < 1000) {
      final t = await _repo.getDailyTip(_cursor);
      final allowed = settings.enabledCategories.isEmpty || settings.enabledCategories.contains(t.category.name);
      if (allowed && _seen.add(t.id)) {
        out.add(t);
      }
      _cursor = _cursor.add(const Duration(days: 1));
      guard++;
    }
    _loading = false;
    return out;
  }

  static DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _sig(Set<String> cats) {
    final s = cats.toList()..sort();
    return s.join(',');
  }
}

final tipsInfiniteFeedProvider = AutoDisposeAsyncNotifierProvider<TipsFeedController, List<EcoTip>>(TipsFeedController.new);
