import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../app/app_theme.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../core/widgets/category_icon.dart';
import '../../data/models/category.dart';
import '../../data/models/recurring_rule.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../providers/categories_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/recurring_rules_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/access_tier_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../services/recurring_transaction_service.dart';

const _windowChannel = MethodChannel('com.feloosy/window');

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
  final _amountFocusNode = FocusNode();
  DateTime _date = DateTime.now();
  String? _selectedCategoryUuid;
  bool _saving = false;
  bool _isRecurring = false;
  RecurringFrequency _frequency = RecurringFrequency.monthly;

  bool get _isEditing => widget.initialTransaction != null;

  bool get _canSave {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', ''));
    return amount != null && amount > 0 && _selectedCategoryUuid != null;
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadRecurringRule() async {
    final ruleUuid = widget.initialTransaction?.recurringRuleUuid;
    if (ruleUuid == null) return;
    final rule =
        await ref.read(recurringRuleRepositoryProvider).getByUuid(ruleUuid);
    if (rule != null && mounted) setState(() => _frequency = rule.frequency);
  }

  @override
  void initState() {
    super.initState();
    _type = widget.type == 'income'
        ? TransactionType.income
        : TransactionType.expense;

    final initial = widget.initialTransaction;
    if (initial != null) {
      if (initial.isCarryOver) {
        // System-generated; pop immediately after the frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (context.canPop()) context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('System transactions cannot be edited.'),
              ),
            );
          }
        });
        return;
      }
      _type = initial.type;
      _amountController.text = initial.amount.toStringAsFixed(2);
      _date = initial.transactionDate;
      _selectedCategoryUuid = initial.categoryUuid;
      if (initial.isRecurring) {
        _isRecurring = true;
        _loadRecurringRule();
      }
    }

    if (_isEditing) _amountController.addListener(_onFieldChanged);

    // Normal push-nav: keyboard via postFrameCallback + immediate TextInput.show.
    // Deep-link / widget-tap: when the app is already foregrounded, Android never
    // re-fires onWindowFocusChanged, so the MethodChannel event never arrives.
    // The timer fallback below covers that case: by 300 ms the window always has
    // OS-level focus, so TextInput.show reliably raises the soft keyboard.
    _windowChannel.setMethodCallHandler(_onWindowFocused);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _amountFocusNode.requestFocus();
      // Immediate attempt for regular push-navigation.
      await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      // Delayed fallback for widget deep-links where window focus arrives late.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (mounted && _amountFocusNode.hasFocus) {
        await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      }
    });
  }

  Future<dynamic> _onWindowFocused(MethodCall call) async {
    if (!mounted) return;
    // Restore focus to the amount field only when Flutter-level focus was
    // cleared by a native overlay (e.g. Google Sign-In silent restore) AND
    // the user hasn't yet moved to the description field. This avoids yanking
    // focus away mid-interaction while still recovering the keyboard after the
    // native dialog dismisses.
    final descEmpty = _descFieldController?.text.isEmpty ?? true;
    if (!_amountFocusNode.hasFocus && descEmpty) {
      _amountFocusNode.requestFocus();
    }
    await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  @override
  void dispose() {
    _windowChannel.setMethodCallHandler(null);
    _amountController.removeListener(_onFieldChanged);
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  // ── Auto-save logic ─────────────────────────────────────────────────────

  /// Called whenever a field changes. Saves silently when all three
  /// required fields (amount, description, category) are complete.
  /// [description] can be supplied directly (e.g. from an autocomplete
  /// selection) to avoid reading the controller which may not have settled yet.
  void _tryAutoSave({String? description}) {
    if (_saving || _isEditing) return;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    final desc = description ?? _descFieldController?.text.trim() ?? '';
    if (desc.isEmpty) return;
    if (_selectedCategoryUuid == null) return;
    _commit(amount: amount, description: desc);
  }

  void _manualSave() {
    final l10n = context.l10n;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionValidAmount)),
      );
      return;
    }
    final desc = _descFieldController?.text.trim() ?? '';
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionAddDescription)),
      );
      return;
    }
    if (_selectedCategoryUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionSelectCategory)),
      );
      return;
    }
    final initial = widget.initialTransaction;
    if (initial != null && initial.isRecurring) {
      _showEditScopeDialog(amount: amount, description: desc);
    } else {
      _commit(amount: amount, description: desc);
    }
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
        // accessTierProvider is synchronous and resolves to free while async
        // providers are still loading — same conservative intent as before.
        final tier = ref.read(accessTierProvider);
        final limit = tier.monthlyTxPerWallet;
        if (limit != null) {
          final now = DateTime.now();
          final count = await ref
              .read(transactionRepositoryProvider)
              .countForMonth(now.year, now.month, account?.id ?? 1);
          if (count >= limit) {
            if (mounted) context.push('/paywall');
            return;
          }
        }
        if (_isRecurring) {
          final ruleUuid = const Uuid().v4();
          final rule = RecurringRule(
            uuid: ruleUuid,
            accountId: account?.id ?? 1,
            amount: amount,
            type: _type.name,
            description: description,
            categoryUuid: _selectedCategoryUuid!,
            frequency: _frequency,
            startDate: DateUtils.dateOnly(_date),
            isActive: true,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(recurringRuleRepositoryProvider).insert(rule);
          await RecurringTransactionService.generatePending(
            txRepo: ref.read(transactionRepositoryProvider),
            ruleRepo: ref.read(recurringRuleRepositoryProvider),
          );
          ref.invalidate(transactionsProvider);
          ref.invalidate(recurringRulesProvider);
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
      }
      if (mounted) {
        if (context.canPop()) { context.pop(); }
        else { context.go('/'); }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showEditScopeDialog({
    required double amount,
    required String description,
  }) async {
    final scope = await showDialog<_EditScope>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit recurring transaction'),
        content: const Text('How would you like to apply this change?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _EditScope.thisOnly),
            child: const Text('Only this'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _EditScope.thisAndFuture),
            child: const Text('This & future'),
          ),
        ],
      ),
    );
    if (scope == null) return;
    await _commitWithScope(scope: scope, amount: amount, description: description);
  }

  Future<void> _commitWithScope({
    required _EditScope scope,
    required double amount,
    required String description,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final initial = widget.initialTransaction!;

      if (scope == _EditScope.thisOnly) {
        // Detach this occurrence from the rule — it becomes a standalone tx.
        final updated = Transaction(
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
          source: 'manual',
        );
        await ref.read(transactionsProvider.notifier).edit(updated);
      } else {
        // Save this occurrence (keep source so the badge stays).
        final updatedTx = Transaction(
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
          source: initial.source,
        );
        await ref.read(transactionsProvider.notifier).edit(updatedTx);

        // Update the rule and trim future occurrences.
        final ruleUuid = initial.recurringRuleUuid!;
        final ruleRepo = ref.read(recurringRuleRepositoryProvider);
        final rule = await ruleRepo.getByUuid(ruleUuid);
        if (rule != null) {
          final thisDate = DateUtils.dateOnly(_date);
          final updatedRule = RecurringRule(
            uuid: rule.uuid,
            accountId: rule.accountId,
            amount: amount,
            type: _type.name,
            description: description,
            categoryUuid: _selectedCategoryUuid!,
            frequency: _frequency,
            startDate: rule.startDate,
            lastGeneratedDate: thisDate,
            isActive: rule.isActive,
            createdAt: rule.createdAt,
            updatedAt: now,
          );
          await ruleRepo.update(updatedRule);
          await ruleRepo.deleteFutureOccurrences(ruleUuid, thisDate);
          ref.invalidate(recurringRulesProvider);
        }
        ref.invalidate(transactionsProvider);
      }

      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
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
        isExpense ? AppTheme.expenseText(cs) : AppTheme.incomeText(cs);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) { context.pop(); }
            else { context.go('/'); }
          },
        ),
        title: Text(_isEditing ? context.l10n.transactionTitleEdit : context.l10n.transactionTitleNew),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _canSave ? _manualSave : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(context.l10n.save),
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

                  // Recurring toggle (create mode) / frequency picker (edit mode)
                  if (!_isEditing || _isRecurring) ...[
                    const SizedBox(height: 10),
                    _RecurringToggleRow(
                      isRecurring: _isRecurring,
                      frequency: _frequency,
                      isEditing: _isEditing,
                      onToggle: _isEditing
                          ? null
                          : (v) => setState(() => _isRecurring = v),
                      onFrequencyChanged: (f) =>
                          setState(() => _frequency = f),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Amount row: currency label left, DM Mono number right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryText(cs),
                          letterSpacing: 14 * 0.08,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.]')),
                          ],
                          autofocus: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'DM Mono',
                            color: amountColor,
                            letterSpacing: 56 * -0.02,
                            height: 1.1,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'DM Mono',
                              color: cs.onSurface.withValues(alpha: 0.35),
                              letterSpacing: 56 * -0.02,
                              height: 1.1,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                            _tryAutoSave();
                          },
                        ),
                      ),
                    ],
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
                      // Pass the description directly — the controller text
                      // may not have propagated to _descFieldController yet.
                      _tryAutoSave(description: suggestion.description);
                    },
                    onSubmitted: _tryAutoSave,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Divider(height: 1, color: cs.outlineVariant),

            // ── Scrollable: categories ───────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(context.l10n.categories, style: tt.titleSmall),

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
                          final typeKey = isExpense ? 'expense' : 'income';
                          final currencyCode =
                              account?.currencyCode ?? 'AED';
                          final active =
                              (cats.where((c) =>
                                      c.isActive &&
                                      (c.transactionType == typeKey ||
                                          c.transactionType == null) &&
                                      (c.currencyHint == null ||
                                          c.currencyHint == currencyCode))
                                  .toList()
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
                            onAddCategory: () => context.push(
                              '/categories/edit',
                              extra: {'defaultType': typeKey},
                            ),
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
    if (d == today) return context.l10n.today;
    if (d == today.subtract(const Duration(days: 1))) return context.l10n.yesterday;
    return DateFormat('MMM d').format(date);
  }
}

