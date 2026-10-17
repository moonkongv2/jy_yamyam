import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_history_entry.dart';
import '../models/meal_progress_snapshot.dart';
import '../models/meal_session_result.dart';
import '../models/reward_goal.dart';
import '../models/reward_item.dart';

class DeletedMealSessionException implements Exception {
  const DeletedMealSessionException();
}

class MealProgressDataException implements Exception {
  const MealProgressDataException();
}

class LocalMealProgressService {
  LocalMealProgressService();

  // Keep deleted IDs so a late completion cannot grant the same rewards again.
  static const _deletedSessionIdsKey = 'deletedMealSessionIds';
  static const _historyKey = 'mealHistory';
  static const _inventoryKey = 'rewardInventory';
  static const _legacyActiveRewardGoalKey = 'activeRewardGoal';
  static const _legacyRedeemedRewardGoalsKey = 'redeemedRewardGoals';
  static const _activeRewardGoalsKey = 'activeRewardGoals';
  static const _earnedRewardGoalsKey = 'earnedRewardGoals';
  static const _usedRewardGoalsKey = 'usedRewardGoals';
  static const maxActiveRewardGoals = 2;

  static const _completionJournalKey = 'mealCompletionJournal';
  // SharedPreferences instances identify one storage lifetime (including test resets).
  static final _operationQueues = Expando<Future<void>>();

  Future<T> _withPreferences<T>(
    Future<T> Function(SharedPreferences) operation,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final previous = _operationQueues[preferences] ?? Future<void>.value();
    final result = previous.then((_) async {
      await _recoverCompletion(preferences);
      return operation(preferences);
    });
    _operationQueues[preferences] = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return result;
  }

  void _requireWrite(bool success) {
    if (!success) throw StateError('Unable to persist meal completion.');
  }

  Future<void> _recoverCompletion(SharedPreferences preferences) async {
    final String? raw;
    try {
      raw = preferences.getString(_completionJournalKey);
    } catch (_) {
      throw const MealProgressDataException();
    }
    if (raw == null) return;
    final Map<String, dynamic> journal;
    final Map<String, List<String>> valuesByKey;
    try {
      journal = jsonDecode(raw) as Map<String, dynamic>;
      valuesByKey = {
        for (final key in [
          _historyKey,
          _inventoryKey,
          _activeRewardGoalsKey,
          _earnedRewardGoalsKey,
        ])
          key: List<String>.from(journal[key] as List),
      };
      // Older completion journals do not carry or overwrite deleted IDs.
      if (journal.containsKey(_deletedSessionIdsKey)) {
        valuesByKey[_deletedSessionIdsKey] = _validatedDeletedIds(
          journal[_deletedSessionIdsKey],
        ).toList();
      }
    } catch (_) {
      throw const MealProgressDataException();
    }
    if (valuesByKey.containsKey(_deletedSessionIdsKey)) {
      _requireWrite(
        await preferences.setStringList(
          _deletedSessionIdsKey,
          valuesByKey[_deletedSessionIdsKey]!,
        ),
      );
    }
    for (final key in [
      _historyKey,
      _inventoryKey,
      _activeRewardGoalsKey,
      _earnedRewardGoalsKey,
    ]) {
      final values = valuesByKey[key]!;
      _requireWrite(await preferences.setStringList(key, values));
    }
    _requireWrite(await preferences.remove(_legacyActiveRewardGoalKey));
    _requireWrite(await preferences.remove(_completionJournalKey));
  }

  Future<MealProgressSnapshot> loadSnapshot() async {
    return _withPreferences((preferences) async {
      return MealProgressSnapshot(
        history: _decodeList(
          preferences.getStringList(_historyKey),
          MealHistoryEntry.fromJson,
        ),
        inventory: _decodeList(
          preferences.getStringList(_inventoryKey),
          RewardInventoryItem.fromJson,
        ),
        activeRewardGoals: _loadActiveRewardGoals(preferences),
        earnedRewardGoals: _loadEarnedRewardGoals(preferences),
        usedRewardGoals: _loadUsedRewardGoals(preferences),
      );
    });
  }

  Future<RewardGoal?> loadActiveRewardGoal() async {
    return _withPreferences((preferences) async {
      final goals = _loadActiveRewardGoals(preferences);
      return goals.isEmpty ? null : goals.first;
    });
  }

