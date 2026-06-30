import 'package:in_app_purchase/in_app_purchase.dart';

import 'iap_purchase_client.dart';

class InAppPurchaseClient implements IapPurchaseClient {
  InAppPurchaseClient({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

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
  Future<void> restorePurchases({String? applicationUserName}) {
    return _inAppPurchase.restorePurchases(
      applicationUserName: applicationUserName,
    );
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return _inAppPurchase.completePurchase(purchase);
  }
}
