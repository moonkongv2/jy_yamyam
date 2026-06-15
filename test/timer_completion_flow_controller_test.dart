import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/controllers/timer_completion_flow_controller.dart';
import 'package:jy_yamyam/models/meal_completion_status.dart';
import 'package:jy_yamyam/models/meal_session_result.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';

void main() {
  const controller = TimerCompletionFlowController();

  test('TimerCompletionFlowController decides incomplete result recording', () {
    expect(
      controller.shouldRecordIncompleteResult(
        confirmed: false,
        showFailureOnDecline: true,
      ),
      isTrue,
    );
    expect(
      controller.shouldRecordIncompleteResult(
        confirmed: null,
        showFailureOnDecline: true,
      ),
      isTrue,
    );
    expect(
      controller.shouldRecordIncompleteResult(
        confirmed: false,
        showFailureOnDecline: false,
      ),
      isFalse,
    );
    expect(
      controller.shouldRecordIncompleteResult(
        confirmed: true,
        showFailureOnDecline: true,
      ),
      isFalse,
    );
  });

  test('TimerCompletionFlowController returns completion statuses', () {
    expect(
      controller.completionStatusForConfirmedResult(showFailureOnDecline: true),
      MealCompletionStatus.completedAtArrival,
    );
    expect(
      controller.completionStatusForConfirmedResult(
        showFailureOnDecline: false,
      ),
      isNull,
    );
    expect(
      controller.completionStatusForIncompleteResult(),
      MealCompletionStatus.notCompleted,
    );
  });

  test('TimerCompletionFlowController decides finish drive from result', () {
    expect(
      controller.shouldStartFinishDrive(
        _mealResult(completedBeforeArrival: true),
      ),
      isTrue,
    );
    expect(
      controller.shouldStartFinishDrive(
        _mealResult(completedBeforeArrival: false),
      ),
      isFalse,
    );
  });

  test('TimerCompletionFlowController keeps manual selected ingredients', () {
    final result = controller.resultWithSelectedIngredients(
      result: _mealResult(),
      config: MealTimerConfig.defaults().copyWith(
        courseIngredientMode: CourseIngredientMode.manual,
        selectedCourseIngredientIds: const ['carrot', 'egg'],
      ),
    );

    expect(result.selectedIngredientIds, ['carrot', 'egg']);
  });

  test(
    'TimerCompletionFlowController clears non-manual selected ingredients',
    () {
      final result = controller.resultWithSelectedIngredients(
        result: _mealResult(selectedIngredientIds: const ['carrot']),
        config: MealTimerConfig.defaults().copyWith(
          courseIngredientMode: CourseIngredientMode.random,
        ),
      );

      expect(result.selectedIngredientIds, isEmpty);
    },
  );
}

MealSessionResult _mealResult({
  bool completedBeforeArrival = false,
  List<String> selectedIngredientIds = const [],
}) {
  return MealSessionResult(
    startedAt: DateTime.utc(2026, 6, 15, 10),
    endedAt: DateTime.utc(2026, 6, 15, 10, 20),
    targetDuration: const Duration(minutes: 20),
    actualDuration: const Duration(minutes: 20),
    completedBeforeArrival: completedBeforeArrival,
    selectedIngredientIds: selectedIngredientIds,
  );
}
