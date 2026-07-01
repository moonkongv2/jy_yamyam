import '../catalogs/vehicle_unlock_catalog.dart';
import '../models/active_meal_timer_session.dart';
import '../models/meal_timer_config.dart';
import '../models/purchase_entitlement.dart';

MealTimerConfig configWithEffectiveVehicle(
  MealTimerConfig config, {
  required PurchaseEntitlement entitlement,
}) {
  final effectiveVehicleId = VehicleUnlockCatalog.effectiveVehicleId(
    config.vehicleId,
    entitlement: entitlement,
  );
  if (effectiveVehicleId == config.vehicleId) {
    return config;
  }

  return config.copyWith(vehicleId: effectiveVehicleId);
}

ActiveMealTimerSession sessionWithEffectiveVehicle(
  ActiveMealTimerSession session, {
  required PurchaseEntitlement entitlement,
}) {
  final effectiveConfig = configWithEffectiveVehicle(
    session.config,
    entitlement: entitlement,
  );
  if (identical(effectiveConfig, session.config)) {
    return session;
  }

  return session.copyWith(config: effectiveConfig);
}
