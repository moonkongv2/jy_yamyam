import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:jy_yamyam/constants/iap_product_ids.dart';
import 'package:jy_yamyam/services/iap_purchase_client.dart';

class FakeIapPurchaseClient implements IapPurchaseClient {
  FakeIapPurchaseClient({
    this.available = true,
    ProductDetailsResponse? productDetailsResponse,
    this.buyNonConsumableResult = true,
  }) : productDetailsResponse =
           productDetailsResponse ??
           ProductDetailsResponse(
             productDetails: const [],
             notFoundIDs: const [],
           );

  final StreamController<List<PurchaseDetails>> _purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();

  bool available;
  ProductDetailsResponse productDetailsResponse;
  bool buyNonConsumableResult;
  Object? isAvailableError;
  Object? queryProductDetailsError;
  Object? buyNonConsumableError;
  Object? restorePurchasesError;
  Object? completePurchaseError;
  final queriedProductIdSets = <Set<String>>[];
  final boughtProducts = <ProductDetails>[];
  final buyApplicationUserNames = <String?>[];
  final restoreApplicationUserNames = <String?>[];
  final completedPurchases = <PurchaseDetails>[];

  int get restorePurchasesCallCount => restoreApplicationUserNames.length;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseController.stream;

  void emitPurchases(List<PurchaseDetails> purchases) {
    _purchaseController.add(purchases);
  }

  Future<void> dispose() {
    return _purchaseController.close();
  }

  @override
  Future<bool> isAvailable() async {
    final error = isAvailableError;
    if (error != null) {
      throw error;
    }

    return available;
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> productIds,
  ) async {
    final error = queryProductDetailsError;
    if (error != null) {
      throw error;
    }

    queriedProductIdSets.add(Set.unmodifiable(productIds));
    return productDetailsResponse;
  }

  @override
  Future<bool> buyNonConsumable({
    required ProductDetails productDetails,
    String? applicationUserName,
  }) async {
    final error = buyNonConsumableError;
    if (error != null) {
      throw error;
    }

    boughtProducts.add(productDetails);
    buyApplicationUserNames.add(applicationUserName);
    return buyNonConsumableResult;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    final error = restorePurchasesError;
    if (error != null) {
      throw error;
    }

    restoreApplicationUserNames.add(applicationUserName);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    final error = completePurchaseError;
    if (error != null) {
      throw error;
    }

    completedPurchases.add(purchase);
  }
}

ProductDetails fakeProductDetails({
  String id = IapProductIds.vehiclePack,
  String title = 'Vehicle Pack',
  String description = 'Unlocks extra vehicles.',
  String price = r'$2.99',
  double rawPrice = 2.99,
  String currencyCode = 'USD',
  String currencySymbol = r'$',
}) {
  return ProductDetails(
    id: id,
    title: title,
    description: description,
    price: price,
    rawPrice: rawPrice,
    currencyCode: currencyCode,
    currencySymbol: currencySymbol,
  );
}

PurchaseDetails fakePurchaseDetails({
  String? purchaseId = 'purchase-1',
  String productId = IapProductIds.vehiclePack,
  String? transactionDate = '1782864000000',
  PurchaseStatus status = PurchaseStatus.purchased,
  bool pendingCompletePurchase = false,
}) {
  return PurchaseDetails(
    purchaseID: purchaseId,
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local-verification-data',
      serverVerificationData: 'server-verification-data',
      source: 'fake',
    ),
    transactionDate: transactionDate,
    status: status,
  )..pendingCompletePurchase = pendingCompletePurchase;
}
