import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../app/app_flavor.dart';
import '../data/database/database_helper.dart';
import '../data/models/transaction.dart';
import '../data/repositories/account_repository.dart';
import '../data/repositories/sms_rule_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/services/sms_parser_service.dart';

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
      if (body.isNotEmpty) {
        await _processSms(body);
      }
      _channel.invokeMethod('processed', null);
    }
  });

  _channel.invokeMethod('ready', null);
}

Future<void> _processSms(String body) async {
  final db = DatabaseHelper.instance;
  final ruleRepo = SmsRuleRepository(db);
  final txRepo = TransactionRepository(db);
  final accountRepo = AccountRepository(db);

  final rules = await ruleRepo.getAll();
  final activeRules = rules.where((r) => r.isActive).toList();

  final matched = SmsParserService.matchRule(body, activeRules);
  if (matched == null) return;

  final amount = SmsParserService.extractAmount(
    body,
    customRegex: matched.amountRegex,
  );
  if (amount == null || amount <= 0) return;

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
  for (final accountId in resolvedAccountIds) {
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
  }
}
