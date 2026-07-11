// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrMealIngredientTexts implements MealIngredientTextSet {
  const PtBrMealIngredientTexts();

  String get title => 'Quais ingredientes vamos comer hoje?';
  String get subtitle => 'Os ingredientes escolhidos aparecem na rota Yamyam.';
  String get helpLinkLabel => 'O que os ingredientes significam?';
  String get helpTitle => 'Ingredientes na rota';
  List<String> get helpBodyParagraphs => const [
    'Os ingredientes são marcadores visuais para ajudar a criança a lembrar da comida de hoje.',
    'Eles não são avaliação nutricional nem definem sucesso ou não conclusão. Também não estão ligados diretamente aos adesivos.',
  ];
  List<String> get helpBulletItems => const [
    'Desativado: não mostra ingredientes na rota.',
    'Escolher: antes de começar, escolha até 5. Os escolhidos ficam no histórico.',
    'Automático: o app mostra ingredientes aleatórios na rota. Eles não ficam no histórico.',
    'No histórico aparecem apenas os ingredientes escolhidos manualmente.',
  ];
  String get randomStartButton => 'Começar aleatório';
  String get selectedStartButton => 'Começar com seleção';

  String selectedCount(int selectedCount, int maxCount) {
    return '$selectedCount/$maxCount selecionados';
  }
}
