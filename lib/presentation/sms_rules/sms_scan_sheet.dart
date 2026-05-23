import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_theme.dart';
import '../../data/models/category.dart';
import '../../data/models/sms_rule.dart';
import '../../data/models/transaction.dart';
import '../../domain/services/sms_parser_service.dart';
import '../../providers/categories_provider.dart';
import '../../providers/sms_rules_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../services/sms_scan_service.dart';

// ---------------------------------------------------------------------------
// Entry-point: show the scan sheet from any context
// ---------------------------------------------------------------------------

void showSmsScanSheet(
  BuildContext context, {
  void Function(int created, List<DateTime> dates)? onImported,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SmsScanSheet(onImported: onImported),
  );
}

// ---------------------------------------------------------------------------
// Internal data model
// ---------------------------------------------------------------------------

class _Candidate {
  final Transaction transaction;
  final String smsBody;
  final SmsRule rule;
  final Category? category;
  final bool likelyDuplicate;
  bool selected;
  String description; // editable before import

  _Candidate({
    required this.transaction,
    required this.smsBody,
    required this.rule,
    required this.category,
    required this.likelyDuplicate,
    required this.selected,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

enum _Step { range, scanning, results }

class _SmsScanSheet extends ConsumerStatefulWidget {
  final void Function(int created, List<DateTime> dates)? onImported;
  const _SmsScanSheet({this.onImported});

  @override
  ConsumerState<_SmsScanSheet> createState() => _SmsScanSheetState();
}

class _SmsScanSheetState extends ConsumerState<_SmsScanSheet> {
  static const _presets = [
    (label: 'Yesterday', days: 1),
    (label: '3 days', days: 3),
    (label: '7 days', days: 7),
    (label: '30 days', days: 30),
  ];

  _Step _step = _Step.range;
  int _preset = 1; // default: 3 days
  DateTimeRange? _customRange;
  List<_Candidate> _candidates = [];
  bool _importing = false;
  String? _error;

  static const _uuid = Uuid();

  DateTimeRange _computeRange() {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    if (_preset == 4 && _customRange != null) {
      return DateTimeRange(
        start: DateTime(
          _customRange!.start.year,
          _customRange!.start.month,
          _customRange!.start.day,
        ),
        end: DateTime(
          _customRange!.end.year,
          _customRange!.end.month,
          _customRange!.end.day,
          23, 59, 59, 999,
        ),
      );
    }
    final days = _preset < _presets.length ? _presets[_preset].days : 3;
    return DateTimeRange(
      start: endOfToday.subtract(Duration(days: days)),
      end: endOfToday,
    );
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
      helpText: 'Select date range',
    );
    if (range != null && mounted) {
      setState(() {
        _customRange = range;
        _preset = 4;
      });
    }
  }

  Future<void> _scan() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.sms.status;
    if (!status.isGranted) {
      setState(() => _error = 'SMS permission is required to scan messages.');
      return;
    }

    setState(() {
      _step = _Step.scanning;
      _error = null;
    });

    try {
      final range = _computeRange();
      final messages = await SmsScanService.readInbox(
        from: range.start,
        to: range.end,
      );

      final rules = ref.read(smsRulesProvider).asData?.value ?? [];
      final cats = ref.read(categoriesProvider).asData?.value ?? [];
      final existing = ref.read(transactionsProvider).asData?.value ?? [];
      final activeRules = rules.where((r) => r.isActive).toList();

      if (activeRules.isEmpty) {
        if (mounted) {
          setState(() {
            _candidates = [];
            _step = _Step.results;
          });
        }
        return;
      }

      final candidates = <_Candidate>[];
      for (final msg in messages) {
        final rule = SmsParserService.matchRule(msg.body, activeRules);
        if (rule == null) continue;

        final amount = SmsParserService.extractAmount(
          msg.body,
          customRegex: rule.amountRegex,
        );
        if (amount == null || amount <= 0) continue;

        final cat = cats.where((c) => c.uuid == rule.categoryUuid).firstOrNull;

        // Duplicate check: same amount + category within ±3 days.
        // Uses a window instead of exact-day so a manually-entered transaction
        // dated "today" is still caught when the SMS itself is from yesterday.
        final isDuplicate = existing.any((tx) =>
            tx.amount == amount &&
            tx.categoryUuid == rule.categoryUuid &&
            tx.transactionDate.difference(msg.date).inDays.abs() <= 3);

        final now = DateTime.now();
        final tx = Transaction(
          uuid: _uuid.v4(),
          accountId: rule.accountId,
          amount: amount,
          type: rule.transactionType == 'income'
              ? TransactionType.income
              : TransactionType.expense,
          description: rule.transactionDescription,
          categoryUuid: rule.categoryUuid,
          transactionDate: msg.date,
          createdAt: now,
          updatedAt: now,
          source: 'sms_rule:${rule.id}',
        );

        candidates.add(_Candidate(
          transaction: tx,
          smsBody: msg.body,
          rule: rule,
          category: cat,
          likelyDuplicate: isDuplicate,
          selected: !isDuplicate,
          description: rule.transactionDescription,
        ));
      }

      if (mounted) {
        setState(() {
          _candidates = candidates;
          _step = _Step.results;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.code == 'PERMISSION_DENIED'
              ? 'SMS permission denied.'
              : 'Could not read SMS: ${e.message}';
          _step = _Step.range;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unexpected error: $e';
          _step = _Step.range;
        });
      }
    }
  }

  Future<void> _import() async {
    if (_importing) return;
    setState(() => _importing = true);

    final selected = _candidates.where((c) => c.selected).toList();
    int count = 0;
    final importedDates = <DateTime>[];
    for (final c in selected) {
      try {
        // Use the (possibly edited) description rather than the original rule default.
        final tx = c.description == c.transaction.description
            ? c.transaction
            : c.transaction.copyWith(description: c.description);
        await ref.read(transactionsProvider.notifier).add(tx);
        count++;
        importedDates.add(c.transaction.transactionDate);
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pop(context);
      widget.onImported?.call(count, importedDates);
    }
  }

  Future<void> _editDescription(int index) async {
    final ctrl = TextEditingController(text: _candidates[index].description);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit label'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Transaction description',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.pop(ctx, ctrl.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && result.isNotEmpty && mounted) {
      setState(() => _candidates[index].description = result);
    }
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _buildHandle(ColorScheme cs) => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildRangeStep(ColorScheme cs, TextTheme tt) {
    final hasCustom = _preset == 4 && _customRange != null;
    final customLabel = hasCustom
        ? '${DateFormat('MMM d').format(_customRange!.start)} – '
          '${DateFormat('MMM d').format(_customRange!.end)}'
        : 'Custom…';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(cs),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Text('Scan existing SMS', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Text(
            'Apply your active rules to messages already in your inbox.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!, style: TextStyle(color: cs.error, fontSize: 13)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text('Date range', style: tt.labelSmall?.copyWith(
            color: AppTheme.primaryText(cs),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < _presets.length; i++)
                _RangeChip(
                  label: _presets[i].label,
                  selected: _preset == i,
                  onTap: () => setState(() => _preset = i),
                ),
              _RangeChip(
                label: customLabel,
                selected: _preset == 4,
                onTap: _pickCustomRange,
                icon: Icons.calendar_month_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: FilledButton(
            onPressed: _scan,
            child: const Text('Scan'),
          ),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
      ],
    );
  }

  Widget _buildScanningStep(ColorScheme cs, TextTheme tt) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(cs),
        const SizedBox(height: 32),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text('Scanning messages…', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 48),
      ],
    );
  }

