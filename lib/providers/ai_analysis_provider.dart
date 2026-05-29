import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';
import '../data/models/category.dart';
import '../data/models/transaction.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../domain/services/ai_analysis_result.dart';
import '../domain/services/local_analysis_service.dart';
import '../domain/services/local_llm_service.dart';
import 'categories_provider.dart';
import 'model_download_provider.dart';

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

// ── On-demand analysis job ───────────────────────────────────────────────────

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

// ── Analysis notifier ────────────────────────────────────────────────────────

class AiBackgroundScanner extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  /// Runs analysis for a single period on demand. No-op if already cached or running.
  Future<void> analyzeOne(AiScanJob job) async {
    if (state.contains(job.hash)) return;

    final repo = ref.read(aiCacheRepositoryProvider);
    final existing = await repo.get(job.hash);
    if (existing != null) return; // already cached

    state = {...state, job.hash};

    final cats =
        ref.read(categoriesProvider).asData?.value ?? const <Category>[];

    AiAnalysisResult result;
    String source;

    // Use on-device LLM on Android when model is ready; rule-based everywhere else
    if (Platform.isAndroid) {
      final modelState = ref.read(modelDownloadProvider).value;
      if (modelState is ModelStateReady) {
        result = await LocalLlmService.analyze(
          modelPath: modelState.modelPath,
          transactions: job.transactions,
          categories: cats,
          groupLabel: job.groupLabel,
          currencySymbol: job.currencySymbol,
          symbolLeading: job.symbolLeading,
          budgetAmount: job.budgetAmount,
        );
        source = result is AiAnalysisSuccess ? 'on-device' : 'local';
        // If LLM failed, fall back to rule-based
        if (result is! AiAnalysisSuccess) {
          result = LocalAnalysisService.analyze(
            transactions: job.transactions,
            categories: cats,
            groupLabel: job.groupLabel,
            currencySymbol: job.currencySymbol,
            symbolLeading: job.symbolLeading,
            budgetAmount: job.budgetAmount,
          );
          source = 'local';
        }
      } else {
        // Model not ready — use rule-based
        result = LocalAnalysisService.analyze(
          transactions: job.transactions,
          categories: cats,
          groupLabel: job.groupLabel,
          currencySymbol: job.currencySymbol,
          symbolLeading: job.symbolLeading,
          budgetAmount: job.budgetAmount,
        );
        source = 'local';
      }
    } else {
      // Non-Android: rule-based only
      result = LocalAnalysisService.analyze(
        transactions: job.transactions,
        categories: cats,
        groupLabel: job.groupLabel,
        currencySymbol: job.currencySymbol,
        symbolLeading: job.symbolLeading,
        budgetAmount: job.budgetAmount,
      );
      source = 'local';
    }

    if (result is AiAnalysisSuccess) {
      await repo.put(
        hash: job.hash,
        groupLabel: job.groupLabel,
        result: result,
        source: source,
      );
    }

    ref.invalidate(aiCacheForHashProvider(job.hash));
    state = state.difference({job.hash});
  }
}

final aiBackgroundScannerProvider =
    NotifierProvider<AiBackgroundScanner, Set<String>>(
  AiBackgroundScanner.new,
);
