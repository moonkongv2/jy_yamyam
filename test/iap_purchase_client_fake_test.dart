import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'fakes/fake_iap_purchase_client.dart';

void main() {
  test(
    'Fake IAP purchase client records product queries and purchases',
    () async {
      final productDetails = fakeProductDetails();
      final client = FakeIapPurchaseClient(
        productDetailsResponse: ProductDetailsResponse(
          productDetails: [productDetails],
          notFoundIDs: const [],
        ),
      );
      addTearDown(client.dispose);

      expect(await client.isAvailable(), isTrue);
      final response = await client.queryProductDetails({'vehicle_pack'});
      final purchaseStarted = await client.buyNonConsumable(
        productDetails: productDetails,
        applicationUserName: 'guardian',
      );

      expect(response.productDetails, [productDetails]);
      expect(client.queriedProductIdSets, [
        {'vehicle_pack'},
      ]);
      expect(purchaseStarted, isTrue);
      expect(client.boughtProducts, [productDetails]);
      expect(client.buyApplicationUserNames, ['guardian']);
    },
  );

  test('Fake IAP purchase client emits purchase stream updates', () async {
    final client = FakeIapPurchaseClient();
    addTearDown(client.dispose);
    final purchase = fakePurchaseDetails(
      status: PurchaseStatus.restored,
      pendingCompletePurchase: true,
    );
    final streamValues = <List<PurchaseDetails>>[];
    final subscription = client.purchaseStream.listen(streamValues.add);
    addTearDown(subscription.cancel);

    client.emitPurchases([purchase]);
    await pumpEventQueue();
    await client.completePurchase(purchase);

    expect(streamValues, [
      [purchase],
    ]);
    expect(client.completedPurchases, [purchase]);
  });

  test('Fake IAP purchase client records restore calls', () async {
    final client = FakeIapPurchaseClient();
    addTearDown(client.dispose);

    await client.restorePurchases(applicationUserName: 'guardian');

    expect(client.restorePurchasesCallCount, 1);
    expect(client.restoreApplicationUserNames, ['guardian']);
  });
}
