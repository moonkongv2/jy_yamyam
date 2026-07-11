// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrHomeTexts implements HomeTextSet {
  const PtBrHomeTexts();

  String get subtitle => 'Vamos fazer a rota Yamyam de hoje?';
  String get heroMissionSubtitle =>
      'O rider está esperando uma chegada deliciosa';
  String get todayVehicleTitle => 'Veículo de hoje';
  String get morningCourse => 'Rota de 15 min';
  String get morningCourseSubtitle => 'Um aquecimento leve';
  String get slowCourse => 'Rota de 35 min';
  String get slowCourseSubtitle => 'Chegar com calma';
  String get quickCourseTitle => 'Outras rotas';
  String get customStartButton => 'Começar com tempo próprio';
  String get customSheetTitle => 'Tempo próprio';
  String get mealSummaryLabel => 'Refeições';
  String get stickerKindSummaryLabel => 'Tipos de veículo';
  String get stickerSummaryLabel => 'Adesivos de veículo';
  String get openStickerCollection => 'Ver coleção de adesivos';
  String get avatarCtaSubtitle => 'Coloque o rosto da criança no veículo.';
  String get avatarCtaButton => 'Criar';
  String get avatarCtaEditButton => 'Editar';
  String get avatarCtaCreateSemantics => 'Criar rider';
  String get avatarCtaEditSemantics => 'Editar rider';
  String get avatarInlineDefaultState => 'Usando rosto padrão';
  String get avatarInlineCustomState => 'Criança a bordo';
  String get activeTimerTitle => 'Timer de refeição em andamento';
  String get activeTimerResumeButton => 'Continuar';
  String get activeTimerCancelButton => 'Cancelar';
  String get activeTimerCancelDialogTitle => 'Cancelar o timer em andamento?';
  String get activeTimerCancelDialogMessage =>
      'Se cancelar, este timer de refeição não será salvo.';
  String get activeTimerNewTimerDialogTitle => 'Há um timer em andamento';
  String get activeTimerNewTimerDialogMessage =>
      'Ao iniciar um novo timer, o timer atual será cancelado.';
  String get activeTimerStartNewButton => 'Começar novo';
  String get activeTimerArrivedSubtitle => 'O tempo da refeição acabou';

  String heroMissionTitle(String childName) => 'Missão Yamyam de $childName';
  String recentCustomMinutes(int minutes) => 'Recente: $minutes min';
  String minuteLabel(int minutes) => '$minutes min';
  String activeTimerSubtitle(String remainingTime) =>
      'Tempo restante $remainingTime';
  String normalCourse(int minutes) => 'Rota normal de $minutes min';
  String alternateCourse(int minutes) => 'Rota de $minutes min';
  String alternateCourseSubtitle(int minutes) {
    return switch (minutes) {
      15 => 'Um aquecimento leve',
      25 => 'Chegar no ritmo de sempre',
      35 => 'Chegar com calma',
      _ => 'Rodar por $minutes min',
    };
  }

  String progressTitle(String childName) => 'Registro Yamyam de $childName';
  String mealCount(int count) => '$count';
  String stickerKindCount(int count) => '$count';
  String stickerCount(int count) => '$count';
}
