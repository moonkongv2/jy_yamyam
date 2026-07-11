// ignore_for_file: annotate_overrides

import '../../models/meal_completion_status.dart';
import '../text_sets.dart';

class EsMealHistoryTexts implements MealHistoryTextSet {
  const EsMealHistoryTexts();

  String get title => 'Historial de comidas';
  String get emptyTitle => 'Aún no hay comidas guardadas';
  String get emptyBody =>
      'Cuando completes un temporizador, el historial aparecerá aquí.';
  String get helpTitle => 'Guía del historial';
  List<String> get helpBulletItems => const [
    'El historial muestra el tiempo objetivo, el tiempo real, el estado y la pegatina recibida.',
    'Si se eligieron ingredientes manualmente, también aparecen en el historial.',
    'Los ingredientes automáticos solo aparecen en la ruta y no se guardan.',
    'Una comida no completada puede aparecer sin pegatina de vehículo.',
  ];
  String get targetTimeLabel => 'Objetivo';
  String get actualTimeLabel => 'Real';
  String get rewardLabel => 'Pegatina recibida';
  String get noRewardLabel => 'Sin pegatina';
  String get selectedIngredientLabel => 'Ingredientes elegidos';
  String get deleteRecordLabel => 'Eliminar comida';
  String get deleteRecordDialogTitle => '¿Eliminar esta comida del historial?';
  String get deleteRecordDialogBody =>
      'Solo se elimina el registro. Las pegatinas recibidas se conservan.';
  String get deleteRecordConfirmLabel => 'Eliminar';
  String get deleteRecordSuccessMessage => 'Comida eliminada del historial.';

  String completedStatus(MealCompletionStatus completionStatus) {
    return completionStatus == MealCompletionStatus.notCompleted
        ? 'No completada'
        : 'Completada';
  }

  String dateLabel(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month} $hour:$minute';
  }
}