  Future<List<RewardGoal>> loadActiveRewardGoals() async {
    return _withPreferences((preferences) async {
      return _loadActiveRewardGoals(preferences);
    });
  }

  Future<RewardGoal> createRewardGoal({
    required int requiredStickerCount,
    required String rewardText,
  }) async {
    return _withPreferences((preferences) async {
      final trimmedRewardText = rewardText.trim();
      if (trimmedRewardText.isEmpty) {
        throw ArgumentError.value(rewardText, 'rewardText');
      }

      final activeGoals = _loadActiveRewardGoals(preferences).toList();
      if (activeGoals.length >= maxActiveRewardGoals) {
        throw StateError('Up to two active reward goals are supported.');
      }

      final now = DateTime.now();
      final goal = RewardGoal(
        id: now.microsecondsSinceEpoch.toString(),
        rewardText: trimmedRewardText,
        requiredStickerCount: requiredStickerCount.clamp(1, 20).toInt(),
        filledSlots: const [],
        createdAt: now,
        status: RewardGoalStatus.active,
      );
      activeGoals.add(goal);
      await _saveRewardGoalList(
        preferences,
        _activeRewardGoalsKey,
        activeGoals,
      );
      await preferences.remove(_legacyActiveRewardGoalKey);
      return goal;
    });
  }

  Future<RewardGoal?> updateActiveRewardGoal({
    String? goalId,
    required int requiredStickerCount,
    required String rewardText,
  }) async {
    return _withPreferences((preferences) async {
      final trimmedRewardText = rewardText.trim();
      if (trimmedRewardText.isEmpty) {
        throw ArgumentError.value(rewardText, 'rewardText');
      }

      final activeGoals = _loadActiveRewardGoals(preferences).toList();
      if (activeGoals.isEmpty) {
        return null;
      }

      final targetIndex = goalId == null
          ? 0
          : activeGoals.indexWhere((goal) => goal.id == goalId);
      if (targetIndex == -1) {
        return null;
      }

      final activeGoal = activeGoals[targetIndex];
      final nextRequiredStickerCount = requiredStickerCount
          .clamp(1, 20)
          .toInt();
      final isEarned = activeGoal.filledCount >= nextRequiredStickerCount;
      final updatedGoal = activeGoal.copyWith(
        rewardText: trimmedRewardText,
        requiredStickerCount: nextRequiredStickerCount,
        status: isEarned ? RewardGoalStatus.earned : RewardGoalStatus.active,
        earnedAt: isEarned ? activeGoal.earnedAt ?? DateTime.now() : null,
        readyAt: isEarned ? activeGoal.readyAt ?? DateTime.now() : null,
      );
      if (isEarned) {
        activeGoals.removeAt(targetIndex);
        final earnedGoals = _loadEarnedRewardGoals(preferences).toList()
          ..insert(0, updatedGoal);
        await _saveRewardGoalList(
          preferences,
          _activeRewardGoalsKey,
          activeGoals,
        );
        await _saveRewardGoalList(
          preferences,
          _earnedRewardGoalsKey,
          earnedGoals,
        );
      } else {
        activeGoals[targetIndex] = updatedGoal;
        await _saveRewardGoalList(
          preferences,
          _activeRewardGoalsKey,
          activeGoals,
        );
      }
      await preferences.remove(_legacyActiveRewardGoalKey);
      return updatedGoal;
    });
  }

  Future<RewardGoal?> cancelActiveRewardGoal({String? goalId}) async {
    return _withPreferences((preferences) async {
      final activeGoals = _loadActiveRewardGoals(preferences).toList();
      if (activeGoals.isEmpty) {
        return null;
      }

      final targetIndex = goalId == null
          ? 0
          : activeGoals.indexWhere((goal) => goal.id == goalId);
      if (targetIndex == -1) {
        return null;
      }

      final canceledGoal = activeGoals.removeAt(targetIndex);
      await _saveRewardGoalList(
        preferences,
        _activeRewardGoalsKey,
        activeGoals,
      );
      await preferences.remove(_legacyActiveRewardGoalKey);
      return canceledGoal;
    });
  }

  Future<RewardGoal?> redeemActiveRewardGoal() async {
    return useEarnedRewardGoal();
  }

