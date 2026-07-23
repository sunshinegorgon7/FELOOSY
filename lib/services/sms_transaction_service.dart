import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/dev_log.dart';
import '../data/models/transaction.dart';
import '../data/repositories/sms_ledger_repository.dart';
import '../domain/services/sms_parser_service.dart';
import '../providers/accounts_provider.dart';
import '../providers/database_provider.dart';
import '../providers/sms_rules_provider.dart';
import '../providers/transactions_provider.dart';

class SmsTransactionService {
  static const _channel = EventChannel('com.feloosy/sms');
  static const _uuid = Uuid();

  StreamSubscription<dynamic>? _sub;

  void start(WidgetRef ref, {void Function(Transaction)? onCreated}) {
    if (!Platform.isAndroid) return;
    _sub?.cancel();
    _sub = _channel.receiveBroadcastStream().listen(
      (event) => _onSms(ref, event as Map, onCreated: onCreated),
      onError: (_) {},
    );
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> _onSms(
    WidgetRef ref,
    Map event, {
    void Function(Transaction)? onCreated,
  }) async {
    final body = event['body'] as String? ?? '';
    final sender = event['sender'] as String? ?? '';
    if (body.isEmpty) return;

    await DevLog.log('FG', 'received body="${_preview(body)}"');

    final rules = await ref.read(smsRulesProvider.future);
    final activeRules = rules.where((r) => r.isActive).toList();

    final matched = SmsParserService.matchRule(body, activeRules);
    if (matched == null) {
      await DevLog.log('FG', 'no rule matched');
      return;
    }

    final amount = SmsParserService.extractAmount(
      body,
      customRegex: matched.amountRegex,
    );
    if (amount == null || amount <= 0) {
      await DevLog.log('FG', 'rule "${matched.keyword}" matched but no amount');
      return;
    }

    // Atomic claim: the headless background engine may be processing this same
    // SMS. Whichever path wins the claim creates the transaction; the other
    // returns here, so the message is never double-counted.
    final hash = SmsLedgerRepository.hashFor(sender: sender, body: body);
    final claimed = await ref.read(smsLedgerRepositoryProvider).claim(hash);
    await DevLog.log('FG',
        'rule="${matched.keyword}" amount=$amount claim=$claimed hash=${hash.substring(0, 8)}');
    if (!claimed) return;

    final accounts = await ref.read(accountsProvider.future);
    final fallbackAccountId = accounts.isNotEmpty
        ? (accounts.firstWhere((a) => a.isFavorite, orElse: () => accounts.first).id ?? 1)
        : 1;

    final resolvedAccountIds = matched.accountIds
        .where((id) => accounts.any((a) => a.id == id))
        .toList();
    if (resolvedAccountIds.isEmpty) {
      resolvedAccountIds.add(fallbackAccountId);
    }

    final now = DateTime.now();
    final txRepo = ref.read(transactionRepositoryProvider);
    for (final accountId in resolvedAccountIds) {
      // Second layer: skip if the user already entered this manually.
      final isDuplicate = await txRepo.hasSimilarRecent(
        accountId: accountId,
        amount: amount,
        categoryUuid: matched.categoryUuid,
        around: now,
      );
      if (isDuplicate) {
        await DevLog.log('FG', 'account $accountId: amount-dup, skipped');
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

      await ref.read(transactionsProvider.notifier).add(tx);
      onCreated?.call(tx);
      await DevLog.log('FG', 'account $accountId: inserted $amount');
    }
  }

  static String _preview(String body) =>
      body.length <= 40 ? body : '${body.substring(0, 40)}…';
}
