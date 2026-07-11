// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsTimerTexts implements TimerTextSet {
  const EsTimerTexts();

  String get courseTitle => 'Ruta Yamyam de hoy';
  String get progressJustStarted => '¡Ya salimos!';
  String get progressGoingWell => '¡Vas muy bien!';
  String get progressPastHalfway => '¡Ya avanzaste mucho!';
  String get progressAlmostThere => '¡Casí llegamos!';
  String get progressArrived => '¡Llegaste!';
  String get completeDialogTitle => '¿Terminaste la comida?';
  String get completeDialogMessage => '¿Terminamos la ruta Yamyam de hoy?';
  String get exitDialogTitle => '¿Salir de la ruta?';
  String get exitDialogMessage =>
      'Si sales ahora, la ruta en curso no se guardará.';
  String get exitDialogCancelButton => 'Seguir';
  String get exitDialogConfirmButton => 'Salir';
  String get pauseButton => 'Pausa';
  String get completeMealButton => 'Comida lista';
  String get runningArrivalLabel => 'Tiempo restante';
  String get pausedTimeLabel => 'Descanso breve';
  String get arrivedTimeLabel => 'Llegada completa';
  String get idleTimeLabel => 'Preparando';
  String get pausedProgressMessage => 'Tomemos un descansito';
  String get arrivedProgressMessage => '¡Llegaste!';
  String get idleProgressMessage => 'Preparando la salida';
  String get finishDriveProgressMessage => '¡Vamos a terminar!';
  String get finishDriveTimeLabel => 'Terminando';
  String get previewReady => 'Preparados... 🚦';
  String get previewGo => '¡Vamos! 🌟';

  String arrivalDialogMessage(String vehicleLabel) {
    return '$vehicleLabel llegó primero. ¿Terminaste la comida?';
  }

  String remainingTime(String remaining) => 'Queda $remaining';
  String remainingTimeSemanticLabel(String label, String remaining) {
    return '$label, queda $remaining';
  }
}
