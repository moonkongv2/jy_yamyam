// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrSettingsTexts implements SettingsTextSet {
  const PtBrSettingsTexts();

  String get title => 'Ajustes';
  String get showRemainingTime => 'Mostrar tempo restante';
  String get soundEnabled => 'Efeitos sonoros';
  String get motivationVideoEnabled => 'Vídeos de incentivo';
  String get motivationVideoCustomInterval => 'Usar intervalo personalizado';
  String get motivationVideoInterval => 'Intervalo dos vídeos de incentivo';
  String get motivationVideoHelpTitle => 'Guia dos vídeos de incentivo';
  String get motivationVideoHelpSummary =>
      'Os vídeos de incentivo são apoios curtos durante a refeição e não afetam o resultado.';
  List<String> get motivationVideoHelpBodyParagraphs => const [
    'Os vídeos de incentivo aparecem no meio da refeição para ajudar a criança a manter o ritmo.',
    'Eles não influenciam sucesso, refeição não concluída nem adesivos.',
  ];
  List<String> get motivationVideoHelpBulletItems => const [
    'Em rotas de até 30 minutos, eles costumam aparecer em marcos de 10% de progresso, como 10% ou 20%.',
    'Em rotas personalizadas muito curtas, alguns marcos podem ser pulados para evitar vídeos sobrepostos.',
    'Em rotas com mais de 30 minutos ou com intervalo personalizado, eles podem aparecer por intervalo de tempo.',
    'O intervalo personalizado pode ser de 3, 5 ou 10 minutos.',
    'As configurações de som e de vídeo funcionam separadamente.',
    'O app ajusta o intervalo para os vídeos não aparecerem com frequência demais.',
  ];
  String get keepScreenAwake => 'Manter a tela ligada';
  String get savedOnlySubtitle => 'Liga ou desliga os sons durante o timer.';
  String get keepScreenAwakeSubtitle => 'Vale durante o timer da refeição.';
  String get courseIngredientModeTitle => 'Ingredientes na rota';
  String get courseIngredientModeOff => 'Desativado';
  String get courseIngredientModeManual => 'Escolher';
  String get courseIngredientModeRandom => 'Automático';
  String get courseIngredientModeDescription =>
      'Só os ingredientes escolhidos ficam no histórico. Os automáticos aparecem apenas na rota.';
  String get defaultMealDuration => 'Tempo padrão da refeição';
  String get vehicleSelection => 'Escolher veículo';
  String get childNameTitle => 'Nome da criança';
  String get childNameFieldLabel => 'Nome';
  String get childNameSetupTitle => 'Quem vai pilotar hoje?';
  String get childNameSetupSubtitle => 'Primeiro informe o nome da criança.';
  String get saveChildName => 'Salvar nome';
  String get childNameRequiredMessage => 'Digite o nome da criança.';
  String get childNameSavedMessage => 'Nome salvo.';
  String get avatarSettingsTitle => 'Ajustes do rider';
  String get avatarDefaultState => 'Usando imagem padrão';
  String get avatarCustomState => 'Usando rider personalizado';
  String get avatarSettingsButton => 'Abrir ajustes do rider';
  String get helpSupportTitle => 'Ajuda e suporte';
  String get userGuide => 'Guia de uso';
  String get restorePurchase => 'Restaurar compra';
  String get contactSupport => 'Falar com o suporte';
  String get aboutTitle => 'Sobre';
  String get privacyPolicy => 'Política de privacidade';
  String get appVersion => 'Versão do app';

  String durationSegmentLabel(int minutes) => '$minutes min';
  String motivationVideoIntervalSegmentLabel(int minutes) => '$minutes min';
}
