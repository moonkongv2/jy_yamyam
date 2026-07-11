// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrFirstRunOnboardingTexts implements FirstRunOnboardingTextSet {
  const PtBrFirstRunOnboardingTexts();

  String get title => 'Antes da primeira rota Yamyam';
  String get subtitle =>
      'Transforme a refeição em um passeio leve e acolhedor.';
  String get previousButtonLabel => 'Voltar';
  String get nextButtonLabel => 'Próximo';
  String get startButtonLabel => 'Começar';
  String get skipButtonLabel => 'Começar agora';

  List<FirstRunOnboardingSlideText> get slides => const [
    FirstRunOnboardingSlideText(
      emoji: '💛',
      title: 'Acompanhar uma refeição também pode ser puxado',
      body:
          'Quando o adulto repete "só mais uma colherada", ele também se cansa\n'
          'e a refeição pode ficar pesada para a criança.\n'
          'O Yamyam Rider cria um ritmo de refeição seguindo uma rota divertida, sem pressa.',
      bullets: [
        'A criança consegue ver o tempo passar.',
        'Ajuda a reduzir lembretes repetidos.',
        'Valoriza a pequena tentativa de hoje.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🚗',
      title: 'A refeição vira um passeio',
      body:
          'O veículo escolhido percorre a rota durante o tempo definido. A criança acompanha o veículo e percebe melhor o ritmo da refeição.',
      bullets: [
        'Você pode escolher rotas de 15, 25 ou 35 minutos.',
        'Também pode definir um tempo próprio.',
        'No fim, um responsável confirma se a refeição terminou.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🧭',
      title: 'Como começar',
      body:
          'Digite o nome, escolha o veículo de hoje e o tempo da refeição para iniciar a rota Yamyam.',
      bullets: [
        'Nome → veículo → tempo → partida',
        'Dependendo dos ajustes, ingredientes podem ser escolhidos.',
        'Durante a refeição, dá para pausar e continuar.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🌱',
      title: 'Não precisa ser perfeito',
      body:
          'O Yamyam Rider não avalia a criança.\nEle ajuda a hora da refeição a ficar um pouco mais tranquila.',
      bullets: [
        'A cada dia, a criança pratica o ritmo da refeição.',
        'Não concluir não é falhar; é informação para a próxima tentativa.',
        'Elogie primeiro a tentativa e o ritmo, antes do adesivo.',
      ],
    ),
  ];

  String pageSemanticLabel({
    required int currentPage,
    required int totalPages,
  }) {
    return 'Guia $currentPage/$totalPages';
  }
}
