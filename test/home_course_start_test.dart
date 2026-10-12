import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/catalogs/meal_ingredient_catalog.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/widgets/app/app_bouncy_button.dart';

void main() {
  testWidgets(
    'rapid course taps open one picker and allow retry after dismissal',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = DelayedStore();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: HomeScreen(
            config: MealTimerConfig.defaults().copyWith(childName: '지율'),
            mealProgressService: LocalMealProgressService(),
            activeSessionStore: store,
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      store.delay = true;
      final button = find.textContaining('25분 보통 코스');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(button);
      await tester.pump();
      expect(store.pending.length, 1);
      store.delay = false;
      for (final c in store.pending) {
        c.complete(null);
      }
      await tester.pumpAndSettle();
      final sheets = find.byKey(
        const ValueKey('mealIngredientPickerSheet'),
        skipOffstage: false,
      );
      expect(sheets, findsOneWidget);
      Navigator.of(
        tester.element(find.byKey(const ValueKey('mealIngredientPickerSheet'))),
      ).pop();
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(sheets, findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('randomStartMealIngredientsButton')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(TimerScreen, skipOffstage: false), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
  for (final disposeHome in [false, true]) {
    testWidgets(
      disposeHome
          ? 'pending course lookup tolerates disposed home'
          : 'failed course lookup releases guard for retry',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = DelayedStore();
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: AppTexts.supportedLocales,
            locale: const Locale('ko'),
            home: HomeScreen(
              config: MealTimerConfig.defaults(),
              mealProgressService: LocalMealProgressService(),
              activeSessionStore: store,
              onConfigChanged: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        store.delay = true;
        final button = find.textContaining('25분 보통 코스');
        await tester.tap(button);
        await tester.pump();
        expect(store.pending, hasLength(1));
        if (disposeHome) await tester.pumpWidget(const SizedBox.shrink());
        store.delay = false;
        if (disposeHome) {
          store.pending.single.complete(null);
        } else {
          store.pending.single.completeError(StateError('storage unavailable'));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (!disposeHome) {
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('mealIngredientPickerSheet')),
            findsOneWidget,
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('Starting a course opens the ingredient picker first', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            duration: const Duration(minutes: 35),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('35분 보통 코스'), findsOneWidget);

    final regularCourseButton = tester.widget<AppBouncyButton>(
      find.ancestor(
        of: find.textContaining('35분 보통 코스'),
        matching: find.byType(AppBouncyButton),
      ),
    );
    regularCourseButton.onPressed!();
    expect(tester.takeException(), isNull);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey('mealIngredientPickerSheet')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mealIngredientChipImage_egg')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mealIngredientChipImage_seaweed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mealIngredientChipImage_tofu')),
      findsOneWidget,
    );
    expect(find.text('배추'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mealIngredientChipImage_radish')),
      findsOneWidget,
    );
    expect(find.text('콩'), findsOneWidget);
    expect(find.byType(TimerScreen), findsNothing);
  });

  testWidgets('Meal ingredient picker help opens ingredient help text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final regularCourseButton = tester.widget<AppBouncyButton>(
      find.ancestor(
        of: find.textContaining('25분 보통 코스'),
        matching: find.byType(AppBouncyButton),
      ),
    );
    regularCourseButton.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('mealIngredientPickerSheet')),
      findsOneWidget,
    );
    expect(find.text('식재료는 어떤 의미인가요?'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('mealIngredientPickerHelpButton')),
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

  testWidgets('Course ingredient off starts timer without picker', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            duration: const Duration(minutes: 35),
            courseIngredientMode: CourseIngredientMode.off,
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('35분 보통 코스'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey('mealIngredientPickerSheet')),
      findsNothing,
    );
    expect(find.byType(TimerScreen), findsOneWidget);
    expect(
      tester
          .widget<TimerScreen>(find.byType(TimerScreen))
          .config
          .courseIngredientIds,
      isEmpty,
    );
    expect(
      tester
          .widget<TimerScreen>(find.byType(TimerScreen))
          .config
          .selectedCourseIngredientIds,
      isEmpty,
    );
  });

  testWidgets('Course ingredient random starts timer without picker', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            duration: const Duration(minutes: 35),
            courseIngredientMode: CourseIngredientMode.random,
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('35분 보통 코스'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey('mealIngredientPickerSheet')),
      findsNothing,
    );
    expect(find.byType(TimerScreen), findsOneWidget);
    expect(
      tester
          .widget<TimerScreen>(find.byType(TimerScreen))
          .config
          .courseIngredientIds,
      hasLength(MealIngredientCatalog.maxSelectableIngredientCount),
    );
    expect(
      tester
          .widget<TimerScreen>(find.byType(TimerScreen))
          .config
          .selectedCourseIngredientIds,
      isEmpty,
    );
  });

  testWidgets('Tapping random start opens timer screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            duration: const Duration(minutes: 35),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final regularCourseButton = tester.widget<AppBouncyButton>(
      find.ancestor(
        of: find.textContaining('35분 보통 코스'),
        matching: find.byType(AppBouncyButton),
      ),
    );
    regularCourseButton.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final randomStartButton = find.byKey(
      const ValueKey('randomStartMealIngredientsButton'),
    );
    tester.widget<OutlinedButton>(randomStartButton).onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TimerScreen), findsOneWidget);
    expect(
      tester.widget<TimerScreen>(find.byType(TimerScreen)).config.duration,
      const Duration(minutes: 35),
    );
    expect(
      tester
          .widget<TimerScreen>(find.byType(TimerScreen))
          .config
          .courseIngredientIds,
      hasLength(MealIngredientCatalog.maxSelectableIngredientCount),
    );
  });

  testWidgets(
    'Selecting carrot and egg opens timer with selected ingredients',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      addTearDown(() async {
        await const ActiveMealTimerSessionStore().clear();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: HomeScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(childName: '지율'),
            mealProgressService: LocalMealProgressService(),
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pump();

      final regularCourseButton = tester.widget<AppBouncyButton>(
        find.ancestor(
          of: find.textContaining('25분 보통 코스'),
          matching: find.byType(AppBouncyButton),
        ),
      );
      regularCourseButton.onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final carrotChip = find.byKey(
        const ValueKey('mealIngredientChip_carrot'),
      );
      tester.widget<ChoiceChip>(carrotChip).onSelected!(true);
      await tester.pump();
      final eggChip = find.byKey(const ValueKey('mealIngredientChip_egg'));
      tester.widget<ChoiceChip>(eggChip).onSelected!(true);
      await tester.pump();
      final startSelectedButton = find.byKey(
        const ValueKey('startSelectedMealIngredientsButton'),
      );
      tester.widget<FilledButton>(startSelectedButton).onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        tester
            .widget<TimerScreen>(find.byType(TimerScreen))
            .config
            .courseIngredientIds,
        ['carrot', 'egg'],
      );
      expect(
        tester
            .widget<TimerScreen>(find.byType(TimerScreen))
            .config
            .selectedCourseIngredientIds,
        ['carrot', 'egg'],
      );
    },
  );

  testWidgets('Dismissing the ingredient picker does not open timer screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final regularCourseButton = tester.widget<AppBouncyButton>(
      find.ancestor(
        of: find.textContaining('25분 보통 코스'),
        matching: find.byType(AppBouncyButton),
      ),
    );
    regularCourseButton.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey('mealIngredientPickerSheet')),
      findsNothing,
    );
    expect(find.byType(TimerScreen), findsNothing);
  });

  testWidgets('Alternate courses exclude the selected default duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            duration: const Duration(minutes: 15),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('15분 보통 코스'), findsOneWidget);
    expect(find.text('15분 코스'), findsNothing);
    expect(find.text('25분 코스'), findsOneWidget);
    expect(find.text('35분 코스'), findsOneWidget);
  });

  testWidgets('Quick courses do not overwrite default meal duration', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    MealTimerConfig? changedConfig;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            duration: const Duration(minutes: 35),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (config) => changedConfig = config,
        ),
      ),
    );
    await tester.pump();

    final quickCourseButton = tester.widget<InkWell>(
      find
          .ancestor(of: find.text('25분 코스'), matching: find.byType(InkWell))
          .first,
    );
    quickCourseButton.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey('mealIngredientPickerSheet')),
      findsOneWidget,
    );
    expect(find.byType(TimerScreen), findsNothing);

    final randomStartButton = find.byKey(
      const ValueKey('randomStartMealIngredientsButton'),
    );
    tester.widget<OutlinedButton>(randomStartButton).onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TimerScreen), findsOneWidget);
    expect(
      tester.widget<TimerScreen>(find.byType(TimerScreen)).config.duration,
      const Duration(minutes: 25),
    );
    expect(changedConfig, isNull);
  });

  testWidgets(
    'Timer motivation settings do not overwrite default meal duration',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      addTearDown(() async {
        await const ActiveMealTimerSessionStore().clear();
      });
      MealTimerConfig? changedConfig;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: HomeScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(
              childName: '지율',
              duration: const Duration(minutes: 35),
            ),
            mealProgressService: LocalMealProgressService(),
            onConfigChanged: (config) => changedConfig = config,
          ),
        ),
      );
      await tester.pump();

      final quickCourseButton = tester.widget<InkWell>(
        find
            .ancestor(of: find.text('25분 코스'), matching: find.byType(InkWell))
            .first,
      );
      quickCourseButton.onTap!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final randomStartButton = find.byKey(
        const ValueKey('randomStartMealIngredientsButton'),
      );
      tester.widget<OutlinedButton>(randomStartButton).onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(TimerScreen), findsOneWidget);
      expect(
        tester.widget<TimerScreen>(find.byType(TimerScreen)).config.duration,
        const Duration(minutes: 25),
      );

      await tester.tap(find.byKey(const ValueKey('motivationSettingsButton')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('motivationVideoEnabledSwitch')),
          )
          .onChanged!(false);
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('motivationSettingsApplyButton')),
      );
      await tester.pump();

      expect(changedConfig?.duration, const Duration(minutes: 35));
      expect(changedConfig?.motivationVideoEnabled, isFalse);
      expect(changedConfig?.courseIngredientIds, isEmpty);
    },
  );
}

class DelayedStore extends ActiveMealTimerSessionStore {
  bool delay = false;
  final pending = <Completer<ActiveMealTimerSession?>>[];
  @override
  Future<ActiveMealTimerSession?> load() {
    if (!delay) return Future.value(null);
    final c = Completer<ActiveMealTimerSession?>();
    pending.add(c);
    return c.future;
  }
}
