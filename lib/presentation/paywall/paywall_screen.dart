import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../providers/access_tier_provider.dart';
import '../../providers/license_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/trial_provider.dart';
import '../../services/license_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _buyingProductId;
  bool _restoring = false;
  Map<String, String?> _prices = {};

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final p = await ref.read(purchaseProvider.notifier).fetchPrices();
    if (mounted) setState(() => _prices = p);
  }

  Future<void> _buy(String productId) async {
    setState(() => _buyingProductId = productId);
    try {
      await ref.read(purchaseProvider.notifier).buy(productId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _buyingProductId = null);
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

  void _showLicenseDialog() {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        String? error;
        bool activating = false;
        return StatefulBuilder(
          builder: (ctx, setDS) => AlertDialog(
            title: const Text('License Key'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Paste the license key you received.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    labelText: 'License key',
                    errorText: error,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: activating
                    ? null
                    : () async {
                        setDS(() { activating = true; error = null; });
                        final ok = await LicenseService.activate(ctrl.text);
                        if (!ctx.mounted) return;
                        if (ok) {
                          ref.invalidate(licenseProvider);
                          Navigator.pop(ctx);
                        } else {
                          setDS(() { activating = false; error = 'Invalid license key'; });
                        }
                      },
                child: activating
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Activate'),
              ),
            ],
          ),
        );
      },
    ).then((_) => ctrl.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPro = ref.watch(accessTierProvider) == AccessTier.pro;
    final trial = ref.watch(trialProvider).asData?.value;
    final busy  = _buyingProductId != null || _restoring;

    if (isPro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final accent = AppTheme.primaryText(cs);

    final monthlyPrice = _prices[kProductMonthly] ?? r'$12.99';
    final annualPrice  = _prices[kProductAnnual]  ?? r'$100';

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
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_open_rounded, color: accent, size: 38),
                ),
              ),
              const SizedBox(height: 16),

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
                (Icons.history_outlined,       l10n.paywallFeatureHistory),
                (Icons.cloud_upload_outlined,  l10n.paywallFeatureBackup),
                (Icons.file_download_outlined, l10n.paywallFeatureExport),
                (Icons.category_outlined,      l10n.paywallFeatureCategories),
                (Icons.sms_outlined,           l10n.paywallFeatureSms),
              ].map((f) => _FeatureRow(icon: f.$1, label: f.$2)),

              const SizedBox(height: 28),

              // Plans or unlocked state
              if (isPro)
                const Center(child: _UnlockedChip())
              else ...[
                // Monthly plan
                _PlanCard(
                  label: monthlyPrice,
                  period: '/ month',
                  badge: null,
                  buying: _buyingProductId == kProductMonthly,
                  busy: busy,
                  onTap: () => _buy(kProductMonthly),
                  cs: cs,
                ),
                const SizedBox(height: 10),
                // Annual plan
                _PlanCard(
                  label: annualPrice,
                  period: '/ year',
                  badge: 'Save ~36%',
                  buying: _buyingProductId == kProductAnnual,
                  busy: busy,
                  onTap: () => _buy(kProductAnnual),
                  cs: cs,
                ),
              ],

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: busy ? null : _restore,
                  child: _restoring
                      ? const SizedBox(
                          width: 16, height: 16,
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

              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: busy ? null : _showLicenseDialog,
                  child: Text(
                    'Have a license key?',
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final String label;
  final String period;
  final String? badge;
  final bool buying;
  final bool busy;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _PlanCard({
    required this.label,
    required this.period,
    required this.badge,
    required this.buying,
    required this.busy,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final isBest = badge != null;
    final borderColor = isBest ? cs.primary : cs.outlineVariant;
    final bgColor = isBest
        ? cs.primary.withValues(alpha: 0.07)
        : cs.surfaceContainerHighest.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: busy ? null : onTap,
      child: AnimatedOpacity(
        opacity: busy && !buying ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: borderColor,
              width: isBest ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isBest ? cs.primary : cs.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          period,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (buying)
                SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isBest ? cs.primary : cs.onSurface,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isBest ? cs.primary : cs.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final accent = AppTheme.primaryText(cs);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
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
