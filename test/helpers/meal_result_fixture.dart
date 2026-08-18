import 'package:jy_yamyam/models/meal_completion_status.dart';
import 'package:jy_yamyam/models/meal_session_result.dart';

MealSessionResult mealResult({
  DateTime? startedAt,
  DateTime? endedAt,
  Duration targetDuration = const Duration(minutes: 20),
  Duration actualDuration = const Duration(minutes: 25),
  bool completedBeforeArrival = false,
  bool mealCompleted = true,
  MealCompletionStatus? completionStatus,
  List<String> selectedIngredientIds = const [],
}) {
  final resolvedStartedAt = startedAt ?? DateTime(2026, 5, 4, 12);
  final resolvedEndedAt = endedAt ?? resolvedStartedAt.add(actualDuration);

  return MealSessionResult(
    startedAt: resolvedStartedAt,
    endedAt: resolvedEndedAt,
    targetDuration: targetDuration,
    actualDuration: actualDuration,
    completedBeforeArrival: completedBeforeArrival,
    mealCompleted: mealCompleted,
    completionStatus: completionStatus,
    selectedIngredientIds: selectedIngredientIds,
  );
}
