import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/settings_screen.dart';
import 'package:jy_yamyam/screens/user_guide_screen.dart';

void main() {
  testWidgets('Settings screen opens Korean parent guide', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: SettingsScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          onConfigChanged: (_) {},
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('userGuideSettingsTile')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('userGuideSettingsTile')), findsOneWidget);
    expect(find.text(AppTexts.ko.settings.userGuide), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('userGuideSettingsTile')));
    await tester.pumpAndSettle();

    expect(find.byType(UserGuideScreen), findsOneWidget);
    expect(find.text(AppTexts.ko.userGuide.title), findsOneWidget);
    expect(find.text(AppTexts.ko.userGuide.subtitle), findsOneWidget);
    expect(
      find.textContaining('부모님뿐 아니라 아이의 식사를 함께 돕는 보호자도 참고할 수 있어요.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text(AppTexts.ko.userGuide.guardianTipsTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text(AppTexts.ko.userGuide.guardianTipsTitle), findsOneWidget);
  });

  testWidgets('User guide uses English localization', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: Locale('en'),
        home: UserGuideScreen(motivationMediaAvailable: true),
      ),
    );

    expect(find.text('Parent Guide'), findsWidgets);
    expect(find.textContaining('parents and other caregivers'), findsOneWidget);
    expect(
      find.text('Review ingredients, motivation videos, and sticker rules.'),
      findsOneWidget,
    );
    expect(find.text('What is Yamyam Rider?'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Road ingredients'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Road ingredients'), findsOneWidget);
    expect(
      find.textContaining('Only manually chosen ingredients'),
      findsOneWidget,
    );
  });

  testWidgets('User guide shows key Korean guide copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: Locale('ko'),
        home: UserGuideScreen(motivationMediaAvailable: true),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('도로 위 식재료'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('도로 위 식재료'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('직접 고른 식재료').first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('직접 고른 식재료'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('동기부여 영상'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('동기부여 영상'), findsOneWidget);
    expect(find.textContaining('진행률 10%'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('차량 스티커 1개'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('스티커'), findsWidgets);
  });
}
