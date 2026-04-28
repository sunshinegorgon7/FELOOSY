import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/category.dart';
import '../../providers/categories_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: catsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cats) {
          if (cats.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }
          final sorted = [...cats]
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final bottomPad = MediaQuery.paddingOf(context).bottom;
          return ReorderableListView.builder(
            padding: EdgeInsets.only(bottom: bottomPad + 80),
            itemCount: sorted.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              ref
                  .read(categoriesProvider.notifier)
                  .reorder(sorted, oldIndex, newIndex);
            },
            buildDefaultDragHandles: true,
            itemBuilder: (context, index) => _CategoryTile(
              key: ValueKey(sorted[index].uuid),
              category: sorted[index],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/categories/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  final Category category;
  const _CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = category;
    final color = Color(cat.colorValue);
    final iconData =
        IconData(cat.iconCodePoint, fontFamily: cat.iconFontFamily);
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: cat.isActive ? 0.15 : 0.06),
        child: Icon(
          iconData,
          color: cat.isActive ? color : color.withValues(alpha: 0.4),
          size: 20,
        ),
      ),
      title: Text(
        cat.name,
        style: TextStyle(
          color: cat.isActive ? null : cs.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        cat.isCustom ? 'Custom' : 'Built-in',
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!cat.isActive)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                'Hidden',
                style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => context.push('/categories/edit', extra: cat),
          ),
          if (cat.isCustom)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              color: Colors.red.shade400,
              onPressed: () => _confirmDelete(context, ref, cat),
            )
          else
            IconButton(
              icon: Icon(
                cat.isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              tooltip: cat.isActive ? 'Hide' : 'Show',
              onPressed: () => ref
                  .read(categoriesProvider.notifier)
                  .setActive(cat.uuid, active: !cat.isActive),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Category cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Delete "${cat.name}"? Transactions using it will keep the category label.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(categoriesProvider.notifier).delete(cat.uuid);
    }
  }
}
