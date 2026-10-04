import 'meal_completion_status.dart';

class MealSessionResult {
  const MealSessionResult({
    required this.startedAt,
    required this.endedAt,
    required this.targetDuration,
    required this.actualDuration,
    required this.completedBeforeArrival,
    this.sessionId,
    this.mealCompleted = true,
    this.selectedIngredientIds = const [],
    MealCompletionStatus? completionStatus,
  }) : completionStatus =
           completionStatus ??
           (mealCompleted
               ? (completedBeforeArrival
                     ? MealCompletionStatus.completedBeforeArrival
                     : MealCompletionStatus.completedAfterArrival)
               : MealCompletionStatus.notCompleted);

  final String? sessionId;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration targetDuration;
  final Duration actualDuration;
  final bool completedBeforeArrival;
  final bool mealCompleted;
  final List<String> selectedIngredientIds;
  final MealCompletionStatus completionStatus;

  MealSessionResult copyWith({
    List<String>? selectedIngredientIds,
    String? sessionId,
  }) {
    return MealSessionResult(
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt,
      endedAt: endedAt,
      targetDuration: targetDuration,
      actualDuration: actualDuration,
      completedBeforeArrival: completedBeforeArrival,
      mealCompleted: mealCompleted,
      selectedIngredientIds:
          selectedIngredientIds ?? this.selectedIngredientIds,
      completionStatus: completionStatus,
    );
  }

  Map<String, Object?> toJson() => {
    'sessionId': sessionId,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'targetDuration': targetDuration.inMicroseconds,
    'actualDuration': actualDuration.inMicroseconds,
    'completedBeforeArrival': completedBeforeArrival,
    'mealCompleted': mealCompleted,
    'completionStatus': completionStatus.name,
    'selectedIngredientIds': selectedIngredientIds,
  };

  factory MealSessionResult.fromJson(Map<String, Object?> json) =>
      MealSessionResult(
        sessionId: json['sessionId'] as String?,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        targetDuration: Duration(microseconds: json['targetDuration'] as int),
        actualDuration: Duration(microseconds: json['actualDuration'] as int),
        completedBeforeArrival: json['completedBeforeArrival'] as bool,
        mealCompleted: json['mealCompleted'] as bool,
        completionStatus: mealCompletionStatusFromJson(
          json['completionStatus'],
          completedBeforeArrival: json['completedBeforeArrival'] as bool,
          mealCompleted: json['mealCompleted'] as bool,
        ),
        selectedIngredientIds: (json['selectedIngredientIds'] as List)
            .cast<String>(),
      );
}
