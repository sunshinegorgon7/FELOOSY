import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../app/app_flavor.dart';
import '../core/utils/dev_log.dart';
import '../data/database/database_helper.dart';
import '../data/models/transaction.dart';
import '../data/repositories/account_repository.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/sms_ledger_repository.dart';
import '../data/repositories/sms_rule_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/services/sms_parser_service.dart';
import 'home_widget_sync_service.dart';

const _uuid = Uuid();
const _channel = MethodChannel('com.feloosy/sms_background');

@pragma('vm:entry-point')
void smsBackgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();

  _channel.setMethodCallHandler((call) async {
    if (call.method == 'sms') {
      final args = call.arguments as Map;
      final isDev = args['isDev'] as bool? ?? false;
      await AppFlavor.initialize(isDev ? Flavor.dev : Flavor.prod);

      final body = args['body'] as String? ?? '';
      final sender = args['sender'] as String? ?? '';
      await DevLog.log('BG', 'engine started, body="${_preview(body)}"');
      if (body.isNotEmpty) {
        await _processSms(sender: sender, body: body);
      }
      _channel.invokeMethod('processed', null);
    }
  });

  _channel.invokeMethod('ready', null);
}

Future<void> _processSms({required String sender, required String body}) async {
  final db = DatabaseHelper.instance;
  final ruleRepo = SmsRuleRepository(db);
  final txRepo = TransactionRepository(db);
  final accountRepo = AccountRepository(db);
  final ledger = SmsLedgerRepository(db);

  final rules = await ruleRepo.getAll();
  final activeRules = rules.where((r) => r.isActive).toList();

  final matched = SmsParserService.matchRule(body, activeRules);
  if (matched == null) {
    await DevLog.log('BG', 'no rule matched');
    return;
  }

  final amount = SmsParserService.extractAmount(
    body,
    customRegex: matched.amountRegex,
  );
  if (amount == null || amount <= 0) {
    await DevLog.log('BG', 'rule "${matched.keyword}" matched but no amount');
    return;
  }

  // Atomic claim: the foreground replay may be processing this same SMS.
  final hash = SmsLedgerRepository.hashFor(sender: sender, body: body);
  final claimed = await ledger.claim(hash);
  await DevLog.log('BG',
      'rule="${matched.keyword}" amount=$amount claim=$claimed hash=${hash.substring(0, 8)}');
  if (!claimed) return;

  final accounts = await accountRepo.getAll();
  if (accounts.isEmpty) return;

  final fallbackAccountId =
      accounts.firstWhere((a) => a.isFavorite, orElse: () => accounts.first).id ?? 1;

  final resolvedAccountIds = matched.accountIds
      .where((id) => accounts.any((a) => a.id == id))
      .toList();
  if (resolvedAccountIds.isEmpty) {
    resolvedAccountIds.add(fallbackAccountId);
  }

  final now = DateTime.now();
  var inserted = false;
  for (final accountId in resolvedAccountIds) {
    // Second layer: skip if the user already entered this manually.
    final isDuplicate = await txRepo.hasSimilarRecent(
      accountId: accountId,
      amount: amount,
      categoryUuid: matched.categoryUuid,
      around: now,
    );
    if (isDuplicate) {
      await DevLog.log('BG', 'account $accountId: amount-dup, skipped');
      continue;
    }

    final tx = Transaction(
      uuid: _uuid.v4(),
      accountId: accountId,
      amount: amount,
      type: matched.transactionType == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      description: matched.transactionDescription,
      categoryUuid: matched.categoryUuid,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
      source: 'sms_rule:${matched.id}',
    );
    await txRepo.insert(tx);
    inserted = true;
    await DevLog.log('BG', 'account $accountId: inserted $amount');
  }

  // Refresh the home widget so it reflects the new transaction even though the
  // app process is dead — otherwise the widget stays stale until next open.
  if (inserted) {
    await syncWidgetFromRepos(
      accounts: accounts,
      settingsRepo: SettingsRepository(db),
      txRepo: txRepo,
      budgetRepo: BudgetRepository(db),
      categoryRepo: CategoryRepository(db),
    );
    await DevLog.log('BG', 'widget synced');
  }
}

String _preview(String body) =>
    body.length <= 40 ? body : '${body.substring(0, 40)}…';
