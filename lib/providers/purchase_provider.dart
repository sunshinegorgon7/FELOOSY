import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../app/app_flavor.dart';
import 'trial_provider.dart';

const _purchasedKey = 'feloosy_pro_purchased';
const kProProductId = 'feloosy_pro_lifetime';

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

    final trial = await ref.watch(trialProvider.future);
    return trial.isActive;
  }

  Future<bool> _readStorage() async {
    final val = await _storage.read(key: _purchasedKey);
    return val == 'true';
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != kProProductId) continue;
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

  /// Returns the localized price string from the store, or null if unavailable.
  Future<String?> fetchPrice() async {
    try {
      final response = await InAppPurchase.instance
          .queryProductDetails({kProProductId});
      return response.productDetails.firstOrNull?.price;
    } catch (_) {
      return null;
    }
  }

  Future<void> buy() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) throw Exception('Store not available');

    final response = await InAppPurchase.instance
        .queryProductDetails({kProProductId});
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
