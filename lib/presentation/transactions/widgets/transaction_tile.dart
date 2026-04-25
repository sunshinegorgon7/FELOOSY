import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/category.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/settings_provider.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isExpense = transaction.type == TransactionType.expense;
    final amountColor =
        isExpense ? Colors.red.shade400 : Colors.green.shade600;
    final amountText = settings != null
        ? CurrencyFormatter.format(transaction.amount, settings)
        : transaction.amount.toStringAsFixed(2);

    final tileColor = isExpense
        ? Colors.red.withValues(alpha: isDark ? 0.07 : 0.04)
        : Colors.green.withValues(alpha: isDark ? 0.07 : 0.04);

    final iconColor =
        category != null ? Color(category!.colorValue) : Colors.grey;
    final iconData = category != null
        ? IconData(category!.iconCodePoint,
            fontFamily: category!.iconFontFamily)
        : Icons.receipt_outlined;

    return ListTile(
      onTap: onTap,
      tileColor: tileColor,
      contentPadding: const EdgeInsets.only(left: 28, right: 16),
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.15),
        child: Icon(iconData, color: iconColor, size: 20),
      ),
      title: Text(
        transaction.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        category?.name ?? 'Uncategorized',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        amountText,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: amountColor,
          fontSize: 14,
        ),
      ),
    );
  }
}
