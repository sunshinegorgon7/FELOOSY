import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/ai_cache_repository.dart';

class AiInsightsCard extends StatelessWidget {
  final AiCacheEntry entry;

  const AiInsightsCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isAi = entry.source == 'ai';
    final accentColor = cs.brightness == Brightness.dark ? cs.primary : cs.onSurface;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 13, color: accentColor),
              const SizedBox(width: 5),
              Text(
                isAi ? 'AI Insights' : 'Summary',
                style: tt.labelSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM').format(entry.createdAt),
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Summary
          Text(
            entry.result.summary,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface,
              height: 1.5,
              fontSize: 12.5,
            ),
          ),

          if (entry.result.insights.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...entry.result.insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface,
                          height: 1.45,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (entry.result.advice.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 13, color: accentColor),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      entry.result.advice,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.45,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AiInsightsPendingCard extends StatelessWidget {
  final String groupLabel;

  const AiInsightsPendingCard({super.key, required this.groupLabel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 13, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Analysis will be available once this period ends.',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiInsightsPreparingCard extends StatelessWidget {
  const AiInsightsPreparingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = cs.brightness == Brightness.dark ? cs.primary : cs.onSurface;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Preparing insights in the background…',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
