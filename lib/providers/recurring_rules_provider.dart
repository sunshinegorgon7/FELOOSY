import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/recurring_rule.dart';
import 'database_provider.dart';

final recurringRulesProvider =
    AsyncNotifierProvider<RecurringRulesNotifier, List<RecurringRule>>(
        RecurringRulesNotifier.new);

class RecurringRulesNotifier extends AsyncNotifier<List<RecurringRule>> {
  @override
  Future<List<RecurringRule>> build() =>
      ref.read(recurringRuleRepositoryProvider).getAll();

  Future<void> add(RecurringRule rule) async {
    await ref.read(recurringRuleRepositoryProvider).insert(rule);
    ref.invalidateSelf();
  }

  Future<void> save(RecurringRule rule) async {
    await ref.read(recurringRuleRepositoryProvider).update(rule);
    ref.invalidateSelf();
  }

  Future<void> remove(String uuid) async {
    await ref.read(recurringRuleRepositoryProvider).delete(uuid);
    ref.invalidateSelf();
  }

  Future<void> toggleActive(RecurringRule rule) async {
    await ref
        .read(recurringRuleRepositoryProvider)
        .update(rule.copyWith(isActive: !rule.isActive));
    ref.invalidateSelf();
  }
}
