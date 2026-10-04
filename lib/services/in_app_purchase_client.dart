import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

import 'iap_purchase_client.dart';

class InAppPurchaseClient
    implements IapPurchaseClient, PurchaseReconciliationClient {
  InAppPurchaseClient({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _inAppPurchase
      .purchaseStream
      .map((purchases) => purchases.map(preserveAndroidPurchaseState).toList());

  @override
  Future<bool> isAvailable() {
    return _inAppPurchase.isAvailable();
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> productIds) {
    return _inAppPurchase.queryProductDetails(productIds);
  }

  @override
  Future<bool> buyNonConsumable({
    required ProductDetails productDetails,
    String? applicationUserName,
  }) {
    return _inAppPurchase.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: productDetails,
        applicationUserName: applicationUserName,
      ),
    );
  }

  @override
  bool get supportsPurchaseReconciliation =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<List<PurchaseDetails>> queryOwnedPurchases() async {
    final response = await _inAppPurchase
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
        .queryPastPurchases();
    if (response.error != null) throw StateError(response.error.toString());
    return response.pastPurchases.map(preserveAndroidPurchaseState).toList();
  }

  @override
  Future<List<PurchaseDetails>?> restorePurchases({
    String? applicationUserName,
  }) async {
    if (supportsPurchaseReconciliation) return queryOwnedPurchases();
    await _inAppPurchase.restorePurchases(
      applicationUserName: applicationUserName,
    );
    return null;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return _inAppPurchase.completePurchase(purchase);
  }
}

/// Native purchase state remains authoritative even on plugin restore events.
PurchaseDetails preserveAndroidPurchaseState(PurchaseDetails purchase) {
  if (purchase is GooglePlayPurchaseDetails) {
    switch (purchase.billingClientPurchase.purchaseState) {
      case PurchaseStateWrapper.pending:
        purchase.status = PurchaseStatus.pending;
      case PurchaseStateWrapper.purchased:
        // Keep restored for the manual restore UI.
        if (purchase.status != PurchaseStatus.restored) {
          purchase.status = PurchaseStatus.purchased;
        }
      case PurchaseStateWrapper.unspecified_state:
        purchase.status = PurchaseStatus.error;
    }
  }
  return purchase;
}
