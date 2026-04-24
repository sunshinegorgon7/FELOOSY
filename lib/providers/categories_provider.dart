import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category.dart';
import 'database_provider.dart';

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repo = ref.watch(categoryRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(Category category) async {
    await ref.read(categoryRepositoryProvider).insert(category);
    ref.invalidateSelf();
  }

  Future<void> setActive(String uuid, {required bool active}) async {
    final repo = ref.read(categoryRepositoryProvider);
    final cat = await repo.getByUuid(uuid);
    if (cat != null) await repo.update(cat.copyWith(isActive: active));
    ref.invalidateSelf();
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
        CategoriesNotifier.new);
