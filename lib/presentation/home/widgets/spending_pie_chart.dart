import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import '../../../data/models/transaction.dart';
import '../../../domain/entities/budget_summary.dart';

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

  static const double _startDeg = 270.0;
  static const double _minFraction = 0.04;
  static const double _iconSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final totals = <String, double>{};
    for (final tx
        in transactions.where((t) => t.type == TransactionType.expense)) {
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

    final data = <_Stat>[];
    for (final e in sorted) {
      final cat = categories.where((c) => c.uuid == e.key).firstOrNull;
      if (cat != null) data.add(_Stat(cat, e.value));
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

    final total = data.fold(0.0, (s, d) => s + d.amount);

    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth;
      final centerR = size * 0.24;
      final sectionR = size * 0.175;
      final iconR = centerR + sectionR * 0.5;

      final sections = <PieChartSectionData>[];
      final overlays = <_Overlay>[];
      double angle = _startDeg;

      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final fraction = item.amount / total;
        final sweep = fraction * 360;
        final mid = angle + sweep / 2;
        final color = Color(item.category.colorValue);
        final isSel = item.category.uuid == selectedCategoryUuid;
        final isLit = selectedCategoryUuid == null || isSel;

        sections.add(PieChartSectionData(
          color: isLit ? color : color.withValues(alpha: 0.15),
          value: item.amount,
          radius: isSel ? sectionR + 8 : sectionR,
          showTitle: false,
        ));

        if (fraction >= _minFraction) {
          final rad = mid * math.pi / 180;
          overlays.add(_Overlay(
            x: iconR * math.cos(rad),
            y: iconR * math.sin(rad),
            category: item.category,
            isLit: isLit,
            isSel: isSel,
            isTop: i == 0,
          ));
        }

        angle += sweep;
      }

      const spentColor = Color(0xFFE64A19); // deep orange-red

      final half = size / 2;

      return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: centerR,
                  sectionsSpace: 2,
                  startDegreeOffset: _startDeg,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent) return;
                      final idx =
                          response?.touchedSection?.touchedSectionIndex;
                      if (idx == null || idx < 0 || idx >= data.length) {
                        return;
                      }
                      final uuid = data[idx].category.uuid;
                      onCategoryToggle(
                          selectedCategoryUuid == uuid ? null : uuid);
                    },
                  ),
                ),
              ),

              // Total spent in center
              Text(
                summary.formatAmount(total),
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: spentColor,
                ),
                textAlign: TextAlign.center,
              ),

              // Category icons on slices
              for (final o in overlays)
                Positioned(
                  left: half + o.x - _iconSize / 2,
                  top: half + o.y - _iconSize / 2,
                  child: GestureDetector(
                    onTap: () => onCategoryToggle(
                      selectedCategoryUuid == o.category.uuid
                          ? null
                          : o.category.uuid,
                    ),
                    child: AnimatedOpacity(
                      opacity: o.isLit ? 1.0 : 0.25,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: _iconSize,
                        height: _iconSize,
                        decoration: BoxDecoration(
                          color: o.isSel
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.88),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (o.isTop)
                              BoxShadow(
                                color: Color(o.category.colorValue)
                                    .withValues(alpha: 0.65),
                                blurRadius: 18,
                                spreadRadius: 4,
                              ),
                            BoxShadow(
                              color: Color(o.category.colorValue)
                                  .withValues(
                                      alpha: o.isSel ? 0.5 : 0.25),
                              blurRadius: o.isSel ? 6 : 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          IconData(
                            o.category.iconCodePoint,
                            fontFamily: o.category.iconFontFamily,
                          ),
                          size: 14,
                          color: Color(o.category.colorValue),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _Stat {
  final Category category;
  final double amount;
  const _Stat(this.category, this.amount);
}

class _Overlay {
  final double x, y;
  final Category category;
  final bool isLit, isSel, isTop;
  const _Overlay({
    required this.x,
    required this.y,
    required this.category,
    required this.isLit,
    required this.isSel,
    this.isTop = false,
  });
}
