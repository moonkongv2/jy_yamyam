import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/constants/child_name_limits.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/settings_screen.dart';

import 'helpers/app_test_harness.dart';

void main() {
  testWidgets('Remaining time setting can be turned off', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('남은 시간 보여주기'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('남은 시간 보여주기'), findsOneWidget);
    await tester.tap(find.text('남은 시간 보여주기'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('25분 보통 코스'));
    await tester.pump();

    expect(find.textContaining('남은 시간'), findsNothing);
    expect(find.text('남은 식사 시간'), findsNothing);
  });

  testWidgets('Settings screen opens course ingredient help sheet', (
    tester,
  ) async {
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
      find.byKey(const ValueKey('courseIngredientModeHelpButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('courseIngredientModeHelpButton')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('courseIngredientModeHelpButton')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('appHelpSheet')), findsOneWidget);
    expect(find.textContaining('직접 고른 식재료'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('appHelpSheet')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Settings screen updates course ingredient mode', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    var latestConfig = MealTimerConfig.defaults();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: SettingsScreen(
          motivationMediaAvailable: true,
          config: latestConfig,
          onConfigChanged: (config) => latestConfig = config,
        ),
      ),
    );

    expect(find.text('도로 위 식재료'), findsOneWidget);
    final segmentedButtonFinder = find.byKey(
      const ValueKey('courseIngredientModeSegmentedButton'),
    );
    final segmentedButton = tester
        .widget<SegmentedButton<CourseIngredientMode>>(segmentedButtonFinder);
    final segmentedButtonRect = tester.getRect(segmentedButtonFinder);
    final cardRect = tester.getRect(
      find.ancestor(of: segmentedButtonFinder, matching: find.byType(Card)),
    );
    expect(segmentedButton.selected, {CourseIngredientMode.manual});
    expect(segmentedButton.showSelectedIcon, isFalse);
    expect(segmentedButtonRect.left, greaterThanOrEqualTo(cardRect.left));
    expect(segmentedButtonRect.right, lessThanOrEqualTo(cardRect.right));
    expect(find.text('사용 안 함'), findsOneWidget);
    expect(find.text('직접 선택'), findsOneWidget);
    expect(find.text('자동 선택'), findsOneWidget);
    expect(
      find.text('직접 선택한 식재료만 식사 기록에 남아요. 자동 선택은 도로에만 표시돼요.'),
      findsOneWidget,
    );

    segmentedButton.onSelectionChanged!({CourseIngredientMode.random});
    await tester.pump();

    expect(latestConfig.courseIngredientMode, CourseIngredientMode.random);
  });

  testWidgets('Settings screen updates motivation video settings', (
    tester,
  ) async {
    var latestConfig = MealTimerConfig.defaults();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: SettingsScreen(
          motivationMediaAvailable: true,
          config: latestConfig,
          onConfigChanged: (config) => latestConfig = config,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('motivationVideoIntervalSegmentedButton')),
      findsNothing,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('motivationVideoCustomIntervalSwitch')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    tester
        .widget<SwitchListTile>(
          find.byKey(const ValueKey('motivationVideoCustomIntervalSwitch')),
        )
        .onChanged!(true);
    await tester.pump();

    expect(latestConfig.motivationVideoUseCustomInterval, isTrue);
    expect(
      find.byKey(const ValueKey('motivationVideoIntervalSegmentedButton')),
      findsOneWidget,
    );

    tester
        .widget<SegmentedButton<int>>(
          find.byKey(const ValueKey('motivationVideoIntervalSegmentedButton')),
        )
        .onSelectionChanged!({10});
    await tester.pump();

    expect(latestConfig.motivationVideoInterval, const Duration(minutes: 10));

    tester
        .widget<SwitchListTile>(
          find.byKey(const ValueKey('motivationVideoEnabledSwitch')),
        )
        .onChanged!(false);
    await tester.pump();

    expect(latestConfig.motivationVideoEnabled, isFalse);
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('motivationVideoCustomIntervalSwitch')),
          )
          .onChanged,
      isNull,
    );
    expect(
      find.byKey(const ValueKey('motivationVideoIntervalSegmentedButton')),
      findsNothing,
    );
  });

  testWidgets('Settings screen opens motivation video help sheet', (
    tester,
  ) async {
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
      find.byKey(const ValueKey('motivationVideoHelpButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('motivationVideoHelpButton')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('motivationVideoHelpButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('appHelpSheet')), findsOneWidget);
    expect(find.text('동기부여 영상 안내'), findsWidgets);
    expect(find.textContaining('진행률 10%'), findsOneWidget);
    expect(find.textContaining('3분, 5분, 10분'), findsOneWidget);
  });

  testWidgets('Child name can be changed in settings', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();

    expect(find.text('아이 이름'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '서아');
    await tester.tap(find.text('이름 저장'));
    await tester.pump();

    expect(find.text('이름을 저장했어요.'), findsOneWidget);
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('childName'), '서아');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('서아의 냠냠 기록'), findsOneWidget);
  });

  testWidgets('Child name settings limits input length', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();

    final longName = '가' * (childNameMaxLength + 3);
    await tester.enterText(find.byType(TextField), longName);
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '가' * childNameMaxLength,
    );

    await tester.tap(find.text('이름 저장'));
    await tester.pump();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('childName'), '가' * childNameMaxLength);
  });

  testWidgets('Empty child name in settings shows validation message', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('이름 저장'));
    await tester.pump();

    expect(find.text('아이 이름을 입력해 주세요.'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('childName'), '지율');
  });
}
