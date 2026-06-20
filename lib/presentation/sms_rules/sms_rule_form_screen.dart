import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../app/app_theme.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../data/models/category.dart';
import '../../data/models/sms_rule.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sms_rules_provider.dart';

class SmsRuleFormScreen extends ConsumerStatefulWidget {
  final SmsRule? rule;
  const SmsRuleFormScreen({super.key, this.rule});

  @override
  ConsumerState<SmsRuleFormScreen> createState() => _SmsRuleFormScreenState();
}

class _SmsRuleFormScreenState extends ConsumerState<SmsRuleFormScreen> {
  late final TextEditingController _keywordCtrl;
  late final TextEditingController _regexCtrl;
  TextEditingController? _descFieldCtrl;

  String _type = 'expense';
  String? _categoryUuid;
  Set<int> _selectedAccountIds = {};
  bool _saving = false;

  bool get _isEditing => widget.rule != null;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _keywordCtrl = TextEditingController(text: rule?.keyword ?? '');
    _regexCtrl = TextEditingController(text: rule?.amountRegex ?? '');
    _type = rule?.transactionType ?? 'expense';
    _categoryUuid = rule?.categoryUuid;
    if (rule != null) {
      _selectedAccountIds = rule.accountIds.toSet();
    }
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
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
    final l10n = context.l10n;
    final keyword = _keywordCtrl.text.trim();
    if (keyword.isEmpty) {
      _showError(l10n.smsRuleFormEnterKeyword);
      return;
    }
    if (_categoryUuid == null) {
      _showError(l10n.smsRuleFormSelectCategoryError);
      return;
    }

    final allAccounts = ref.read(accountsProvider).asData?.value ?? [];

    if (_selectedAccountIds.isEmpty && allAccounts.isNotEmpty) {
      _showError(l10n.smsRuleFormSelectWalletError);
      return;
    }

