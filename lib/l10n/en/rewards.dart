// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EnRewardTexts implements RewardTextSet {
  const EnRewardTexts();

  String get collectionTitle => 'Sticker Collection';
  String get lockedSticker => 'Not collected yet';
  String get lockedStatus => 'Locked';
  String get uncollectedSemanticLabel => 'Not collected yet';
  String get rewardGoalTitle => 'Reward Goal';
  String get createRewardGoal => 'Create Reward Goal';
  String get rewardGoalEmptyTitle => 'Create a new reward goal';
  String get rewardGoalEmptyBody =>
      'Each completed meal earns a sticker and fills one spot on the reward board.';
  String get rewardGoalRewardFieldLabel => 'Reward';
  String get rewardGoalRequiredStickerCountLabel => 'Stickers needed';
  String get rewardGoalSaveButton => 'Save Goal';
  String get rewardGoalReadyMessage => 'Your reward is ready!';
  String get rewardGoalGivenButton => 'Give Reward';
  String get rewardGoalCreatedMessage => 'Reward goal saved.';
  String get rewardGoalUpdatedMessage => 'Reward goal updated.';
  String get rewardGoalCanceledMessage => 'Reward goal canceled.';
  String get rewardGoalRedeemedMessage => 'Reward given.';
  String get rewardGoalUsedMessage => 'Reward given.';
  String get rewardGoalProgressTitle => 'Reward Board';
  String get rewardGoalEmptySlotSemanticLabel => 'Empty reward slot';
  String get openRewardGoal => 'View Reward Board';
  String get rewardGoalPromiseTitle => 'Current Goal';
  String get activeRewardGoalsTitle => 'Active Reward Goals';
  String get earnedRewardGoalsTitle => 'Earned Rewards';
  String get usedRewardGoalsTitle => 'Given Rewards';
  String get maxActiveRewardGoalsMessage =>
      'You can keep up to 2 active reward goals.';
  String get editRewardGoal => 'Edit Goal';
  String get cancelRewardGoal => 'Cancel Goal';
  String get rewardGoalHistoryTitle => 'Reward History';
  String get rewardGoalNoHistory => 'No rewards have been given yet.';
  String get confirmRedeemRewardGoalTitle => 'Was the reward given?';
  String get confirmRedeemRewardGoalMessage =>
      'This reward will move to reward history.';
  String get confirmCancelRewardGoalTitle => 'Cancel this reward goal?';
  String get confirmCancelRewardGoalMessage =>
      'The current board progress will be removed.';
  String get keepRewardGoal => 'Keep Goal';
  String get confirmRewardGiven => 'Mark Given';
  String get confirmCancelGoal => 'Cancel Goal';
  String get confirmUseRewardGoalTitle => 'Give this reward?';
  String get confirmUseRewardGoalMessage =>
      'It will move from earned rewards to given rewards.';
  String get confirmUseRewardGoal => 'Give Reward';

  String stickerCount(int count) => '$count';
  String rewardGoalProgress(int filledCount, int requiredCount) =>
      '$filledCount/$requiredCount';
  String rewardGoalRemaining(int remainingCount) =>
      '$remainingCount spots left';
  String rewardGoalSlotSemanticLabel(int slotNumber, String rewardName) =>
      'Reward slot $slotNumber, $rewardName';
  String rewardGoalReadyAt(String dateLabel) => 'Ready: $dateLabel';
  String rewardGoalRedeemedAt(String dateLabel) => 'Given: $dateLabel';
}
