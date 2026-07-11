// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsSettingsTexts implements SettingsTextSet {
  const EsSettingsTexts();

  String get title => 'Ajustes';
  String get showRemainingTime => 'Mostrar tiempo restante';
  String get soundEnabled => 'Efectos de sonido';
  String get motivationVideoEnabled => 'Vídeos de ánimo';
  String get motivationVideoCustomInterval => 'Usar intervalo personalizado';
  String get motivationVideoInterval => 'Intervalo de vídeos de ánimo';
  String get motivationVideoHelpTitle => 'Guía de vídeos de ánimo';
  String get motivationVideoHelpSummary =>
      'Los vídeos de ánimo son pequeños apoyos durante la comida; no afectan al resultado.';
  List<String> get motivationVideoHelpBodyParagraphs => const [
    'Los vídeos de ánimo aparecen durante la comida para ayudar a mantener el ritmo.',
    'No tienen relación con el éxito, la comida no completada ni las pegatinas.',
  ];
  List<String> get motivationVideoHelpBulletItems => const [
    'En rutas de 30 minutos o menos, suelen aparecer en tramos del 10% de progreso, como 10% o 20%.',
    'En rutas personalizadas muy cortas, algunos tramos pueden omitirse para que no se acumulen vídeos.',
    'En rutas de más de 30 minutos o con intervalo personalizado, pueden aparecer según el tiempo.',
    'El intervalo personalizado puede ser de 3, 5 o 10 minutos.',
    'Los ajustes de sonido y de vídeo funcionan por separado.',
    'La app ajusta el intervalo para que los vídeos no aparezcan demasiado seguido.',
  ];
  String get keepScreenAwake => 'Mantener pantalla encendida';
  String get savedOnlySubtitle =>
      'Activa o desactiva los sonidos del temporizador.';
  String get keepScreenAwakeSubtitle =>
      'Se aplica durante el temporizador de comida.';
  String get courseIngredientModeTitle => 'Ingredientes en la ruta';
  String get courseIngredientModeOff => 'Desactivado';
  String get courseIngredientModeManual => 'Elegir';
  String get courseIngredientModeRandom => 'Automático';
  String get courseIngredientModeDescription =>
      'Solo los ingredientes elegidos se guardan en el historial. Los automáticos solo aparecen en la ruta.';
  String get defaultMealDuration => 'Tiempo de comida predeterminado';
  String get vehicleSelection => 'Elegir vehículo';
  String get childNameTitle => 'Nombre del peque';
  String get childNameFieldLabel => 'Nombre';
  String get childNameSetupTitle => '¿Quién va a montar hoy?';
  String get childNameSetupSubtitle => 'Primero escribe el nombre del peque.';
  String get saveChildName => 'Guardar nombre';
  String get childNameRequiredMessage => 'Escribe el nombre del peque.';
  String get childNameSavedMessage => 'Nombre guardado.';
  String get avatarSettingsTitle => 'Ajustes del rider';
  String get avatarDefaultState => 'Usando imagen predeterminada';
  String get avatarCustomState => 'Usando rider personalizado';
  String get avatarSettingsButton => 'Abrir ajustes del rider';

  String durationSegmentLabel(int minutes) => '$minutes min';
  String motivationVideoIntervalSegmentLabel(int minutes) => '$minutes min';
}
