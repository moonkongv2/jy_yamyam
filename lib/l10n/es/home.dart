// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsHomeTexts implements HomeTextSet {
  const EsHomeTexts();

  String get subtitle => '¿Hacemos otra ruta Yamyam hoy?';
  String get heroMissionSubtitle => 'El rider espera una llegada deliciosa';
  String get todayVehicleTitle => 'Vehículo de hoy';
  String get morningCourse => 'Ruta de 15 min';
  String get morningCourseSubtitle => 'Para calentar con calma';
  String get slowCourse => 'Ruta de 35 min';
  String get slowCourseSubtitle => 'Llegar sin prisa';
  String get quickCourseTitle => 'Otras rutas';
  String get customStartButton => 'Empezar con tiempo propio';
  String get customSheetTitle => 'Tiempo propio';
  String get mealSummaryLabel => 'Comidas';
  String get stickerKindSummaryLabel => 'Tipos de vehículo';
  String get stickerSummaryLabel => 'Pegatinas de vehículo';
  String get openStickerCollection => 'Ver colección de pegatinas';
  String get avatarCtaSubtitle => 'Pon la cara del peque en su vehículo.';
  String get avatarCtaButton => 'Crear';
  String get avatarCtaEditButton => 'Editar';
  String get avatarCtaCreateSemantics => 'Crear rider';
  String get avatarCtaEditSemantics => 'Editar rider';
  String get avatarInlineDefaultState => 'Usando cara predeterminada';
  String get avatarInlineCustomState => 'El peque va a bordo';
  String get activeTimerTitle => 'Temporizador de comida en curso';
  String get activeTimerResumeButton => 'Continuar';
  String get activeTimerCancelButton => 'Cancelar';
  String get activeTimerCancelDialogTitle =>
      '¿Cancelar el temporizador en curso?';
  String get activeTimerCancelDialogMessage =>
      'Si lo cancelas, esta comida no se guardará en el historial.';
  String get activeTimerNewTimerDialogTitle => 'Hay un temporizador en curso';
  String get activeTimerNewTimerDialogMessage =>
      'Si empiezas uno nuevo, se cancelará el temporizador actual.';
  String get activeTimerStartNewButton => 'Empezar nuevo';
  String get activeTimerArrivedSubtitle => 'El tiempo de comida terminó';

  String heroMissionTitle(String childName) => 'Misión Yamyam de $childName';
  String recentCustomMinutes(int minutes) => 'Reciente: $minutes min';
  String minuteLabel(int minutes) => '$minutes min';
  String activeTimerSubtitle(String remainingTime) =>
      'Tiempo restante $remainingTime';
  String normalCourse(int minutes) => 'Ruta normal de $minutes min';
  String alternateCourse(int minutes) => 'Ruta de $minutes min';
  String alternateCourseSubtitle(int minutes) {
    return switch (minutes) {
      15 => 'Para calentar con calma',
      25 => 'Llegar con el ritmo habitual',
      35 => 'Llegar sin prisa',
      _ => 'Rodar durante $minutes min',
    };
  }

  String progressTitle(String childName) => 'Historial Yamyam de $childName';
  String mealCount(int count) => '$count';
  String stickerKindCount(int count) => '$count';
  String stickerCount(int count) => '$count';
}
