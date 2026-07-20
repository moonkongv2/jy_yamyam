// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsMealIngredientTexts implements MealIngredientTextSet {
  const EsMealIngredientTexts();

  String get title => '¿Qué ingredientes comemos hoy?';
  String get subtitle =>
      'Los ingredientes elegidos aparecerán en la ruta Yamyam.';
  String get helpLinkLabel => '¿Qué significan los ingredientes?';
  String get helpTitle => 'Ingredientes en la ruta';
  List<String> get helpBodyParagraphs => const [
    'Los ingredientes son señales visuales para ayudar al peque a recordar lo que come hoy.',
    'No son una evaluación nutricional ni deciden el éxito o el resultado. Tampoco están ligados directamente a las pegatinas.',
  ];
  List<String> get helpBulletItems => const [
    'Desactivado: no muestra ingredientes en la ruta.',
    'Elegir: antes de empezar, se pueden escoger hasta 5. Los elegidos quedan en el historial.',
    'Automático: la app muestra ingredientes al azar en la ruta. No se guardan en el historial.',
    'En el historial solo aparecen los ingredientes elegidos manualmente.',
  ];
  String get randomStartButton => 'Empezar al azar';
  String get selectedStartButton => 'Usar selección';

  String selectedCount(int selectedCount, int maxCount) {
    return '$selectedCount/$maxCount seleccionados';
  }
}
