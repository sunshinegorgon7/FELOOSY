import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/category_options.dart';
import '../../data/models/category.dart';
import '../../providers/categories_provider.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  final Category? category;
  const EditCategoryScreen({super.key, this.category});

  @override
  ConsumerState<EditCategoryScreen> createState() =>
      _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  late TextEditingController _nameCtrl;
  late IconData _icon;
  late Color _color;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    _nameCtrl = TextEditingController(text: cat?.name ?? '');
    _icon = cat != null
        ? IconData(cat.iconCodePoint, fontFamily: cat.iconFontFamily)
        : kPickableIcons.first;
    _color = cat != null ? Color(cat.colorValue) : kPickableColors.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a category name')),
      );
      return;
    }

    final now = DateTime.now();
    final existing = widget.category;

    if (existing != null) {
      final updated = Category(
        id: existing.id,
        uuid: existing.uuid,
        name: name,
        colorValue: _color.toARGB32(),
        iconCodePoint: _icon.codePoint,
        iconFontFamily: _icon.fontFamily ?? 'MaterialIcons',
        isCustom: existing.isCustom,
        isActive: existing.isActive,
        sortOrder: existing.sortOrder,
        createdAt: existing.createdAt,
      );
      await ref.read(categoriesProvider.notifier).saveCategory(updated);
    } else {
      final allCats = ref.read(categoriesProvider).value ?? [];
      final maxSort = allCats.isEmpty
          ? 0
          : allCats.map((c) => c.sortOrder).reduce(math.max);

      final newCat = Category(
        uuid: const Uuid().v4(),
        name: name,
        colorValue: _color.toARGB32(),
        iconCodePoint: _icon.codePoint,
        iconFontFamily: _icon.fontFamily ?? 'MaterialIcons',
        isCustom: true,
        isActive: true,
        sortOrder: maxSort + 1,
        createdAt: now,
      );
      await ref.read(categoriesProvider.notifier).add(newCat);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final previewName = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Category';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Category' : 'Add Category'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview
            Center(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon, color: _color, size: 36),
                  ),
                  const SizedBox(height: 8),
                  Text(previewName, style: tt.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Color picker
            Text('Colour', style: tt.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: kPickableColors.map((c) {
                final isSel = c == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSel
                          ? Border.all(
                              color: cs.onSurface, width: 2.5)
                          : null,
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                  color: c.withValues(alpha: 0.5),
                                  blurRadius: 6)
                            ]
                          : null,
                    ),
                    child: isSel
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Icon picker
            Text('Icon', style: tt.titleSmall),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: kPickableIcons.length,
              itemBuilder: (context, i) {
                final ic = kPickableIcons[i];
                final isSel = ic.codePoint == _icon.codePoint;
                return GestureDetector(
                  onTap: () => setState(() => _icon = ic),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSel
                          ? _color
                          : _color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      ic,
                      size: 22,
                      color: isSel ? Colors.white : _color,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
