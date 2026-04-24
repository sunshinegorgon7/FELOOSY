import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../providers/categories_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String type; // 'expense' | 'income'
  const AddTransactionScreen({super.key, required this.type});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type;

  // Autocomplete manages its own controller; we keep a reference for _save().
  TextEditingController? _descFieldController;

  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  String? _selectedCategoryUuid;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.type == 'income'
        ? TransactionType.income
        : TransactionType.expense;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final desc = _descFieldController?.text.trim() ?? '';
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a description')),
      );
      return;
    }
    if (_selectedCategoryUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final amount =
          double.parse(_amountController.text.replaceAll(',', ''));
      final now = DateTime.now();
      final tx = Transaction(
        uuid: const Uuid().v4(),
        amount: amount,
        type: _type,
        description: desc,
        categoryUuid: _selectedCategoryUuid!,
        transactionDate: _date,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(transactionsProvider.notifier).add(tx);
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
    final settingsAsync = ref.watch(settingsProvider);
    final symbol =
        settingsAsync.whenOrNull(data: (s) => s.currencySymbol) ?? 'AED';

    return Scaffold(
      appBar: AppBar(
        title: Text(isExpense ? 'Add Expense' : 'Add Income'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Expense / Income toggle
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  icon: Icon(Icons.remove_circle_outline),
                  label: Text('Expense'),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  icon: Icon(Icons.add_circle_outline),
                  label: Text('Income'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) =>
                  setState(() => _type = s.first),
            ),
            const Gap(24),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$symbol  ',
                prefixStyle: TextStyle(
                  fontSize: 20,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                border: const OutlineInputBorder(),
                hintText: '0.00',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter an amount';
                final n = double.tryParse(v.replaceAll(',', ''));
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const Gap(16),

            // Description with autocomplete
            _DescriptionAutocomplete(
              onControllerReady: (c) => _descFieldController = c,
              onSuggestionSelected: (suggestion) {
                setState(() => _selectedCategoryUuid = suggestion.categoryUuid);
              },
            ),
            const Gap(24),

            // Category
            Text('Category', style: Theme.of(context).textTheme.titleSmall),
            const Gap(8),
            ref.watch(categoriesProvider).when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                  data: (cats) => _CategoryGrid(
                    categories: cats,
                    selected: _selectedCategoryUuid,
                    onSelect: (uuid) =>
                        setState(() => _selectedCategoryUuid = uuid),
                  ),
                ),
            const Gap(24),

            // Date
            Text('Date', style: Theme.of(context).textTheme.titleSmall),
            const Gap(8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: cs.primary),
                    const Gap(10),
                    Text(_formatDate(_date),
                        style: Theme.of(context).textTheme.bodyLarge),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const Gap(32),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save Transaction'),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today, ${DateFormat('MMMM d').format(date)}';
    if (d == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('MMMM d').format(date)}';
    }
    return DateFormat('EEEE, MMMM d, y').format(date);
  }
}

// ---------------------------------------------------------------------------
// Description field with autocomplete history
// ---------------------------------------------------------------------------

class _DescriptionAutocomplete extends ConsumerWidget {
  final ValueChanged<TextEditingController> onControllerReady;
  final ValueChanged<DescriptionSuggestion> onSuggestionSelected;

  const _DescriptionAutocomplete({
    required this.onControllerReady,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(transactionRepositoryProvider);
    final cats = ref.watch(categoriesProvider).valueOrNull ?? [];
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
            borderRadius: BorderRadius.circular(8),
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
                            child:
                                Icon(iconData, color: iconColor, size: 14),
                          ),
                          const Gap(10),
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
        // Expose the controller so _save() can read the typed value
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => onControllerReady(controller));
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            hintText: 'e.g. Lunch at the office',
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Category chip grid
// ---------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = cat.uuid == selected;
        final color = Color(cat.colorValue);
        return FilterChip(
          avatar: Icon(
            IconData(cat.iconCodePoint, fontFamily: cat.iconFontFamily),
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          label: Text(cat.name),
          selected: isSelected,
          onSelected: (_) => onSelect(cat.uuid),
          backgroundColor: color.withValues(alpha: 0.08),
          selectedColor: color,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
          ),
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected ? color : color.withValues(alpha: 0.3),
          ),
        );
      }).toList(),
    );
  }
}
