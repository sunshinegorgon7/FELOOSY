import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../providers/categories_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String type; // 'expense' | 'income'
  final Transaction? initialTransaction;

  const AddTransactionScreen({
    super.key,
    required this.type,
    this.initialTransaction,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type;

  TextEditingController? _descFieldController;
  bool _descInitialized = false;

  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _selectedCategoryUuid;
  bool _saving = false;

  bool get _isEditing => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    _type = widget.type == 'income'
        ? TransactionType.income
        : TransactionType.expense;

    final initial = widget.initialTransaction;
    if (initial != null) {
      _type = initial.type;
      _amountController.text = initial.amount.toStringAsFixed(2);
      _date = initial.transactionDate;
      _selectedCategoryUuid = initial.categoryUuid;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ── Auto-save logic ─────────────────────────────────────────────────────

  /// Called whenever a field changes. Saves silently when all three
  /// required fields (amount, description, category) are complete.
  void _tryAutoSave() {
    if (_saving) return;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    final desc = _descFieldController?.text.trim() ?? '';
    if (desc.isEmpty) return;
    if (_selectedCategoryUuid == null) return;
    _commit(amount: amount, description: desc);
  }

  Future<void> _commit({
    required double amount,
    required String description,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final initial = widget.initialTransaction;
      final account = ref.read(activeAccountProvider);

      if (initial != null) {
        await ref.read(transactionsProvider.notifier).edit(
              Transaction(
                id: initial.id,
                uuid: initial.uuid,
                accountId: initial.accountId,
                amount: amount,
                type: _type,
                description: description,
                categoryUuid: _selectedCategoryUuid!,
                transactionDate: _date,
                createdAt: initial.createdAt,
                updatedAt: now,
              ),
            );
      } else {
        await ref.read(transactionsProvider.notifier).add(
              Transaction(
                uuid: const Uuid().v4(),
                accountId: account?.id ?? 1,
                amount: amount,
                type: _type,
                description: description,
                categoryUuid: _selectedCategoryUuid!,
                transactionDate: _date,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final account = ref.watch(activeAccountProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final symbol = account?.currencySymbol ??
        settingsAsync.whenOrNull(data: (s) => s.currencySymbol) ??
        'AED';
    final mostUsedUuids =
        ref.watch(mostUsedCategoryUuidsProvider).value ?? [];

    final amountColor =
        isExpense ? Colors.red.shade400 : Colors.green.shade500;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Fixed top: type toggle + date + amount hero ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  // Type toggle + date chip row
                  Row(
                    children: [
                      _TypeToggle(
                        isExpense: isExpense,
                        onExpense: () => setState(
                            () => _type = TransactionType.expense),
                        onIncome: () => setState(
                            () => _type = TransactionType.income),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 13,
                                  color: cs.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                _formatDateShort(_date),
                                style: tt.labelMedium?.copyWith(
                                    color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount hero input
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d.]')),
                    ],
                    autofocus: !_isEditing,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w300,
                      color: amountColor,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w300,
                        color: cs.onSurface.withValues(alpha: 0.18),
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                      prefixText: '$symbol  ',
                      prefixStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: amountColor.withValues(alpha: 0.7),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                      _tryAutoSave();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description — fixed so it's always visible
                  _DescriptionAutocomplete(
                    initialDescription:
                        widget.initialTransaction?.description,
                    onControllerReady: (c) {
                      _descFieldController = c;
                      if (!_descInitialized &&
                          widget.initialTransaction != null) {
                        _descInitialized = true;
                        c.text =
                            widget.initialTransaction!.description;
                        c.selection = TextSelection.collapsed(
                            offset: c.text.length);
                      }
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() => _selectedCategoryUuid =
                          suggestion.categoryUuid);
                      _tryAutoSave();
                    },
                    onSubmitted: _tryAutoSave,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: cs.outlineVariant,
            ),

            // ── Scrollable: categories ───────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  // Category header
                  Row(
                    children: [
                      Text('Category', style: tt.titleSmall),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('New'),
                        onPressed: () =>
                            context.push('/categories/edit'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),

                  // Hint when nothing selected yet
                  _SelectionHint(
                    amountMissing: double.tryParse(
                            _amountController.text
                                .replaceAll(',', '')) ==
                        null,
                    categoryMissing: _selectedCategoryUuid == null,
                  ),

                  const SizedBox(height: 8),
                  ref.watch(categoriesProvider).when(
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (e, _) => Text('$e'),
                        data: (cats) {
                          final active =
                              (cats.where((c) => c.isActive).toList()
                                    ..sort((a, b) => a.sortOrder
                                        .compareTo(b.sortOrder)))
                                  .toList();
                          return _CategoryGrid(
                            categories: active,
                            selected: _selectedCategoryUuid,
                            onSelect: (uuid) {
                              setState(
                                  () => _selectedCategoryUuid = uuid);
                              _tryAutoSave();
                            },
                            mostUsedUuids: mostUsedUuids,
                          );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }
}

// ---------------------------------------------------------------------------
// Hint row shown below the category label
// ---------------------------------------------------------------------------

class _SelectionHint extends StatelessWidget {
  final bool amountMissing;
  final bool categoryMissing;

  const _SelectionHint({
    required this.amountMissing,
    required this.categoryMissing,
  });

  @override
  Widget build(BuildContext context) {
    if (!amountMissing && !categoryMissing) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final parts = <String>[
      if (amountMissing) 'amount',
      if (categoryMissing) 'category',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        'Add ${parts.join(' & ')} to save',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type toggle chips
// ---------------------------------------------------------------------------

class _TypeToggle extends StatelessWidget {
  final bool isExpense;
  final VoidCallback onExpense;
  final VoidCallback onIncome;

  const _TypeToggle({
    required this.isExpense,
    required this.onExpense,
    required this.onIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Chip(
          label: 'Expense',
          selected: isExpense,
          selectedColor: Colors.red.shade400,
          onTap: onExpense,
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Income',
          selected: !isExpense,
          selectedColor: Colors.green.shade500,
          onTap: onIncome,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.15)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? selectedColor.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? selectedColor : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Description field with autocomplete history
// ---------------------------------------------------------------------------

class _DescriptionAutocomplete extends ConsumerWidget {
  final String? initialDescription;
  final ValueChanged<TextEditingController> onControllerReady;
  final ValueChanged<DescriptionSuggestion> onSuggestionSelected;
  final VoidCallback? onSubmitted;

  const _DescriptionAutocomplete({
    required this.onControllerReady,
    required this.onSuggestionSelected,
    this.initialDescription,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(transactionRepositoryProvider);
    final cats = (ref.watch(categoriesProvider).value ?? [])
        .where((c) => c.isActive)
        .toList();
    final cs = Theme.of(context).colorScheme;

    return Autocomplete<DescriptionSuggestion>(
      optionsBuilder: (textEditingValue) async {
        final text = textEditingValue.text.trim();
        if (text.length < 2) return const [];
        return repo.getDescriptionSuggestions(text);
      },
      displayStringForOption: (option) => option.description,
      onSelected: onSuggestionSelected,
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: cs.surfaceContainerHighest),
                itemBuilder: (context, index) {
                  final opt = options.elementAt(index);
                  final cat = cats
                      .where((c) => c.uuid == opt.categoryUuid)
                      .firstOrNull;
                  final iconColor =
                      cat != null ? Color(cat.colorValue) : Colors.grey;
                  final iconData = cat != null
                      ? IconData(cat.iconCodePoint,
                          fontFamily: cat.iconFontFamily)
                      : Icons.receipt_outlined;

                  return InkWell(
                    onTap: () => onSelected(opt),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                iconColor.withValues(alpha: 0.15),
                            child: Icon(iconData,
                                color: iconColor, size: 14),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(opt.description,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                if (cat != null)
                                  Text(cat.name,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Icon(Icons.north_west,
                              size: 14, color: cs.onSurfaceVariant),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => onControllerReady(controller));
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () {
            focusNode.unfocus();
            onSubmitted?.call();
          },
          decoration: InputDecoration(
            hintText: 'Description',
            filled: true,
            fillColor: cs.surfaceContainerLow,
            prefixIcon:
                Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Category grid with optional frequent row
// ---------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final String? selected;
  final ValueChanged<String> onSelect;
  final List<String> mostUsedUuids;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
    this.mostUsedUuids = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final mostUsed = mostUsedUuids
        .map((uuid) =>
            categories.where((c) => c.uuid == uuid).firstOrNull)
        .whereType<Category>()
        .take(4)
        .toList();
    final frequentUuids = mostUsed.map((cat) => cat.uuid).toSet();
    final remainingCategories = categories
        .where((cat) => !frequentUuids.contains(cat.uuid))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostUsed.isNotEmpty) ...[
          Text('Frequent',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          SizedBox(
            height: 76,
            child: Row(
              children: [
                for (int i = 0; i < mostUsed.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _CategoryCell(
                      cat: mostUsed[i],
                      isSelected: mostUsed[i].uuid == selected,
                      onSelect: onSelect,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: cs.outlineVariant),
          const SizedBox(height: 12),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 76,
          ),
          itemCount: remainingCategories.length,
          itemBuilder: (context, index) {
            final cat = remainingCategories[index];
            return _CategoryCell(
              cat: cat,
              isSelected: cat.uuid == selected,
              onSelect: onSelect,
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCell extends StatelessWidget {
  final Category cat;
  final bool isSelected;
  final ValueChanged<String> onSelect;

  const _CategoryCell({
    required this.cat,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(cat.colorValue);
    return GestureDetector(
      onTap: () => onSelect(cat.uuid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconData(cat.iconCodePoint, fontFamily: cat.iconFontFamily),
              size: 20,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cat.name,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
