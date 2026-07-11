// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrUserGuideTexts implements UserGuideTextSet {
  const PtBrUserGuideTexts();

  String get title => 'Guia de uso';
  String get subtitle =>
      'Confira ingredientes, vídeos de incentivo e regras dos adesivos.';
  String get introTitle => 'Guia para responsáveis';
  String get introBody =>
      'Antes de usar o Yamyam Rider, você pode revisar o ritmo da refeição e as regras do app. Também ajuda outros cuidadores que acompanham a criança.';
  String get basicFlowTitle => startCourseTitle;
  String get ingredientsTitle => roadIngredientsTitle;
  String get motivationTitle => 'Vídeos de incentivo';
  String get resultRewardsTitle => completionTitle;
  String get historyTitle => historyRewardsTitle;
  String get guardianTipsTitle => 'Dicas para responsáveis';

  String get whatIsYamyamTitle => 'O que é o Yamyam Rider?';
  List<String> get whatIsYamyamItems => const [
    'É um app que transforma a refeição em uma rota divertida, não apenas em uma contagem regressiva.',
    'A criança escolhe um veículo e acompanha a rota durante o tempo definido para ajustar o ritmo da refeição.',
    'No final, um responsável confirma se a refeição terminou e define o status.',
  ];

  String get startCourseTitle => 'Iniciar uma rota de refeição';
  List<String> get startCourseItems => const [
    'Depois de configurar o nome, você pode escolher o veículo na tela inicial.',
    'Escolha uma rota de 15, 25 ou 35 minutos, ou um tempo personalizado.',
    'Dependendo dos ajustes, antes de começar é possível escolher ingredientes ou deixar o app mostrar automaticamente.',
    'Pausar durante o timer não é falhar; dá para descansar um pouco e continuar.',
  ];

  String get roadIngredientsTitle => 'Ingredientes na rota';
  List<String> get roadIngredientsItems => const [
    'Os ingredientes são marcadores visuais para ajudar a criança a lembrar da comida de hoje.',
    'Eles não são avaliação nutricional nem decisão de sucesso ou falha.',
    'Desativado: não mostra ingredientes na rota.',
    'Escolher: antes de começar, escolha até 5. Os escolhidos ficam no histórico.',
    'Automático: o app mostra ingredientes aleatórios na rota. Eles não ficam no histórico.',
    'Lembre-se: no histórico aparecem apenas os ingredientes escolhidos manualmente.',
  ];

  List<String> get motivationItems => const [
    'São vídeos curtos de incentivo que aparecem durante a refeição.',
    'Eles não têm relação com recompensas nem com o resultado concluída/não concluída.',
    'Em rotas de até 30 minutos, costumam aparecer por marcos de 10% de progresso.',
    'Em rotas personalizadas muito curtas, alguns marcos podem ser pulados para evitar sobreposição.',
    'Em rotas longas ou com intervalo personalizado, podem aparecer por tempo.',
    'O intervalo pode ser de 3, 5 ou 10 minutos.',
    'Se o som estiver desligado, o vídeo pode aparecer sem áudio.',
  ];

  String get completionTitle => 'Concluída, não concluída e adesivos';
  List<String> get completionItems => const [
    'Quando você confirma que a refeição terminou, ela fica registrada como concluída.',
    'Ao concluir, a criança recebe 1 adesivo do veículo escolhido.',
    'Se o tempo acaba e a refeição ainda não terminou, toque em "Ainda não". Ela será registrada como não concluída.',
    'Refeições não concluídas ficam no histórico, mas não entregam adesivo.',
    'A tela da criança mantém um tom leve, sem mensagens duras de falha.',
  ];

  String get historyRewardsTitle => 'Histórico e metas de recompensa';
  List<String> get historyRewardsItems => const [
    'No histórico, você vê tempo planejado, tempo real e status. Também aparecem adesivos recebidos e ingredientes escolhidos.',
    'Os adesivos recebidos ficam na coleção.',
    'Se houver uma meta de recompensa, os adesivos podem preencher os espaços dela.',
  ];

  String get exitResumeTitle => 'Sair e continuar durante o timer';
  List<String> get exitResumeItems => const [
    'Ao voltar durante o timer, o app pede confirmação.',
    'Pausar não é falhar; dá para descansar um pouco e continuar.',
    'Se houver um timer salvo, um cartão pode aparecer na tela inicial para continuar ou cancelar.',
  ];

  List<String> get guardianTipsItems => const [
    'Elogie primeiro que a criança manteve o ritmo da refeição, antes do adesivo.',
    'Configure um tempo de refeição adequado para a criança, não uma meta curta demais.',
    'Explique resultados não concluídos como informação para a próxima vez, não como castigo.',
  ];
}