  Widget _buildResultsStep(ColorScheme cs, TextTheme tt) {
    final selected = _candidates.where((c) => c.selected).length;
    final dupCount = _candidates.where((c) => c.likelyDuplicate).length;

    if (_candidates.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHandle(cs),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step = _Step.range),
              ),
              Text('No matches found', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Text(
              'No messages in this range matched your active rules.\n'
              'Try a wider range or check your rule keywords.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: OutlinedButton(
              onPressed: () => setState(() => _step = _Step.range),
              child: const Text('Try different range'),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHandle(cs),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _step = _Step.range),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_candidates.length} match${_candidates.length == 1 ? '' : 'es'} found',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (dupCount > 0)
                    Text(
                      '$dupCount already exist${dupCount == 1 ? 's' : ''} today — unchecked by default',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 1),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.52,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _candidates.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: cs.outlineVariant),
            itemBuilder: (_, i) => _CandidateTile(
              candidate: _candidates[i],
              onToggle: (v) => setState(() => _candidates[i].selected = v),
              onEditDescription: () => _editDescription(i),
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.paddingOf(context).bottom + 16,
          ),
          child: FilledButton(
            onPressed: selected == 0 || _importing ? null : _import,
            child: _importing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    selected == 0
                        ? 'Nothing selected'
                        : 'Import $selected transaction${selected == 1 ? '' : 's'}',
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, _) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (_step) {
            _Step.range    => _buildRangeStep(cs, tt),
            _Step.scanning => _buildScanningStep(cs, tt),
            _Step.results  => _buildResultsStep(cs, tt),
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Range chip
// ---------------------------------------------------------------------------

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.12) : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? AppTheme.primaryText(cs) : cs.onSurfaceVariant),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.primaryText(cs) : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Candidate tile
// ---------------------------------------------------------------------------

