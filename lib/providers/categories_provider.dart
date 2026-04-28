import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category.dart';
import 'database_provider.dart';
import 'firebase_sync_provider.dart';

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repo = ref.watch(categoryRepositoryProvider);
    return repo.getAll(activeOnly: false);
  }

  Future<void> add(Category category) async {
    await ref.read(categoryRepositoryProvider).insert(category);
    try {
      await ref.read(firebaseSyncProvider)?.syncCategory(category);
    } catch (e) {
      debugPrint('Firestore sync (category add) error: $e');
    }
    ref.invalidateSelf();
  }

  Future<void> saveCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).update(category);
    try {
      await ref.read(firebaseSyncProvider)?.syncCategory(category);
    } catch (e) {
      debugPrint('Firestore sync (category save) error: $e');
    }
    ref.invalidateSelf();
  }

  Future<void> delete(String uuid) async {
    await ref.read(categoryRepositoryProvider).delete(uuid);
    try {
      await ref.read(firebaseSyncProvider)?.deleteCategory(uuid);
    } catch (e) {
      debugPrint('Firestore sync (category delete) error: $e');
    }
    ref.invalidateSelf();
  }

  Future<void> setActive(String uuid, {required bool active}) async {
    final repo = ref.read(categoryRepositoryProvider);
    final cat = await repo.getByUuid(uuid);
    if (cat != null) {
      await repo.update(cat.copyWith(isActive: active));
      try {
        await ref.read(firebaseSyncProvider)?.syncCategory(cat.copyWith(isActive: active));
      } catch (e) {
        debugPrint('Firestore sync (category setActive) error: $e');
      }
    }
    ref.invalidateSelf();
  }

  Future<void> reorder(
      List<Category> cats, int oldIndex, int newIndex) async {
    final repo = ref.read(categoryRepositoryProvider);
    final list = [...cats];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    final sync = ref.read(firebaseSyncProvider);
    for (int i = 0; i < list.length; i++) {
      if (list[i].sortOrder != i) {
        final updated = list[i].copyWith(sortOrder: i);
        await repo.update(updated);
        try {
          await sync?.syncCategory(updated);
        } catch (e) {
          debugPrint('Firestore sync (category reorder) error: $e');
        }
      }
    }
    ref.invalidateSelf();
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
        CategoriesNotifier.new);
