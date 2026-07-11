// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsResultTexts implements ResultTextSet {
  const EsResultTexts();

  String get rewardLoading => 'Preparando la recompensa...';
  String get recordSaved => 'El registro de hoy se guardó.';

  String title(bool mealCompleted) => mealCompleted
      ? '¡Terminaste muy bien la comida!'
      : 'Hoy hizo falta un poco más de tiempo';

  String primaryMessage(bool mealCompleted, {String? vehicleId}) =>
      mealCompleted
      ? 'Hoy terminaste la comida dentro del ritmo elegido.'
      : _esFailedPrimaryMessagesByVehicle[vehicleId] ??
            'Hoy la comida necesitó un poco más de tiempo.';

  String secondaryMessage(bool mealCompleted) => mealCompleted
      ? '¡Terminaste la comida y recibiste una pegatina de vehículo!'
      : 'La próxima vez podemos ajustar un poco el tiempo.';

  String get parentTipLabel => 'Consejo para adultos';

  String parentTipTitle(bool mealCompleted) => mealCompleted
      ? 'Prueba decirle esto'
      : 'Anima el próximo intento con calma';

  String parentTipSubtitle(bool mealCompleted) => mealCompleted
      ? 'Elogia primero el proceso de comer, no la pegatina.'
      : 'Un resultado incompleto también ayuda a preparar el próximo intento.';

  String parentTipSemanticLabel(bool mealCompleted) => mealCompleted
      ? 'Ver consejo para resultado completado'
      : 'Ver consejo para resultado no completado';

  String helpButtonLabel(bool mealCompleted) => mealCompleted
      ? 'Guía de cierre y ánimo'
      : 'Guía para ajustar la próxima comida';

  String helpTitle(bool mealCompleted) =>
      mealCompleted ? 'Cierre de comida y ánimo' : 'Ajustar la próxima comida';

  List<String> helpBodyParagraphs(bool mealCompleted) => mealCompleted
      ? const ['Al confirmar que la comida terminó, se guarda como completada.']
      : const [
          'Si el tiempo termina y la comida no ha terminado, se guarda como no completada.',
        ];

  List<String> helpBulletItems(bool mealCompleted) => mealCompleted
      ? const [
          'Al completarla, recibe 1 pegatina del vehículo elegido.',
          'Si hay una meta de recompensa, la pegatina puede llenar un espacio del tablero.',
        ]
      : const [
          'La comida no completada queda en el historial, pero no entrega pegatina.',
          'No completar no es un castigo; es información para el próximo intento.',
        ];

  String resultHelpMeaningTitle(bool mealCompleted) =>
      '¿Qué significa este resultado?';

  List<String> resultHelpMeaningItems(bool mealCompleted) => mealCompleted
      ? const [
          'Se confirmó que la comida terminó y se guarda como completada.',
          'Una comida completada da 1 pegatina del vehículo elegido.',
          'Si hay una meta, la pegatina puede llenar un espacio del tablero.',
        ]
      : const [
          'El tiempo terminó, pero la comida aún no había terminado, así que se guarda como no completada.',
          'El registro queda en el historial, pero no se entrega pegatina.',
          'No completar no es un castigo; es información para el próximo intento.',
        ];

  String resultHelpSayTitle(bool mealCompleted) => 'Prueba decir esto';

  List<String> resultHelpSayItems(bool mealCompleted) => mealCompleted
      ? const [
          'Me gustó mucho que intentaras comer durante el tiempo que acordamos.',
          'Hoy llegaste hasta el final de la ruta Yamyam. Muy bien.',
          'La pegatina está bien, pero lo mejor fue terminar la comida.',
        ]
      : const [
          'Hoy el vehículo llegó primero. No pasa nada, lo intentamos otra vez.',
          '¿Miramos juntos hasta dónde llegaste?',
          'Hoy fue un poco difícil. La próxima vez puedo darte un poquito más de tiempo.',
        ];

  String resultHelpAvoidTitle(bool mealCompleted) => 'Intenta evitar';

  List<String> resultHelpAvoidItems(bool mealCompleted) => mealCompleted
      ? const [
          'Lo hiciste bien porque comiste rápido.',
          'La próxima vez tienes que lograrlo sí o sí.',
          'Si quieres pegatina, tienes que hacerlo mejor.',
        ]
      : const [
          'Fallaste.',
          '¿Por qué comiste tan poco?',
          'Te quedaste sin pegatina, ¿estás triste?',
        ];

  String resultHelpNextCourseTitle(bool mealCompleted) =>
      'Para la próxima ruta';

  List<String> resultHelpNextCourseItems(bool mealCompleted) => mealCompleted
      ? const [
          'Si comió con demasiada prisa, puedes alargar un poco el tiempo la próxima vez.',
          'Si completó con calma, repetir el mismo tiempo puede dar seguridad.',
          'Elogia primero el ritmo y el intento, antes que la pegatina.',
        ]
      : const [
          'Si ocurre a menudo, prueba aumentar un poco el tiempo predeterminado.',
          'Si se atasca con algún alimento, usa la selección manual de ingredientes para que la ruta resulte más familiar.',
          'Usa el historial para entender patrones, no para evaluar al peque.',
        ];
}

const _esFailedPrimaryMessagesByVehicle = {
  'motorcycle': 'La moto pasó primero.',
  'fire_truck': 'El camión de bomberos salió primero.',
  'police_car': 'El coche de policía pasó primero.',
  'excavator': 'La excavadora se movió primero.',
  'airplane': 'El avión voló primero.',
  'bus': 'El autobús salió primero.',
  'supercar': 'El supercoche corrió primero.',
  'train': 'El tren salió primero.',
  't_rex': 'El T-rex avanzó primero.',
  'shark': 'El tiburón nadó primero.',
  'brachio': 'El braquiosaurio caminó primero.',
  'pteranodon': 'El pteranodón voló primero.',
};
