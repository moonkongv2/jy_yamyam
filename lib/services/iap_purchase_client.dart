import 'package:in_app_purchase/in_app_purchase.dart';

abstract interface class IapPurchaseClient {
  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<bool> isAvailable();

  Future<ProductDetailsResponse> queryProductDetails(Set<String> productIds);

  Future<bool> buyNonConsumable({
    required ProductDetails productDetails,
    String? applicationUserName,
  });

  Future<void> restorePurchases({String? applicationUserName});

  Future<void> completePurchase(PurchaseDetails purchase);
}
