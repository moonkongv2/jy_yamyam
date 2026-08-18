import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/screens/first_run_onboarding_screen.dart';

void main() {
  test('First-run onboarding text bundles include four slides', () {
    expect(AppTexts.ko.firstRunOnboarding.slides, hasLength(4));
    expect(AppTexts.en.firstRunOnboarding.slides, hasLength(4));
  });

  test('First-run onboarding text bundles include expected first titles', () {
    expect(
      AppTexts.ko.firstRunOnboarding.slides.first.title,
      '밥 한 끼 먹이는 일도 참 큰일이에요',
    );
    expect(
      AppTexts.en.firstRunOnboarding.slides.first.title,
      'Mealtime can be hard for parents too',
    );
  });

  testWidgets('First-run onboarding screen shows and advances Korean slides', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: FirstRunOnboardingScreen(onCompleted: () async {}),
      ),
    );

    expect(
      find.byKey(const ValueKey('firstRunOnboardingScreen')),
      findsOneWidget,
    );
    expect(find.text('밥 한 끼 먹이는 일도 참 큰일이에요'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('firstRunOnboardingNextButton')),
    );
    await tester.pumpAndSettle();

    expect(find.text('식사 시간을 신나는 라이딩으로'), findsOneWidget);
  });

  testWidgets('First-run onboarding complete button completes once', (
    tester,
  ) async {
    var completedCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: FirstRunOnboardingScreen(
          onCompleted: () async {
            completedCount += 1;
          },
        ),
      ),
    );

    for (var index = 0; index < 3; index += 1) {
      await tester.tap(
        find.byKey(const ValueKey('firstRunOnboardingNextButton')),
      );
      await tester.pumpAndSettle();
    }

    expect(find.text('완벽하지 않아도 괜찮아요'), findsOneWidget);

    final completeButton = find.byKey(
      const ValueKey('firstRunOnboardingCompleteButton'),
    );
    await tester.tap(completeButton);
    await tester.pump();
    await tester.tap(completeButton);
    await tester.pump();

    expect(completedCount, 1);
  });

  testWidgets('First-run onboarding skip button completes once', (
    tester,
  ) async {
    var completedCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: FirstRunOnboardingScreen(
          onCompleted: () async {
            completedCount += 1;
          },
        ),
      ),
    );

    final skipButton = find.byKey(
      const ValueKey('firstRunOnboardingSkipButton'),
    );
    await tester.tap(skipButton);
    await tester.pump();
    await tester.tap(skipButton);
    await tester.pump();

    expect(completedCount, 1);
  });
}
