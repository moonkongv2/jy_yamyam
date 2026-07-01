import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/app.dart';
import 'package:jy_yamyam/constants/iap_product_ids.dart';
import 'package:jy_yamyam/controllers/vehicle_pack_purchase_controller.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/services/local_purchase_entitlement_store.dart';
import 'package:jy_yamyam/services/local_settings_service.dart';
import 'package:jy_yamyam/widgets/purchases/purchase_entitlement_scope.dart';

import 'fakes/fake_iap_purchase_client.dart';

void main() {
  testWidgets('YamyamRiderApp exposes initial purchase entitlement', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const entitlement = PurchaseEntitlement(
      vehiclePackUnlocked: true,
      productId: IapProductIds.vehiclePack,
      source: 'localCache',
    );

    await tester.pumpWidget(
      YamyamRiderApp(
        settingsService: LocalSettingsService(),
        mealProgressService: LocalMealProgressService(),
        activeSessionStore: const ActiveMealTimerSessionStore(),
        initialConfig: MealTimerConfig.defaults(),
        initialHasSeenFirstRunOnboarding: true,
        initialPurchaseEntitlement: entitlement,
        showSplashOnStart: false,
      ),
    );
    await tester.pump();

    final scope = tester.widget<PurchaseEntitlementScope>(
      find.byType(PurchaseEntitlementScope),
    );
    expect(scope.entitlement, entitlement);
  });

  testWidgets('YamyamRiderApp prefers purchase controller entitlement', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final client = FakeIapPurchaseClient();
    addTearDown(client.dispose);
    final controller = VehiclePackPurchaseController(
      purchaseClient: client,
      entitlementStore: const LocalPurchaseEntitlementStore(),
      initialEntitlement: const PurchaseEntitlement(
        vehiclePackUnlocked: true,
        productId: IapProductIds.vehiclePack,
        source: 'localCache',
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      YamyamRiderApp(
        settingsService: LocalSettingsService(),
        mealProgressService: LocalMealProgressService(),
        activeSessionStore: const ActiveMealTimerSessionStore(),
        initialConfig: MealTimerConfig.defaults(),
        initialHasSeenFirstRunOnboarding: true,
        purchaseController: controller,
        showSplashOnStart: false,
      ),
    );
    await tester.pump();

    final scope = tester.widget<PurchaseEntitlementScope>(
      find.byType(PurchaseEntitlementScope),
    );
    expect(scope.entitlement.vehiclePackUnlocked, isTrue);
    expect(scope.entitlement.productId, IapProductIds.vehiclePack);
    expect(scope.purchaseController, controller);
  });
}
