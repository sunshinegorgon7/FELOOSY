import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/currencies.dart';
import '../data/models/account.dart';
import 'database_provider.dart';

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    return ref.watch(accountRepositoryProvider).getAll();
  }

  Future<void> add({
    required String name,
    required CurrencyOption currency,
    double? defaultMonthlyBudget,
  }) async {
    final now = DateTime.now();
    final account = Account(
      name: name,
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      currencySymbolLeading: currency.symbolLeading,
      defaultMonthlyBudget: defaultMonthlyBudget,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(accountRepositoryProvider).create(account);
    ref.invalidateSelf();
  }

  Future<void> save(Account account) async {
    await ref.read(accountRepositoryProvider).save(account);
    ref.invalidateSelf();
  }

  Future<void> setFavorite(int accountId) async {
    await ref.read(accountRepositoryProvider).setFavorite(accountId);
    ref.invalidateSelf();
  }

  Future<void> delete(int accountId) async {
    await ref.read(accountRepositoryProvider).delete(accountId);
    ref.invalidateSelf();
  }
}

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<Account>>(AccountsNotifier.new);

/// Home filter. null => all accounts.
final selectedHomeAccountIdProvider = StateProvider<int?>((ref) => null);

final activeAccountProvider = Provider<Account?>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
  if (accounts.isEmpty) return null;
  final selected = ref.watch(selectedHomeAccountIdProvider);
  if (selected != null) {
    return accounts.where((a) => a.id == selected).firstOrNull ?? accounts.first;
  }
  return accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.first;
});
