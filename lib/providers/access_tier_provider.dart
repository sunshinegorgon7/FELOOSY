import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_flavor.dart';
import 'purchase_provider.dart';
import 'sms_subscription_provider.dart';

enum AccessTier { free, pro, subscription }

extension AccessTierLimits on AccessTier {
  /// null = unlimited
  int? get monthlyTxPerWallet => switch (this) {
        AccessTier.free => 10,
        AccessTier.pro => 50,
        AccessTier.subscription => null,
      };

  /// null = unlimited
  int? get maxWallets => switch (this) {
        AccessTier.free => 1,
        AccessTier.pro => 2,
        AccessTier.subscription => null,
      };

  bool get hasFullHistory => this != AccessTier.free;
  bool get canCustomCategories => this != AccessTier.free;
  bool get canBackup => this != AccessTier.free;
  bool get canExport => this != AccessTier.free;
}

/// Synchronous tier resolution. Loading async providers → treated as free
/// (conservative; same intent as the comment in add_transaction_screen.dart).
final accessTierProvider = Provider<AccessTier>((ref) {
  if (AppFlavor.isDev) return AccessTier.subscription;
  if (ref.watch(smsSubscriptionProvider).value ?? false) {
    return AccessTier.subscription;
  }
  if (ref.watch(purchaseProvider).value ?? false) return AccessTier.pro;
  return AccessTier.free;
});
