import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'controllers/vehicle_pack_purchase_controller.dart';
import 'services/active_meal_timer_session_store.dart';
import 'services/in_app_purchase_client.dart';
import 'services/local_meal_progress_service.dart';
import 'services/local_purchase_entitlement_store.dart';
import 'services/local_settings_service.dart';
import 'services/orientation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(const SystemOrientationService().lockPortrait());

  final settingsService = LocalSettingsService();
  final mealProgressService = LocalMealProgressService();
  const purchaseEntitlementStore = LocalPurchaseEntitlementStore();
  const activeSessionStore = ActiveMealTimerSessionStore();
  final initialConfig = await settingsService.loadConfig();
  final initialPurchaseEntitlement = await purchaseEntitlementStore.load();
  final initialHasSeenFirstRunOnboarding = await settingsService
      .loadHasSeenFirstRunOnboarding();
  final purchaseController = VehiclePackPurchaseController(
    purchaseClient: InAppPurchaseClient(),
    entitlementStore: purchaseEntitlementStore,
    initialEntitlement: initialPurchaseEntitlement,
  )..startListening();

  runApp(
    YamyamRiderApp(
      settingsService: settingsService,
      mealProgressService: mealProgressService,
      activeSessionStore: activeSessionStore,
      initialConfig: initialConfig,
      initialPurchaseEntitlement: initialPurchaseEntitlement,
      purchaseController: purchaseController,
      initialHasSeenFirstRunOnboarding: initialHasSeenFirstRunOnboarding,
    ),
  );
}
