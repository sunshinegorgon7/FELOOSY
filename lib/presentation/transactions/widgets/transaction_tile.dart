import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

    final isExpense = transaction.type == TransactionType.expense;
    final amountColor =
        isExpense ? Colors.red.shade400 : Colors.green.shade600;
    final amountPrefix = isExpense ? '-' : '+';
    final amountText = settings != null
        ? '$amountPrefix${CurrencyFormatter.format(transaction.amount, settings)}'
        : '$amountPrefix${transaction.amount.toStringAsFixed(2)}';

    final iconColor =
        category != null ? Color(category!.colorValue) : Colors.grey;
    final iconData = category != null
        ? IconData(category!.iconCodePoint,
            fontFamily: category!.iconFontFamily)
        : Icons.receipt_outlined;

    return ListTile(
      onTap: onTap,
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
        '${category?.name ?? 'Uncategorized'} · ${_formatDate(transaction.transactionDate)}',
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }
}
