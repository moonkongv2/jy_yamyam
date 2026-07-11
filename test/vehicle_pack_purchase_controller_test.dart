import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/constants/iap_product_ids.dart';
import 'package:jy_yamyam/controllers/vehicle_pack_purchase_controller.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/services/local_purchase_entitlement_store.dart';

import 'fakes/fake_iap_purchase_client.dart';

void main() {
  test('Vehicle pack purchase controller loads product details', () async {
    SharedPreferences.setMockInitialValues({});
    final productDetails = fakeProductDetails();
    final client = FakeIapPurchaseClient(
      productDetailsResponse: ProductDetailsResponse(
        productDetails: [productDetails],
        notFoundIDs: const [],
      ),
    );
    addTearDown(client.dispose);
    final controller = _controller(client);
    addTearDown(controller.dispose);

    await controller.loadProductDetails();

    expect(controller.state.status, VehiclePackPurchaseStatus.productReady);
    expect(controller.state.productDetails, productDetails);
    expect(client.queriedProductIdSets, [IapProductIds.all]);
  });

  test('Vehicle pack purchase controller reports unavailable store', () async {
    SharedPreferences.setMockInitialValues({});
    final client = FakeIapPurchaseClient(available: false);
    addTearDown(client.dispose);
    final controller = _controller(client);
    addTearDown(controller.dispose);

    await controller.loadProductDetails();

    expect(controller.state.status, VehiclePackPurchaseStatus.storeUnavailable);
    expect(controller.state.productDetails, isNull);
  });

  test('Vehicle pack purchase controller reports missing product', () async {
    SharedPreferences.setMockInitialValues({});
    final client = FakeIapPurchaseClient();
    addTearDown(client.dispose);
    final controller = _controller(client);
    addTearDown(controller.dispose);

    await controller.loadProductDetails();

    expect(controller.state.status, VehiclePackPurchaseStatus.productNotFound);
    expect(controller.state.productDetails, isNull);
  });

  test(
    'Vehicle pack purchase controller starts non-consumable purchase',
    () async {
      SharedPreferences.setMockInitialValues({});
      final productDetails = fakeProductDetails();
      final client = FakeIapPurchaseClient(
        productDetailsResponse: ProductDetailsResponse(
          productDetails: [productDetails],
          notFoundIDs: const [],
        ),
      );
      addTearDown(client.dispose);
      final controller = _controller(client);
      addTearDown(controller.dispose);

      final started = await controller.buyVehiclePack(
        applicationUserName: 'guardian',
      );

      expect(started, isTrue);
      expect(client.boughtProducts, [productDetails]);
      expect(client.buyApplicationUserNames, ['guardian']);
    },
  );

  test(
    'Vehicle pack purchase controller processes startup purchase stream events',
    () async {
      SharedPreferences.setMockInitialValues({});
      final now = DateTime.utc(2026, 7, 1, 10, 31);
      final client = FakeIapPurchaseClient();
      addTearDown(client.dispose);
      final store = const LocalPurchaseEntitlementStore();
      final controller = _controller(client, store: store, now: () => now);
      addTearDown(controller.dispose);
      final purchase = fakePurchaseDetails(
        purchaseId: 'purchase-startup',
        transactionDate: '1782901800000',
        status: PurchaseStatus.purchased,
        pendingCompletePurchase: true,
      );

      controller.startListening();
      client.emitPurchases([purchase]);
      await pumpEventQueue();

      final entitlement = await store.load();
      expect(
        controller.state.status,
        VehiclePackPurchaseStatus.purchaseCompleted,
      );
      expect(controller.state.vehiclePackUnlocked, isTrue);
      expect(entitlement.vehiclePackUnlocked, isTrue);
      expect(entitlement.productId, IapProductIds.vehiclePack);
      expect(entitlement.source, 'purchase');
      expect(entitlement.transactionId, 'purchase-startup');
      expect(entitlement.purchasedAt, DateTime.utc(2026, 7, 1, 10, 30));
      expect(entitlement.lastUpdatedAt, now);
      expect(client.completedPurchases, [purchase]);
    },
  );

  test('Vehicle pack purchase controller handles restored purchases', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime.utc(2026, 7, 1, 10, 31);
    final client = FakeIapPurchaseClient();
    addTearDown(client.dispose);
    final store = const LocalPurchaseEntitlementStore();
    final controller = _controller(client, store: store, now: () => now);
    addTearDown(controller.dispose);
    final purchase = fakePurchaseDetails(
      purchaseId: 'restore-1',
      status: PurchaseStatus.restored,
      transactionDate: null,
      pendingCompletePurchase: true,
    );

    controller.startListening();
    client.emitPurchases([purchase]);
    await pumpEventQueue();

    final entitlement = await store.load();
    expect(controller.state.status, VehiclePackPurchaseStatus.restoreCompleted);
    expect(entitlement.vehiclePackUnlocked, isTrue);
    expect(entitlement.source, 'restore');
    expect(entitlement.purchasedAt, now);
    expect(client.completedPurchases, [purchase]);
  });

  test(
    'Vehicle pack purchase controller leaves pending purchases locked',
    () async {
      SharedPreferences.setMockInitialValues({});
      final client = FakeIapPurchaseClient();
      addTearDown(client.dispose);
      final controller = _controller(client);
      addTearDown(controller.dispose);
      final purchase = fakePurchaseDetails(
        status: PurchaseStatus.pending,
        pendingCompletePurchase: false,
      );

      controller.startListening();
      client.emitPurchases([purchase]);
      await pumpEventQueue();

      expect(
        controller.state.status,
        VehiclePackPurchaseStatus.purchasePending,
      );
      expect(controller.state.vehiclePackUnlocked, isFalse);
      expect(client.completedPurchases, isEmpty);
    },
  );

  test(
    'Vehicle pack purchase controller completes error purchases without unlock',
    () async {
      SharedPreferences.setMockInitialValues({});
      final client = FakeIapPurchaseClient();
      addTearDown(client.dispose);
      final store = const LocalPurchaseEntitlementStore();
      final controller = _controller(client, store: store);
      addTearDown(controller.dispose);
      final purchase =
          fakePurchaseDetails(
              status: PurchaseStatus.error,
              pendingCompletePurchase: true,
            )
            ..error = IAPError(
              source: 'fake',
              code: 'billing_error',
              message: 'Billing failed.',
            );

      controller.startListening();
      client.emitPurchases([purchase]);
      await pumpEventQueue();

      expect(controller.state.status, VehiclePackPurchaseStatus.error);
      expect(controller.state.errorMessage, 'Billing failed.');
      expect(controller.state.vehiclePackUnlocked, isFalse);
      expect(await store.load(), const PurchaseEntitlement.locked());
      expect(client.completedPurchases, [purchase]);
    },
  );

  test(
    'Vehicle pack purchase controller completes canceled purchases without unlock',
    () async {
      SharedPreferences.setMockInitialValues({});
      final client = FakeIapPurchaseClient();
      addTearDown(client.dispose);
      final store = const LocalPurchaseEntitlementStore();
      final controller = _controller(client, store: store);
      addTearDown(controller.dispose);
      final purchase = fakePurchaseDetails(
        status: PurchaseStatus.canceled,
        pendingCompletePurchase: true,
      );

      controller.startListening();
      client.emitPurchases([purchase]);
      await pumpEventQueue();

      expect(controller.state.status, VehiclePackPurchaseStatus.canceled);
      expect(controller.state.vehiclePackUnlocked, isFalse);
      expect(await store.load(), const PurchaseEntitlement.locked());
      expect(client.completedPurchases, [purchase]);
    },
  );

  test('Vehicle pack purchase controller ignores unrelated products', () async {
    SharedPreferences.setMockInitialValues({});
    final client = FakeIapPurchaseClient();
    addTearDown(client.dispose);
    final controller = _controller(client);
    addTearDown(controller.dispose);
    final purchase = fakePurchaseDetails(
      productId: 'unrelated_product',
      status: PurchaseStatus.purchased,
      pendingCompletePurchase: true,
    );

    controller.startListening();
    client.emitPurchases([purchase]);
    await pumpEventQueue();

    expect(controller.state.status, VehiclePackPurchaseStatus.idle);
    expect(controller.state.vehiclePackUnlocked, isFalse);
    expect(client.completedPurchases, isEmpty);
  });

  test(
    'Vehicle pack purchase controller does not complete successful purchase when cache fails',
    () async {
      SharedPreferences.setMockInitialValues({});
      final client = FakeIapPurchaseClient();
      addTearDown(client.dispose);
      final controller = _controller(
        client,
        store: const _ThrowingPurchaseEntitlementStore(),
      );
      addTearDown(controller.dispose);
      final purchase = fakePurchaseDetails(
        status: PurchaseStatus.purchased,
        pendingCompletePurchase: true,
      );

      controller.startListening();
      client.emitPurchases([purchase]);
      await pumpEventQueue();

      expect(controller.state.status, VehiclePackPurchaseStatus.error);
      expect(controller.state.vehiclePackUnlocked, isFalse);
      expect(client.completedPurchases, isEmpty);
    },
  );

  test(
    'Vehicle pack purchase controller reports restore without purchase updates',
    () async {
      SharedPreferences.setMockInitialValues({});
      final productDetails = fakeProductDetails();
      final client = FakeIapPurchaseClient(
        productDetailsResponse: ProductDetailsResponse(
          productDetails: [productDetails],
          notFoundIDs: const [],
        ),
      );
      addTearDown(client.dispose);
      final store = const LocalPurchaseEntitlementStore();
      final controller = _controller(client, store: store);
      addTearDown(controller.dispose);

      await controller.restorePurchases(applicationUserName: 'guardian');

      expect(client.restoreApplicationUserNames, ['guardian']);
      expect(
        controller.state.status,
        VehiclePackPurchaseStatus.restoreNotFound,
      );
      expect(controller.state.vehiclePackUnlocked, isFalse);
      expect(controller.state.productDetails, productDetails);
      expect(client.queriedProductIdSets, [IapProductIds.all]);
      expect(await store.load(), const PurchaseEntitlement.locked());
    },
  );

  test('Vehicle pack purchase controller keeps restored state after restore', () async {
    SharedPreferences.setMockInitialValues({});
    final client = FakeIapPurchaseClient();
    addTearDown(client.dispose);
    final store = const LocalPurchaseEntitlementStore();
    final controller = _controller(client, store: store);
    addTearDown(controller.dispose);
    final purchase = fakePurchaseDetails(
      purchaseId: 'restore-during-call',
      status: PurchaseStatus.restored,
      pendingCompletePurchase: true,
    );

    controller.startListening();
    final restore = controller.restorePurchases(applicationUserName: 'guardian');
    client.emitPurchases([purchase]);
    await restore;
    await pumpEventQueue();

    expect(client.restoreApplicationUserNames, ['guardian']);
    expect(controller.state.status, VehiclePackPurchaseStatus.restoreCompleted);
    expect(controller.state.vehiclePackUnlocked, isTrue);
    expect((await store.load()).vehiclePackUnlocked, isTrue);
    expect(client.completedPurchases, [purchase]);
  });
}

VehiclePackPurchaseController _controller(
  FakeIapPurchaseClient client, {
  LocalPurchaseEntitlementStore store = const LocalPurchaseEntitlementStore(),
  DateTime Function()? now,
}) {
  return VehiclePackPurchaseController(
    purchaseClient: client,
    entitlementStore: store,
    now: now,
  );
}

class _ThrowingPurchaseEntitlementStore extends LocalPurchaseEntitlementStore {
  const _ThrowingPurchaseEntitlementStore();

  @override
  Future<void> save(PurchaseEntitlement entitlement) {
    throw StateError('Unable to cache purchase.');
  }
}
