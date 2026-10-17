// ignore_for_file: annotate_overrides

import '../../models/meal_completion_status.dart';
import '../text_sets.dart';

class JaMealHistoryTexts implements MealHistoryTextSet {
  const JaMealHistoryTexts();

  String get title => '食事記録';
  String get emptyTitle => 'まだ食事記録がありません';
  String get emptyBody => 'タイマーを完了すると、ここに記録がたまります。';
  String get helpTitle => '食事記録について';
  List<String> get helpBulletItems => const [
    '食事記録には、目標時間、実際の時間、完了状態、もらったのりものシールが表示されます。',
    '自分で選んだ食材がある場合は、記録にも表示されます。',
    '自動選択の食材は道にだけ表示され、記録には残りません。',
    '未完了の記録は、のりものシールなしと表示されることがあります。',
  ];
  String get targetTimeLabel => '目標';
  String get actualTimeLabel => '実際';
  String get rewardLabel => 'もらったシール';
  String get noRewardLabel => 'シールなし';
  String get selectedIngredientLabel => '選んだ食材';
  String get deleteRecordLabel => '食事記録を削除';
  String get deleteRecordDialogTitle => 'この食事記録を削除しますか？';
  String get deleteRecordDialogBody => '記録だけが削除され、もらったシールは残ります。';
  String get deleteRecordConfirmLabel => '削除';
  String get deleteRecordSuccessMessage => '食事記録を削除しました。';

  String get deleteLinkedRewardsLabel => "この食事でもらったシールも削除する";
  String get deleteLinkedRewardsBody =>
      "シールコレクションとごほうびボードからも減ります。未使用のごほうびは達成が取り消される場合があります。使用済みのごほうびは残ります。";
  String get deleteRecordOnlyWarning =>
      "記録だけを削除すると、あとからこの記録のシールをまとめて削除することはできません。";
  String get deleteRecordError => "保存を完了できませんでした。もう一度お試しください。";
  String get deleteRecordDataError => "保存データに問題があるため変更できません。データをご確認ください。";
  String get deletedMealMessage => "この食事はすでに削除されています。";

  String completedStatus(MealCompletionStatus completionStatus) {
    return completionStatus == MealCompletionStatus.notCompleted ? '未完了' : '完了';
  }

  String dateLabel(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.month}/${dateTime.day} $hour:$minute';
  }
}
