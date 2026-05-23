import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sms_rule.dart';
import 'database_provider.dart';

final smsRulesProvider =
    AsyncNotifierProvider<SmsRulesNotifier, List<SmsRule>>(
        SmsRulesNotifier.new);

class SmsRulesNotifier extends AsyncNotifier<List<SmsRule>> {
  @override
  Future<List<SmsRule>> build() =>
      ref.read(smsRuleRepositoryProvider).getAll();

  Future<void> add(SmsRule rule) async {
    await ref.read(smsRuleRepositoryProvider).insert(rule);
    ref.invalidateSelf();
  }

  Future<void> save(SmsRule rule) async {
    await ref.read(smsRuleRepositoryProvider).update(rule);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(smsRuleRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  Future<void> toggleActive(SmsRule rule) async {
    await ref
        .read(smsRuleRepositoryProvider)
        .update(rule.copyWith(isActive: !rule.isActive));
    ref.invalidateSelf();
  }
}
