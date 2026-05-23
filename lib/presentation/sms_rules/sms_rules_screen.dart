import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/app_theme.dart';
import '../../data/models/category.dart';
import '../../data/models/sms_rule.dart';
import '../../providers/categories_provider.dart';
import '../../providers/sms_rules_provider.dart';

class SmsRulesScreen extends ConsumerStatefulWidget {
  const SmsRulesScreen({super.key});

  @override
  ConsumerState<SmsRulesScreen> createState() => _SmsRulesScreenState();
}

class _SmsRulesScreenState extends ConsumerState<SmsRulesScreen> {
  PermissionStatus _smsPermission = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.sms.status;
    if (mounted) setState(() => _smsPermission = status);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.sms.request();
    if (mounted) setState(() => _smsPermission = status);
    if (status.isPermanentlyDenied && mounted) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(smsRulesProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('SMS Rules')),
      body: Column(
        children: [
          if (!_smsPermission.isGranted) _PermissionBanner(onGrant: _requestPermission),
          Expanded(
            child: rulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (rules) {
                if (rules.isEmpty) return _EmptyState(onAdd: _navigateToAdd);
                final cats = catsAsync.asData?.value ?? [];
                return ListView.builder(
                  itemCount: rules.length,
                  itemBuilder: (ctx, i) {
                    final rule = rules[i];
                    final cat = cats.where((c) => c.uuid == rule.categoryUuid).firstOrNull;
                    return _RuleTile(
                      rule: rule,
                      category: cat,
                      onTap: () => _navigateToEdit(rule),
                      onDelete: () => _confirmDelete(rule),
                      onToggle: () => ref.read(smsRulesProvider.notifier).toggleActive(rule),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAdd() => context.push('/sms-rules/edit');
  void _navigateToEdit(SmsRule rule) => context.push('/sms-rules/edit', extra: rule);

  Future<void> _confirmDelete(SmsRule rule) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete rule?'),
        content: Text('The rule for "${rule.keyword}" will be deleted. '
            'Existing transactions it created will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && rule.id != null) {
      await ref.read(smsRulesProvider.notifier).remove(rule.id!);
    }
  }
}

class _PermissionBanner extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionBanner({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.errorContainer.withValues(alpha: 0.4),
      child: ListTile(
        leading: Icon(Icons.sms_failed_outlined, color: cs.error),
        title: Text(
          'SMS permission required',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.error),
        ),
        subtitle: Text(
          'Grant access so incoming messages can be matched against your rules.',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        trailing: TextButton(
          onPressed: onGrant,
          child: const Text('Grant'),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sms_outlined, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No rules yet', style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add a rule to automatically create transactions when you receive bank SMS messages.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add first rule'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final SmsRule rule;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _RuleTile({
    required this.rule,
    required this.category,
    required this.onTap,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = category != null
        ? Color(category!.colorValue)
        : cs.onSurfaceVariant;
    final iconData = category != null
        ? IconData(category!.iconCodePoint, fontFamily: category!.iconFontFamily)
        : Icons.receipt_outlined;
    final typeLabel = rule.transactionType == 'income' ? 'Income' : 'Expense';
    final typeColor = rule.transactionType == 'income'
        ? AppTheme.incomeText(cs)
        : AppTheme.expenseText(cs);

    return Slidable(
      key: ValueKey(rule.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: ListTile(
        onTap: rule.isActive ? onTap : null,
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: rule.isActive ? 0.15 : 0.07),
          child: Icon(iconData, color: iconColor.withValues(alpha: rule.isActive ? 1.0 : 0.4), size: 20),
        ),
        title: Text(
          rule.keyword,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: rule.isActive ? null : cs.onSurfaceVariant,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              category?.name ?? 'Unknown category',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 6),
            Text(
              '·',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 6),
            Text(
              typeLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: rule.isActive ? typeColor : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.isActive,
              onChanged: (_) => onToggle(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Icon(Icons.chevron_right, size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
