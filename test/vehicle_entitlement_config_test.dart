import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/utils/vehicle_entitlement_config.dart';

void main() {
  test(
    'configWithEffectiveVehicle falls back without changing original config',
    () {
      final config = MealTimerConfig.defaults().copyWith(vehicleId: 'bus');

      final effectiveConfig = configWithEffectiveVehicle(
        config,
        entitlement: const PurchaseEntitlement.locked(),
      );

      expect(config.vehicleId, 'bus');
      expect(effectiveConfig.vehicleId, 'motorcycle');
    },
  );

  test('configWithEffectiveVehicle keeps premium vehicle when unlocked', () {
    final config = MealTimerConfig.defaults().copyWith(vehicleId: 'bus');

    final effectiveConfig = configWithEffectiveVehicle(
      config,
      entitlement: const PurchaseEntitlement(vehiclePackUnlocked: true),
    );

    expect(identical(effectiveConfig, config), isTrue);
    expect(effectiveConfig.vehicleId, 'bus');
  });

  test(
    'sessionWithEffectiveVehicle falls back without changing original session',
    () {
      final session = ActiveMealTimerSession(
        sessionId: 'session-1',
        startedAt: DateTime.utc(2026, 7, 1, 10),
        config: MealTimerConfig.defaults().copyWith(vehicleId: 'bus'),
        state: ActiveMealTimerSessionState.running,
      );

      final effectiveSession = sessionWithEffectiveVehicle(
        session,
        entitlement: const PurchaseEntitlement.locked(),
      );

      expect(session.config.vehicleId, 'bus');
      expect(effectiveSession.config.vehicleId, 'motorcycle');
      expect(effectiveSession.sessionId, session.sessionId);
    },
  );
}
