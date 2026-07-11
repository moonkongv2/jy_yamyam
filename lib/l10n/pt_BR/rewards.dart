// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrRewardTexts implements RewardTextSet {
  const PtBrRewardTexts();

  String get collectionTitle => 'Coleção de adesivos';
  String get lockedSticker => 'Ainda não coletado';
  String get lockedStatus => 'Bloqueado';
  String get uncollectedSemanticLabel => 'Ainda não coletado';
  String get rewardGoalTitle => 'Meta de recompensa';
  String get createRewardGoal => 'Criar meta de recompensa';
  String get rewardGoalEmptyTitle => 'Crie uma nova meta';
  String get rewardGoalEmptyBody =>
      'Cada refeição concluída dá um adesivo de veículo e preenche um espaço do quadro.';
  String get rewardGoalRewardFieldLabel => 'Recompensa';
  String get rewardGoalRequiredStickerCountLabel => 'Adesivos necessários';
  String get rewardGoalSaveButton => 'Salvar meta';
  String get rewardGoalReadyMessage => 'A recompensa está pronta!';
  String get rewardGoalGivenButton => 'Usar';
  String get rewardGoalCreatedMessage => 'Meta salva.';
  String get rewardGoalUpdatedMessage => 'Meta atualizada.';
  String get rewardGoalCanceledMessage => 'Meta cancelada.';
  String get rewardGoalRedeemedMessage => 'Entrega da recompensa registrada.';
  String get rewardGoalUsedMessage => 'Recompensa usada.';
  String get rewardGoalProgressTitle => 'Quadro de recompensas';
  String get rewardGoalEmptySlotSemanticLabel => 'Espaço de recompensa vazio';
  String get openRewardGoal => 'Ver quadro';
  String get rewardGoalPromiseTitle => 'Recompensa atual';
  String get activeRewardGoalsTitle => 'Metas ativas';
  String get earnedRewardGoalsTitle => 'Recompensas ganhas';
  String get usedRewardGoalsTitle => 'Recompensas usadas';
  String get maxActiveRewardGoalsMessage =>
      'Você pode ter até 2 metas ativas ao mesmo tempo.';
  String get editRewardGoal => 'Editar meta';
  String get cancelRewardGoal => 'Cancelar meta';
  String get rewardGoalHistoryTitle => 'Histórico de recompensas';
  String get rewardGoalNoHistory => 'Ainda não há recompensas entregues.';
  String get confirmRedeemRewardGoalTitle => 'A recompensa foi entregue?';
  String get confirmRedeemRewardGoalMessage =>
      'Ao concluir, esta meta vai para o histórico de entregues.';
  String get confirmCancelRewardGoalTitle => 'Cancelar esta meta?';
  String get confirmCancelRewardGoalMessage =>
      'O progresso atual do quadro será perdido.';
  String get keepRewardGoal => 'Manter meta';
  String get confirmRewardGiven => 'Marcar entregue';
  String get confirmCancelGoal => 'Cancelar meta';
  String get confirmUseRewardGoalTitle => 'Usar esta recompensa?';
  String get confirmUseRewardGoalMessage =>
      'Ao usar, ela sai das recompensas ganhas e fica registrada como usada.';
  String get confirmUseRewardGoal => 'Usar recompensa';

  String stickerCount(int count) => '$count';
  String rewardGoalProgress(int filledCount, int requiredCount) =>
      '$filledCount/$requiredCount';
  String rewardGoalRemaining(int remainingCount) => 'Faltam $remainingCount';
  String rewardGoalSlotSemanticLabel(int slotNumber, String rewardName) =>
      'Espaço $slotNumber, $rewardName';
  String rewardGoalReadyAt(String dateLabel) => 'Pronta: $dateLabel';
  String rewardGoalRedeemedAt(String dateLabel) => 'Entregue: $dateLabel';
}