  Future<RewardGoal?> useEarnedRewardGoal({String? goalId}) async {
    return _withPreferences((preferences) async {
      final earnedGoals = _loadEarnedRewardGoals(preferences).toList();
      if (earnedGoals.isEmpty) {
        return null;
      }

      final targetIndex = goalId == null
          ? 0
          : earnedGoals.indexWhere((goal) => goal.id == goalId);
      if (targetIndex == -1) {
        return null;
      }

      final earnedGoal = earnedGoals.removeAt(targetIndex);
      final usedGoal = earnedGoal.copyWith(
        status: RewardGoalStatus.used,
        usedAt: DateTime.now(),
        redeemedAt: DateTime.now(),
      );
      final usedGoals = _loadUsedRewardGoals(preferences).toList()
        ..insert(0, usedGoal);

      await _saveRewardGoalList(
        preferences,
        _earnedRewardGoalsKey,
        earnedGoals,
      );
      await _saveRewardGoalList(preferences, _usedRewardGoalsKey, usedGoals);
      return usedGoal;
    });
  }

  Future<void> clearActiveRewardGoal() async {
    return _withPreferences((preferences) async {
      await preferences.remove(_legacyActiveRewardGoalKey);
      await preferences.remove(_activeRewardGoalsKey);
    });
  }

  Set<String> _validatedDeletedIds(Object? raw) {
    if (raw is! List || raw.any((id) => id is! String || id.trim().isEmpty)) {
      throw const MealProgressDataException();
    }
    return raw.cast<String>().toSet();
  }

  Set<String> _loadDeletedIds(SharedPreferences preferences) {
    try {
      if (!preferences.containsKey(_deletedSessionIdsKey)) return {};
      return _validatedDeletedIds(preferences.get(_deletedSessionIdsKey));
    } catch (_) {
      throw const MealProgressDataException();
    }
  }

  Future<bool> hasLinkedMealRewards(String entryId) {
    return _withPreferences((preferences) async {
      final history = _decodeList(
        preferences.getStringList(_historyKey),
        MealHistoryEntry.fromJson,
      );
      return history.any(
            (entry) => entry.id == entryId && entry.rewardIds.isNotEmpty,
          ) ||
          [
            ..._loadActiveRewardGoals(preferences),
            ..._loadEarnedRewardGoals(preferences),
          ].any(
            (goal) =>
                goal.filledSlots.any((slot) => slot.mealSessionId == entryId),
          );
    });
  }

