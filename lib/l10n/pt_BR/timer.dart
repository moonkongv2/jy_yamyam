// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrTimerTexts implements TimerTextSet {
  const PtBrTimerTexts();

  String get courseTitle => 'Rota Yamyam de hoje';
  String get progressJustStarted => 'Partimos!';
  String get progressGoingWell => 'Você está indo muito bem!';
  String get progressPastHalfway => 'Você já avançou bastante!';
  String get progressAlmostThere => 'Estamos quase lá!';
  String get progressArrived => 'Chegamos!';
  String get completeDialogTitle => 'A refeição terminou?';
  String get completeDialogMessage => 'Vamos encerrar a rota Yamyam de hoje?';
  String get exitDialogTitle => 'Sair da rota?';
  String get exitDialogMessage =>
      'Se sair agora, a rota em andamento não será salva.';
  String get exitDialogCancelButton => 'Continuar';
  String get exitDialogConfirmButton => 'Sair';
  String get pauseButton => 'Pausar';
  String get completeMealButton => 'Refeição concluída';
  String get runningArrivalLabel => 'Tempo restante';
  String get pausedTimeLabel => 'Pausa rapidinha';
  String get arrivedTimeLabel => 'Chegada concluída';
  String get idleTimeLabel => 'Preparando';
  String get pausedProgressMessage => 'Vamos descansar um pouquinho';
  String get arrivedProgressMessage => 'Chegamos!';
  String get idleProgressMessage => 'Preparando a partida';
  String get finishDriveProgressMessage => 'Indo para finalizar!';
  String get finishDriveTimeLabel => 'Finalizando';
  String get previewReady => 'Preparar... 🚦';
  String get previewGo => 'Vai! 🌟';

  String arrivalDialogMessage(String vehicleLabel) {
    return '$vehicleLabel chegou primeiro. A refeição terminou?';
  }

  String remainingTime(String remaining) => 'Falta $remaining';
  String remainingTimeSemanticLabel(String label, String remaining) {
    return '$label, falta $remaining';
  }
}
