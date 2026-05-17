import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';
import '../data/models/category.dart';
import '../data/models/transaction.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../domain/services/ai_analysis_service.dart';
import '../domain/services/local_analysis_service.dart';
import 'categories_provider.dart';

// ── Repository provider ──────────────────────────────────────────────────────

final aiCacheRepositoryProvider = Provider<AiCacheRepository>((_) {
  return AiCacheRepository(DatabaseHelper.instance);
});

// ── Hash computation ─────────────────────────────────────────────────────────

String computeGroupHash(List<Transaction> transactions, double budgetAmount) {
  final sorted = [...transactions]..sort((a, b) => a.uuid.compareTo(b.uuid));
  final buffer = StringBuffer();
  for (final t in sorted) {
    buffer.write(
      '${t.uuid}|${t.amount}|${t.type.name}|${t.categoryUuid}|${t.transactionDate.millisecondsSinceEpoch}|',
    );
  }
  buffer.write('budget:${budgetAmount.toStringAsFixed(2)}');
  return sha256.convert(utf8.encode(buffer.toString())).toString();
}

// ── Per-group cache lookup ───────────────────────────────────────────────────

final aiCacheForHashProvider =
    FutureProvider.family<AiCacheEntry?, String>((ref, hash) async {
  final repo = ref.read(aiCacheRepositoryProvider);
  return repo.get(hash);
});

// ── Background scanner state ─────────────────────────────────────────────────

class AiScanJob {
  final String hash;
  final String groupLabel;
  final List<Transaction> transactions;
  final double budgetAmount;
  final String currencySymbol;
  final bool symbolLeading;

  const AiScanJob({
    required this.hash,
    required this.groupLabel,
    required this.transactions,
    required this.budgetAmount,
    required this.currencySymbol,
    required this.symbolLeading,
  });
}

class AiBackgroundScanner extends Notifier<Set<String>> {
  bool _running = false;

  @override
  Set<String> build() => {};

  /// Queue a list of groups for background analysis.
  /// Only complete (past) periods should be enqueued.
  Future<void> enqueue(List<AiScanJob> jobs) async {
    if (_running) return;
    _running = true;

    final repo = ref.read(aiCacheRepositoryProvider);
    final cats = ref.read(categoriesProvider).asData?.value ?? const <Category>[];

    for (final job in jobs) {
      // Skip if already cached and doesn't need retry
      final existing = await repo.get(job.hash);
      final needsRetry = existing != null && await repo.needsRetry(job.hash);
      if (existing != null && !needsRetry) continue;

      // Mark as in-progress in state so UI can react
      state = {...state, job.hash};

      final result = await AiAnalysisService.analyze(
        transactions: job.transactions,
        categories: cats,
        groupLabel: job.groupLabel,
        currencySymbol: job.currencySymbol,
        symbolLeading: job.symbolLeading,
        budgetAmount: job.budgetAmount,
      );

      if (result is AiAnalysisSuccess) {
        await repo.put(
          hash: job.hash,
          groupLabel: job.groupLabel,
          result: result,
          source: 'ai',
        );
      } else if (result is AiAnalysisQuotaExceeded) {
        // Fall back to local, mark for retry tomorrow
        final local = LocalAnalysisService.analyze(
          transactions: job.transactions,
          categories: cats,
          groupLabel: job.groupLabel,
          currencySymbol: job.currencySymbol,
          symbolLeading: job.symbolLeading,
          budgetAmount: job.budgetAmount,
        );
        final retryAfter = DateTime.now().add(const Duration(hours: 25));
        await repo.put(
          hash: job.hash,
          groupLabel: job.groupLabel,
          result: local,
          source: 'local',
          retryAfter: retryAfter,
        );
        // Refresh UI then stop — quota hit, no point continuing
        ref.invalidate(aiCacheForHashProvider(job.hash));
        state = state.difference({job.hash});
        break;
      } else {
        // Network/other failure — local fallback, retry in 1 hour
        final local = LocalAnalysisService.analyze(
          transactions: job.transactions,
          categories: cats,
          groupLabel: job.groupLabel,
          currencySymbol: job.currencySymbol,
          symbolLeading: job.symbolLeading,
          budgetAmount: job.budgetAmount,
        );
        final retryAfter = DateTime.now().add(const Duration(hours: 1));
        await repo.put(
          hash: job.hash,
          groupLabel: job.groupLabel,
          result: local,
          source: 'local',
          retryAfter: retryAfter,
        );
      }

      // Refresh the UI cache for this hash so the card re-reads from SQLite
      ref.invalidate(aiCacheForHashProvider(job.hash));
      state = state.difference({job.hash});

      // Rate limit: 1 request per 5 seconds (12 RPM, safely under 15 RPM free tier)
      await Future.delayed(const Duration(seconds: 5));
    }

    _running = false;
  }
}

final aiBackgroundScannerProvider =
    NotifierProvider<AiBackgroundScanner, Set<String>>(
        AiBackgroundScanner.new);