  Future<bool> deleteMealHistoryEntry(
    String entryId, {
    bool deleteLinkedRewards = false,
  }) async {
    return _withPreferences((preferences) async {
      final history = _decodeList(
        preferences.getStringList(_historyKey),
        MealHistoryEntry.fromJson,
      ).toList();
      final index = history.indexWhere((entry) => entry.id == entryId);
      if (index == -1) return false;
      final deletedIds = _loadDeletedIds(preferences)..add(entryId);
      final entry = history.removeAt(index);
      var inventoryValues =
          preferences.getStringList(_inventoryKey) ?? <String>[];
      var activeValues =
          preferences.getStringList(_activeRewardGoalsKey) ??
          _loadActiveRewardGoals(
            preferences,
          ).map((goal) => jsonEncode(goal.toJson())).toList();
      var earnedValues =
          preferences.getStringList(_earnedRewardGoalsKey) ??
          _loadEarnedRewardGoals(
            preferences,
          ).map((goal) => jsonEncode(goal.toJson())).toList();

      if (deleteLinkedRewards) {
        final active = _loadActiveRewardGoals(preferences);
        final earned = _loadEarnedRewardGoals(preferences);
        final goalIds = <String>{};
        for (final goal in [...active, ...earned]) {
          if (!goalIds.add(goal.id)) throw const MealProgressDataException();
        }
        final deductions = <String, int>{};
        for (final id in entry.rewardIds) {
          deductions[id] = (deductions[id] ?? 0) + 1;
        }
        final inventory = _decodeList(
          inventoryValues,
          RewardInventoryItem.fromJson,
        );
        if (inventory.length != inventoryValues.length ||
            active.length != activeValues.length ||
            earned.length != earnedValues.length) {
          throw const MealProgressDataException();
        }
        final nextInventory = <RewardInventoryItem>[];
        for (final item in inventory) {
          final deduction = deductions.remove(item.rewardId) ?? 0;
          if (deduction == 0) {
            nextInventory.add(item);
          } else {
            final count = item.count - deduction;
            if (count > 0) nextInventory.add(item.copyWith(count: count));
          }
        }
        final nextActive = <RewardGoal>[];
        final nextEarned = <RewardGoal>[];
        for (final goal in [...active, ...earned]) {
          final slots = goal.filledSlots
              .where((slot) => slot.mealSessionId != entryId)
              .toList();
          final changed = slots.length != goal.filledSlots.length;
          final revert =
              changed &&
              goal.isReady &&
              slots.length < goal.requiredStickerCount;
          final updated = !changed
              ? goal
              : goal.copyWith(
                  filledSlots: slots,
                  status: revert ? RewardGoalStatus.active : goal.status,
                  earnedAt: revert ? null : goal.earnedAt,
                  readyAt: revert ? null : goal.readyAt,
                );
          if (updated.isReady) {
            nextEarned.add(updated);
          } else {
            nextActive.add(updated);
          }
        }
        inventoryValues = nextInventory
            .map((item) => jsonEncode(item.toJson()))
            .toList();
        activeValues = nextActive
            .map((goal) => jsonEncode(goal.toJson()))
            .toList();
        earnedValues = nextEarned
            .map((goal) => jsonEncode(goal.toJson()))
            .toList();
      }
      final journal = <String, Object?>{
        _deletedSessionIdsKey: deletedIds.toList(),
        _historyKey: history
            .map((entry) => jsonEncode(entry.toJson()))
            .toList(),
        _inventoryKey: inventoryValues,
        _activeRewardGoalsKey: activeValues,
        _earnedRewardGoalsKey: earnedValues,
      };
      _requireWrite(
        await preferences.setString(_completionJournalKey, jsonEncode(journal)),
      );
      await _recoverCompletion(preferences);
      return true;
    });
  }

  Future<RecordedMealSession> recordMealResult(
    MealSessionResult result, {
    required String vehicleId,
  }) async {
    return _withPreferences((preferences) async {
      final sessionId =
          result.sessionId ?? result.endedAt.microsecondsSinceEpoch.toString();
      if (_loadDeletedIds(preferences).contains(sessionId)) {
        throw const DeletedMealSessionException();
      }
      final history = _decodeList(
        preferences.getStringList(_historyKey),
        MealHistoryEntry.fromJson,
      ).toList();
      final inventory = _decodeList(
        preferences.getStringList(_inventoryKey),
        RewardInventoryItem.fromJson,
      ).toList();
      final activeRewardGoals = _loadActiveRewardGoals(preferences).toList();
      final earnedRewardGoals = _loadEarnedRewardGoals(preferences).toList();

      if (result.sessionId != null) {
        final existing = history
            .where((entry) => entry.id == sessionId)
            .firstOrNull;
        if (existing != null) {
          final relatedActive = activeRewardGoals
              .where(
                (goal) => goal.filledSlots.any(
                  (slot) => slot.mealSessionId == existing.id,
                ),
              )
              .toList();
          final relatedEarned = earnedRewardGoals
              .where(
                (goal) => goal.filledSlots.any(
                  (slot) => slot.mealSessionId == existing.id,
                ),
              )
              .toList();
          return RecordedMealSession(
            entry: existing,
            awardedRewards: existing.rewardIds
                .map(RewardCatalog.findById)
                .whereType<RewardDefinition>()
                .toList(),
            updatedRewardGoals: relatedActive,
            earnedRewardGoals: relatedEarned,
            inventory: inventory,
          );
        }
      }

      final awardedRewards = _selectRewards(result, vehicleId: vehicleId);
      final entry = MealHistoryEntry(
        id: sessionId,
        startedAt: result.startedAt,
        endedAt: result.endedAt,
        targetDuration: result.targetDuration,
        actualDuration: result.actualDuration,
        completedBeforeArrival: result.completedBeforeArrival,
        mealCompleted: result.mealCompleted,
        completionStatus: result.completionStatus,
        rewardIds: awardedRewards.map((reward) => reward.id).toList(),
        selectedIngredientIds: result.selectedIngredientIds,
      );

      history.insert(0, entry);
      _addRewardsToInventory(inventory, awardedRewards, result.endedAt);
      final goalUpdate = _fillRewardGoalSlotsIfEligible(
        goals: activeRewardGoals,
        awardedRewards: awardedRewards,
        result: result,
        mealSessionId: entry.id,
      );

      if (goalUpdate.changed) {
        earnedRewardGoals.insertAll(0, goalUpdate.earnedGoals);
      }
      final journal = <String, Object?>{
        _historyKey: history
            .map((entry) => jsonEncode(entry.toJson()))
            .toList(),
        _inventoryKey: inventory
            .map((item) => jsonEncode(item.toJson()))
            .toList(),
        _activeRewardGoalsKey: goalUpdate.activeGoals
            .map((goal) => jsonEncode(goal.toJson()))
            .toList(),
        _earnedRewardGoalsKey: earnedRewardGoals
            .map((goal) => jsonEncode(goal.toJson()))
            .toList(),
      };
      _requireWrite(
        await preferences.setString(_completionJournalKey, jsonEncode(journal)),
      );
      await _recoverCompletion(preferences);

      return RecordedMealSession(
        entry: entry,
        awardedRewards: awardedRewards,
        updatedRewardGoals: goalUpdate.updatedGoals,
        earnedRewardGoals: goalUpdate.earnedGoals,
        inventory: inventory,
      );
    });
  }

