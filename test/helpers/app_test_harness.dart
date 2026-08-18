import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/app.dart';
import 'package:jy_yamyam/main.dart' as app;
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/services/local_settings_service.dart';

Future<void> startApp(
  WidgetTester tester,
  Locale locale, {
  bool completeChildNameSetup = true,
}) async {
  tester.binding.platformDispatcher.localeTestValue = locale;
  tester.binding.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

  await app.main();
  await tester.pump(const Duration(milliseconds: 3500));
  await tester.pumpAndSettle();
  if (find
          .byKey(const ValueKey('firstRunOnboardingScreen'))
          .evaluate()
          .isNotEmpty &&
      completeChildNameSetup) {
    final skipButton = find.byKey(
      const ValueKey('firstRunOnboardingSkipButton'),
    );
    await tester.ensureVisible(skipButton);
    await tester.pumpAndSettle();
    await tester.tap(skipButton);
    await tester.pumpAndSettle();
  }
  if (!completeChildNameSetup || find.byType(TextField).evaluate().isEmpty) {
    return;
  }

  await tester.enterText(find.byType(TextField), '지율');
  await tester.pump();
  await tester.tap(find.byType(FilledButton).first);
  await tester.pumpAndSettle();
}

Future<void> pumpYamyamApp(
  WidgetTester tester, {
  required MealTimerConfig initialConfig,
  required bool initialHasSeenFirstRunOnboarding,
  Locale locale = const Locale('ko'),
  bool motivationMediaAvailable = true,
}) async {
  tester.binding.platformDispatcher.localeTestValue = locale;
  tester.binding.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(
    YamyamRiderApp(
      settingsService: LocalSettingsService(),
      mealProgressService: LocalMealProgressService(),
      activeSessionStore: const ActiveMealTimerSessionStore(),
      initialConfig: initialConfig,
      initialHasSeenFirstRunOnboarding: initialHasSeenFirstRunOnboarding,
      motivationMediaAvailable: motivationMediaAvailable,
      showSplashOnStart: false,
    ),
  );
  await tester.pumpAndSettle();
}
