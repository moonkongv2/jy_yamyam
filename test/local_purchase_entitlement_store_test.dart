import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/constants/iap_product_ids.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/services/local_purchase_entitlement_store.dart';
import 'package:jy_yamyam/services/local_settings_service.dart';

void main() {
  test('Purchase entitlement defaults to locked', () async {
    SharedPreferences.setMockInitialValues({});

    final entitlement = await const LocalPurchaseEntitlementStore().load();

    expect(entitlement, const PurchaseEntitlement.locked());
    expect(entitlement.vehiclePackUnlocked, isFalse);
  });

  test(
    'Purchase entitlement store saves and loads vehicle pack unlock',
    () async {
      SharedPreferences.setMockInitialValues({});
      const store = LocalPurchaseEntitlementStore();
      final purchasedAt = DateTime.utc(2026, 7, 1, 10, 30);
      final lastUpdatedAt = DateTime.utc(2026, 7, 1, 10, 31);

      await store.save(
        PurchaseEntitlement(
          vehiclePackUnlocked: true,
          productId: IapProductIds.vehiclePack,
          purchasedAt: purchasedAt,
          lastUpdatedAt: lastUpdatedAt,
          source: 'purchase',
          transactionId: 'transaction-1',
        ),
      );

      final loadedEntitlement = await store.load();
      final preferences = await SharedPreferences.getInstance();

      expect(loadedEntitlement.vehiclePackUnlocked, isTrue);
      expect(loadedEntitlement.productId, IapProductIds.vehiclePack);
      expect(loadedEntitlement.purchasedAt, purchasedAt);
      expect(loadedEntitlement.lastUpdatedAt, lastUpdatedAt);
      expect(loadedEntitlement.source, 'purchase');
      expect(loadedEntitlement.transactionId, 'transaction-1');
      expect(preferences.getBool('purchase.vehiclePackUnlocked'), isTrue);
      expect(
        preferences.getString('purchase.vehiclePackProductId'),
        IapProductIds.vehiclePack,
      );
    },
  );

  test('Purchase entitlement store ignores malformed metadata', () async {
    SharedPreferences.setMockInitialValues({
      'purchase.vehiclePackUnlocked': true,
      'purchase.vehiclePackProductId': '   ',
      'purchase.vehiclePackPurchasedAt': 'not-a-date',
      'purchase.vehiclePackLastUpdatedAt': '',
      'purchase.vehiclePackSource': '   ',
      'purchase.vehiclePackTransactionId': ' transaction-2 ',
    });

    final entitlement = await const LocalPurchaseEntitlementStore().load();

    expect(entitlement.vehiclePackUnlocked, isTrue);
    expect(entitlement.productId, isNull);
    expect(entitlement.purchasedAt, isNull);
    expect(entitlement.lastUpdatedAt, isNull);
    expect(entitlement.source, isNull);
    expect(entitlement.transactionId, 'transaction-2');
  });

  test(
    'Purchase entitlement store removes metadata when saving locked state',
    () async {
      SharedPreferences.setMockInitialValues({
        'purchase.vehiclePackUnlocked': true,
        'purchase.vehiclePackProductId': IapProductIds.vehiclePack,
        'purchase.vehiclePackPurchasedAt': '2026-07-01T10:30:00.000Z',
        'purchase.vehiclePackLastUpdatedAt': '2026-07-01T10:31:00.000Z',
        'purchase.vehiclePackSource': 'restore',
        'purchase.vehiclePackTransactionId': 'transaction-3',
      });
      const store = LocalPurchaseEntitlementStore();

      await store.save(const PurchaseEntitlement.locked());

      final preferences = await SharedPreferences.getInstance();
      expect(await store.load(), const PurchaseEntitlement.locked());
      expect(preferences.getBool('purchase.vehiclePackUnlocked'), isFalse);
      expect(preferences.getString('purchase.vehiclePackProductId'), isNull);
      expect(preferences.getString('purchase.vehiclePackPurchasedAt'), isNull);
      expect(
        preferences.getString('purchase.vehiclePackLastUpdatedAt'),
        isNull,
      );
      expect(preferences.getString('purchase.vehiclePackSource'), isNull);
      expect(
        preferences.getString('purchase.vehiclePackTransactionId'),
        isNull,
      );
    },
  );

  test('Purchase entitlement store clears saved state', () async {
    SharedPreferences.setMockInitialValues({});
    const store = LocalPurchaseEntitlementStore();

    await store.save(
      PurchaseEntitlement(
        vehiclePackUnlocked: true,
        productId: IapProductIds.vehiclePack,
        lastUpdatedAt: DateTime.utc(2026, 7, 1, 10, 31),
      ),
    );
    await store.clear();

    final preferences = await SharedPreferences.getInstance();
    expect(await store.load(), const PurchaseEntitlement.locked());
    expect(preferences.getBool('purchase.vehiclePackUnlocked'), isNull);
    expect(preferences.getString('purchase.vehiclePackProductId'), isNull);
  });

  test(
    'Purchase entitlement storage is separate from meal timer config',
    () async {
      SharedPreferences.setMockInitialValues({});
      final settingsService = LocalSettingsService();
      const purchaseStore = LocalPurchaseEntitlementStore();

      await settingsService.saveConfig(
        MealTimerConfig.defaults().copyWith(vehicleId: 'bus', childName: '지율'),
      );
      await purchaseStore.save(
        PurchaseEntitlement(
          vehiclePackUnlocked: true,
          productId: IapProductIds.vehiclePack,
          source: 'restore',
          lastUpdatedAt: DateTime.utc(2026, 7, 1, 10, 31),
        ),
      );

      final loadedConfig = await settingsService.loadConfig();
      final loadedEntitlement = await purchaseStore.load();

      expect(loadedConfig.vehicleId, 'bus');
      expect(loadedConfig.childName, '지율');
      expect(loadedEntitlement.vehiclePackUnlocked, isTrue);
    },
  );
}
