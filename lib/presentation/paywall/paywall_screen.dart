import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../providers/access_tier_provider.dart';
import '../../providers/license_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/trial_provider.dart';
import '../../services/license_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _buying = false;
  bool _restoring = false;
  String? _price;
  late final bool _wasProOnOpen;

  @override
  void initState() {
    super.initState();
    _wasProOnOpen = ref.read(accessTierProvider) == AccessTier.pro;
    _loadPrices();
  }

  Future<void> _loadPrices() async {
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

  Future<void> _disableTrial() async {
    await ref.read(trialProvider.notifier).endTrialEarly();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.paywallTrialDisabledSnack),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final source = ref.watch(proSourceProvider);
    final isPurchased = source == ProSource.purchase || source == ProSource.license;
    final trial = ref.watch(trialProvider).asData?.value;
    final busy  = _buying || _restoring;

    if (isPurchased && !_wasProOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final accent = AppTheme.primaryText(cs);

    final lifetimePrice = _price ?? r'$9.99';

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
              if (source == ProSource.trial) ...[
                const SizedBox(height: 8),
                _TrialActiveBanner(
                  cs: cs, tt: tt,
                  daysRemaining: trial?.daysRemaining ?? 0,
                ),
                const SizedBox(height: 20),
              ] else if (trial?.hasExpired == true) ...[
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

              if (isPurchased)
                const Center(child: _UnlockedChip())
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: busy ? null : _buy,
                    child: _buying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.paywallUnlock(lifetimePrice),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
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
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: busy ? null : _showLicenseDialog,
                      icon: Icon(
                        LucideIcons.keyRound,
                        size: 18,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      tooltip: l10n.paywallRestore,
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Text(
                  l10n.paywallRestoreNote,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),

                if (source == ProSource.trial) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: busy ? null : _disableTrial,
                      child: Text(
                        l10n.paywallDisableTrial,
                        style: TextStyle(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _TrialActiveBanner extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final int daysRemaining;
  const _TrialActiveBanner({
    required this.cs, required this.tt, required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final warningColor = AppTheme.warningText(cs);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: warningColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.paywallTrialBanner(daysRemaining),
              style: tt.bodyMedium?.copyWith(
                color: warningColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
