import '../models/meal_completion_status.dart';
import '../models/meal_session_result.dart';
import '../models/meal_timer_config.dart';

class TimerCompletionFlowController {
  const TimerCompletionFlowController();

  bool shouldRecordIncompleteResult({
    required bool? confirmed,
    required bool showFailureOnDecline,
  }) {
    return confirmed != true && showFailureOnDecline;
  }

  MealCompletionStatus? completionStatusForConfirmedResult({
    required bool showFailureOnDecline,
  }) {
    return showFailureOnDecline
        ? MealCompletionStatus.completedAtArrival
        : null;
  }

  MealCompletionStatus completionStatusForIncompleteResult() {
    return MealCompletionStatus.notCompleted;
  }

  bool shouldStartFinishDrive(MealSessionResult result) {
    return result.completedBeforeArrival;
  }

  MealSessionResult resultWithSelectedIngredients({
    required MealSessionResult result,
    required MealTimerConfig config,
  }) {
    if (config.courseIngredientMode != CourseIngredientMode.manual) {
      return result.copyWith(selectedIngredientIds: const []);
    }

    return result.copyWith(
      selectedIngredientIds: config.selectedCourseIngredientIds,
    );
  }
}
