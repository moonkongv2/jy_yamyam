// ignore_for_file: annotate_overrides

import '../text_sets.dart';
import '../../models/meal_completion_status.dart';

class EnMealHistoryTexts implements MealHistoryTextSet {
  const EnMealHistoryTexts();

  String get title => 'Meal Records';
  String get emptyTitle => 'No meal records yet';
  String get emptyBody => 'Completed timer sessions will appear here.';
  String get helpTitle => 'Meal history guide';
  List<String> get helpBulletItems => const [
    'Meal history shows target time, actual time, completion status, and earned stickers.',
    'Manually chosen ingredients appear when they were saved with the meal.',
    'Auto-selected ingredients appear on the road only and are not saved in history.',
    'Incomplete meals may show no stickers.',
    'Deleting a meal record keeps its earned stickers and rewards by default.',
    'If the meal has linked stickers or reward board slots, you can select “Also remove stickers earned from this meal” to remove them from the collection and linked reward boards.',
    'Unused rewards return to an in-progress state if they fall below their goal after removal. Rewards already used stay unchanged.',
    'If you delete only the record, you cannot later use that record to remove its stickers.',
  ];
  String get targetTimeLabel => 'Target';
  String get actualTimeLabel => 'Actual';
  String get rewardLabel => 'Stickers earned';
  String get noRewardLabel => 'No stickers';
  String get selectedIngredientLabel => 'Chosen ingredients';
  String get deleteRecordLabel => 'Delete meal record';
  String get deleteRecordDialogTitle => 'Delete this meal record?';
  String get deleteRecordDialogBody =>
      'Only the record will be removed. Earned stickers will stay.';
  String get deleteRecordConfirmLabel => 'Delete';
  String get deleteRecordSuccessMessage => 'Meal record deleted.';

  String get deleteLinkedRewardsLabel =>
      "Also remove stickers earned from this meal";
  String get deleteLinkedRewardsBody =>
      "Stickers will be removed from your collection and reward boards. Unused rewards may lose their earned status. Rewards already used will stay.";
  String get deleteRecordOnlyWarning =>
      "If you delete only the record, you cannot remove its stickers from this record later.";
  String get deleteRecordError =>
      "Saving could not be completed. Please try again.";
  String get deleteRecordDataError =>
      "Changes cannot be saved because there is a problem with the stored data. Please check your data.";
  String get deletedMealMessage => "This meal has already been deleted.";

  String completedStatus(MealCompletionStatus completionStatus) {
    return completionStatus == MealCompletionStatus.notCompleted
        ? 'Incomplete'
        : 'Complete';
  }

  String dateLabel(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.month}/${dateTime.day} $hour:$minute';
  }
}