  List<RewardDefinition> _selectRewards(
    MealSessionResult result, {
    required String vehicleId,
  }) {
    if (!result.mealCompleted) {
      return const [];
    }

    final sticker = RewardCatalog.findVehicleStickerByVehicleId(vehicleId);
    return sticker == null ? const [] : [sticker];
  }

  void _addRewardsToInventory(
    List<RewardInventoryItem> inventory,
    List<RewardDefinition> rewards,
    DateTime acquiredAt,
  ) {
    for (final reward in rewards) {
      final index = inventory.indexWhere((item) => item.rewardId == reward.id);
      if (index == -1) {
        inventory.add(
          RewardInventoryItem(
            rewardId: reward.id,
            acquiredAt: acquiredAt,
            count: 1,
          ),
        );
        continue;
      }

      final item = inventory[index];
      inventory[index] = item.copyWith(count: item.count + 1);
    }
  }

  _RewardGoalUpdate _fillRewardGoalSlotsIfEligible({
    required List<RewardGoal> goals,
    required List<RewardDefinition> awardedRewards,
    required MealSessionResult result,
    required String mealSessionId,
  }) {
    if (goals.isEmpty || !result.mealCompleted) {
      return _RewardGoalUpdate(activeGoals: goals);
    }

    final slotReward = _rewardGoalSlotReward(awardedRewards);
    if (slotReward == null) {
      return _RewardGoalUpdate(activeGoals: goals);
    }

    final activeGoals = <RewardGoal>[];
    final updatedGoals = <RewardGoal>[];
    final earnedGoals = <RewardGoal>[];

    for (final goal in goals) {
      if (goal.status != RewardGoalStatus.active ||
          goal.filledCount >= goal.requiredStickerCount) {
        activeGoals.add(goal);
        continue;
      }

      final filledSlots = [
        ...goal.filledSlots,
        RewardGoalSlot(
          rewardId: slotReward.id,
          filledAt: result.endedAt,
          mealSessionId: mealSessionId,
        ),
      ];
      final becameEarned = filledSlots.length >= goal.requiredStickerCount;
      final updatedGoal = goal.copyWith(
        filledSlots: filledSlots,
        status: becameEarned
            ? RewardGoalStatus.earned
            : RewardGoalStatus.active,
        earnedAt: becameEarned ? result.endedAt : goal.earnedAt,
        readyAt: becameEarned ? result.endedAt : goal.readyAt,
      );

      if (becameEarned) {
        earnedGoals.add(updatedGoal);
      } else {
        activeGoals.add(updatedGoal);
        updatedGoals.add(updatedGoal);
      }
    }

    return _RewardGoalUpdate(
      activeGoals: activeGoals,
      updatedGoals: updatedGoals,
      earnedGoals: earnedGoals,
      changed: updatedGoals.isNotEmpty || earnedGoals.isNotEmpty,
    );
  }

