// ignore_for_file: annotate_overrides

import '../../models/meal_completion_status.dart';
import '../text_sets.dart';

class PtBrMealHistoryTexts implements MealHistoryTextSet {
  const PtBrMealHistoryTexts();

  String get title => 'Histórico de refeições';
  String get emptyTitle => 'Ainda não há refeições salvas';
  String get emptyBody =>
      'Quando um timer for concluído, o histórico aparecerá aqui.';
  String get helpTitle => 'Guia do histórico';
  List<String> get helpBulletItems => const [
    'O histórico mostra tempo planejado, tempo real, status e adesivo recebido.',
    'Ingredientes escolhidos manualmente também aparecem no histórico.',
    'Ingredientes automáticos aparecem apenas na rota e não ficam salvos.',
    'Uma refeição não concluída pode aparecer sem adesivo de veículo.',
    'Ao excluir uma refeição do histórico, os adesivos e as recompensas recebidos são mantidos por padrão.',
    'Se a refeição tiver adesivos ou espaços vinculados nos quadros de recompensas, você pode marcar “Remover também os adesivos desta refeição” para removê-los da coleção e dos quadros vinculados.',
    'Recompensas não usadas voltam a ficar em andamento se deixarem de atingir a meta. As recompensas já utilizadas são mantidas.',
    'Se excluir apenas o registro, você não poderá usá-lo depois para remover os adesivos daquela refeição.',
  ];
  String get targetTimeLabel => 'Meta';
  String get actualTimeLabel => 'Real';
  String get rewardLabel => 'Adesivo recebido';
  String get noRewardLabel => 'Sem adesivo';
  String get selectedIngredientLabel => 'Ingredientes escolhidos';
  String get deleteRecordLabel => 'Excluir refeição';
  String get deleteRecordDialogTitle => 'Excluir esta refeição do histórico?';
  String get deleteRecordDialogBody =>
      'Só o registro será excluído. Os adesivos recebidos ficam salvos.';
  String get deleteRecordConfirmLabel => 'Excluir';
  String get deleteRecordSuccessMessage => 'Refeição excluída do histórico.';

  String get deleteLinkedRewardsLabel =>
      "Remover também os adesivos desta refeição";
  String get deleteLinkedRewardsBody =>
      "Os adesivos serão removidos da coleção e dos quadros de recompensas. Recompensas não usadas podem deixar de estar disponíveis. As já utilizadas serão mantidas.";
  String get deleteRecordOnlyWarning =>
      "Se excluir apenas o registro, não será possível remover seus adesivos por ele depois.";
  String get deleteRecordError =>
      "Não foi possível concluir o salvamento. Tente novamente.";
  String get deleteRecordDataError =>
      "Não é possível salvar as alterações porque há um problema nos dados armazenados. Verifique seus dados.";
  String get deletedMealMessage => "Esta refeição já foi excluída.";

  String completedStatus(MealCompletionStatus completionStatus) {
    return completionStatus == MealCompletionStatus.notCompleted
        ? 'Não concluída'
        : 'Concluída';
  }

  String dateLabel(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month} $hour:$minute';
  }
}
