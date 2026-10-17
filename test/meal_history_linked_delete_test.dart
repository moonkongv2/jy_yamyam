import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:jy_yamyam/models/reward_goal.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';

import 'helpers/meal_result_fixture.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final linked in [false, true]) {
    test(
      'Deletion linked=$linked cannot be replayed by late completion',
      () async {
        final service = LocalMealProgressService();
        final result = mealResult().copyWith(sessionId: 'late');
        await service.createRewardGoal(
          requiredStickerCount: 5,
          rewardText: 'Park',
        );
        await service.recordMealResult(result, vehicleId: 'bus');
        expect(await service.hasLinkedMealRewards('late'), isTrue);
        expect(
          await service.deleteMealHistoryEntry(
            'late',
            deleteLinkedRewards: linked,
          ),
          isTrue,
        );
        expect(
          await service.deleteMealHistoryEntry(
            'late',
            deleteLinkedRewards: linked,
          ),
          isFalse,
        );
        await expectLater(
          service.recordMealResult(result, vehicleId: 'bus'),
          throwsA(isA<DeletedMealSessionException>()),
        );
        final snapshot = await service.loadSnapshot();
        expect(snapshot.history, isEmpty);
        expect(snapshot.inventory.length, linked ? 0 : 1);
        expect(snapshot.activeRewardGoal!.filledCount, linked ? 0 : 1);
      },
    );
  }

  test(
    'Legacy result without sessionId is also blocked after deletion',
    () async {
      final service = LocalMealProgressService();
      final result = mealResult();
      final recorded = await service.recordMealResult(result, vehicleId: 'bus');
      await service.deleteMealHistoryEntry(
        recorded.entry.id,
        deleteLinkedRewards: true,
      );
      await expectLater(
        service.recordMealResult(result, vehicleId: 'bus'),
        throwsA(isA<DeletedMealSessionException>()),
      );
    },
  );

  test(
    'Only selected meal is deducted, repeated concurrent delete is harmless',
    () async {
      final service = LocalMealProgressService();
      await service.createRewardGoal(
        requiredStickerCount: 5,
        rewardText: 'Park',
      );
      for (final id in ['first', 'second']) {
        await service.recordMealResult(
          mealResult().copyWith(sessionId: id),
          vehicleId: 'bus',
        );
      }
      expect(
        await Future.wait([
          service.deleteMealHistoryEntry('first', deleteLinkedRewards: true),
          service.deleteMealHistoryEntry('first', deleteLinkedRewards: true),
        ]),
        [true, false],
      );
      final snapshot = await service.loadSnapshot();
      expect(snapshot.inventory.single.count, 1);
      expect(
        snapshot.activeRewardGoal!.filledSlots.single.mealSessionId,
        'second',
      );
      expect(snapshot.history.single.id, 'second');
    },
  );

  test(
    'Earned reversals preserve used rewards and more than two active goals',
    () async {
      final service = LocalMealProgressService();
      await service.createRewardGoal(
        requiredStickerCount: 1,
        rewardText: 'Used',
      );
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'used'),
        vehicleId: 'bus',
      );
      await service.useEarnedRewardGoal();
      await service.createRewardGoal(
        requiredStickerCount: 1,
        rewardText: 'Ice cream',
      );
      await service.createRewardGoal(
        requiredStickerCount: 1,
        rewardText: 'Park',
      );
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'earned'),
        vehicleId: 'bus',
      );
      await service.createRewardGoal(
        requiredStickerCount: 5,
        rewardText: 'Book',
      );
      await service.createRewardGoal(
        requiredStickerCount: 5,
        rewardText: 'Trip',
      );
      final prefs = await SharedPreferences.getInstance();
      final usedRaw = prefs.getStringList('usedRewardGoals');
      await service.deleteMealHistoryEntry('earned', deleteLinkedRewards: true);
      var snapshot = await LocalMealProgressService().loadSnapshot();
      expect(snapshot.activeRewardGoals.map((goal) => goal.rewardText), [
        'Book',
        'Trip',
        'Ice cream',
        'Park',
      ]);
      expect(snapshot.earnedRewardGoals, isEmpty);
      expect(
        snapshot.activeRewardGoals.every(
          (goal) => goal.earnedAt == null && goal.readyAt == null,
        ),
        isTrue,
      );
      await expectLater(
        service.createRewardGoal(
          requiredStickerCount: 3,
          rewardText: 'Blocked',
        ),
        throwsStateError,
      );
      await service.updateActiveRewardGoal(
        goalId: snapshot.activeRewardGoals.first.id,
        requiredStickerCount: 6,
        rewardText: 'Book',
      );
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'next'),
        vehicleId: 'bus',
      );
      snapshot = await service.loadSnapshot();
      expect(snapshot.activeRewardGoals, hasLength(2));
      expect(
        snapshot.activeRewardGoals.every((goal) => goal.filledCount == 1),
        isTrue,
      );
      expect(snapshot.earnedRewardGoals, hasLength(2));
      await service.deleteMealHistoryEntry('used', deleteLinkedRewards: true);
      expect(prefs.getStringList('usedRewardGoals'), usedRaw);
      expect(
        (await service.loadSnapshot()).usedRewardGoals.single.filledCount,
        1,
      );
      await service.cancelActiveRewardGoal(
        goalId: snapshot.activeRewardGoals.first.id,
      );
      await service.createRewardGoal(
        requiredStickerCount: 2,
        rewardText: 'Allowed',
      );
    },
  );

  test('Empty reward ids can still remove legacy linked slots', () async {
    final service = LocalMealProgressService();
    final recorded = await service.recordMealResult(
      mealResult().copyWith(sessionId: 'old'),
      vehicleId: 'bus',
    );
    final prefs = await SharedPreferences.getInstance();
    final history = recorded.entry.toJson()..['rewardIds'] = <String>[];
    await prefs.setStringList('mealHistory', [jsonEncode(history)]);
    await prefs.remove('activeRewardGoals');
    await prefs.remove('earnedRewardGoals');
    await prefs.setString(
      'activeRewardGoal',
      jsonEncode(_goal('legacy', 'old').toJson()),
    );
    expect(await service.hasLinkedMealRewards('old'), isTrue);
    await service.deleteMealHistoryEntry('old', deleteLinkedRewards: true);
    final snapshot = await service.loadSnapshot();
    expect(snapshot.activeRewardGoal!.filledCount, 0);
    expect(snapshot.inventory.single.count, 1);
  });

  test(
    'Unknown/duplicate reward ids and missing inventory never go negative',
    () async {
      final service = LocalMealProgressService();
      final recorded = await service.recordMealResult(
        mealResult().copyWith(sessionId: 'unknown'),
        vehicleId: 'bus',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('mealHistory', [
        jsonEncode(
          recorded.entry.toJson()..['rewardIds'] = ['old', 'old', 'missing'],
        ),
      ]);
      await prefs.setStringList('rewardInventory', [
        jsonEncode({
          'rewardId': 'old',
          'count': 1,
          'acquiredAt': DateTime(2026).toIso8601String(),
        }),
      ]);
      await service.deleteMealHistoryEntry(
        'unknown',
        deleteLinkedRewards: true,
      );
      expect((await service.loadSnapshot()).inventory, isEmpty);
    },
  );

  test(
    'History-only delete preserves opaque unrelated lists and legacy used data',
    () async {
      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'raw'),
        vehicleId: 'bus',
      );
      final prefs = await SharedPreferences.getInstance();
      final values = {
        'rewardInventory': ['opaque inventory'],
        'activeRewardGoals': ['opaque active'],
        'earnedRewardGoals': ['opaque earned'],
        'redeemedRewardGoals': ['opaque redeemed'],
        'usedRewardGoals': ['opaque used'],
      };
      for (final entry in values.entries) {
        await prefs.setStringList(entry.key, entry.value);
      }
      await service.deleteMealHistoryEntry('raw');
      for (final entry in values.entries) {
        expect(prefs.getStringList(entry.key), entry.value);
      }
    },
  );

  test(
    'Goal id collisions fail before writing, history-only delete remains available',
    () async {
      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'collision'),
        vehicleId: 'bus',
      );
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_goal('duplicate', 'collision').toJson());
      await prefs.setStringList('activeRewardGoals', [raw, raw]);
      final before = prefs.getStringList('mealHistory');
      await expectLater(
        service.deleteMealHistoryEntry('collision', deleteLinkedRewards: true),
        throwsA(isA<MealProgressDataException>()),
      );
      expect(prefs.getStringList('mealHistory'), before);
      expect(prefs.containsKey('mealCompletionJournal'), isFalse);
      await service.deleteMealHistoryEntry('collision');
      expect(prefs.getStringList('activeRewardGoals'), [raw, raw]);
    },
  );

  for (final corrupt in [
    42,
    <String>[''],
    'invalid',
  ]) {
    test(
      'Corrupt deleted IDs $corrupt block mutation without blocking snapshots',
      () async {
        final service = LocalMealProgressService();
        await service.recordMealResult(
          mealResult().copyWith(sessionId: 'safe'),
          vehicleId: 'bus',
        );
        final prefs = await SharedPreferences.getInstance();
        if (corrupt is int) {
          await prefs.setInt('deletedMealSessionIds', corrupt);
        } else if (corrupt is List<String>) {
          await prefs.setStringList('deletedMealSessionIds', corrupt);
        } else {
          await prefs.setString('deletedMealSessionIds', corrupt as String);
        }
        await expectLater(
          service.deleteMealHistoryEntry('safe'),
          throwsA(isA<MealProgressDataException>()),
        );
        await expectLater(
          service.recordMealResult(mealResult(), vehicleId: 'bus'),
          throwsA(isA<MealProgressDataException>()),
        );
        expect((await service.loadSnapshot()).history, hasLength(1));
        expect(prefs.get('deletedMealSessionIds'), corrupt);
      },
    );
  }

  test('Malformed journal is validated before any recovery write', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mealHistory', ['preserve']);
    await prefs.setString(
      'mealCompletionJournal',
      jsonEncode({
        'deletedMealSessionIds': [''],
        'mealHistory': <String>[],
        'rewardInventory': <String>[],
        'activeRewardGoals': <String>[],
        'earnedRewardGoals': <String>[],
      }),
    );
    await expectLater(
      LocalMealProgressService().loadSnapshot(),
      throwsA(isA<MealProgressDataException>()),
    );
    expect(prefs.getStringList('mealHistory'), ['preserve']);
  });

  test('Old journal and normal completions preserve deleted IDs', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('deletedMealSessionIds', ['old']);
    await prefs.setString(
      'mealCompletionJournal',
      jsonEncode({
        'mealHistory': <String>[],
        'rewardInventory': <String>[],
        'activeRewardGoals': <String>[],
        'earnedRewardGoals': <String>[],
      }),
    );
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult().copyWith(sessionId: 'new'),
      vehicleId: 'bus',
    );
    expect(prefs.getStringList('deletedMealSessionIds'), ['old']);
  });

  for (final linked in [false, true]) {
    for (final throwsError in [false, true]) {
      for (final key in [
        'mealCompletionJournal',
        'deletedMealSessionIds',
        'mealHistory',
        'rewardInventory',
        'activeRewardGoals',
        'earnedRewardGoals',
        'remove:activeRewardGoal',
        'remove:mealCompletionJournal',
      ]) {
        test(
          'Deletion recovers failure $key throws=$throwsError linked=$linked without double deduction',
          () async {
            final original = SharedPreferencesStorePlatform.instance;
            final disk = _FailOnceStore();
            SharedPreferencesStorePlatform.instance = disk;
            addTearDown(
              () => SharedPreferencesStorePlatform.instance = original,
            );
            final service = LocalMealProgressService();
            await service.recordMealResult(
              mealResult().copyWith(sessionId: 'fault'),
              vehicleId: 'bus',
            );
            disk.failKey = key;
            disk.throwsError = throwsError;
            await expectLater(
              service.deleteMealHistoryEntry(
                'fault',
                deleteLinkedRewards: linked,
              ),
              throwsA(anything),
            );
            await (await SharedPreferences.getInstance()).reload();
            final restarted = LocalMealProgressService();
            // Journal creation may have failed before a durable intent existed.
            await restarted.deleteMealHistoryEntry(
              'fault',
              deleteLinkedRewards: linked,
            );
            final snapshot = await restarted.loadSnapshot();
            expect(snapshot.history, isEmpty);
            expect(snapshot.inventory.length, linked ? 0 : 1);
            expect(
              (await SharedPreferences.getInstance()).containsKey(
                'mealCompletionJournal',
              ),
              isFalse,
            );
            await expectLater(
              restarted.recordMealResult(
                mealResult().copyWith(sessionId: 'fault'),
                vehicleId: 'bus',
              ),
              throwsA(isA<DeletedMealSessionException>()),
            );
          },
        );
      }
    }
  }

  test(
    'Linked delete rejects undecodable unrelated data without discarding it',
    () async {
      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'malformed'),
        vehicleId: 'bus',
      );
      final prefs = await SharedPreferences.getInstance();
      final values = [
        ...prefs.getStringList('rewardInventory')!,
        'malformed unrelated item',
      ];
      await prefs.setStringList('rewardInventory', values);
      await expectLater(
        service.deleteMealHistoryEntry('malformed', deleteLinkedRewards: true),
        throwsA(isA<MealProgressDataException>()),
      );
      expect(prefs.getStringList('rewardInventory'), values);
      expect(prefs.containsKey('mealCompletionJournal'), isFalse);
      expect((await service.loadSnapshot()).history, hasLength(1));
    },
  );

  test('Unrelated zero-count inventory is retained', () async {
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult().copyWith(sessionId: 'zero'),
      vehicleId: 'bus',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rewardInventory', [
      ...prefs.getStringList('rewardInventory')!,
      jsonEncode({
        'rewardId': 'unrelated',
        'count': 0,
        'acquiredAt': DateTime(2026).toIso8601String(),
      }),
    ]);
    await service.deleteMealHistoryEntry('zero', deleteLinkedRewards: true);
    expect(
      (await service.loadSnapshot()).inventory.single.rewardId,
      'unrelated',
    );
  });

  test(
    'Legacy earned goal is preserved by history-only delete and reversed by linked delete',
    () async {
      for (final linked in [false, true]) {
        SharedPreferences.setMockInitialValues({});
        final service = LocalMealProgressService();
        await service.recordMealResult(
          mealResult().copyWith(sessionId: 'legacy-earned'),
          vehicleId: 'bus',
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('activeRewardGoals');
        await prefs.remove('earnedRewardGoals');
        await prefs.setString(
          'activeRewardGoal',
          jsonEncode(
            _goal('legacy', 'legacy-earned')
                .copyWith(
                  requiredStickerCount: 1,
                  status: RewardGoalStatus.earned,
                  earnedAt: DateTime(2026),
                  readyAt: DateTime(2026),
                )
                .toJson(),
          ),
        );
        await service.deleteMealHistoryEntry(
          'legacy-earned',
          deleteLinkedRewards: linked,
        );
        final snapshot = await service.loadSnapshot();
        expect(snapshot.earnedRewardGoals.length, linked ? 0 : 1);
        expect(snapshot.activeRewardGoals.length, linked ? 1 : 0);
        expect(prefs.containsKey('activeRewardGoal'), isFalse);
      }
    },
  );

  test(
    'Deleting a meal unrelated to an earned goal does not revoke it',
    () async {
      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'unrelated'),
        vehicleId: 'bus',
      );
      await service.createRewardGoal(
        requiredStickerCount: 1,
        rewardText: 'Keep',
      );
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'earner'),
        vehicleId: 'bus',
      );
      final before = (await SharedPreferences.getInstance()).getStringList(
        'earnedRewardGoals',
      );
      await service.deleteMealHistoryEntry(
        'unrelated',
        deleteLinkedRewards: true,
      );
      expect(
        (await SharedPreferences.getInstance()).getStringList(
          'earnedRewardGoals',
        ),
        before,
      );
    },
  );

  test(
    'Journal can restore a corrupt deleted-ID key before mutation',
    () async {
      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'recover'),
        vehicleId: 'bus',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deletedMealSessionIds', 'broken');
      await prefs.setString(
        'mealCompletionJournal',
        jsonEncode({
          'deletedMealSessionIds': ['older'],
          for (final key in [
            'mealHistory',
            'rewardInventory',
            'activeRewardGoals',
            'earnedRewardGoals',
          ])
            key: prefs.getStringList(key) ?? <String>[],
        }),
      );
      await service.deleteMealHistoryEntry('recover');
      expect(prefs.getStringList('deletedMealSessionIds'), [
        'older',
        'recover',
      ]);
    },
  );

  test(
    'Multi-year deleted IDs retain replay protection across another deletion',
    () async {
      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult().copyWith(sessionId: 'last'),
        vehicleId: 'bus',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'deletedMealSessionIds',
        List.generate(11000, (index) => 'historical-$index'),
      );
      await service.deleteMealHistoryEntry('last');
      expect(prefs.getStringList('deletedMealSessionIds'), hasLength(11001));
    },
  );
}

RewardGoal _goal(String id, String mealId) => RewardGoal(
  id: id,
  rewardText: 'Park',
  requiredStickerCount: 5,
  filledSlots: [
    RewardGoalSlot(
      rewardId: 'sticker_vehicle_bus',
      filledAt: DateTime(2026),
      mealSessionId: mealId,
    ),
  ],
  createdAt: DateTime(2026),
  status: RewardGoalStatus.active,
);

class _FailOnceStore extends InMemorySharedPreferencesStore {
  _FailOnceStore() : super.empty();
  String? failKey;
  bool throwsError = false;
  bool _fails(String key) {
    if (key != failKey) return false;
    failKey = null;
    if (throwsError) throw StateError('Injected write failure');
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (_fails(key.replaceFirst('flutter.', ''))) return false;
    return super.setValue(valueType, key, value);
  }

  @override
  Future<bool> remove(String key) async {
    if (_fails('remove:${key.replaceFirst('flutter.', '')}')) return false;
    return super.remove(key);
  }
}
