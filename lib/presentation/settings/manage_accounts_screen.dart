import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_theme.dart';
import '../../core/constants/currencies.dart';
import '../../data/models/account.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/purchase_provider.dart';

class ManageAccountsScreen extends ConsumerWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final purchaseAsync = ref.watch(purchaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Wallets')),
      floatingActionButton: FloatingActionButton(
        onPressed: purchaseAsync.isLoading
            ? null
            : () {
                final accounts = accountsAsync.value ?? [];
                final isPurchased = purchaseAsync.value ?? false;
                if (!isPurchased && accounts.isNotEmpty) {
                  context.push('/paywall');
                  return;
                }
                _showAccountEditor(context, ref);
              },
        child: const Icon(Icons.add),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Text(
                'No wallets yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 80,
            ),
            children: [
              for (final a in accounts)
                _WalletRow(
                  account: a,
                  onFavorite: a.isFavorite || a.id == null
                      ? null
                      : () => ref
                          .read(accountsProvider.notifier)
                          .setFavorite(a.id!),
                  onEdit: () => _showAccountEditor(
                    context,
                    ref,
                    account: a,
                    canDelete: accounts.length > 1,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAccountEditor(
    BuildContext context,
    WidgetRef ref, {
    Account? account,
    bool canDelete = false,
  }) async {
    final nameCtrl = TextEditingController(text: account?.name ?? '');
    final budgetCtrl = TextEditingController(
      text: account?.defaultMonthlyBudget?.toStringAsFixed(2) ?? '',
    );
    var selectedCurrency = kCurrencies
            .where((c) => c.code == account?.currencyCode)
            .firstOrNull ??
        kCurrencies.first;
    int? selectedMonthStartDay = account?.monthStartDay;
    bool carryOverEnabled = account?.carryOverEnabled ?? false;
    String? nameError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(account == null ? 'Add wallet' : 'Edit wallet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  onChanged: (_) {
                    if (nameError != null) setState(() => nameError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Wallet name',
                    errorText: nameError,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CurrencyOption>(
                  initialValue: selectedCurrency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: kCurrencies
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text('${c.code} — ${c.name}')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedCurrency = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Default monthly budget (optional)',
                    hintText: 'Leave empty to disable',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: selectedMonthStartDay,
                  decoration: const InputDecoration(
                    labelText: 'Month starts on (optional)',
                    helperText: 'Leave as app default if not set',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('App default'),
                    ),
                    ...List.generate(28, (i) => i + 1).map(
                      (d) => DropdownMenuItem<int?>(
                        value: d,
                        child: Text('Day $d'),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedMonthStartDay = value),
                ),
                SwitchListTile(
                  title: const Text('Carry over unused budget'),
                  subtitle: const Text('Surplus rolls into the next month'),
                  value: carryOverEnabled,
                  onChanged: (v) => setState(() => carryOverEnabled = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actionsAlignment: canDelete && account != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          actions: [
            if (canDelete && account != null && account.id != null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.error,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(accountsProvider.notifier)
                      .delete(account.id!);
                },
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final currentAccounts =
                    ref.read(accountsProvider).value ?? [];
                final isDuplicate = currentAccounts.any(
                  (a) =>
                      a.name.toLowerCase() == name.toLowerCase() &&
                      a.id != account?.id,
                );
                if (isDuplicate) {
                  setState(() =>
                      nameError = 'A wallet with this name already exists');
                  return;
                }

                final budget = budgetCtrl.text.trim().isEmpty
                    ? null
                    : double.tryParse(
                        budgetCtrl.text.trim().replaceAll(',', ''));

                if (account == null) {
                  await ref.read(accountsProvider.notifier).add(
                        name: name,
                        currency: selectedCurrency,
                        defaultMonthlyBudget: budget,
                        monthStartDay: selectedMonthStartDay,
                        carryOverEnabled: carryOverEnabled,
                      );
                } else {
                  await ref.read(accountsProvider.notifier).save(
                        account.copyWith(
                          name: name,
                          currencyCode: selectedCurrency.code,
                          currencySymbol: selectedCurrency.symbol,
                          currencySymbolLeading: selectedCurrency.symbolLeading,
                          defaultMonthlyBudget: budget,
                          clearDefaultMonthlyBudget: budget == null,
                          monthStartDay: selectedMonthStartDay,
                          clearMonthStartDay: selectedMonthStartDay == null,
                          carryOverEnabled: carryOverEnabled,
                        ),
                      );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _WalletRow extends StatelessWidget {
  final Account account;
  final VoidCallback? onFavorite;
  final VoidCallback onEdit;

  const _WalletRow({
    required this.account,
    required this.onFavorite,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = AppTheme.primaryText(cs);
    final sliverColor = account.isFavorite ? accentColor : cs.outlineVariant;

    final budgetText = account.defaultMonthlyBudget != null
        ? '${_fmtAmount(account.defaultMonthlyBudget!)} / mo'
        : 'No default budget';
    final subtitle = account.carryOverEnabled
        ? '$budgetText · Carry-over on'
        : budgetText;

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 52,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: sliverColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
              color: account.isFavorite ? accentColor : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.name,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              account.currencyCode,
              style: GoogleFonts.dmMono(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: accentColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 2),
            IconButton(
              icon: Icon(
                account.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 20,
                color: account.isFavorite
                    ? accentColor
                    : cs.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              tooltip: account.isFavorite ? 'Default wallet' : 'Set as default',
              onPressed: onFavorite,
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              tooltip: 'Edit wallet',
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtAmount(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '$whole.${parts[1]}';
}
