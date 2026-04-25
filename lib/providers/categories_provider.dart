import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category.dart';
import 'database_provider.dart';

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repo = ref.watch(categoryRepositoryProvider);
    return repo.getAll(activeOnly: false);
  }

  Future<void> add(Category category) async {
    await ref.read(categoryRepositoryProvider).insert(category);
    ref.invalidateSelf();
  }

  Future<void> saveCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).update(category);
    ref.invalidateSelf();
  }

  Future<void> delete(String uuid) async {
    await ref.read(categoryRepositoryProvider).delete(uuid);
    ref.invalidateSelf();
  }

  Future<void> setActive(String uuid, {required bool active}) async {
    final repo = ref.read(categoryRepositoryProvider);
    final cat = await repo.getByUuid(uuid);
    if (cat != null) await repo.update(cat.copyWith(isActive: active));
    ref.invalidateSelf();
  }

  Future<void> reorder(
      List<Category> cats, int oldIndex, int newIndex) async {
    final repo = ref.read(categoryRepositoryProvider);
    final list = [...cats];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      if (list[i].sortOrder != i) {
        await repo.update(list[i].copyWith(sortOrder: i));
      }
    }
    ref.invalidateSelf();
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
        CategoriesNotifier.new);
