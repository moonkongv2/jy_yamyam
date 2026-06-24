import 'package:flutter_test/flutter_test.dart';
import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/models/meal_history_entry.dart';
import 'package:jy_yamyam/models/meal_progress_snapshot.dart';
import 'package:jy_yamyam/models/reward_item.dart';

void main() {
  test('RecordedMealSession sticker type count ignores unknown rewards', () {
    final recordedSession = RecordedMealSession(
      entry: MealHistoryEntry(
        id: 'meal-1',
        startedAt: DateTime(2026, 5, 5, 12),
        endedAt: DateTime(2026, 5, 5, 12, 20),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 20),
        completedBeforeArrival: true,
        mealCompleted: true,
        rewardIds: const ['sticker_vehicle_supercar'],
        selectedIngredientIds: const [],
      ),
      awardedRewards: const [],
      updatedRewardGoals: const [],
      earnedRewardGoals: const [],
      inventory: [
        RewardInventoryItem(
          rewardId: 'legacy_sticker_unknown',
          acquiredAt: DateTime(2026, 5, 3, 12),
          count: 9,
        ),
        RewardInventoryItem(
          rewardId: 'sticker_vehicle_motorcycle',
          acquiredAt: DateTime(2026, 5, 4, 12),
          count: 2,
        ),
        RewardInventoryItem(
          rewardId: 'sticker_vehicle_supercar',
          acquiredAt: DateTime(2026, 5, 5, 12),
          count: 1,
        ),
      ],
    );

    expect(recordedSession.collectedStickerTypeCount, 2);
    expect(recordedSession.totalStickerTypeCount, VehicleCatalog.all.length);
  });
}
