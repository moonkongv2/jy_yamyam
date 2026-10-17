import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/reward_goal.dart';
import 'package:jy_yamyam/models/meal_session_result.dart';
import 'package:jy_yamyam/models/meal_progress_snapshot.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/widgets/timer_control_bar.dart';
import 'helpers/timer_screen_test_harness.dart';
import 'package:jy_yamyam/navigation/app_route_observer.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/meal_history_screen.dart';
import 'package:jy_yamyam/screens/result_screen.dart';
import 'package:jy_yamyam/screens/reward_goal_screen.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';

import 'helpers/meal_result_fixture.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final linked in [false, true]) {
    testWidgets(
      'Dialog defaults to history only; selected linked=$linked is applied',
      (tester) async {
        final service = LocalMealProgressService();
        await service.recordMealResult(
          mealResult().copyWith(sessionId: 'dialog'),
          vehicleId: 'bus',
        );
        await tester.pumpWidget(
          _app(MealHistoryScreen(mealProgressService: service)),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();
        expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isFalse,
        );
        if (linked) {
          await tester.tap(find.byType(CheckboxListTile));
          await tester.pumpAndSettle();
          expect(find.text('기록만 삭제되고 받은 차량 스티커는 유지돼요.'), findsNothing);
          expect(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.textContaining('이미 사용한 보상은 유지돼요.'),
            ),
            findsOneWidget,
          );
        }
        await tester.tap(find.widgetWithText(FilledButton, '삭제'));
        await tester.pumpAndSettle();
        final snapshot = await service.loadSnapshot();
        expect(snapshot.history, isEmpty);
        expect(snapshot.inventory.length, linked ? 0 : 1);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  }

  testWidgets('Cancel and repeated delete requests do not modify data', (
    tester,
  ) async {
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult().copyWith(sessionId: 'cancel'),
      vehicleId: 'bus',
    );
    await tester.pumpWidget(
      _app(MealHistoryScreen(mealProgressService: service)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.tap(
      find.byIcon(Icons.delete_outline_rounded),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect((await service.loadSnapshot()).history, hasLength(1));
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();
    expect((await service.loadSnapshot()).history, hasLength(1));
  });

  testWidgets('Incomplete meal with no linked rewards hides checkbox', (
    tester,
  ) async {
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(mealCompleted: false).copyWith(sessionId: 'incomplete'),
      vehicleId: 'bus',
    );
    await tester.pumpWidget(
      _app(MealHistoryScreen(mealProgressService: service)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, '삭제'));
    await tester.pumpAndSettle();
    expect((await service.loadSnapshot()).history, isEmpty);
  });

  testWidgets(
    'Save failure remains visible and retry reloads recovered state',
    (tester) async {
      final service = _FailDeleteService();
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'failure'),
        vehicleId: 'bus',
      );
      await tester.pumpWidget(
        _app(MealHistoryScreen(mealProgressService: service)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '삭제'));
      await tester.pumpAndSettle();
      expect(find.text('저장을 완료하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
      expect(find.text('식사 기록을 삭제했어요.'), findsNothing);
      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    },
  );

  for (final locale in const [
    Locale('ko'),
    Locale('en'),
    Locale('ja'),
    Locale('es'),
    Locale('pt', 'BR'),
  ]) {
    testWidgets(
      'Linked delete dialog fits small screen and large text in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final service = LocalMealProgressService();
        await service.recordMealResult(
          mealResult().copyWith(sessionId: 'layout'),
          vehicleId: 'bus',
        );
        await tester.pumpWidget(
          _app(
            MealHistoryScreen(mealProgressService: service),
            locale: locale,
            largeText: true,
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byIcon(Icons.delete_outline_rounded),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await Scrollable.ensureVisible(
          tester.element(find.byIcon(Icons.delete_outline_rounded)),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(CheckboxListTile));
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isTrue,
        );
      },
    );
  }

  testWidgets('Home RouteObserver refreshes counts after linked deletion', (
    tester,
  ) async {
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult().copyWith(sessionId: 'home'),
      vehicleId: 'bus',
    );
    await tester.pumpWidget(
      _app(
        HomeScreen(
          config: MealTimerConfig.defaults(),
          mealProgressService: service,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(HomeScreen));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '삭제'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(MealHistoryScreen))).pop();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('0번'), findsOneWidget);
    expect(find.text('0장'), findsOneWidget);
    expect(find.text('0개'), findsOneWidget);
  });

  testWidgets(
    'Deleted pending completion is cleaned up by home without resurrection',
    (tester) async {
      final service = LocalMealProgressService();
      final result = mealResult().copyWith(sessionId: 'pending');
      await service.recordMealResult(result, vehicleId: 'bus');
      await service.deleteMealHistoryEntry(
        'pending',
        deleteLinkedRewards: true,
      );
      final config = MealTimerConfig.defaults();
      await const ActiveMealTimerSessionStore().save(
        ActiveMealTimerSession(
          sessionId: 'pending',
          config: config,
          startedAt: result.startedAt,
          state: ActiveMealTimerSessionState.arrived,
          pendingCompletion: result,
        ),
      );
      await tester.pumpWidget(
        _app(
          HomeScreen(
            config: config,
            mealProgressService: service,
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(await const ActiveMealTimerSessionStore().load(), isNull);
      expect((await service.loadSnapshot()).history, isEmpty);
      expect((await service.loadSnapshot()).inventory, isEmpty);
    },
  );

  testWidgets(
    'Deleted result fallback does not start intro or award animation',
    (tester) async {
      final service = LocalMealProgressService();
      final result = mealResult().copyWith(sessionId: 'result');
      await service.recordMealResult(result, vehicleId: 'bus');
      await service.deleteMealHistoryEntry('result', deleteLinkedRewards: true);
      await tester.pumpWidget(
        _app(
          ResultScreen(
            result: result,
            config: MealTimerConfig.defaults(),
            mealProgressService: service,
            onConfigChanged: (_) {},
            introControllerFactory: (_) =>
                throw StateError('Intro must not start'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('이미 삭제된 식사예요.'), findsOneWidget);
      expect(find.text('홈으로'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect((await service.loadSnapshot()).inventory, isEmpty);
    },
  );

  testWidgets('Deleted timer completion retries session cleanup only', (
    tester,
  ) async {
    final service = _DeleteDuringCompletionService();
    final store = _FailClearOnceStore();
    await tester.pumpWidget(_app(const Scaffold(body: Text('Root'))));
    final context = tester.element(find.text('Root'));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TimerScreen(
          config: MealTimerConfig.defaults(),
          mealProgressService: service,
          activeSessionStore: store,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await finishCoursePreview(tester);
    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('저장을 완료하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(service.calls, 1);
    final oldCleanupAction = tester
        .widget<SnackBarAction>(find.byType(SnackBarAction))
        .onPressed;
    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Root'), findsOneWidget);
    expect(find.byType(TimerScreen), findsNothing);
    expect(service.calls, 1);
    expect(await store.load(), isNull);
    expect((await service.loadSnapshot()).inventory, isEmpty);
    await store.save(
      ActiveMealTimerSession(
        sessionId: 'new-session',
        startedAt: DateTime(2026),
        config: MealTimerConfig.defaults(),
        state: ActiveMealTimerSessionState.running,
      ),
    );
    oldCleanupAction();
    await tester.pump();
    expect((await store.load())!.sessionId, 'new-session');
  });

  testWidgets('Overflow goals are all displayed and creation stays blocked', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'activeRewardGoals',
      List.generate(
        3,
        (index) => jsonEncode(
          RewardGoal(
            id: 'goal-$index',
            rewardText: 'Reward $index',
            requiredStickerCount: 5,
            filledSlots: const [],
            createdAt: DateTime(2026),
            status: RewardGoalStatus.active,
          ).toJson(),
        ),
      ),
    );
    final service = LocalMealProgressService();
    await tester.pumpWidget(
      _app(RewardGoalScreen(mealProgressService: service)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Reward 2'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Reward 2'), findsOneWidget);
    await tester.pumpWidget(
      _app(
        HomeScreen(
          config: MealTimerConfig.defaults(),
          mealProgressService: service,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('외 1개'), findsOneWidget);
  });
}

Widget _app(
  Widget home, {
  Locale locale = const Locale('ko'),
  bool largeText = false,
}) => MaterialApp(
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: AppTexts.supportedLocales,
  locale: locale,
  navigatorObservers: [appRouteObserver],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(largeText ? 2 : 1)),
    child: child!,
  ),
  home: home,
);

class _FailDeleteService extends LocalMealProgressService {
  @override
  Future<bool> deleteMealHistoryEntry(
    String entryId, {
    bool deleteLinkedRewards = false,
  }) async {
    throw StateError('Injected delete failure');
  }
}

class _DeleteDuringCompletionService extends LocalMealProgressService {
  int calls = 0;
  @override
  Future<RecordedMealSession> recordMealResult(
    MealSessionResult result, {
    required String vehicleId,
  }) async {
    calls++;
    final recorded = await super.recordMealResult(result, vehicleId: vehicleId);
    await deleteMealHistoryEntry(recorded.entry.id, deleteLinkedRewards: true);
    return super.recordMealResult(result, vehicleId: vehicleId);
  }
}

class _FailClearOnceStore extends ActiveMealTimerSessionStore {
  bool fail = true;
  @override
  Future<void> clear() async {
    if (fail) {
      fail = false;
      throw StateError('Injected session clear failure');
    }
    await super.clear();
  }
}
