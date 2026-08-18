import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/constants/child_name_limits.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';

import 'helpers/app_test_harness.dart';

void main() {
  testWidgets('First launch asks for child name before home', (tester) async {
    SharedPreferences.setMockInitialValues({'hasSeenFirstRunOnboarding': true});

    await startApp(tester, const Locale('ko'), completeChildNameSetup: false);

    expect(find.text('누가 냠냠 라이더를 탈까?'), findsOneWidget);
    expect(find.text('이름 저장'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '민준');
    await tester.pump();
    await tester.tap(find.text('이름 저장'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('homeLogo')), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('childName'), '민준');
  });

  testWidgets('Child name setup limits input length', (tester) async {
    SharedPreferences.setMockInitialValues({'hasSeenFirstRunOnboarding': true});

    await startApp(tester, const Locale('en'), completeChildNameSetup: false);

    final longName = 'a' * (childNameMaxLength + 4);
    await tester.enterText(find.byType(TextField), longName);
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'a' * childNameMaxLength,
    );

    await tester.tap(find.text('Save name'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('childName'), 'a' * childNameMaxLength);
  });

  testWidgets('First-run onboarding appears before child name setup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await pumpYamyamApp(
      tester,
      initialConfig: MealTimerConfig.defaults(),
      initialHasSeenFirstRunOnboarding: false,
    );

    expect(
      find.byKey(const ValueKey('firstRunOnboardingScreen')),
      findsOneWidget,
    );
    expect(find.text('밥 한 끼 먹이는 일도 참 큰일이에요'), findsOneWidget);
  });

  testWidgets('Completing first-run onboarding opens child name setup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await pumpYamyamApp(
      tester,
      initialConfig: MealTimerConfig.defaults(),
      initialHasSeenFirstRunOnboarding: false,
    );

    for (var index = 0; index < 3; index += 1) {
      await tester.tap(
        find.byKey(const ValueKey('firstRunOnboardingNextButton')),
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(
      find.byKey(const ValueKey('firstRunOnboardingCompleteButton')),
    );
    await tester.pumpAndSettle();

    expect(find.text('누가 냠냠 라이더를 탈까?'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        'hasSeenFirstRunOnboarding',
      ),
      isTrue,
    );
  });

  testWidgets(
    'Skipping first-run onboarding opens child name setup and persists seen state',
    (tester) async {
      SharedPreferences.setMockInitialValues({});

      await pumpYamyamApp(
        tester,
        initialConfig: MealTimerConfig.defaults(),
        initialHasSeenFirstRunOnboarding: false,
      );

      expect(
        find.byKey(const ValueKey('firstRunOnboardingScreen')),
        findsOneWidget,
      );

      final skipButton = find.byKey(
        const ValueKey('firstRunOnboardingSkipButton'),
      );
      await tester.ensureVisible(skipButton);
      await tester.pumpAndSettle();
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(find.text('누가 냠냠 라이더를 탈까?'), findsOneWidget);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('hasSeenFirstRunOnboarding'), isTrue);
    },
  );

  testWidgets('Saved child name skips first-run onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await pumpYamyamApp(
      tester,
      initialConfig: MealTimerConfig.defaults().copyWith(childName: '지율'),
      initialHasSeenFirstRunOnboarding: false,
    );

    expect(
      find.byKey(const ValueKey('firstRunOnboardingScreen')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('homeLogo')), findsOneWidget);
  });

  testWidgets('Seen first-run onboarding opens child name setup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await pumpYamyamApp(
      tester,
      initialConfig: MealTimerConfig.defaults(),
      initialHasSeenFirstRunOnboarding: true,
    );

    expect(
      find.byKey(const ValueKey('firstRunOnboardingScreen')),
      findsNothing,
    );
    expect(find.text('누가 냠냠 라이더를 탈까?'), findsOneWidget);
  });

  testWidgets('Unsupported locale falls back to English', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('fr'));

    expect(find.byKey(const ValueKey('homeLogo')), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.textContaining('Custom time'), findsOneWidget);
  });
}
