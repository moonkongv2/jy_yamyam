import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_completion_status.dart';
import 'package:jy_yamyam/models/meal_session_result.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/reward_goal.dart';
import 'package:jy_yamyam/models/reward_item.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/meal_history_screen.dart';
import 'package:jy_yamyam/screens/reward_goal_screen.dart';
import 'package:jy_yamyam/screens/sticker_collection_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/theme/app_theme.dart';
import 'package:jy_yamyam/widgets/reward_sticker_image.dart';
import 'package:jy_yamyam/widgets/result_sticker_album_sheet.dart';

import 'helpers/meal_result_fixture.dart';

void main() {
  test('Fast meal awards the selected vehicle sticker', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      MealSessionResult(
        startedAt: DateTime(2026, 5, 4, 12),
        endedAt: DateTime(2026, 5, 4, 12, 10),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 13),
        completedBeforeArrival: true,
      ),
      vehicleId: 'motorcycle',
    );

    expect(recordedSession.awardedRewards, hasLength(1));
    expect(
      recordedSession.awardedRewards.single.id,
      'sticker_vehicle_motorcycle',
    );
    expect(recordedSession.entry.rewardIds, ['sticker_vehicle_motorcycle']);
  });

  test('Completed overtime meal awards the selected vehicle sticker', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      MealSessionResult(
        startedAt: DateTime(2026, 5, 4, 12),
        endedAt: DateTime(2026, 5, 4, 12, 25),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        completedBeforeArrival: false,
      ),
      vehicleId: 'fire_truck',
    );

    expect(recordedSession.awardedRewards, hasLength(1));
    expect(
      recordedSession.awardedRewards.single.id,
      'sticker_vehicle_fire_truck',
    );
  });

  test('Incomplete meal does not award stickers', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      MealSessionResult(
        startedAt: DateTime(2026, 5, 4, 12),
        endedAt: DateTime(2026, 5, 4, 12, 25),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        completedBeforeArrival: false,
        mealCompleted: false,
      ),
      vehicleId: 'shark',
    );

    expect(recordedSession.awardedRewards, isEmpty);
    expect(recordedSession.entry.mealCompleted, isFalse);
    expect(
      recordedSession.entry.completionStatus,
      MealCompletionStatus.notCompleted,
    );
    expect(recordedSession.entry.rewardIds, isEmpty);
    expect((await service.loadSnapshot()).inventory, isEmpty);
  });

  test('Unknown vehicle does not award stickers', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'missing_vehicle',
    );

    expect(recordedSession.awardedRewards, isEmpty);
    expect(recordedSession.entry.rewardIds, isEmpty);
  });

  test('Arrival-completed meal records at-arrival status', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(
        actualDuration: const Duration(minutes: 20),
        completedBeforeArrival: false,
        completionStatus: MealCompletionStatus.completedAtArrival,
      ),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(
      recordedSession.entry.completionStatus,
      MealCompletionStatus.completedAtArrival,
    );
    expect(
      snapshot.history.single.completionStatus,
      MealCompletionStatus.completedAtArrival,
    );
  });

  test('Meal history stores directly selected ingredient ids', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(selectedIngredientIds: const ['carrot', 'egg']),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.entry.selectedIngredientIds, ['carrot', 'egg']);
    expect(snapshot.history.single.selectedIngredientIds, ['carrot', 'egg']);
  });

  test('Deleting meal history removes only the saved record', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 2,
      rewardText: '아이스크림',
    );
    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'motorcycle',
    );
    final beforeDelete = await service.loadSnapshot();

    expect(beforeDelete.history, hasLength(1));
    expect(beforeDelete.inventory, isNotEmpty);
    expect(beforeDelete.activeRewardGoals.single.filledCount, 1);

    final deleted = await service.deleteMealHistoryEntry(
      recordedSession.entry.id,
    );
    final afterDelete = await service.loadSnapshot();

    expect(deleted, isTrue);
    expect(afterDelete.history, isEmpty);
    expect(afterDelete.inventory, hasLength(beforeDelete.inventory.length));
    expect(
      afterDelete.inventory.single.rewardId,
      beforeDelete.inventory.single.rewardId,
    );
    expect(
      afterDelete.inventory.single.count,
      beforeDelete.inventory.single.count,
    );
    expect(afterDelete.activeRewardGoals.single.filledCount, 1);
    expect(
      afterDelete.activeRewardGoals.single.filledSlots.single.mealSessionId,
      recordedSession.entry.id,
    );
  });

  test(
    'Deleting missing meal history entry leaves records unchanged',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = LocalMealProgressService();
      await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');

      final deleted = await service.deleteMealHistoryEntry('missing-meal');
      final snapshot = await service.loadSnapshot();

      expect(deleted, isFalse);
      expect(snapshot.history, hasLength(1));
    },
  );

  test('Completed meal fills exactly one active reward goal slot', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.updatedRewardGoal?.filledCount, 1);
    expect(recordedSession.rewardGoalJustReady, isFalse);
    expect(snapshot.activeRewardGoals.single.filledCount, 1);
  });

  test('Completed meal fills all active reward goals', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );
    await service.createRewardGoal(requiredStickerCount: 7, rewardText: '딸기');

    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.updatedRewardGoals, hasLength(2));
    expect(snapshot.activeRewardGoals, hasLength(2));
    expect(snapshot.activeRewardGoals.map((goal) => goal.filledCount), [1, 1]);
  });

  test('Only two active reward goals can be created', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );
    await service.createRewardGoal(requiredStickerCount: 7, rewardText: '딸기');

    expect(
      () =>
          service.createRewardGoal(requiredStickerCount: 10, rewardText: '젤리'),
      throwsStateError,
    );
  });

  test(
    'Legacy single reward goal storage loads into list storage shape',
    () async {
      final legacyGoal = RewardGoal(
        id: 'legacy-active',
        rewardText: '아이스크림',
        requiredStickerCount: 5,
        filledSlots: const [],
        createdAt: DateTime(2026, 5, 4, 12),
        status: RewardGoalStatus.active,
      );
      final legacyUsedGoal = RewardGoal(
        id: 'legacy-used',
        rewardText: '딸기',
        requiredStickerCount: 1,
        filledSlots: [
          RewardGoalSlot(
            rewardId: 'sticker_vehicle_motorcycle',
            filledAt: DateTime(2026, 5, 4, 12),
            mealSessionId: 'meal-1',
          ),
        ],
        createdAt: DateTime(2026, 5, 4, 12),
        status: RewardGoalStatus.redeemed,
        redeemedAt: DateTime(2026, 5, 5, 12),
      );
      SharedPreferences.setMockInitialValues({
        'activeRewardGoal': jsonEncode(legacyGoal.toJson()),
        'redeemedRewardGoals': [jsonEncode(legacyUsedGoal.toJson())],
      });

      final snapshot = await LocalMealProgressService().loadSnapshot();

      expect(snapshot.activeRewardGoals, hasLength(1));
      expect(snapshot.activeRewardGoals.first.rewardText, '아이스크림');
      expect(snapshot.usedRewardGoals, hasLength(1));
      expect(snapshot.usedRewardGoals.first.status, RewardGoalStatus.used);
    },
  );

  test('Legacy meal history loads with completion status fallback', () async {
    SharedPreferences.setMockInitialValues({
      'mealHistory': [
        jsonEncode({
          'id': 'legacy-meal',
          'startedAt': DateTime(2026, 5, 4, 12).toIso8601String(),
          'endedAt': DateTime(2026, 5, 4, 12, 25).toIso8601String(),
          'targetMs': const Duration(minutes: 20).inMilliseconds,
          'actualMs': const Duration(minutes: 25).inMilliseconds,
          'completedBeforeArrival': false,
          'rewardIds': <String>[],
        }),
      ],
    });

    final snapshot = await LocalMealProgressService().loadSnapshot();

    expect(snapshot.history.single.mealCompleted, isTrue);
    expect(
      snapshot.history.single.completionStatus,
      MealCompletionStatus.completedAfterArrival,
    );
    expect(snapshot.history.single.selectedIngredientIds, isEmpty);
  });

  test(
    'Malformed meal history items are skipped during snapshot load',
    () async {
      final firstMeal = jsonEncode({
        'id': 'meal-1',
        'startedAt': DateTime(2026, 5, 4, 12).toIso8601String(),
        'endedAt': DateTime(2026, 5, 4, 12, 20).toIso8601String(),
        'targetMs': const Duration(minutes: 20).inMilliseconds,
        'actualMs': const Duration(minutes: 20).inMilliseconds,
        'completedBeforeArrival': true,
        'mealCompleted': true,
        'completionStatus': MealCompletionStatus.completedBeforeArrival.name,
        'rewardIds': <String>['sticker_vehicle_motorcycle'],
        'selectedIngredientIds': <String>['egg'],
      });
      final secondMeal = jsonEncode({
        'id': 'meal-2',
        'startedAt': DateTime(2026, 5, 5, 12).toIso8601String(),
        'endedAt': DateTime(2026, 5, 5, 12, 25).toIso8601String(),
        'targetMs': const Duration(minutes: 20).inMilliseconds,
        'actualMs': const Duration(minutes: 25).inMilliseconds,
        'completedBeforeArrival': false,
        'mealCompleted': true,
        'completionStatus': MealCompletionStatus.completedAfterArrival.name,
        'rewardIds': <String>['sticker_vehicle_fire_truck'],
        'selectedIngredientIds': <String>['tofu'],
      });
      final rawHistory = [
        firstMeal,
        '{malformed',
        jsonEncode(<String>['not-a-map']),
        jsonEncode({'id': 'bad-meal', 'startedAt': 'not-a-date'}),
        secondMeal,
      ];
      SharedPreferences.setMockInitialValues({'mealHistory': rawHistory});

      final snapshot = await LocalMealProgressService().loadSnapshot();
      final preferences = await SharedPreferences.getInstance();

      expect(snapshot.history.map((entry) => entry.id), ['meal-1', 'meal-2']);
      expect(snapshot.history.first.rewardIds, ['sticker_vehicle_motorcycle']);
      expect(snapshot.history.last.selectedIngredientIds, ['tofu']);
      expect(preferences.getStringList('mealHistory'), rawHistory);
    },
  );

  test(
    'Malformed reward inventory items are skipped during snapshot load',
    () async {
      final firstReward = jsonEncode({
        'rewardId': 'sticker_vehicle_motorcycle',
        'acquiredAt': DateTime(2026, 5, 4, 12).toIso8601String(),
        'count': 1,
      });
      final secondReward = jsonEncode({
        'rewardId': 'sticker_vehicle_fire_truck',
        'acquiredAt': DateTime(2026, 5, 5, 12).toIso8601String(),
        'count': 2,
      });
      final rawInventory = [
        firstReward,
        '{malformed',
        jsonEncode('not-a-map'),
        jsonEncode({
          'rewardId': 'bad-reward',
          'acquiredAt': 'not-a-date',
          'count': 'many',
        }),
        secondReward,
      ];
      SharedPreferences.setMockInitialValues({'rewardInventory': rawInventory});

      final snapshot = await LocalMealProgressService().loadSnapshot();
      final preferences = await SharedPreferences.getInstance();

      expect(snapshot.inventory.map((item) => item.rewardId), [
        'sticker_vehicle_motorcycle',
        'sticker_vehicle_fire_truck',
      ]);
      expect(snapshot.inventory.map((item) => item.count), [1, 2]);
      expect(preferences.getStringList('rewardInventory'), rawInventory);
    },
  );

  test('Fast meal fills only one reward goal slot', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final recordedSession = await service.recordMealResult(
      mealResult(
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 13),
      ),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.awardedRewards, hasLength(1));
    expect(snapshot.activeRewardGoals.single.filledCount, 1);
  });

  test('Incomplete meal does not fill a reward goal slot', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final recordedSession = await service.recordMealResult(
      mealResult(mealCompleted: false),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.updatedRewardGoal, isNull);
    expect(snapshot.activeRewardGoals.single.filledCount, 0);
  });

  test('Reward goal becomes earned when required count is reached', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 2,
      rewardText: '아이스크림',
    );

    await service.recordMealResult(
      mealResult(endedAt: DateTime(2026, 5, 4, 12)),
      vehicleId: 'motorcycle',
    );
    final recordedSession = await service.recordMealResult(
      mealResult(endedAt: DateTime(2026, 5, 4, 13)),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.rewardGoalJustReady, isTrue);
    expect(snapshot.activeRewardGoals, isEmpty);
    expect(snapshot.earnedRewardGoals.single.status, RewardGoalStatus.earned);
    expect(snapshot.earnedRewardGoals.single.earnedAt, isNotNull);
  });

  test('Using an earned goal moves it to used history', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 1,
      rewardText: '아이스크림',
    );
    await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');

    final usedGoal = await service.useEarnedRewardGoal();
    final snapshot = await service.loadSnapshot();

    expect(usedGoal?.status, RewardGoalStatus.used);
    expect(usedGoal?.usedAt, isNotNull);
    expect(snapshot.activeRewardGoals, isEmpty);
    expect(snapshot.earnedRewardGoals, isEmpty);
    expect(snapshot.usedRewardGoals, hasLength(1));
    expect(snapshot.usedRewardGoals.first.rewardText, '아이스크림');
  });

  test('Active reward goal can be updated', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final updatedGoal = await service.updateActiveRewardGoal(
      requiredStickerCount: 7,
      rewardText: '딸기',
    );
    final snapshot = await service.loadSnapshot();

    expect(updatedGoal?.rewardText, '딸기');
    expect(updatedGoal?.requiredStickerCount, 7);
    expect(snapshot.activeRewardGoals.single.rewardText, '딸기');
    expect(snapshot.activeRewardGoals.single.requiredStickerCount, 7);
  });

  test(
    'Reducing required count to filled count makes reward goal earned',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = LocalMealProgressService();
      await service.createRewardGoal(
        requiredStickerCount: 5,
        rewardText: '아이스크림',
      );
      await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 13)),
        vehicleId: 'motorcycle',
      );

      final updatedGoal = await service.updateActiveRewardGoal(
        requiredStickerCount: 2,
        rewardText: '아이스크림',
      );

      final snapshot = await service.loadSnapshot();

      expect(updatedGoal?.status, RewardGoalStatus.earned);
      expect(updatedGoal?.earnedAt, isNotNull);
      expect(snapshot.activeRewardGoals, isEmpty);
      expect(snapshot.earnedRewardGoals, hasLength(1));
    },
  );

  test('Active reward goal can be canceled', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final canceledGoal = await service.cancelActiveRewardGoal();
    final snapshot = await service.loadSnapshot();

    expect(canceledGoal?.rewardText, '아이스크림');
    expect(snapshot.activeRewardGoals, isEmpty);
    expect(snapshot.usedRewardGoals, isEmpty);
  });

  test('Existing sticker inventory counts still increase', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();
    final inventoryCount = snapshot.inventory.fold<int>(
      0,
      (total, item) => total + item.count,
    );

    expect(inventoryCount, recordedSession.awardedRewards.length);
    expect(snapshot.activeRewardGoals.single.filledCount, 1);
  });

  test(
    'Completing meals with the same vehicle increments inventory count',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 12, 20)),
        vehicleId: 'bus',
      );
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 13, 20)),
        vehicleId: 'bus',
      );

      final snapshot = await service.loadSnapshot();

      expect(snapshot.inventory, hasLength(1));
      expect(snapshot.inventory.single.rewardId, 'sticker_vehicle_bus');
      expect(snapshot.inventory.single.count, 2);
    },
  );

  test(
    'Completing meals with different vehicles creates separate inventory items',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 12, 20)),
        vehicleId: 'motorcycle',
      );
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 13, 20)),
        vehicleId: 'fire_truck',
      );

      final snapshot = await service.loadSnapshot();

      expect(snapshot.inventory, hasLength(2));
      expect(snapshot.inventory.map((item) => item.rewardId), [
        'sticker_vehicle_motorcycle',
        'sticker_vehicle_fire_truck',
      ]);
      expect(snapshot.inventory.map((item) => item.count), [1, 1]);
    },
  );

  testWidgets('Home screen shows reward goal CTA', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: 'Jiyul'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Create Reward Goal'), findsOneWidget);
  });

  testWidgets(
    'Home reward summary refreshes after returning from reward goal',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final service = LocalMealProgressService();

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

      await tester.tap(find.text('Create Reward Goal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ice cream');
      await tester.pump();
      await tester.tap(find.text('Save Goal'));
      await tester.pumpAndSettle();

      expect(find.byType(RewardGoalScreen), findsOneWidget);
      expect(find.text('ice cream'), findsOneWidget);

      Navigator.of(tester.element(find.byType(RewardGoalScreen))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('ice cream · 0/5'), findsOneWidget);
      expect(find.text('Create Reward Goal'), findsNothing);
    },
  );

  testWidgets('Result sticker album uses bounded three-column landscape grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(852, 393);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpOpenResultStickerAlbumSheet(tester);

    expect(find.text('차량 스티커 보관함'), findsOneWidget);
    expect(find.text('오토바이 스티커'), findsOneWidget);

    final firstCard = tester.getRect(find.byType(Card).at(0));
    final secondCard = tester.getRect(find.byType(Card).at(1));
    final thirdCard = tester.getRect(find.byType(Card).at(2));
    final stickerSizes = tester
        .widgetList<RewardStickerImage>(find.byType(RewardStickerImage))
        .map((widget) => widget.size);

    expect((firstCard.top - secondCard.top).abs(), lessThan(0.1));
    expect((firstCard.top - thirdCard.top).abs(), lessThan(0.1));
    expect(firstCard.left, greaterThan(70));
    expect(thirdCard.right, lessThan(780));
    expect(firstCard.width, lessThan(240));
    expect(stickerSizes.every((size) => size <= 96), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Result sticker album keeps two-column portrait grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpOpenResultStickerAlbumSheet(tester);

    expect(find.text('차량 스티커 보관함'), findsOneWidget);
    expect(find.text('오토바이 스티커'), findsOneWidget);

    final firstCard = tester.getRect(find.byType(Card).at(0));
    final secondCard = tester.getRect(find.byType(Card).at(1));
    final thirdCard = tester.getRect(find.byType(Card).at(2));
    final firstSticker = tester.widget<RewardStickerImage>(
      find.byType(RewardStickerImage).first,
    );

    expect((firstCard.top - secondCard.top).abs(), lessThan(0.1));
    expect(thirdCard.top, greaterThan(firstCard.bottom));
    expect(firstCard.width, lessThan(180));
    expect(firstSticker.size, 85);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sticker collection shows motorcycle and supercar first', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'rewardInventory': [
        jsonEncode({
          'rewardId': 'sticker_vehicle_motorcycle',
          'acquiredAt': DateTime(2026, 5, 4, 12).toIso8601String(),
          'count': 1,
        }),
        jsonEncode({
          'rewardId': 'sticker_vehicle_supercar',
          'acquiredAt': DateTime(2026, 5, 4, 13).toIso8601String(),
          'count': 1,
        }),
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: StickerCollectionScreen(
          mealProgressService: LocalMealProgressService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('오토바이 스티커')).dy,
      tester.getTopLeft(find.text('슈퍼카 스티커')).dy,
    );
  });

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

  testWidgets('Reward goal creation form saves a goal', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: RewardGoalScreen(mealProgressService: service),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ChoiceChip, '7'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ice cream');
    await tester.pump();
    await tester.tap(find.text('Save Goal'));
    await tester.pumpAndSettle();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.activeRewardGoals.single.rewardText, 'ice cream');
    expect(snapshot.activeRewardGoals.single.requiredStickerCount, 7);
  });

  testWidgets('Earned reward use flow asks for confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 1,
      rewardText: 'ice cream',
    );
    await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: RewardGoalScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward'));
    await tester.pumpAndSettle();
    expect(find.text('Give this reward?'), findsOneWidget);

    await tester.tap(find.text('Keep Goal'));
    await tester.pumpAndSettle();
    expect((await service.loadSnapshot()).earnedRewardGoals, hasLength(1));

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward').last);
    await tester.pumpAndSettle();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.earnedRewardGoals, isEmpty);
    expect(snapshot.usedRewardGoals, hasLength(1));
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
}

Future<void> _pumpOpenResultStickerAlbumSheet(WidgetTester tester) async {
  final inventory = [
    RewardInventoryItem(
      rewardId: RewardCatalog.vehicleStickerIdForVehicle('motorcycle'),
      acquiredAt: DateTime(2026),
      count: 2,
    ),
  ];

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppTexts.supportedLocales,
      locale: const Locale('ko'),
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () {
              showResultStickerAlbumSheet(context, inventory: inventory);
            },
            child: const Text('openAlbum'),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('openAlbum'));
  await tester.pumpAndSettle();
}