enum _EditScope { thisOnly, thisAndFuture }

// ---------------------------------------------------------------------------
// Recurring toggle + frequency chips
// ---------------------------------------------------------------------------

class _RecurringToggleRow extends StatelessWidget {
  final bool isRecurring;
  final RecurringFrequency frequency;
  final bool isEditing;
  final ValueChanged<bool>? onToggle;
  final ValueChanged<RecurringFrequency> onFrequencyChanged;

  const _RecurringToggleRow({
    required this.isRecurring,
    required this.frequency,
    required this.isEditing,
    required this.onToggle,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final l10n = context.l10n;
    final freqLabels = {
      RecurringFrequency.daily: l10n.daily,
      RecurringFrequency.weekly: l10n.weekly,
      RecurringFrequency.monthly: l10n.monthly,
      RecurringFrequency.annually: l10n.annually,
    };

    Widget frequencyChips() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: RecurringFrequency.values.map((f) {
              final selected = f == frequency;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => onFrequencyChanged(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.primary.withValues(alpha: 0.12)
                          : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? cs.primary
                            : cs.outlineVariant,
                        width: selected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      freqLabels[f]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? cs.primary
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );

    // Edit mode: just show the frequency picker with a label.
    if (isEditing) {
      return Row(
        children: [
          Icon(Icons.repeat_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            l10n.transactionRepeats,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: frequencyChips()),
        ],
      );
    }

    // Create mode: toggle + chips when active.
    return Row(
      children: [
        GestureDetector(
          onTap: () => onToggle?.call(!isRecurring),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRecurring
                    ? Icons.repeat_rounded
                    : Icons.repeat_outlined,
                size: 16,
                color: isRecurring ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.recurring,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isRecurring
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isRecurring ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isRecurring) ...[
          const SizedBox(width: 10),
          Expanded(child: frequencyChips()),
        ],
      ],
    );
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
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final parts = <String>[
      if (amountMissing) 'amount',
      if (categoryMissing) 'category',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        l10n.transactionAddFieldsTooltip(parts.join(' & ')),
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
          label: context.l10n.expense,
          symbol: '−',
          selected: isExpense,
          selectedColor: AppTheme.expenseText(Theme.of(context).colorScheme),
          onTap: onExpense,
        ),
        const SizedBox(width: 8),
        _Chip(
          label: context.l10n.income,
          symbol: '+',
          selected: !isExpense,
          selectedColor: AppTheme.incomeText(Theme.of(context).colorScheme),
          onTap: onIncome,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String symbol;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.symbol,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? selectedColor : cs.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? selectedColor : cs.outlineVariant,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: selected
                    ? selectedColor.withValues(alpha: 0.18)
                    : cs.outlineVariant.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
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
                  final iconColor = cat != null
                      ? AppTheme.categoryBarColor(
                          uuid: cat.uuid,
                          colorValue: cat.colorValue,
                          colorScheme: cs,
                        )
                      : cs.onSurfaceVariant;

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
                            child: cat != null
                                ? CategoryIcon(
                                    category: cat,
                                    size: 14,
                                    color: iconColor,
                                  )
                                : Icon(Icons.receipt_outlined,
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
            hintText: context.l10n.transactionDescription,
            filled: true,
            fillColor: cs.surfaceContainerLow,
            prefixIcon:
                Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
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
  final VoidCallback? onAddCategory;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
    this.mostUsedUuids = const [],
    this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            context.l10n.transactionFrequent,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.10 * 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
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
          Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
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
          itemCount: remainingCategories.length + 1,
          itemBuilder: (context, index) {
            if (index == remainingCategories.length) {
              return _AddCategoryCell(onTap: onAddCategory);
            }
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
    final cs = Theme.of(context).colorScheme;
    final color = AppTheme.categoryBarColor(
      uuid: cat.uuid,
      colorValue: cat.colorValue,
      colorScheme: cs,
    );
    return GestureDetector(
      onTap: () => onSelect(cat.uuid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.12)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : color.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryIcon(
              category: cat,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cat.name,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
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

class _AddCategoryCell extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddCategoryCell({this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 22, color: cs.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(
              context.l10n.transactionNewCategory,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
