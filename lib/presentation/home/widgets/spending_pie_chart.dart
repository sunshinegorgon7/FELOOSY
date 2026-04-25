import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import '../../../data/models/transaction.dart';
import '../../../domain/entities/budget_summary.dart';

class _CategoryStat {
  final Category category;
  final double amount;
  const _CategoryStat(this.category, this.amount);
}

class SpendingPieChart extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final BudgetSummary summary;
  final String? selectedCategoryUuid;
  final ValueChanged<String?> onCategoryToggle;

  const SpendingPieChart({
    super.key,
    required this.transactions,
    required this.categories,
    required this.summary,
    required this.selectedCategoryUuid,
    required this.onCategoryToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final totals = <String, double>{};
    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      totals[tx.categoryUuid] = (totals[tx.categoryUuid] ?? 0) + tx.amount;
    }

    if (totals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No expenses this period.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final data = <_CategoryStat>[];
    for (final e in sorted) {
      final cat = categories.where((c) => c.uuid == e.key).firstOrNull;
      if (cat != null) data.add(_CategoryStat(cat, e.value));
    }

    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No expenses this period.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final color = Color(item.category.colorValue);
      final isSelected = item.category.uuid == selectedCategoryUuid;
      final isHighlighted = selectedCategoryUuid == null || isSelected;
      sections.add(PieChartSectionData(
        color: isHighlighted ? color : color.withValues(alpha: 0.18),
        value: item.amount,
        radius: isSelected ? 54 : 48,
        showTitle: false,
      ));
    }

    final remainingColor = summary.isOverBudget
        ? Colors.red
        : summary.spentPercentage > 0.8
            ? Colors.orange
            : cs.primary;

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 58,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is! FlTapUpEvent) return;
                        final index =
                            response?.touchedSection?.touchedSectionIndex;
                        if (index == null || index < 0 || index >= data.length) {
                          return;
                        }
                        final uuid = data[index].category.uuid;
                        onCategoryToggle(
                            selectedCategoryUuid == uuid ? null : uuid);
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      summary.formatAmount(summary.remaining),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: remainingColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'remaining',
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.map((item) {
                  final color = Color(item.category.colorValue);
                  final isHighlighted = selectedCategoryUuid == null ||
                      item.category.uuid == selectedCategoryUuid;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onCategoryToggle(
                      selectedCategoryUuid == item.category.uuid
                          ? null
                          : item.category.uuid,
                    ),
                    child: AnimatedOpacity(
                      opacity: isHighlighted ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.5),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              IconData(
                                item.category.iconCodePoint,
                                fontFamily: item.category.iconFontFamily,
                              ),
                              size: 13,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.category.name,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              summary.formatAmount(item.amount),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
