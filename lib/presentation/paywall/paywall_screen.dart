import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/trial_provider.dart';

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
    final p = await ref.read(purchaseProvider.notifier).fetchPrice();
    if (mounted) setState(() => _price = p);
  }

  Future<void> _buy() async {
    setState(() => _buying = true);
    try {
      await ref.read(purchaseProvider.notifier).buy();
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
      await Future.delayed(const Duration(seconds: 2));
      final purchased = ref.read(purchaseProvider).asData?.value ?? false;
      if (mounted && !purchased) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.paywallNoRestoreFound),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.paywallRestoreFailed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPro = ref.watch(purchaseProvider).asData?.value ?? false;
    final trial = ref.watch(trialProvider).asData?.value;

    if (isPro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = AppTheme.primaryText(cs);
    final busy = _buying || _restoring;
    final priceLabel = _price ?? r'$9.99';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (trial?.hasExpired == true) ...[
                const SizedBox(height: 8),
                _TrialExpiredBanner(cs: cs, tt: tt),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 4),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_open_rounded,
                      color: accent, size: 38),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.paywallTitle,
                style: tt.headlineSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.paywallSubtitle,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Feature list
              ...[
                (Icons.all_inclusive_outlined, l10n.paywallFeatureWallets),
                (Icons.all_inclusive_outlined, l10n.paywallFeatureTransactions),
                (Icons.history_outlined, l10n.paywallFeatureHistory),
                (Icons.cloud_upload_outlined, l10n.paywallFeatureBackup),
                (Icons.file_download_outlined, l10n.paywallFeatureExport),
                (Icons.category_outlined, l10n.paywallFeatureCategories),
                (Icons.sms_outlined, l10n.paywallFeatureSms),
              ].map((f) => _FeatureRow(icon: f.$1, label: f.$2)),

              const SizedBox(height: 28),

              // Buy / unlocked state
              if (isPro)
                const Center(child: _UnlockedChip())
              else
                _BuyButton(
                  label: l10n.paywallUnlock(priceLabel),
                  buying: _buying,
                  busy: busy,
                  onTap: _buy,
                ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: busy ? null : _restore,
                  child: _restoring
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          l10n.paywallRestore,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                ),
              ),

              const SizedBox(height: 4),
              Text(
                l10n.paywallRestoreNote,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _TrialExpiredBanner extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  const _TrialExpiredBanner({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_off_outlined, color: cs.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.paywallTrialEnded,
              style: tt.bodyMedium?.copyWith(
                color: cs.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedChip extends StatelessWidget {
  const _UnlockedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Text(
            context.l10n.paywallProUnlocked,
            style: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final String label;
  final bool buying;
  final bool busy;
  final VoidCallback onTap;

  const _BuyButton({
    required this.label,
    required this.buying,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: busy ? null : onTap,
        child: buying
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: cs.onPrimary),
              )
            : Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = AppTheme.primaryText(cs);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
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
          Icon(Icons.check_circle_rounded, color: accent, size: 18),
        ],
      ),
    );
  }
}

