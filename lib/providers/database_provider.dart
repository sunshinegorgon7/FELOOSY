import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/account_repository.dart';
import '../data/repositories/recurring_rule_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/sms_rule_repository.dart';
import '../data/repositories/sms_suggestion_feedback_repository.dart';
import '../data/repositories/transaction_repository.dart';

export '../data/repositories/sms_suggestion_feedback_repository.dart' show SmsRejectedEntry;

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseHelperProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseHelperProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(databaseHelperProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(databaseHelperProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(databaseHelperProvider));
});

final smsRuleRepositoryProvider = Provider<SmsRuleRepository>((ref) {
  return SmsRuleRepository(ref.watch(databaseHelperProvider));
});

final recurringRuleRepositoryProvider = Provider<RecurringRuleRepository>((ref) {
  return RecurringRuleRepository(ref.watch(databaseHelperProvider));
});

final smsSuggestionFeedbackRepositoryProvider = Provider<SmsSuggestionFeedbackRepository>((ref) {
  return SmsSuggestionFeedbackRepository(ref.watch(databaseHelperProvider));
});

final dismissedSuggestionsProvider = FutureProvider<List<SmsRejectedEntry>>((ref) {
  return ref.watch(smsSuggestionFeedbackRepositoryProvider).getAllRejected();
});
