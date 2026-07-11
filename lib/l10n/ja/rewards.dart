// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaRewardTexts implements RewardTextSet {
  const JaRewardTexts();

  String get collectionTitle => 'のりものシール';
  String get lockedSticker => 'まだ集めていません';
  String get lockedStatus => 'ロック';
  String get uncollectedSemanticLabel => 'まだ集めていません';
  String get rewardGoalTitle => 'ごほうびの約束';
  String get createRewardGoal => 'ごほうびの約束を作る';
  String get rewardGoalEmptyTitle => '新しいごほうびの約束を作りましょう';
  String get rewardGoalEmptyBody => '食事を完了するたびにのりものシールをもらい、ごほうびボードが1マスずつ埋まります。';
  String get rewardGoalRewardFieldLabel => 'ごほうび';
  String get rewardGoalRequiredStickerCountLabel => '必要なシール数';
  String get rewardGoalSaveButton => '約束を保存';
  String get rewardGoalReadyMessage => 'ごほうびの準備ができました！';
  String get rewardGoalGivenButton => '使う';
  String get rewardGoalCreatedMessage => 'ごほうびの約束を保存しました。';
  String get rewardGoalUpdatedMessage => 'ごほうびの約束を更新しました。';
  String get rewardGoalCanceledMessage => 'ごほうびの約束をキャンセルしました。';
  String get rewardGoalRedeemedMessage => 'ごほうびの受け渡しを記録しました。';
  String get rewardGoalUsedMessage => 'ごほうびを使いました。';
  String get rewardGoalProgressTitle => 'ごほうびボード';
  String get rewardGoalEmptySlotSemanticLabel => '空のごほうびマス';
  String get openRewardGoal => 'ごほうびボードを見る';
  String get rewardGoalPromiseTitle => '今回のごほうび';
  String get activeRewardGoalsTitle => '進行中のごほうび約束';
  String get earnedRewardGoalsTitle => 'もらえるごほうび';
  String get usedRewardGoalsTitle => '使ったごほうび';
  String get maxActiveRewardGoalsMessage => '進行中のごほうび約束は2つまで作れます。';
  String get editRewardGoal => '約束を編集';
  String get cancelRewardGoal => '約束をキャンセル';
  String get rewardGoalHistoryTitle => '受け渡し履歴';
  String get rewardGoalNoHistory => 'まだ受け渡し済みのごほうびはありません。';
  String get confirmRedeemRewardGoalTitle => 'ごほうびを渡しましたか？';
  String get confirmRedeemRewardGoalMessage => '完了すると、この約束は受け渡し履歴に移動します。';
  String get confirmCancelRewardGoalTitle => 'ごほうびの約束をキャンセルしますか？';
  String get confirmCancelRewardGoalMessage => '現在のボードの進み具合が消えます。';
  String get keepRewardGoal => '続ける';
  String get confirmRewardGiven => '渡しました';
  String get confirmCancelGoal => '約束をキャンセル';
  String get confirmUseRewardGoalTitle => 'このごほうびを使いますか？';
  String get confirmUseRewardGoalMessage =>
      '使うと、もらえるごほうび一覧から消え、使ったごほうびに記録されます。';
  String get confirmUseRewardGoal => '使う';

  String stickerCount(int count) => '$count枚';
  String rewardGoalProgress(int filledCount, int requiredCount) =>
      '$filledCount/$requiredCount';
  String rewardGoalRemaining(int remainingCount) => 'あと$remainingCountマス';
  String rewardGoalSlotSemanticLabel(int slotNumber, String rewardName) =>
      '$slotNumber番目のごほうびマス、$rewardName';
  String rewardGoalReadyAt(String dateLabel) => '完了: $dateLabel';
  String rewardGoalRedeemedAt(String dateLabel) => '受け渡し: $dateLabel';
}
