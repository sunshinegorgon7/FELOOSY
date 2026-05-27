import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/sms_subscription_provider.dart';
import '../../providers/trial_provider.dart';

enum PaywallFocus { pro, sms }

class PaywallScreen extends ConsumerStatefulWidget {
  final PaywallFocus focus;
  const PaywallScreen({super.key, this.focus = PaywallFocus.pro});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _buyingPro = false;
  bool _buyingSms = false;
  bool _restoring = false;
  String? _proPrice;
  String? _smsPrice;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final pro = await ref.read(purchaseProvider.notifier).fetchPrice();
    final sms = await ref.read(smsSubscriptionProvider.notifier).fetchPrice();
    if (mounted) setState(() { _proPrice = pro; _smsPrice = sms; });
  }

  Future<void> _buyPro() async {
    setState(() => _buyingPro = true);
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
      if (mounted) setState(() => _buyingPro = false);
    }
  }

  Future<void> _buySms() async {
    setState(() => _buyingSms = true);
    try {
      await ref.read(smsSubscriptionProvider.notifier).subscribe();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _buyingSms = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      await ref.read(purchaseProvider.notifier).restore();
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
    final isPro = ref.watch(purchaseProvider).asData?.value ?? false;
    final isSms = ref.watch(smsSubscriptionProvider).asData?.value ?? false;
    final trial = ref.watch(trialProvider).asData?.value;

    // Pop as soon as the focused feature becomes accessible.
    final gatePassed = widget.focus == PaywallFocus.pro ? isPro : isSms;
    if (gatePassed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = AppTheme.primaryText(cs);
    final busy = _buyingPro || _buyingSms || _restoring;
    final proFirst = widget.focus == PaywallFocus.pro;

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
              // Trial-expired banner — only shown after trial ends
              if (trial?.hasExpired == true) ...[
                const SizedBox(height: 8),
                _TrialExpiredBanner(cs: cs, tt: tt),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 4),

              // Primary product section (full, with feature list)
              if (proFirst)
                _ProSection(
                  isPro: isPro,
                  buying: _buyingPro,
                  busy: busy,
                  price: _proPrice ?? r'$4.99',
                  accent: accent,
                  onBuy: _buyPro,
                  primary: true,
                )
              else
                _SmsSection(
                  isSms: isSms,
                  buying: _buyingSms,
                  busy: busy,
                  price: _smsPrice,
                  accent: accent,
                  onBuy: _buySms,
                  primary: true,
                ),

              const SizedBox(height: 28),
              _AlsoAvailableDivider(cs: cs, tt: tt),
              const SizedBox(height: 20),

              // Secondary product section (compact, no feature list)
              if (proFirst)
                _SmsSection(
                  isSms: isSms,
                  buying: _buyingSms,
                  busy: busy,
                  price: _smsPrice,
                  accent: accent,
                  onBuy: _buySms,
                  primary: false,
                )
              else
                _ProSection(
                  isPro: isPro,
                  buying: _buyingPro,
                  busy: busy,
                  price: _proPrice ?? r'$4.99',
                  accent: accent,
                  onBuy: _buyPro,
                  primary: false,
                ),

              const SizedBox(height: 28),

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
                          'Restore Purchase',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                ),
              ),

              const SizedBox(height: 4),
              Text(
                'Flexible pricing · One-time or monthly · No tricks',
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

// ── Pro section ───────────────────────────────────────────────────────────────

class _ProSection extends StatelessWidget {
  final bool isPro;
  final bool buying;
  final bool busy;
  final String price;
  final Color accent;
  final VoidCallback onBuy;
  final bool primary;

  const _ProSection({
    required this.isPro,
    required this.buying,
    required this.busy,
    required this.price,
    required this.accent,
    required this.onBuy,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: primary ? 80 : 52,
          height: primary ? 80 : 52,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_open_rounded,
              color: accent, size: primary ? 38 : 24),
        ),
        SizedBox(height: primary ? 16 : 12),
        Text(
          'FELOOSY PRO',
          style: (primary ? tt.headlineSmall : tt.titleMedium)?.copyWith(
            color: accent,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Everything a power user needs, once.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        if (primary) ...[
          const SizedBox(height: 28),
          ..._proFeatures.map((f) => _FeatureRow(icon: f.$1, label: f.$2)),
        ],
        SizedBox(height: primary ? 24 : 16),
        if (isPro)
          const _UnlockedChip(label: 'Pro Unlocked')
        else
          _BuyButton(
            label: 'Unlock Forever — $price',
            buying: buying,
            busy: busy,
            primary: primary,
            onTap: onBuy,
          ),
      ],
    );
  }
}

// ── SMS section ───────────────────────────────────────────────────────────────

class _SmsSection extends StatelessWidget {
  final bool isSms;
  final bool buying;
  final bool busy;
  final String? price;
  final Color accent;
  final VoidCallback onBuy;
  final bool primary;

  const _SmsSection({
    required this.isSms,
    required this.buying,
    required this.busy,
    required this.price,
    required this.accent,
    required this.onBuy,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final priceLabel = price != null ? '$price/mo' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: primary ? 80 : 52,
          height: primary ? 80 : 52,
          decoration: BoxDecoration(
            color: cs.secondary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.sms_outlined,
              color: cs.secondary, size: primary ? 38 : 24),
        ),
        SizedBox(height: primary ? 16 : 12),
        Text(
          'SMS RULES',
          style: (primary ? tt.headlineSmall : tt.titleMedium)?.copyWith(
            color: cs.secondary,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Auto-create transactions from bank messages.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        if (primary) ...[
          const SizedBox(height: 28),
          ..._smsFeatures.map((f) => _FeatureRow(icon: f.$1, label: f.$2)),
        ],
        SizedBox(height: primary ? 24 : 16),
        if (isSms)
          const _UnlockedChip(label: 'SMS Rules Active')
        else
          _BuyButton(
            label: priceLabel != null
                ? 'Subscribe — $priceLabel'
                : 'Subscribe to SMS Rules',
            buying: buying,
            busy: busy,
            primary: primary,
            onTap: onBuy,
          ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

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
              'Your 14-day free trial has ended',
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

class _AlsoAvailableDivider extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  const _AlsoAvailableDivider({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Also available',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}

class _UnlockedChip extends StatelessWidget {
  final String label;
  const _UnlockedChip({required this.label});

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
            label,
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
  final bool primary;
  final VoidCallback onTap;

  const _BuyButton({
    required this.label,
    required this.buying,
    required this.busy,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spinner = SizedBox(
      width: primary ? 22 : 18,
      height: primary ? 22 : 18,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: primary ? cs.onPrimary : cs.onSurface,
      ),
    );

    if (primary) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: busy ? null : onTap,
          child: buying
              ? spinner
              : Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cs.outline),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: busy ? null : onTap,
        child: buying
            ? spinner
            : Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: cs.onSurface)),
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

// ── Feature lists ─────────────────────────────────────────────────────────────

const _proFeatures = [
  (Icons.account_balance_wallet_outlined, 'Up to 2 wallets'),
  (Icons.swap_horiz_outlined, '50 transactions / month per wallet'),
  (Icons.history_outlined, 'Full transaction history'),
  (Icons.cloud_upload_outlined, 'Google Drive backup'),
  (Icons.file_download_outlined, 'Export your data'),
  (Icons.category_outlined, 'Custom categories'),
];

const _smsFeatures = [
  (Icons.account_balance_wallet_outlined, 'Unlimited wallets'),
  (Icons.all_inclusive_outlined, 'Unlimited transactions'),
  (Icons.sms_outlined, 'Auto-detect transactions from SMS'),
  (Icons.rule_outlined, 'Custom rules per sender & keyword'),
  (Icons.auto_awesome_outlined, 'AI insights (coming soon)'),
];
