import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_feature_flags.dart';
import 'controllers/vehicle_pack_purchase_controller.dart';
import 'l10n/app_texts.dart';
import 'models/meal_timer_config.dart';
import 'models/purchase_entitlement.dart';
import 'navigation/app_route_observer.dart';
import 'screens/child_name_setup_screen.dart';
import 'screens/first_run_onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/active_meal_timer_session_store.dart';
import 'services/local_meal_progress_service.dart';
import 'services/local_settings_service.dart';
import 'theme/app_theme.dart';
import 'widgets/purchases/purchase_entitlement_scope.dart';

class YamyamRiderApp extends StatefulWidget {
  const YamyamRiderApp({
    super.key,
    required this.settingsService,
    required this.mealProgressService,
    required this.initialConfig,
    required this.initialHasSeenFirstRunOnboarding,
    this.initialPurchaseEntitlement = const PurchaseEntitlement.locked(),
    this.purchaseController,
    this.activeSessionStore = const ActiveMealTimerSessionStore(),
    this.motivationMediaAvailable = AppFeatureFlags.motivationMediaAvailable,
    this.showSplashOnStart = true,
  });

  final LocalSettingsService settingsService;
  final LocalMealProgressService mealProgressService;
  final MealTimerConfig initialConfig;
  final bool initialHasSeenFirstRunOnboarding;
  final PurchaseEntitlement initialPurchaseEntitlement;
  final VehiclePackPurchaseController? purchaseController;
  final ActiveMealTimerSessionStore activeSessionStore;
  final bool motivationMediaAvailable;
  final bool showSplashOnStart;

  @override
  State<YamyamRiderApp> createState() => _YamyamRiderAppState();
}

class _YamyamRiderAppState extends State<YamyamRiderApp> {
  late MealTimerConfig _config = widget.initialConfig;
  late PurchaseEntitlement _purchaseEntitlement =
      widget.purchaseController?.entitlement ??
      widget.initialPurchaseEntitlement;
  late bool _showSplash = widget.showSplashOnStart;
  late bool _hasSeenFirstRunOnboarding =
      widget.initialHasSeenFirstRunOnboarding;

  @override
  void initState() {
    super.initState();
    widget.purchaseController?.addListener(_syncPurchaseEntitlement);
  }

  @override
  void didUpdateWidget(covariant YamyamRiderApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.purchaseController != widget.purchaseController) {
      oldWidget.purchaseController?.removeListener(_syncPurchaseEntitlement);
      widget.purchaseController?.addListener(_syncPurchaseEntitlement);
      _purchaseEntitlement =
          widget.purchaseController?.entitlement ??
          widget.initialPurchaseEntitlement;
    } else if (widget.purchaseController == null &&
        oldWidget.initialPurchaseEntitlement !=
            widget.initialPurchaseEntitlement) {
      _purchaseEntitlement = widget.initialPurchaseEntitlement;
    }
  }

  @override
  void dispose() {
    widget.purchaseController?.removeListener(_syncPurchaseEntitlement);
    super.dispose();
  }

  void _syncPurchaseEntitlement() {
    final entitlement = widget.purchaseController?.entitlement;
    if (entitlement == null || entitlement == _purchaseEntitlement) {
      return;
    }

    setState(() => _purchaseEntitlement = entitlement);
  }

  Future<void> _saveConfig(MealTimerConfig config) async {
    setState(() => _config = config);
    await widget.settingsService.saveConfig(config);
  }

  void _finishSplash() {
    if (!_showSplash) {
      return;
    }
    setState(() => _showSplash = false);
  }

  bool get _hasChildName => _config.childName.trim().isNotEmpty;
  bool get _shouldShowFirstRunOnboarding =>
      !_hasSeenFirstRunOnboarding && !_hasChildName;

  Future<void> _saveChildName(String name) {
    return _saveConfig(_config.copyWith(childName: name.trim()));
  }

  Future<void> _completeFirstRunOnboarding() async {
    if (_hasSeenFirstRunOnboarding) {
      return;
    }
    setState(() => _hasSeenFirstRunOnboarding = true);
    await widget.settingsService.saveHasSeenFirstRunOnboarding(true);
  }

  @override
  Widget build(BuildContext context) {
    return PurchaseEntitlementScope(
      entitlement: _purchaseEntitlement,
      purchaseController: widget.purchaseController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppTexts.of(context).common.appTitle,
        supportedLocales: AppTexts.supportedLocales,
        navigatorObservers: [appRouteObserver],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: AppTheme.light(),
        home: _showSplash
            ? SplashScreen(onFinished: _finishSplash)
            : _shouldShowFirstRunOnboarding
            ? FirstRunOnboardingScreen(onCompleted: _completeFirstRunOnboarding)
            : _hasChildName
            ? HomeScreen(
                config: _config,
                mealProgressService: widget.mealProgressService,
                activeSessionStore: widget.activeSessionStore,
                motivationMediaAvailable: widget.motivationMediaAvailable,
                onConfigChanged: _saveConfig,
              )
            : ChildNameSetupScreen(onNameSaved: _saveChildName),
      ),
    );
  }
}
