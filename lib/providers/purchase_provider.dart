import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../app/app_flavor.dart';
import 'trial_provider.dart';

const _purchasedKey = 'feloosy_pro_purchased';

/// Lifetime one-time purchase product ID.
const kProductLifetime = 'feloosy_pro_lifetime';
const kProProductIds = {kProductLifetime};

final purchaseProvider =
    AsyncNotifierProvider<PurchaseNotifier, bool>(PurchaseNotifier.new);

class PurchaseNotifier extends AsyncNotifier<bool> {
  static const _storage = FlutterSecureStorage();
  StreamSubscription<List<PurchaseDetails>>? _sub;

  @override
  Future<bool> build() async {
    if (AppFlavor.isDev) return true;

    _sub?.cancel();
    _sub = InAppPurchase.instance.purchaseStream.listen(_onPurchaseUpdate);
    ref.onDispose(() => _sub?.cancel());

    if (await _readStorage()) return true;

    // Background restore so subscription status is refreshed on every launch.
    // Fired-and-forgotten — the stream listener picks up any restored events.
    InAppPurchase.instance.restorePurchases();

    final trial = await ref.watch(trialProvider.future);
    return trial.isActive;
  }

  Future<bool> _readStorage() async {
    final val = await _storage.read(key: _purchasedKey);
    return val == 'true';
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (!kProProductIds.contains(p.productID)) continue;
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        await _storage.write(key: _purchasedKey, value: 'true');
        state = const AsyncData(true);
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  /// Returns the localized price for the lifetime product, or null.
  Future<String?> fetchPrice() async {
    try {
      final response =
          await InAppPurchase.instance.queryProductDetails(kProProductIds);
      return response.productDetails.firstOrNull?.price;
    } catch (_) {
      return null;
    }
  }

  Future<void> buy() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) throw Exception('Store not available');

    final response =
        await InAppPurchase.instance.queryProductDetails(kProProductIds);
    final product = response.productDetails.firstOrNull;
    if (product == null) throw Exception('Product not found in store');

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restore() async {
    await InAppPurchase.instance.restorePurchases();
  }
}
