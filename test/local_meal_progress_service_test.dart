import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/models/meal_completion_status.dart';
import 'package:jy_yamyam/models/meal_session_result.dart';
import 'package:jy_yamyam/models/reward_goal.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';

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
}