    setState(() => _saving = true);
    try {
      final notifier = ref.read(smsRulesProvider.notifier);
      final now = DateTime.now();
      final fallbackAccount = allAccounts.isNotEmpty
          ? allAccounts.firstWhere((a) => a.isFavorite, orElse: () => allAccounts.first)
          : null;
      final accountIds = _selectedAccountIds.isNotEmpty
          ? _selectedAccountIds.toList()
          : [fallbackAccount?.id ?? 1];
      final regex = _regexCtrl.text.trim();

      final desc = _descFieldCtrl?.text.trim() ?? '';
      if (_isEditing) {
        final updated = widget.rule!.copyWith(
          keyword: keyword,
          description: desc.isEmpty ? null : desc,
          clearDescription: desc.isEmpty,
          categoryUuid: _categoryUuid,
          transactionType: _type,
          accountIds: accountIds,
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
          accountIds: accountIds,
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
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.smsRulesDeleteTitle),
        content: Text(l10n.smsRuleFormDeleteMessage(widget.rule!.keyword)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
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
              child: Text(context.l10n.smsRuleFormSelectCategoryTitle,
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

    if (!_isEditing && _selectedAccountIds.isEmpty && accounts.isNotEmpty) {
      final fav = accounts.firstWhere((a) => a.isFavorite, orElse: () => accounts.first);
      _selectedAccountIds = {fav.id!};
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(_isEditing ? context.l10n.smsRuleFormTitleEdit : context.l10n.smsRuleFormTitleNew),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          _SectionLabel(context.l10n.smsRuleFormKeyword),
          const SizedBox(height: 6),
          TextField(
            controller: _keywordCtrl,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: context.l10n.smsRuleFormKeywordHint,
              border: const OutlineInputBorder(),
              helperText: context.l10n.smsRuleFormKeywordHelper,
              helperMaxLines: 2,
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabel(context.l10n.smsRuleFormLabel),
          const SizedBox(height: 6),
          _DescriptionAutocomplete(
            initialDescription: widget.rule?.description,
            categories: categories,
            repo: ref.read(transactionRepositoryProvider),
            onControllerReady: (controller) {
              _descFieldCtrl = controller;
            },
            onSuggestionSelected: (suggestion) {
              setState(() => _categoryUuid = suggestion.categoryUuid);
            },
          ),

          const SizedBox(height: 24),
          _SectionLabel(context.l10n.smsRuleFormType),
          const SizedBox(height: 8),
          _TypeToggle(
            selected: _type,
            expenseLabel: context.l10n.expense,
            incomeLabel: context.l10n.income,
            onChanged: (t) {
              setState(() {
                _type = t;
                final stillValid = categories.any((c) =>
                    c.uuid == _categoryUuid &&
                    (c.transactionType == null || c.transactionType == t));
                if (!stillValid) _categoryUuid = null;
              });
            },
          ),

          const SizedBox(height: 24),
          _SectionLabel(context.l10n.smsRuleFormCategory),
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
                        Text(context.l10n.smsRuleFormSelectCategory,
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
            _SectionLabel(context.l10n.smsRuleFormWallets),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: accounts.map((a) {
                final isSelected = _selectedAccountIds.contains(a.id);
                return FilterChip(
                  label: Text(a.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAccountIds.add(a.id!);
                      } else {
                        if (_selectedAccountIds.length > 1) {
                          _selectedAccountIds.remove(a.id);
                        }
                      }
                    });
                  },
                  showCheckmark: true,
                  selectedColor: cs.primaryContainer,
                  checkmarkColor: cs.onPrimaryContainer,
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                context.l10n.smsRuleFormWalletsHelper,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],

          const SizedBox(height: 24),
          ExpansionTile(
            title: Text(context.l10n.smsRuleFormAdvanced, style: tt.bodyMedium),
            subtitle: Text(context.l10n.smsRuleFormCustomRegex, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            tilePadding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _regexCtrl,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.l10n.smsRuleFormRegexHint,
                  hintText: r'r"(\d+(?:\.\d{1,2})?)"',
                  helperText: context.l10n.smsRuleFormRegexHelper,
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
                : Text(_isEditing ? context.l10n.smsRuleFormSaveChanges : context.l10n.smsRuleFormSaveNew),
          ),

          if (_isEditing) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _saving ? null : _delete,
              style: TextButton.styleFrom(foregroundColor: cs.error),
              child: Text(context.l10n.smsRuleFormDeleteRule),
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
  final String expenseLabel;
  final String incomeLabel;
  final ValueChanged<String> onChanged;
  const _TypeToggle({required this.selected, required this.expenseLabel, required this.incomeLabel, required this.onChanged});

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
            label: expenseLabel,
            active: selected == 'expense',
            onTap: () => onChanged('expense'),
          ),
          _Segment(
            label: incomeLabel,
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

// ---------------------------------------------------------------------------
// Description field with inline suggestions from past transactions
// ---------------------------------------------------------------------------

class _DescriptionAutocomplete extends StatefulWidget {
  final String? initialDescription;
  final List<Category> categories;
  final TransactionRepository repo;
  final ValueChanged<TextEditingController> onControllerReady;
  final ValueChanged<DescriptionSuggestion> onSuggestionSelected;

  const _DescriptionAutocomplete({
    required this.categories,
    required this.repo,
    required this.onControllerReady,
    required this.onSuggestionSelected,
    this.initialDescription,
  });

  @override
  State<_DescriptionAutocomplete> createState() =>
      _DescriptionAutocompleteState();
}

class _DescriptionAutocompleteState extends State<_DescriptionAutocomplete> {
  late final TextEditingController _ctrl;
  List<DescriptionSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialDescription ?? '');
    _ctrl.addListener(_onChanged);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onControllerReady(_ctrl));
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final text = _ctrl.text.trim();
    if (text.length < 2) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    widget.repo.getDescriptionSuggestions(text).then((results) {
      if (mounted) setState(() => _suggestions = results);
    });
  }

  void _select(DescriptionSuggestion suggestion) {
    _ctrl.text = suggestion.description;
    _ctrl.selection =
        TextSelection.collapsed(offset: _ctrl.text.length);
    setState(() => _suggestions = []);
    widget.onSuggestionSelected(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _ctrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: context.l10n.smsRuleFormLabelHint,
            border: const OutlineInputBorder(),
            helperText: context.l10n.smsRuleFormLabelHelper,
            helperMaxLines: 2,
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < _suggestions.length; i++) ...[
                  if (i > 0)
                    Divider(
                        height: 1, color: cs.surfaceContainerHighest),
                  _SuggestionTile(
                    suggestion: _suggestions[i],
                    categories: widget.categories,
                    onTap: () => _select(_suggestions[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final DescriptionSuggestion suggestion;
  final List<Category> categories;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.suggestion,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cat =
        categories.where((c) => c.uuid == suggestion.categoryUuid).firstOrNull;
    final iconColor =
        cat != null ? Color(cat.colorValue) : cs.onSurfaceVariant;
    final iconData = cat != null
        ? IconData(cat.iconCodePoint, fontFamily: cat.iconFontFamily)
        : Icons.receipt_outlined;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: iconColor.withValues(alpha: 0.15),
              child: Icon(iconData, color: iconColor, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(suggestion.description,
                      style:
                          const TextStyle(fontWeight: FontWeight.w500)),
                  if (cat != null)
                    Text(cat.name,
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.north_west, size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
