import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
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
          iconData: iconData,
          iconColor: iconColor,
          badgeIcon: badgeIcon,
          logoUrl: category?.logoUrl,
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
        iconData: iconData,
        iconColor: iconColor,
        badgeIcon: badgeIcon,
        logoUrl: category?.logoUrl,
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
            category?.name ?? 'No category',
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

// ── Avatar with optional bolt badge ──────────────────────────────────────────

class _AutoAvatar extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final IconData? badgeIcon;
  final String? logoUrl;
  final double radius;
  final double iconSize;
  final double badgeSize;
  final double badgeIconSize;

  const _AutoAvatar({
    required this.iconData,
    required this.iconColor,
    required this.badgeIcon,
    this.logoUrl,
    required this.radius,
    required this.iconSize,
    required this.badgeSize,
    required this.badgeIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double avatarDiameter = radius * 2;
    final Widget iconChild = logoUrl != null
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: logoUrl!,
              width: avatarDiameter,
              height: avatarDiameter,
              fit: BoxFit.cover,
              placeholder: (ctx, url) =>
                  SizedBox(width: avatarDiameter, height: avatarDiameter),
              errorWidget: (ctx, url, err) =>
                  Icon(iconData, color: iconColor, size: iconSize),
            ),
          )
        : Icon(iconData, color: iconColor, size: iconSize);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: iconChild,
        ),
        if (badgeIcon != null)
          Positioned(
            bottom: -2,
            right: -3,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 1.5),
              ),
              child: Center(
                child: Icon(
                  badgeIcon,
                  size: badgeIconSize,
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
              'Auto',
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
      message: 'Rule: ${smsRule!.keyword}  •  tap to edit',
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

    final label = rule != null
        ? switch (rule!.frequency) {
            RecurringFrequency.daily => 'Daily',
            RecurringFrequency.weekly => 'Weekly',
            RecurringFrequency.monthly => 'Monthly',
            RecurringFrequency.annually => 'Annually',
          }
        : 'Recurring';

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
