import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../app/app_flavor.dart';
import 'trial_provider.dart';

const _subscribedKey = 'feloosy_sms_subscribed';
const kSmsProductId = 'feloosy_sms_monthly';

final smsSubscriptionProvider =
    AsyncNotifierProvider<SmsSubscriptionNotifier, bool>(
        SmsSubscriptionNotifier.new);

class SmsSubscriptionNotifier extends AsyncNotifier<bool> {
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
    final val = await _storage.read(key: _subscribedKey);
    return val == 'true';
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != kSmsProductId) continue;
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        await _storage.write(key: _subscribedKey, value: 'true');
        state = const AsyncData(true);
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  Future<String?> fetchPrice() async {
    try {
      final response =
          await InAppPurchase.instance.queryProductDetails({kSmsProductId});
      return response.productDetails.firstOrNull?.price;
    } catch (_) {
      return null;
    }
  }

  Future<void> subscribe() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) throw Exception('Store not available');

    final response = await InAppPurchase.instance
        .queryProductDetails({kSmsProductId});
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
