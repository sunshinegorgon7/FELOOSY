import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_theme.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../data/models/category.dart';
import '../../data/models/sms_rule.dart';
import '../../data/models/transaction.dart';
import '../../domain/services/sms_parser_service.dart';
import '../../providers/accounts_provider.dart';
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
  showDialog<void>(
    context: context,
    barrierColor: AppTheme.deepNimbus.withValues(alpha: 0.54),
    builder: (ctx) {
      final topPad = MediaQuery.paddingOf(context).top;
      final botPad = MediaQuery.paddingOf(context).bottom;
      return Dialog(
        insetPadding: EdgeInsets.fromLTRB(20, topPad + 16, 20, botPad + 16),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: _SmsScanSheet(onImported: onImported),
      );
    },
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
  static const _presetDays = [0, 3];

  _Step _step = _Step.range;
  int _preset = 0; // default: Today
  DateTimeRange? _customRange;
  List<_Candidate> _candidates = [];
  bool _importing = false;
  String? _error;
  String? _importError;

  static const _uuid = Uuid();

  DateTimeRange _computeRange() {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    if (_preset == 2 && _customRange != null) {
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
    final days = _preset < _presetDays.length ? _presetDays[_preset] : 3;
    if (days == 0) {
      // Today: from midnight to right now
      return DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: now,
      );
    }
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
        _preset = 2;
      });
    }
  }

  Future<void> _scan() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.sms.status;
    if (!status.isGranted) {
      setState(() => _error = context.l10n.smsScanPermissionRequired);
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
      final accounts = ref.read(accountsProvider).asData?.value ?? [];
      final fallbackAccountId = accounts.isNotEmpty
          ? (accounts.firstWhere((a) => a.isFavorite, orElse: () => accounts.first).id ?? 1)
          : 1;
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
          requireCurrencyCode: rule.amountRegex == null,
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
        final resolvedAccountId = accounts.any((a) => a.id == rule.accountId)
            ? rule.accountId
            : fallbackAccountId;
        final tx = Transaction(
          uuid: _uuid.v4(),
          accountId: resolvedAccountId,
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
    setState(() {
      _importing = true;
      _importError = null;
    });

    final selected = _candidates.where((c) => c.selected).toList();
    int count = 0;
    final importedDates = <DateTime>[];
    final notifier = ref.read(transactionsProvider.notifier);
    String? firstError;
    for (final c in selected) {
      try {
        final tx = c.description == c.transaction.description
            ? c.transaction
            : c.transaction.copyWith(description: c.description);
        await notifier.add(tx);
        count++;
        importedDates.add(c.transaction.transactionDate);
      } catch (e) {
        firstError ??= e.toString();
      }
    }

    if (!mounted) return;

    if (count == 0 && firstError != null) {
      setState(() {
        _importing = false;
        _importError = 'Import failed: $firstError';
      });
      return;
    }

    Navigator.pop(context);
    widget.onImported?.call(count, importedDates);
  }

  Future<void> _editDescription(int index) async {
    final l10n = context.l10n;
    final ctrl = TextEditingController(text: _candidates[index].description);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.smsScanEditLabel),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.smsScanTransactionDesc,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.pop(ctx, ctrl.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.save),
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

  Widget _buildDialogHeader(TextTheme tt, String title, {VoidCallback? onBack}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
          else
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  bool? _selectAllValue() {
    final n = _candidates.where((c) => c.selected).length;
    if (n == 0) return false;
    if (n == _candidates.length) return true;
    return null;
  }

  Widget _buildRangeStep(ColorScheme cs, TextTheme tt) {
    final l10n = context.l10n;
    final hasCustom = _preset == 2 && _customRange != null;
    final customLabel = hasCustom
        ? '${DateFormat('MMM d').format(_customRange!.start)} –\n'
          '${DateFormat('MMM d').format(_customRange!.end)}'
        : l10n.smsScanCustom;

    return Column(
      key: const ValueKey('range'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDialogHeader(tt, l10n.smsScanTitle),
        Divider(height: 1, color: cs.outlineVariant),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(l10n.smsScanDateRange, style: tt.labelSmall?.copyWith(
            color: AppTheme.primaryText(cs),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _RangeCard(
                    label: l10n.today,
                    icon: Icons.today_outlined,
                    selected: _preset == 0,
                    onTap: () => setState(() => _preset = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RangeCard(
                    label: l10n.smsScan3Days,
                    icon: Icons.date_range_outlined,
                    selected: _preset == 1,
                    onTap: () => setState(() => _preset = 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RangeCard(
                    label: customLabel,
                    icon: Icons.calendar_month_outlined,
                    selected: _preset == 2,
                    onTap: _pickCustomRange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: FilledButton(
            onPressed: _scan,
            child: Text(l10n.smsScanTitle),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningStep(ColorScheme cs, TextTheme tt) {
    return Column(
      key: const ValueKey('scanning'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDialogHeader(tt, context.l10n.smsScanScanning),
        Divider(height: 1, color: cs.outlineVariant),
        const SizedBox(height: 40),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 16),
        Center(
          child: Text(
            context.l10n.smsScanScanning,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildResultsStep(ColorScheme cs, TextTheme tt) {
    final selected = _candidates.where((c) => c.selected).length;
    final dupCount = _candidates.where((c) => c.likelyDuplicate).length;

    if (_candidates.isEmpty) {
      return Column(
        key: const ValueKey('results-empty'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDialogHeader(
            tt,
            context.l10n.smsScanNoMatches,
            onBack: () => setState(() => _step = _Step.range),
          ),
          Divider(height: 1, color: cs.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Text(
              context.l10n.smsScanNoMatchesMessage,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: OutlinedButton(
              onPressed: () => setState(() => _step = _Step.range),
              child: Text(context.l10n.smsScanTryDifferent),
            ),
          ),
        ],
      );
    }

    return Column(
      key: const ValueKey('results'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step = _Step.range),
              ),
              Checkbox(
                tristate: true,
                value: _selectAllValue(),
                onChanged: (v) => setState(() {
                  final target = v ?? true;
                  for (final c in _candidates) {
                    c.selected = target;
                  }
                }),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.smsScanMatchesFound(_candidates.length),
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (dupCount > 0)
                      Text(
                        context.l10n.smsScanDupNote(dupCount),
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.42,
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
        if (_importError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _importError!,
                style: TextStyle(color: cs.error, fontSize: 13),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                        ? context.l10n.smsScanNothingSelected
                        : context.l10n.smsScanImportButton(selected),
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (_step) {
        _Step.range    => _buildRangeStep(cs, tt),
        _Step.scanning => _buildScanningStep(cs, tt),
        _Step.results  => _buildResultsStep(cs, tt),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Range card (replaces _RangeChip)
// ---------------------------------------------------------------------------

class _RangeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RangeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                height: 1.3,
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
              message: context.l10n.smsScanDupWarning,
              child: Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.warningText(cs)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warningText(cs).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.warningText(cs).withValues(alpha: 0.4),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          context.l10n.smsScanExists,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warningText(cs),
                          ),
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
