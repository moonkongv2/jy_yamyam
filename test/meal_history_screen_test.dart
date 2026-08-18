import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_completion_status.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/meal_history_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/widgets/reward_sticker_image.dart';

import 'helpers/meal_result_fixture.dart';

void main() {
  testWidgets('Home meal records summary opens meal history screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: 'Jiyul'),
          mealProgressService: service,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text("Jiyul's meal records"), findsOneWidget);
    expect(find.text('Recent meal 20:00 · complete'), findsNothing);

    await tester.tap(find.text("Jiyul's meal records"));
    await tester.pumpAndSettle();

    expect(find.byType(MealHistoryScreen), findsOneWidget);
    expect(find.text('Meal Records'), findsOneWidget);
  });

  testWidgets('Home meal records summary shows incomplete status', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        mealCompleted: false,
        completionStatus: MealCompletionStatus.notCompleted,
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '강우'),
          mealProgressService: service,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('강우의 냠냠 기록'), findsOneWidget);
    expect(
      find.text('최근 식사 20:00 · 미완료 · 차량 스티커 없음 · 초과 +05:00'),
      findsNothing,
    );
    expect(find.textContaining('최근 식사'), findsNothing);
  });

  testWidgets('Meal history screen shows empty state', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(
          mealProgressService: LocalMealProgressService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('식사 기록'), findsOneWidget);
    expect(find.text('아직 식사 기록이 없어요'), findsOneWidget);
    expect(find.text('타이머를 완료하면 기록이 여기에 쌓여요.'), findsOneWidget);
  });

  testWidgets('Meal history screen lists saved meal records', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        completedBeforeArrival: false,
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('12:25'), findsOneWidget);
    expect(find.text('목표'), findsOneWidget);
    expect(find.text('20:00'), findsNWidgets(2));
    expect(find.text('실제'), findsOneWidget);
    expect(find.text('25:00'), findsNothing);
    expect(find.text('초과 +05:00'), findsNothing);
    expect(find.text('완료'), findsOneWidget);
    expect(find.text('받은 차량 스티커'), findsOneWidget);
    expect(find.text('고른 식재료'), findsNothing);
  });

  testWidgets('Meal history reward sticker renders without a frame', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 18),
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    final stickerFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RewardStickerImage && widget.size == 56 && !widget.framed,
    );

    expect(stickerFinder, findsOneWidget);
  });

  testWidgets('Meal history screen deletes a record after confirmation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('12:25'), findsOneWidget);

    await tester.tap(
      find.byKey(
        ValueKey('deleteMealHistoryEntry-${recordedSession.entry.id}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('이 식사 기록을 삭제할까요?'), findsOneWidget);
    expect(find.text('기록만 삭제되고 받은 차량 스티커는 유지돼요.'), findsOneWidget);

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.text('식사 기록을 삭제했어요.'), findsOneWidget);
    expect(find.textContaining('12:25'), findsNothing);
    expect(find.text('아직 식사 기록이 없어요'), findsOneWidget);
    expect((await service.loadSnapshot()).history, isEmpty);
  });

  testWidgets('Meal history screen shows directly selected ingredients', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 20),
        selectedIngredientIds: const ['carrot', 'egg'],
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('mealHistoryHelpCard')), findsOneWidget);
    expect(find.text('식사 기록 안내'), findsOneWidget);
    expect(find.text('고른 식재료'), findsOneWidget);
    expect(find.text('당근'), findsOneWidget);
    expect(find.text('달걀'), findsOneWidget);
  });

  testWidgets('Meal history screen shows incomplete meal records', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        mealCompleted: false,
        completionStatus: MealCompletionStatus.notCompleted,
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('미완료'), findsOneWidget);
    expect(find.text('차량 스티커 없음'), findsOneWidget);
    expect(find.text('초과 +05:00'), findsNothing);
  });
  testWidgets('Meal history delete dialog can be canceled', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        ValueKey('deleteMealHistoryEntry-${recordedSession.entry.id}'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(find.textContaining('12:25'), findsOneWidget);
    expect((await service.loadSnapshot()).history, hasLength(1));
  });
}
