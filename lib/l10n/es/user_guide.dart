// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsUserGuideTexts implements UserGuideTextSet {
  const EsUserGuideTexts();

  String get title => 'Guía de uso';
  String get subtitle =>
      'Revisa ingredientes, vídeos de ánimo y reglas de pegatinas.';
  String get introTitle => 'Guía para adultos';
  String get introBody =>
      'Antes de usar Yamyam Rider, puedes revisar el ritmo de comida y las reglas de la app. También sirve para otros cuidadores que acompañan al peque.';
  String get basicFlowTitle => startCourseTitle;
  String get ingredientsTitle => roadIngredientsTitle;
  String get motivationTitle => 'Vídeos de ánimo';
  String get resultRewardsTitle => completionTitle;
  String get historyTitle => historyRewardsTitle;
  String get guardianTipsTitle => 'Consejos para adultos';

  String get whatIsYamyamTitle => '¿Qué es Yamyam Rider?';
  List<String> get whatIsYamyamItems => const [
    'Es una app que convierte la comida en una ruta divertida, no solo en una cuenta atrás.',
    'El peque elige un vehículo y sigue la ruta durante el tiempo marcado para acompasar la comida.',
    'Al final, un adulto confirma si la comida terminó y decide el estado.',
  ];

  String get startCourseTitle => 'Empezar una ruta de comida';
  List<String> get startCourseItems => const [
    'Después de configurar el nombre, puedes elegir el vehículo desde Inicio.',
    'Elige una ruta de 15, 25 o 35 minutos, o un tiempo personalizado.',
    'Según los ajustes, antes de empezar se pueden elegir ingredientes o dejar que la app los muestre automáticamente.',
    'Pausar durante el temporizador no es fallar; puedes detener un momento y continuar.',
  ];

  String get roadIngredientsTitle => 'Ingredientes en la ruta';
  List<String> get roadIngredientsItems => const [
    'Los ingredientes son señales visuales para ayudar al peque a recordar la comida de hoy.',
    'No son una evaluación nutricional ni una decisión de éxito o fallo.',
    'Desactivado: no muestra ingredientes en la ruta.',
    'Elegir: antes de empezar, se pueden escoger hasta 5. Los elegidos se guardan en el historial.',
    'Automático: la app muestra ingredientes al azar en la ruta. No se guardan en el historial.',
    'Recuerda que en el historial solo aparecen los ingredientes elegidos manualmente.',
  ];

  List<String> get motivationItems => const [
    'Son vídeos cortos de ánimo que aparecen durante la comida.',
    'No tienen relación con recompensas ni con el resultado de completada/no completada.',
    'En rutas de 30 minutos o menos, suelen aparecer según tramos de 10% de progreso.',
    'En rutas personalizadas muy cortas, algunos tramos pueden omitirse para evitar solapamientos.',
    'En rutas largas o con intervalo personalizado, pueden aparecer según el tiempo.',
    'El intervalo puede ser de 3, 5 o 10 minutos.',
    'Si el sonido está desactivado, puede mostrarse el video sin audio.',
  ];

  String get completionTitle => 'Completada, no completada y pegatinas';
  List<String> get completionItems => const [
    'Cuando confirmas que la comida terminó, se guarda como completada.',
    'Al completarla, recibe 1 pegatina del vehículo elegido.',
    'Si el tiempo termina y la comida no ha terminado, pulsa "Todavía no". Se guardará como no completada.',
    'Las comidas no completadas quedan en el historial, pero no dan pegatina.',
    'La pantalla del peque mantiene un tono suave, sin mensajes duros de fallo.',
  ];

  String get historyRewardsTitle => 'Historial y metas de recompensa';
  List<String> get historyRewardsItems => const [
    'En el historial puedes ver tiempo objetivo, tiempo real y estado. También aparecen las pegatinas recibidas y los ingredientes elegidos.',
    'Las pegatinas recibidas se guardan en la colección.',
    'Si hay una meta de recompensa, las pegatinas pueden llenar sus espacios.',
  ];

  String get exitResumeTitle => 'Salir y continuar durante el temporizador';
  List<String> get exitResumeItems => const [
    'Si vuelves atrás durante el temporizador, se pide confirmación.',
    'Pausar no es fallar; se puede descansar un momento y seguir.',
    'Si hay un temporizador guardado, puede aparecer una tarjeta en Inicio para continuar o cancelar.',
  ];

  List<String> get guardianTipsItems => const [
    'Elogia primero que mantuvo el ritmo de comida, antes que la pegatina.',
    'Configura un tiempo de comida adecuado al peque, no una meta demasiado corta.',
    'Explica los resultados no completados como información para la próxima vez, no como castigo.',
  ];
}
