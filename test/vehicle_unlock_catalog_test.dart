import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/catalogs/vehicle_unlock_catalog.dart';
import 'package:jy_yamyam/constants/iap_product_ids.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';

void main() {
  const lockedEntitlement = PurchaseEntitlement.locked();
  const unlockedEntitlement = PurchaseEntitlement(
    vehiclePackUnlocked: true,
    productId: IapProductIds.vehiclePack,
  );

  test('Vehicle unlock catalog exposes vehicle pack product id', () {
    expect(
      VehicleUnlockCatalog.vehiclePackProductId,
      IapProductIds.vehiclePack,
    );
  });

  test('Vehicle unlock catalog keeps motorcycle and supercar free', () {
    expect(
      VehicleUnlockCatalog.freeVehicleIds,
      containsAll(['motorcycle', 'supercar']),
    );
    expect(
      VehicleUnlockCatalog.isUnlocked(
        'motorcycle',
        entitlement: lockedEntitlement,
      ),
      isTrue,
    );
    expect(
      VehicleUnlockCatalog.isUnlocked(
        'supercar',
        entitlement: lockedEntitlement,
      ),
      isTrue,
    );
  });

  test('Vehicle unlock catalog locks premium vehicles without entitlement', () {
    expect(
      VehicleUnlockCatalog.isUnlocked('bus', entitlement: lockedEntitlement),
      isFalse,
    );
    expect(
      VehicleUnlockCatalog.isUnlocked(
        'fire_truck',
        entitlement: lockedEntitlement,
      ),
      isFalse,
    );
  });

  test('Vehicle unlock catalog unlocks every vehicle with entitlement', () {
    for (final vehicle in VehicleCatalog.all) {
      expect(
        VehicleUnlockCatalog.isUnlocked(
          vehicle.id,
          entitlement: unlockedEntitlement,
        ),
        isTrue,
        reason: vehicle.id,
      );
    }
  });

  test('Vehicle unlock catalog lists locked vehicle ids in catalog order', () {
    expect(VehicleUnlockCatalog.lockedVehicleIds(lockedEntitlement), [
      'fire_truck',
      'police_car',
      'excavator',
      'airplane',
      'bus',
      'train',
      't_rex',
      'shark',
      'brachio',
      'pteranodon',
    ]);
    expect(VehicleUnlockCatalog.lockedVehicleIds(unlockedEntitlement), isEmpty);
  });

  test('Vehicle unlock catalog resolves effective vehicle id safely', () {
    expect(
      VehicleUnlockCatalog.effectiveVehicleId(
        'bus',
        entitlement: lockedEntitlement,
      ),
      'motorcycle',
    );
    expect(
      VehicleUnlockCatalog.effectiveVehicleId(
        'bus',
        entitlement: unlockedEntitlement,
      ),
      'bus',
    );
    expect(
      VehicleUnlockCatalog.effectiveVehicleId(
        'missing_vehicle',
        entitlement: lockedEntitlement,
      ),
      'motorcycle',
    );
    expect(
      VehicleUnlockCatalog.effectiveVehicleId(
        'missing_vehicle',
        entitlement: unlockedEntitlement,
      ),
      'motorcycle',
    );
  });

  test(
    'Vehicle unlock catalog treats unknown vehicle id as default vehicle',
    () {
      expect(
        VehicleUnlockCatalog.isUnlocked(
          'missing_vehicle',
          entitlement: lockedEntitlement,
        ),
        isTrue,
      );
    },
  );
}
