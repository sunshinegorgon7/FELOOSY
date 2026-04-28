import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../domain/entities/budget_summary.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummary summary;
  final VoidCallback onSetBudget;

  const BudgetSummaryCard({
    super.key,
    required this.summary,
    required this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.budgetAmount == 0) {
      return _NoBudgetCard(onSetBudget: onSetBudget, period: summary.period.label);
    }
    return _BudgetCard(summary: summary, onSetBudget: onSetBudget);
  }
}

class _NoBudgetCard extends StatelessWidget {
  final VoidCallback onSetBudget;
  final String period;
  const _NoBudgetCard({required this.onSetBudget, required this.period});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.wallet_outlined, size: 48, color: cs.primary),
            const Gap(12),
            Text(period,
                style: Theme.of(context).textTheme.titleMedium),
            const Gap(4),
            Text(
              'No budget set for this month yet.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: onSetBudget,
              icon: const Icon(Icons.add),
              label: const Text('Set Budget'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetSummary summary;
  final VoidCallback onSetBudget;
  const _BudgetCard({required this.summary, required this.onSetBudget});

  Color _barColor(BuildContext context) {
    if (summary.isOverBudget) return Colors.red;
    if (summary.spentPercentage > 0.8) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final progress = summary.spentPercentage.clamp(0.0, 1.0);
    final remainingColor = summary.isOverBudget
        ? Colors.red
        : summary.spentPercentage > 0.8
            ? Colors.orange
            : cs.primary;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period label + edit button
            Row(
              children: [
                Text(summary.period.label,
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                const Spacer(),
                GestureDetector(
                  onTap: onSetBudget,
                  child: Icon(Icons.edit_outlined,
                      size: 18, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const Gap(12),

            // Remaining amount — hero number
            Text(
              summary.formatAmount(summary.remaining),
              style: tt.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: remainingColor,
              ),
            ),
            Text('remaining',
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const Gap(14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_barColor(context)),
              ),
            ),
            const Gap(4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(summary.spentPercentage * 100).toStringAsFixed(0)}% used',
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            const Gap(16),

            // Three stat chips
            Row(
              children: [
                _Stat(
                  label: 'Budget',
                  value: summary.formatAmount(summary.budgetAmount),
                  color: cs.onSurface,
                ),
                const Gap(8),
                _Stat(
                  label: 'Spent',
                  value: summary.formatAmount(summary.totalExpenses),
                  color: Colors.red.shade400,
                ),
                const Gap(8),
                _Stat(
                  label: 'Income',
                  value: summary.formatAmount(summary.totalIncome),
                  color: Colors.green.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const Gap(2),
            Text(value,
                style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: color),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
