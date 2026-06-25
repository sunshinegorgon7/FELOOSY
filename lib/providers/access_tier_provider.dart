import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_flavor.dart';
import 'license_provider.dart';
import 'purchase_provider.dart';
import 'trial_provider.dart';

enum AccessTier { free, pro }

extension AccessTierLimits on AccessTier {
  /// null = unlimited
  int? get monthlyTxPerWallet => this == AccessTier.free ? 10 : null;

  /// null = unlimited
  int? get maxWallets => this == AccessTier.free ? 1 : null;

  bool get hasFullHistory => this == AccessTier.pro;
  bool get canCustomCategories => this == AccessTier.pro;
  bool get canBackup => this == AccessTier.pro;
  bool get canExport => this == AccessTier.pro;
  bool get hasSms => this == AccessTier.pro;
}

enum ProSource { none, trial, purchase, license }

/// Synchronous tier resolution. Loading async providers → treated as free
/// (conservative default; never grants access on loading state).
/// Resolution order: dev flavor > valid license key > purchase > active trial > free.
final accessTierProvider = Provider<AccessTier>((ref) {
  if (AppFlavor.isDev) return AccessTier.pro;
  if (ref.watch(licenseProvider).value ?? false) return AccessTier.pro;
  if (ref.watch(purchaseProvider).value ?? false) return AccessTier.pro;
  final trial = ref.watch(trialProvider).asData?.value;
  if (trial != null && trial.isActive) return AccessTier.pro;
  return AccessTier.free;
});

final proSourceProvider = Provider<ProSource>((ref) {
  if (AppFlavor.isDev) return ProSource.purchase;
  if (ref.watch(licenseProvider).value ?? false) return ProSource.license;
  if (ref.watch(purchaseProvider).value ?? false) return ProSource.purchase;
  final trial = ref.watch(trialProvider).asData?.value;
  if (trial != null && trial.isActive) return ProSource.trial;
  return ProSource.none;
});
