import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/currencies.dart';
import '../../data/models/account.dart';
import '../../providers/accounts_provider.dart';

class ManageAccountsScreen extends ConsumerWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Wallets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccountEditor(context, ref),
        child: const Icon(Icons.add),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) => ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, i) {
            final a = accounts[i];
            return ListTile(
              title: Text(a.name),
              subtitle: Text('${a.currencyCode}${a.defaultMonthlyBudget != null ? ' • Budget default set' : ' • No default budget'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Favorite',
                    onPressed: a.id == null
                        ? null
                        : () => ref.read(accountsProvider.notifier).setFavorite(a.id!),
                    icon: Icon(
                      a.isFavorite ? Icons.star : Icons.star_border,
                      color: a.isFavorite ? Colors.amber : null,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAccountEditor(context, ref, account: a);
                      } else if (value == 'delete' && a.id != null && accounts.length > 1) {
                        ref.read(accountsProvider.notifier).delete(a.id!);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (accounts.length > 1)
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAccountEditor(BuildContext context, WidgetRef ref, {Account? account}) async {
    final nameCtrl = TextEditingController(text: account?.name ?? '');
    final budgetCtrl = TextEditingController(
      text: account?.defaultMonthlyBudget?.toStringAsFixed(2) ?? '',
    );
    var selectedCurrency = kCurrencies.where((c) => c.code == account?.currencyCode).firstOrNull ?? kCurrencies.first;
    // null = use app default
    int? selectedMonthStartDay = account?.monthStartDay;
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
                      .map((c) => DropdownMenuItem(value: c, child: Text('${c.code} — ${c.name}')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedCurrency = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  onChanged: (value) => setState(() => selectedMonthStartDay = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final currentAccounts = ref.read(accountsProvider).value ?? [];
                final isDuplicate = currentAccounts.any(
                  (a) => a.name.toLowerCase() == name.toLowerCase() && a.id != account?.id,
                );
                if (isDuplicate) {
                  setState(() => nameError = 'A wallet with this name already exists');
                  return;
                }

                final budget = budgetCtrl.text.trim().isEmpty
                    ? null
                    : double.tryParse(budgetCtrl.text.trim().replaceAll(',', ''));

                if (account == null) {
                  await ref.read(accountsProvider.notifier).add(
                        name: name,
                        currency: selectedCurrency,
                        defaultMonthlyBudget: budget,
                        monthStartDay: selectedMonthStartDay,
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
                        ),
                      );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
