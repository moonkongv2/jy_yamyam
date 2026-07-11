// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrResultTexts implements ResultTextSet {
  const PtBrResultTexts();

  String get rewardLoading => 'Preparando a recompensa...';
  String get recordSaved => 'O registro de hoje foi salvo.';

  String title(bool mealCompleted) => mealCompleted
      ? 'A refeição terminou muito bem!'
      : 'Hoje precisou de um pouco mais de tempo';

  String primaryMessage(bool mealCompleted, {String? vehicleId}) =>
      mealCompleted
      ? 'Hoje a refeição terminou dentro do ritmo combinado.'
      : _ptBrFailedPrimaryMessagesByVehicle[vehicleId] ??
            'Hoje a refeição precisou de um pouco mais de tempo.';

  String secondaryMessage(bool mealCompleted) => mealCompleted
      ? 'Você terminou a refeição e recebeu um adesivo de veículo!'
      : 'Na próxima refeição, podemos ajustar um pouco o tempo.';

  String get parentTipLabel => 'Dica para responsáveis';

  String parentTipTitle(bool mealCompleted) => mealCompleted
      ? 'Experimente dizer isto'
      : 'Incentive a próxima tentativa com calma';

  String parentTipSubtitle(bool mealCompleted) => mealCompleted
      ? 'Elogie primeiro o processo da refeição, não o adesivo.'
      : 'Um resultado não concluído também ajuda a preparar a próxima tentativa.';

  String parentTipSemanticLabel(bool mealCompleted) => mealCompleted
      ? 'Ver dica para resultado concluído'
      : 'Ver dica para resultado não concluído';

  String helpButtonLabel(bool mealCompleted) => mealCompleted
      ? 'Guia de encerramento e incentivo'
      : 'Guia para ajustar a próxima refeição';

  String helpTitle(bool mealCompleted) => mealCompleted
      ? 'Encerramento da refeição e incentivo'
      : 'Ajustar a próxima refeição';

  List<String> helpBodyParagraphs(bool mealCompleted) => mealCompleted
      ? const [
          'Ao confirmar que a refeição terminou, ela fica registrada como concluída.',
        ]
      : const [
          'Se o tempo acabar e a refeição ainda não tiver terminado, ela fica registrada como não concluída.',
        ];

  List<String> helpBulletItems(bool mealCompleted) => mealCompleted
      ? const [
          'Ao concluir, a criança recebe 1 adesivo do veículo escolhido.',
          'Se houver uma meta de recompensa, o adesivo pode preencher um espaço do quadro.',
        ]
      : const [
          'A refeição não concluída fica no histórico, mas não entrega adesivo.',
          'Não concluir não é castigo; é informação para a próxima tentativa.',
        ];

  String resultHelpMeaningTitle(bool mealCompleted) =>
      'O que este resultado significa?';

  List<String> resultHelpMeaningItems(bool mealCompleted) => mealCompleted
      ? const [
          'Foi confirmado que a refeição terminou e ela fica registrada como concluída.',
          'Uma refeição concluída entrega 1 adesivo do veículo escolhido.',
          'Se houver uma meta, o adesivo pode preencher um espaço do quadro.',
        ]
      : const [
          'O tempo terminou, mas a refeição ainda não tinha acabado, então ela fica registrada como não concluída.',
          'O registro fica no histórico, mas não entrega adesivo.',
          'Não concluir não é castigo; é informação para a próxima tentativa.',
        ];

  String resultHelpSayTitle(bool mealCompleted) => 'Experimente dizer';

  List<String> resultHelpSayItems(bool mealCompleted) => mealCompleted
      ? const [
          'Gostei muito de ver você tentando comer durante o tempo combinado.',
          'Hoje você chegou até o fim da rota Yamyam. Muito bem.',
          'O adesivo é legal, mas o melhor foi terminar a refeição.',
        ]
      : const [
          'Hoje o veículo chegou primeiro. Tudo bem, tentamos de novo.',
          'Vamos ver juntos até onde você chegou?',
          'Hoje foi um pouco difícil. Na próxima vez posso dar um pouquinho mais de tempo.',
        ];

  String resultHelpAvoidTitle(bool mealCompleted) => 'Tente evitar';

  List<String> resultHelpAvoidItems(bool mealCompleted) => mealCompleted
      ? const [
          'Você foi bem porque comeu rápido.',
          'Da próxima vez tem que conseguir de qualquer jeito.',
          'Para ganhar adesivo, precisa fazer melhor.',
        ]
      : const [
          'Você falhou.',
          'Por que comeu tão pouco?',
          'Ficou sem adesivo, está triste?',
        ];

  String resultHelpNextCourseTitle(bool mealCompleted) => 'Para a próxima rota';

  List<String> resultHelpNextCourseItems(bool mealCompleted) => mealCompleted
      ? const [
          'Se a criança comeu com muita pressa, aumente um pouco o tempo na próxima vez.',
          'Se concluiu com tranquilidade, repetir o mesmo tempo pode trazer segurança.',
          'Elogie primeiro o ritmo e a tentativa, antes do adesivo.',
        ]
      : const [
          'Se isso acontecer com frequência, aumente um pouco o tempo padrão da refeição.',
          'Se a criança trava em algum alimento, use a seleção manual de ingredientes para deixar a rota mais familiar.',
          'Use o histórico para entender padrões, não para avaliar a criança.',
        ];
}

const _ptBrFailedPrimaryMessagesByVehicle = {
  'motorcycle': 'A moto passou primeiro.',
  'fire_truck': 'O caminhão de bombeiros saiu primeiro.',
  'police_car': 'O carro de polícia passou primeiro.',
  'excavator': 'A escavadeira se mexeu primeiro.',
  'airplane': 'O avião voou primeiro.',
  'bus': 'O ônibus saiu primeiro.',
  'supercar': 'O supercarro correu primeiro.',
  'train': 'O trem partiu primeiro.',
  't_rex': 'O T-rex passou primeiro.',
  'shark': 'O tubarão nadou primeiro.',
  'brachio': 'O braquiossauro caminhou primeiro.',
  'pteranodon': 'O pteranodonte voou primeiro.',
};
