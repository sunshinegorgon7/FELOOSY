import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../providers/purchase_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _buying = false;
  bool _restoring = false;
  String? _price;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    final price = await ref.read(purchaseProvider.notifier).fetchPrice();
    if (mounted) setState(() => _price = price);
  }

  Future<void> _buy() async {
    setState(() => _buying = true);
    try {
      await ref.read(purchaseProvider.notifier).buy();
      // Stream will update purchaseProvider → screen will rebuild via ref.watch
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      await ref.read(purchaseProvider.notifier).restore();
      // Stream delivers result; if nothing restored, inform user
      await Future.delayed(const Duration(seconds: 2));
      final purchased = ref.read(purchaseProvider).asData?.value ?? false;
      if (mounted && !purchased) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No previous purchase found for this account.'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPurchased = ref.watch(purchaseProvider).asData?.value ?? false;
    if (isPurchased) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = AppTheme.primaryText(cs);
    final busy = _buying || _restoring;
    final priceLabel = _price ?? '\$4.99';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  color: accentColor,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'FELOOSY PRO',
                style: tt.headlineSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Everything, once. No subscription.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // Feature list
              ..._features.map((f) => _FeatureRow(icon: f.$1, label: f.$2)),

              const Spacer(),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: busy ? null : _buy,
                  child: _buying
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: cs.onPrimary,
                          ),
                        )
                      : Text(
                          'Unlock Forever — $priceLabel',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Restore
              TextButton(
                onPressed: busy ? null : _restore,
                child: _restoring
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Restore Purchase',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
              ),

              const SizedBox(height: 8),

              Text(
                'One-time payment · No subscription · No tricks',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

const _features = [
  (Icons.account_balance_wallet_outlined, 'Multiple wallets'),
  (Icons.cloud_upload_outlined, 'Google Drive backup'),
  (Icons.file_download_outlined, 'Export your data'),
  (Icons.category_outlined, 'Custom categories'),
  (Icons.auto_awesome_outlined, 'All future features'),
];

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = AppTheme.primaryText(cs);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          Icon(Icons.check_circle_rounded, color: accentColor, size: 18),
        ],
      ),
    );
  }
}
