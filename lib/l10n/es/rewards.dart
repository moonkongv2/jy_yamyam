// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsRewardTexts implements RewardTextSet {
  const EsRewardTexts();

  String get collectionTitle => 'Colección de pegatinas';
  String get lockedSticker => 'Aún no conseguida';
  String get lockedStatus => 'Bloqueada';
  String get uncollectedSemanticLabel => 'Aún no conseguida';
  String get rewardGoalTitle => 'Meta de recompensa';
  String get createRewardGoal => 'Crear meta de recompensa';
  String get rewardGoalEmptyTitle => 'Crea una nueva meta';
  String get rewardGoalEmptyBody =>
      'Cada comida completada da una pegatina de vehículo y llena un espacio del tablero.';
  String get rewardGoalRewardFieldLabel => 'Recompensa';
  String get rewardGoalRequiredStickerCountLabel => 'Pegatinas necesarias';
  String get rewardGoalSaveButton => 'Guardar meta';
  String get rewardGoalReadyMessage => '¡La recompensa está lista!';
  String get rewardGoalGivenButton => 'Usar';
  String get rewardGoalCreatedMessage => 'Meta guardada.';
  String get rewardGoalUpdatedMessage => 'Meta actualizada.';
  String get rewardGoalCanceledMessage => 'Meta cancelada.';
  String get rewardGoalRedeemedMessage => 'Entrega de recompensa registrada.';
  String get rewardGoalUsedMessage => 'Recompensa usada.';
  String get rewardGoalProgressTitle => 'Tablero de recompensas';
  String get rewardGoalEmptySlotSemanticLabel => 'Espacio de recompensa vacío';
  String get openRewardGoal => 'Ver tablero';
  String get rewardGoalPromiseTitle => 'Recompensa actual';
  String get activeRewardGoalsTitle => 'Metas activas';
  String get earnedRewardGoalsTitle => 'Recompensas ganadas';
  String get usedRewardGoalsTitle => 'Recompensas usadas';
  String get maxActiveRewardGoalsMessage =>
      'Puedes tener hasta 2 metas activas a la vez.';
  String get editRewardGoal => 'Editar meta';
  String get cancelRewardGoal => 'Cancelar meta';
  String get rewardGoalHistoryTitle => 'Historial de recompensas';
  String get rewardGoalNoHistory => 'Aún no hay recompensas entregadas.';
  String get confirmRedeemRewardGoalTitle => '¿Se entregó la recompensa?';
  String get confirmRedeemRewardGoalMessage =>
      'Al completar, esta meta pasará al historial de entregadas.';
  String get confirmCancelRewardGoalTitle => '¿Cancelar esta meta?';
  String get confirmCancelRewardGoalMessage =>
      'Se perderá el progreso actual del tablero.';
  String get keepRewardGoal => 'Mantener meta';
  String get confirmRewardGiven => 'Marcar entregada';
  String get confirmCancelGoal => 'Cancelar meta';
  String get confirmUseRewardGoalTitle => '¿Usar esta recompensa?';
  String get confirmUseRewardGoalMessage =>
      'Al usarla, desaparece de ganadas y queda registrada como usada.';
  String get confirmUseRewardGoal => 'Usar recompensa';

  String stickerCount(int count) => '$count';
  String rewardGoalProgress(int filledCount, int requiredCount) =>
      '$filledCount/$requiredCount';
  String rewardGoalRemaining(int remainingCount) => 'Faltan $remainingCount';
  String rewardGoalSlotSemanticLabel(int slotNumber, String rewardName) =>
      'Espacio $slotNumber, $rewardName';
  String rewardGoalReadyAt(String dateLabel) => 'Lista: $dateLabel';
  String rewardGoalRedeemedAt(String dateLabel) => 'Entregada: $dateLabel';
}
