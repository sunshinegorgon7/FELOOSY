import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/budget_period_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/budget_summary_provider.dart';
import '../../providers/settings_provider.dart';
import 'set_budget_sheet.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(currentBudgetPeriodProvider);
    final budgetAsync = ref.watch(currentBudgetProvider);
    final summaryAsync = ref.watch(budgetSummaryProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current period card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20),
                      const Gap(8),
                      Text('Current Period',
                          style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                  const Gap(8),
                  Text(period.label,
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '${DateFormat('MMM d').format(period.start)} – ${DateFormat('MMM d, y').format(period.end)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant),
                  ),
                  const Gap(16),
                  budgetAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                    data: (budget) => budget == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No budget set',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                              ),
                              const Gap(12),
                              FilledButton.icon(
                                onPressed: () => _showSetBudget(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Set Budget'),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Budget',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant)),
                                        Text(
                                          settingsAsync.whenOrNull(
                                                data: (s) =>
                                                    CurrencyFormatter.format(
                                                        budget.amount, s),
                                              ) ??
                                              budget.amount
                                                  .toStringAsFixed(2),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _showSetBudget(context),
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 16),
                                    label: const Text('Change'),
                                  ),
                                ],
                              ),
                              const Gap(12),
                              summaryAsync.whenOrNull(
                                    data: (s) {
                                      final progress =
                                          s.spentPercentage.clamp(0.0, 1.0);
                                      return Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 8,
                                            ),
                                          ),
                                          const Gap(4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                'Spent: ${s.formatAmount(s.totalExpenses)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall,
                                              ),
                                              Text(
                                                'Remaining: ${s.formatAmount(s.remaining)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                        color: s.isOverBudget
                                                            ? Colors.red
                                                            : Colors
                                                                .green
                                                                .shade700),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ) ??
                                  const SizedBox.shrink(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetBudget(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SetBudgetSheet(),
    );
  }
}
