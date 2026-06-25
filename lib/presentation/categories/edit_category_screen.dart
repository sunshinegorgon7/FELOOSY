import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../app/app_theme.dart';
import '../../core/constants/category_options.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../data/models/category.dart';
import '../../providers/categories_provider.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  final Category? category;
  final String? defaultType; // 'expense' or 'income' — used when creating new
  const EditCategoryScreen({super.key, this.category, this.defaultType});

  @override
  ConsumerState<EditCategoryScreen> createState() =>
      _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  late TextEditingController _nameCtrl;
  late IconData _icon;
  late Color _color;
  late String? _transactionType; // 'expense', 'income', or null (both)

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
    _transactionType = cat?.transactionType ?? widget.defaultType;
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
        SnackBar(content: Text(context.l10n.transactionEnterCategoryName)),
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
        transactionType: _transactionType,
        currencyHint: existing.currencyHint,
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
        transactionType: _transactionType,
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
    final chartColor = AppTheme.categoryBarColor(
      uuid: widget.category?.uuid ?? '',
      colorValue: _color.toARGB32(),
      colorScheme: cs,
    );
    // Colours already taken by *other* categories — so every category can own a
    // unique, well-separated colour. The category being edited is excluded.
    final allCats = ref.watch(categoriesProvider).value ?? const <Category>[];
    final usedColors = <int>{
      for (final c in allCats)
        if (c.uuid != widget.category?.uuid) c.colorValue,
    };
    // Show the full palette, plus the current colour up front if it isn't a
    // palette swatch (e.g. a default category's original colour).
    final selectedValue = _color.toARGB32();
    final swatches = <Color>[
      if (!kPickableColors.any((c) => c.toARGB32() == selectedValue)) _color,
      ...kPickableColors,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? context.l10n.editCategoryTitleEdit : context.l10n.editCategoryTitleAdd),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(context.l10n.save,
                style: const TextStyle(fontWeight: FontWeight.w700)),
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
                      color: chartColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon, color: chartColor, size: 36),
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
              decoration: InputDecoration(
                labelText: context.l10n.editCategoryName,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Type selector
            Text(context.l10n.editCategoryUsedFor, style: tt.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                _TypeChip(
                  label: context.l10n.expense,
                  symbol: '−',
                  color: AppTheme.expenseText(cs),
                  selected: _transactionType == 'expense',
                  onTap: () => setState(() => _transactionType = 'expense'),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: context.l10n.income,
                  symbol: '+',
                  color: AppTheme.incomeText(cs),
                  selected: _transactionType == 'income',
                  onTap: () => setState(() => _transactionType = 'income'),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: context.l10n.both,
                  symbol: '±',
                  color: cs.onSurfaceVariant,
                  selected: _transactionType == null,
                  onTap: () => setState(() => _transactionType = null),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Color picker
            Text(context.l10n.editCategoryColour, style: tt.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: swatches.map((c) {
                final value = c.toARGB32();
                final isSel = value == selectedValue;
                final isTaken = !isSel && usedColors.contains(value);
                return GestureDetector(
                  // Taken colours can't be re-picked, so each category stays unique.
                  onTap: isTaken ? null : () => setState(() => _color = c),
                  child: Opacity(
                    opacity: isTaken ? 0.28 : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSel
                            ? Border.all(color: cs.onSurface, width: 2.5)
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
                          ? Icon(Icons.check,
                              color: AppTheme.readableOn(c), size: 18)
                          : isTaken
                              ? Icon(Icons.close,
                                  color: AppTheme.readableOn(c), size: 16)
                              : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Icon picker
            Text(context.l10n.editCategoryIcon, style: tt.titleSmall),
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
                      color: isSel ? AppTheme.readableOn(_color) : _color,
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

class _TypeChip extends StatelessWidget {
  final String label;
  final String symbol;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.symbol,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.25),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? color : color.withValues(alpha: 0.5),
                height: 1.0,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? color : color.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
