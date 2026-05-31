import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/extensions/localizations_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/category.dart';
import '../../../data/models/recurring_rule.dart';
import '../../../data/models/sms_rule.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/recurring_rules_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/sms_rules_provider.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onTap;
  final bool compact;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.value;

    final cs = Theme.of(context).colorScheme;
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor =
        isExpense ? AppTheme.expenseText(cs) : AppTheme.incomeText(cs);
    final amountText = settings != null
        ? CurrencyFormatter.format(transaction.amount, settings)
        : transaction.amount.toStringAsFixed(2);

    final tileColor = isExpense
        ? AppTheme.expenseColor.withValues(alpha: 0.06)
        : AppTheme.incomeColor.withValues(alpha: 0.06);

    final iconColor = category != null
        ? Color(category!.colorValue)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final iconData = category != null
        ? IconData(category!.iconCodePoint,
            fontFamily: category!.iconFontFamily)
        : Icons.receipt_outlined;

    SmsRule? smsRule;
    if (transaction.isFromSms) {
      final rules = ref.watch(smsRulesProvider).asData?.value ?? [];
      smsRule = rules.where((r) => r.id == transaction.smsRuleId).firstOrNull;
    }

    RecurringRule? recurringRule;
    if (transaction.isRecurring) {
      final rules = ref.watch(recurringRulesProvider).asData?.value ?? [];
      recurringRule = rules
          .where((r) => r.uuid == transaction.recurringRuleUuid)
          .firstOrNull;
    }

    final badgeIcon = transaction.isFromSms
        ? Icons.bolt_rounded
        : transaction.isRecurring
            ? Icons.repeat_rounded
            : null;

    if (compact) {
      return ListTile(
        onTap: onTap,
        tileColor: tileColor,
        dense: true,
        contentPadding:
            const EdgeInsets.only(left: 32, right: 16, top: 0, bottom: 0),
        minLeadingWidth: 32,
        leading: _AutoAvatar(
          description: transaction.description,
          iconData: iconData,
          iconColor: iconColor,
          badgeIcon: badgeIcon,
          radius: 14,
          iconSize: 14,
          badgeSize: 11,
          badgeIconSize: 7,
        ),
        title: Text(
          transaction.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Text(
          amountText,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontWeight: FontWeight.w500,
            color: amountColor,
            fontSize: 13,
          ),
        ),
      );
    }

    return ListTile(
      onTap: onTap,
      tileColor: tileColor,
      contentPadding: const EdgeInsets.only(left: 28, right: 16),
      leading: _AutoAvatar(
        description: transaction.description,
        iconData: iconData,
        iconColor: iconColor,
        badgeIcon: badgeIcon,
        radius: 20,
        iconSize: 20,
        badgeSize: 15,
        badgeIconSize: 9,
      ),
      title: Text(
        transaction.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            category?.name ?? context.l10n.noCategory,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          if (transaction.isFromSms) ...[
            const SizedBox(width: 6),
            _AutoBadge(smsRule: smsRule),
          ],
          if (transaction.isRecurring) ...[
            const SizedBox(width: 6),
            _RecurringBadge(rule: recurringRule),
          ],
        ],
      ),
      trailing: Text(
        amountText,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontWeight: FontWeight.w500,
          color: amountColor,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ── Avatar: tries merchant favicon from description, falls back to icon ───────

// TLDs tried in order when looking up a merchant favicon.
const _tlds = [
  'com', 'ae', 'sa', 'net', 'org', 'co', 'io',
  'eg', 'in', 'pk', 'qa', 'kw', 'bh', 'om', 'gb', 'de', 'fr',
];

// Generic words that have no meaningful domain to look up.
const _skipWords = {
  'atm', 'pos', 'cash', 'card', 'bank', 'debit', 'credit', 'payment',
  'transfer', 'purchase', 'transaction', 'fee', 'charge', 'refund',
  'withdrawal', 'deposit', 'salary', 'expense', 'income', 'misc',
  'other', 'unknown', 'via', 'for', 'from', 'the', 'and', 'ref',
};

class _AutoAvatar extends StatefulWidget {
  final String description;
  final IconData iconData;
  final Color iconColor;
  final IconData? badgeIcon;
  final double radius;
  final double iconSize;
  final double badgeSize;
  final double badgeIconSize;

  const _AutoAvatar({
    required this.description,
    required this.iconData,
    required this.iconColor,
    required this.badgeIcon,
    required this.radius,
    required this.iconSize,
    required this.badgeSize,
    required this.badgeIconSize,
  });

  @override
  State<_AutoAvatar> createState() => _AutoAvatarState();
}

class _AutoAvatarState extends State<_AutoAvatar> {
  int _tldIndex = 0;
  bool _exhausted = false;
  late String _word;

  @override
  void initState() {
    super.initState();
    _word = _extractWord(widget.description);
  }

  @override
  void didUpdateWidget(_AutoAvatar old) {
    super.didUpdateWidget(old);
    if (old.description != widget.description) {
      setState(() {
        _word = _extractWord(widget.description);
        _tldIndex = 0;
        _exhausted = false;
      });
    }
  }

  // Pulls the first alphabetic-only word ≥3 chars that isn't a generic term.
  static String _extractWord(String description) {
    final words = description.toLowerCase().split(RegExp(r'[^a-z]+'));
    for (final w in words) {
      if (w.length >= 3 && !_skipWords.contains(w)) return w;
    }
    return '';
  }

  String? get _url {
    if (_exhausted || _word.isEmpty || _tldIndex >= _tlds.length) return null;
    return 'https://www.google.com/s2/favicons?sz=128&domain=$_word.${_tlds[_tldIndex]}';
  }

  void _advance() {
    if (!mounted) return;
    if (_tldIndex + 1 < _tlds.length) {
      setState(() => _tldIndex++);
    } else {
      setState(() => _exhausted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double d = widget.radius * 2;
    final url = _url;

    final Widget innerChild = url != null
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: d,
              height: d,
              fit: BoxFit.cover,
              placeholder: (ctx2, url2) => SizedBox(width: d, height: d),
              errorWidget: (ctx2, url2, err2) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _advance());
                return Icon(widget.iconData,
                    color: widget.iconColor, size: widget.iconSize);
              },
            ),
          )
        : Icon(widget.iconData, color: widget.iconColor, size: widget.iconSize);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: widget.iconColor.withValues(alpha: 0.15),
          child: innerChild,
        ),
        if (widget.badgeIcon != null)
          Positioned(
            bottom: -2,
            right: -3,
            child: Container(
              width: widget.badgeSize,
              height: widget.badgeSize,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 1.5),
              ),
              child: Center(
                child: Icon(
                  widget.badgeIcon!,
                  size: widget.badgeIconSize,
                  color: cs.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── "⚡ Auto" pill badge in the subtitle ─────────────────────────────────────

class _AutoBadge extends StatelessWidget {
  final SmsRule? smsRule;
  const _AutoBadge({required this.smsRule});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = AppTheme.primaryText(cs);

    final badge = GestureDetector(
      onTap: smsRule != null
          ? () => context.push('/sms-rules/edit', extra: smsRule)
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 2, 6, 2),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.22),
            width: 0.75,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 10, color: accentColor),
            const SizedBox(width: 2),
            Text(
              context.l10n.auto,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: 0.3,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );

    if (smsRule == null) return badge;

    return Tooltip(
      message: context.l10n.transactionRuleInfo(smsRule!.keyword),
      preferBelow: false,
      child: badge,
    );
  }
}

// ── Recurring pill badge in the subtitle ─────────────────────────────────────

class _RecurringBadge extends StatelessWidget {
  final RecurringRule? rule;
  const _RecurringBadge({required this.rule});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = AppTheme.primaryText(cs);

    final l10n = context.l10n;
    final label = rule != null
        ? switch (rule!.frequency) {
            RecurringFrequency.daily => l10n.daily,
            RecurringFrequency.weekly => l10n.weekly,
            RecurringFrequency.monthly => l10n.monthly,
            RecurringFrequency.annually => l10n.annually,
          }
        : l10n.recurring;

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 2, 6, 2),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.22),
          width: 0.75,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat_rounded, size: 10, color: accentColor),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 0.3,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
