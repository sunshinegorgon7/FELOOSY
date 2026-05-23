import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../app/app_theme.dart';
import '../../data/models/category.dart';
import '../../data/models/sms_rule.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/sms_rules_provider.dart';

class SmsRuleFormScreen extends ConsumerStatefulWidget {
  final SmsRule? rule;
  const SmsRuleFormScreen({super.key, this.rule});

  @override
  ConsumerState<SmsRuleFormScreen> createState() => _SmsRuleFormScreenState();
}

class _SmsRuleFormScreenState extends ConsumerState<SmsRuleFormScreen> {
  late final TextEditingController _keywordCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _regexCtrl;

  String _type = 'expense';
  String? _categoryUuid;
  int? _accountId;
  bool _saving = false;

  bool get _isEditing => widget.rule != null;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _keywordCtrl = TextEditingController(text: rule?.keyword ?? '');
    _descCtrl = TextEditingController(text: rule?.description ?? '');
    _regexCtrl = TextEditingController(text: rule?.amountRegex ?? '');
    _type = rule?.transactionType ?? 'expense';
    _categoryUuid = rule?.categoryUuid;
    _accountId = rule?.accountId;
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    _descCtrl.dispose();
    _regexCtrl.dispose();
    super.dispose();
  }

  List<Category> _filteredCategories(List<Category> all) {
    return all
        .where((c) =>
            c.isActive &&
            (c.transactionType == null || c.transactionType == _type))
        .toList();
  }

  Future<void> _save() async {
    final keyword = _keywordCtrl.text.trim();
    if (keyword.isEmpty) {
      _showError('Please enter a keyword.');
      return;
    }
    if (_categoryUuid == null) {
      _showError('Please select a category.');
      return;
    }

    setState(() => _saving = true);
    try {
      final notifier = ref.read(smsRulesProvider.notifier);
      final now = DateTime.now();
      final accountId = _accountId ?? 1;
      final regex = _regexCtrl.text.trim();

      final desc = _descCtrl.text.trim();
      if (_isEditing) {
        final updated = widget.rule!.copyWith(
          keyword: keyword,
          description: desc.isEmpty ? null : desc,
          clearDescription: desc.isEmpty,
          categoryUuid: _categoryUuid,
          transactionType: _type,
          accountId: accountId,
          amountRegex: regex.isEmpty ? null : regex,
          clearAmountRegex: regex.isEmpty,
        );
        await notifier.save(updated);
      } else {
        final rule = SmsRule(
          keyword: keyword,
          description: desc.isEmpty ? null : desc,
          categoryUuid: _categoryUuid!,
          transactionType: _type,
          accountId: accountId,
          amountRegex: regex.isEmpty ? null : regex,
          createdAt: now,
        );
        await notifier.add(rule);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.rule?.id == null) return;
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete rule?'),
        content: Text(
            'The rule for "${widget.rule!.keyword}" will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(smsRulesProvider.notifier).remove(widget.rule!.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _pickCategory(List<Category> categories) async {
    final filtered = _filteredCategories(categories);
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, sc) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Select Category',
                  style: Theme.of(ctx).textTheme.titleMedium),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final cat = filtered[i];
                  final color = Color(cat.colorValue);
                  final icon = IconData(cat.iconCodePoint,
                      fontFamily: cat.iconFontFamily);
                  final isSelected = cat.uuid == _categoryUuid;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(cat.name),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: Theme.of(ctx).colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, cat.uuid),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _categoryUuid = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final catsAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

    final categories = catsAsync.asData?.value ?? [];
    final accounts = accountsAsync.asData?.value ?? [];
    final selectedCat = categories.where((c) => c.uuid == _categoryUuid).firstOrNull;
    final showAccountPicker = accounts.length > 1;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Rule' : 'New Rule'),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          const _SectionLabel('Keyword'),
          const SizedBox(height: 6),
          TextField(
            controller: _keywordCtrl,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'e.g. Carrefour, VODAFONE, Uber',
              border: OutlineInputBorder(),
              helperText: 'Case-insensitive match anywhere in the SMS body.',
              helperMaxLines: 2,
            ),
          ),

          const SizedBox(height: 24),
          const _SectionLabel('Transaction Label'),
          const SizedBox(height: 6),
          TextField(
            controller: _descCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'e.g. Gas, Coffee, Groceries (leave blank to use keyword)',
              border: OutlineInputBorder(),
              helperText:
                  'Shown as the transaction description. Defaults to the keyword.',
              helperMaxLines: 2,
            ),
          ),

          const SizedBox(height: 24),
          const _SectionLabel('Transaction Type'),
          const SizedBox(height: 8),
          _TypeToggle(
            selected: _type,
            onChanged: (t) {
              setState(() {
                _type = t;
                // Reset category if it no longer matches the new type
                final stillValid = categories.any((c) =>
                    c.uuid == _categoryUuid &&
                    (c.transactionType == null || c.transactionType == t));
                if (!stillValid) _categoryUuid = null;
              });
            },
          ),

          const SizedBox(height: 24),
          const _SectionLabel('Category'),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _pickCategory(categories),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: selectedCat != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              Color(selectedCat.colorValue).withValues(alpha: 0.15),
                          child: Icon(
                            IconData(selectedCat.iconCodePoint,
                                fontFamily: selectedCat.iconFontFamily),
                            color: Color(selectedCat.colorValue),
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(selectedCat.name, style: tt.bodyMedium),
                        const Spacer(),
                        Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                      ],
                    )
                  : Row(
                      children: [
                        Text('Select a category',
                            style: tt.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        const Spacer(),
                        Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                      ],
                    ),
            ),
          ),

          if (showAccountPicker) ...[
            const SizedBox(height: 24),
            const _SectionLabel('Wallet'),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _accountId ?? (accounts.isNotEmpty ? accounts.first.id : null),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: accounts
                  .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                  .toList(),
              onChanged: (id) => setState(() => _accountId = id),
            ),
          ],

          const SizedBox(height: 24),
          ExpansionTile(
            title: Text('Advanced', style: tt.bodyMedium),
            subtitle: Text('Custom amount regex', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            tilePadding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _regexCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount regex (optional)',
                  hintText: r'r"(\d+(?:\.\d{1,2})?)"',
                  helperText:
                      'Use capture group 1 to extract the amount. Leave empty to use built-in detection.',
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

          const Gap(32),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Save Changes' : 'Save Rule'),
          ),

          if (_isEditing) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _saving ? null : _delete,
              style: TextButton.styleFrom(foregroundColor: cs.error),
              child: const Text('Delete Rule'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.primaryText(cs),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Expense',
            active: selected == 'expense',
            onTap: () => onChanged('expense'),
          ),
          _Segment(
            label: 'Income',
            active: selected == 'income',
            onTap: () => onChanged('income'),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Segment({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
