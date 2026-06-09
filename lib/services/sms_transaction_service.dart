import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/transaction.dart';
import '../domain/services/sms_parser_service.dart';
import '../providers/accounts_provider.dart';
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
    if (body.isEmpty) return;

    final rules = ref.read(smsRulesProvider).asData?.value ?? [];
    final activeRules = rules.where((r) => r.isActive).toList();

    final matched = SmsParserService.matchRule(body, activeRules);
    if (matched == null) return;

    final amount = SmsParserService.extractAmount(
      body,
      customRegex: matched.amountRegex,
    );
    if (amount == null || amount <= 0) return;

    final accounts = ref.read(accountsProvider).asData?.value ?? [];
    final fallbackAccountId = accounts.isNotEmpty
        ? (accounts.firstWhere((a) => a.isFavorite, orElse: () => accounts.first).id ?? matched.accountId)
        : matched.accountId;
    final resolvedAccountId = accounts.any((a) => a.id == matched.accountId)
        ? matched.accountId
        : fallbackAccountId;

    final now = DateTime.now();
    final tx = Transaction(
      uuid: _uuid.v4(),
      accountId: resolvedAccountId,
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
  }
}
