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
