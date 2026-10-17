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
    'Al eliminar una comida del historial, las pegatinas y recompensas obtenidas se conservan de forma predeterminada.',
    'Si la comida tiene pegatinas o espacios vinculados en los tableros de recompensas, puedes marcar «Eliminar también las pegatinas de esta comida» para quitarlos de la colección y de los tableros vinculados.',
    'Las recompensas sin usar vuelven a estar en curso si dejan de alcanzar su meta. Las recompensas ya utilizadas se conservan.',
    'Si eliminas solo el registro, después no podrás usarlo para quitar las pegatinas de esa comida.',
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

  String get deleteLinkedRewardsLabel =>
      "Eliminar también las pegatinas de esta comida";
  String get deleteLinkedRewardsBody =>
      "Se quitarán de la colección y de los tableros de recompensas. Las recompensas sin usar pueden dejar de estar disponibles. Las recompensas ya utilizadas se conservarán.";
  String get deleteRecordOnlyWarning =>
      "Si eliminas solo el registro, después no podrás quitar sus pegatinas desde este registro.";
  String get deleteRecordError =>
      "No se pudo completar el guardado. Inténtalo de nuevo.";
  String get deleteRecordDataError =>
      "No se pueden guardar los cambios porque hay un problema con los datos almacenados. Revisa tus datos.";
  String get deletedMealMessage => "Esta comida ya se ha eliminado.";

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