class _CandidateTile extends StatelessWidget {
  final _Candidate candidate;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEditDescription;

  const _CandidateTile({
    required this.candidate,
    required this.onToggle,
    required this.onEditDescription,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tx = candidate.transaction;
    final cat = candidate.category;
    final isDup = candidate.likelyDuplicate;

    final catColor = cat != null ? Color(cat.colorValue) : cs.onSurfaceVariant;
    final catIcon = cat != null
        ? IconData(cat.iconCodePoint, fontFamily: cat.iconFontFamily)
        : Icons.receipt_outlined;

    final amountColor = tx.type == TransactionType.income
        ? AppTheme.incomeText(cs)
        : AppTheme.expenseText(cs);
    final amountPrefix = tx.type == TransactionType.income ? '+' : '−';

    return CheckboxListTile(
      value: candidate.selected,
      onChanged: isDup
          ? (v) => onToggle(v ?? false)
          : (v) => onToggle(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
      secondary: isDup
          ? Tooltip(
              message: 'Transaction for this amount and category already exists on this day',
              child: Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
            )
          : null,
      title: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: catColor.withValues(alpha: candidate.selected ? 0.15 : 0.07),
            child: Icon(catIcon,
                size: 15,
                color: catColor.withValues(alpha: candidate.selected ? 1.0 : 0.4)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onEditDescription,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                candidate.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: candidate.selected
                                      ? cs.onSurface
                                      : cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_outlined,
                              size: 13,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$amountPrefix${tx.amount.toStringAsFixed(tx.amount.truncateToDouble() == tx.amount ? 0 : 2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Mono',
                        color: candidate.selected ? amountColor : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM d, h:mm a').format(tx.transactionDate),
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 6),
                    if (cat != null) ...[
                      Text('·', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                      const SizedBox(width: 6),
                      Text(
                        cat.name,
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                    if (isDup) ...[
                      const SizedBox(width: 6),
                      Text('·', style: TextStyle(fontSize: 11, color: cs.error)),
                      const SizedBox(width: 6),
                      Text(
                        'exists',
                        style: tt.labelSmall?.copyWith(
                          color: cs.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  candidate.smsBody,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
