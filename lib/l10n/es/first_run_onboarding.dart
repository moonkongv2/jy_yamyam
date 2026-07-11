// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsFirstRunOnboardingTexts implements FirstRunOnboardingTextSet {
  const EsFirstRunOnboardingTexts();

  String get title => 'Antes del primer viaje Yamyam';
  String get subtitle => 'Convierte la comida en un paseo sencillo y amable.';
  String get previousButtonLabel => 'Atrás';
  String get nextButtonLabel => 'Siguiente';
  String get startButtonLabel => 'Empezar';
  String get skipButtonLabel => 'Empezar ahora';

  List<FirstRunOnboardingSlideText> get slides => const [
    FirstRunOnboardingSlideText(
      emoji: '💛',
      title: 'Acompañar una comida también puede ser mucho',
      body:
          'Cuando repetimos "un bocado más", los adultos se cansan\n'
          'y la comida puede volverse pesada para el peque.\n'
          'Yamyam Rider crea un ritmo de comida siguiendo una ruta divertida, sin prisas.',
      bullets: [
        'El peque puede ver el paso del tiempo.',
        'Ayuda a reducir recordatorios repetidos.',
        'Anima el pequeño intento de hoy.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🚗',
      title: 'La comida como un paseo',
      body:
          'El vehículo elegido recorre la ruta durante el tiempo marcado. El peque puede seguirlo y sentir mejor el ritmo de la comida.',
      bullets: [
        'Puedes elegir rutas de 15, 25 o 35 minutos.',
        'También puedes ajustar un tiempo propio.',
        'Al final, un adulto confirma si la comida terminó.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🧭',
      title: 'Así se empieza',
      body:
          'Escribe el nombre, elige el vehículo de hoy y el tiempo de comida para iniciar la ruta Yamyam.',
      bullets: [
        'Nombre → vehículo → tiempo → salida',
        'Según los ajustes, se pueden elegir ingredientes.',
        'Durante la comida puedes pausar y continuar.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🌱',
      title: 'No tiene que ser perfecto',
      body:
          'Yamyam Rider no evalúa al peque.\nEs una herramienta para que la hora de comer se sienta un poco mejor.',
      bullets: [
        'Cada día se practica el ritmo de la comida.',
        'No completar no es fallar; es información para la próxima vez.',
        'Elogia primero el intento y el ritmo, antes que la pegatina.',
      ],
    ),
  ];

  String pageSemanticLabel({
    required int currentPage,
    required int totalPages,
  }) {
    return 'Guía $currentPage/$totalPages';
  }
}
