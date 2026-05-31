import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../providers/budget_period_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/settings_provider.dart';

class SetBudgetSheet extends ConsumerStatefulWidget {
  const SetBudgetSheet({super.key});

  @override
  ConsumerState<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends ConsumerState<SetBudgetSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing budget amount if set
    final existing = ref.read(currentBudgetProvider).value;
    if (existing != null) {
      _controller.text = existing.amount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final amount =
          double.parse(_controller.text.replaceAll(',', ''));
      await ref.read(currentBudgetProvider.notifier).setAmount(amount);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final period = ref.watch(currentBudgetPeriodProvider);
    final account = ref.watch(activeAccountProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final symbol = account?.currencySymbol ??
        settingsAsync.whenOrNull(data: (s) => s.currencySymbol) ??
        'AED';

    return Padding(
      // Push sheet up when keyboard appears
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(16),
                Text(l10n.setBudgetForPeriod(period.label),
                    style: Theme.of(context).textTheme.titleMedium),
                const Gap(4),
                Text(
                  l10n.setBudgetHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                ),
                const Gap(20),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: l10n.setBudgetAmount,
                    prefixText: '$symbol  ',
                    prefixStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                    border: const OutlineInputBorder(),
                    hintText: '0.00',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.setBudgetEnterAmount;
                    final n =
                        double.tryParse(v.replaceAll(',', ''));
                    if (n == null || n <= 0) return l10n.setBudgetValidAmount;
                    return null;
                  },
                ),
                const Gap(20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ))
                        : Text(l10n.setBudgetSave),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