  RewardDefinition? _rewardGoalSlotReward(List<RewardDefinition> rewards) {
    for (final reward in rewards) {
      if (reward.type == RewardType.sticker) {
        return reward;
      }
    }
    return null;
  }

  List<RewardGoal> _loadActiveRewardGoals(SharedPreferences preferences) {
    final rawGoals = preferences.getStringList(_activeRewardGoalsKey);
    if (rawGoals != null) {
      return _decodeRewardGoalList(
        rawGoals,
      ).where((goal) => goal.status == RewardGoalStatus.active).toList();
    }

    final legacyGoal = _decodeRewardGoal(
      preferences,
      _legacyActiveRewardGoalKey,
    );
    if (legacyGoal == null || legacyGoal.status != RewardGoalStatus.active) {
      return <RewardGoal>[];
    }
    return [legacyGoal];
  }

  List<RewardGoal> _loadEarnedRewardGoals(SharedPreferences preferences) {
    final rawGoals = preferences.getStringList(_earnedRewardGoalsKey);
    if (rawGoals != null) {
      return _decodeRewardGoalList(
        rawGoals,
      ).where((goal) => goal.status == RewardGoalStatus.earned).toList();
    }

    final legacyGoal = _decodeRewardGoal(
      preferences,
      _legacyActiveRewardGoalKey,
    );
    if (legacyGoal == null || !legacyGoal.isReady) {
      return <RewardGoal>[];
    }
    return [
      legacyGoal.copyWith(
        status: RewardGoalStatus.earned,
        earnedAt: legacyGoal.earnedAt ?? legacyGoal.readyAt,
      ),
    ];
  }

  List<RewardGoal> _loadUsedRewardGoals(SharedPreferences preferences) {
    final rawGoals = preferences.getStringList(_usedRewardGoalsKey);
    if (rawGoals != null) {
      return _decodeRewardGoalList(
        rawGoals,
      ).where((goal) => goal.isUsed).toList();
    }

    return _decodeRewardGoalList(
          preferences.getStringList(_legacyRedeemedRewardGoalsKey),
        )
        .map(
          (goal) => goal.copyWith(
            status: RewardGoalStatus.used,
            usedAt: goal.usedAt ?? goal.redeemedAt,
          ),
        )
        .toList();
  }

  RewardGoal? _decodeRewardGoal(SharedPreferences preferences, String key) {
    final rawGoal = preferences.getString(key);
    if (rawGoal == null || rawGoal.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawGoal);
      if (decoded is Map) {
        return RewardGoal.tryFromJson(Map<String, Object?>.from(decoded));
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  List<RewardGoal> _decodeRewardGoalList(List<String>? rawItems) {
    if (rawItems == null) {
      return <RewardGoal>[];
    }

    final goals = <RewardGoal>[];
    for (final rawItem in rawItems) {
      try {
        final decoded = jsonDecode(rawItem);
        if (decoded is Map) {
          final goal = RewardGoal.tryFromJson(
            Map<String, Object?>.from(decoded),
          );
          if (goal != null) {
            goals.add(goal);
          }
        }
      } catch (_) {
        continue;
      }
    }
    return goals;
  }

  Future<void> _saveRewardGoalList(
    SharedPreferences preferences,
    String key,
    List<RewardGoal> goals,
  ) {
    return preferences.setStringList(
      key,
      goals.map((goal) => jsonEncode(goal.toJson())).toList(),
    );
  }

  List<T> _decodeList<T>(
    List<String>? rawItems,
    T Function(Map<String, Object?> json) fromJson,
  ) {
    if (rawItems == null) {
      return <T>[];
    }

    final items = <T>[];
    for (final rawItem in rawItems) {
      try {
        final decoded = jsonDecode(rawItem);
        if (decoded is Map) {
          items.add(fromJson(Map<String, Object?>.from(decoded)));
        }
      } catch (_) {
        continue;
      }
    }
    return items;
  }
}

class _RewardGoalUpdate {
  const _RewardGoalUpdate({
    required this.activeGoals,
    this.updatedGoals = const [],
    this.earnedGoals = const [],
    this.changed = false,
  });

  final List<RewardGoal> activeGoals;
  final List<RewardGoal> updatedGoals;
  final List<RewardGoal> earnedGoals;
  final bool changed;
}
