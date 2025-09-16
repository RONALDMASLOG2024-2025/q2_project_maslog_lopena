import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recycling_resource.dart';
import '../../data/repositories/local_recycling_repository.dart';

final recyclingRepositoryProvider = Provider<RecyclingRepository>((ref) {
  return const LocalRecyclingRepository();
});

final recyclingDirectoryProvider = FutureProvider<RecyclingDirectory>((ref) async {
  final repo = ref.watch(recyclingRepositoryProvider);
  return repo.loadDirectory();
});
