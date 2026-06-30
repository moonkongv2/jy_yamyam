import '../constants/iap_product_ids.dart';
import '../models/purchase_entitlement.dart';
import 'vehicle_catalog.dart';

abstract final class VehicleUnlockCatalog {
  static const vehiclePackProductId = IapProductIds.vehiclePack;
  static const defaultVehicleId = 'motorcycle';
  static const freeVehicleIds = {'motorcycle', 'supercar'};

  static bool isUnlocked(
    String vehicleId, {
    required PurchaseEntitlement entitlement,
  }) {
    final resolvedVehicleId = VehicleCatalog.findById(vehicleId).id;
    return freeVehicleIds.contains(resolvedVehicleId) ||
        entitlement.vehiclePackUnlocked;
  }

  static String effectiveVehicleId(
    String vehicleId, {
    required PurchaseEntitlement entitlement,
  }) {
    final resolvedVehicleId = VehicleCatalog.findById(vehicleId).id;
    if (isUnlocked(resolvedVehicleId, entitlement: entitlement)) {
      return resolvedVehicleId;
    }

    return defaultVehicleId;
  }

  static List<String> lockedVehicleIds(PurchaseEntitlement entitlement) {
    return [
      for (final vehicle in VehicleCatalog.all)
        if (!isUnlocked(vehicle.id, entitlement: entitlement)) vehicle.id,
    ];
  }
}
