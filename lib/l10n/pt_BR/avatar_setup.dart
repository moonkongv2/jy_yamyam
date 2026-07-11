// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrAvatarSetupTexts implements AvatarSetupTextSet {
  const PtBrAvatarSetupTexts();

  String get title => 'Criar o rider da criança';
  String get intro =>
      'Crie e envie a imagem do rider que será usada no Yamyam Rider.';
  String get selectedVehicleTitle => 'Veículo selecionado';
  String get currentAvatarModeTitle => 'Modo da imagem do rider';
  String get defaultImageMode => 'Usar imagem padrão';
  String get customAvatarMode => 'Usar rider personalizado';
  String get copyPromptMessage =>
      'Prompt copiado. Cole em um serviço externo de IA para usar.';
  String get avatarSaveFailureMessage =>
      'Não foi possível salvar a imagem do rider.';
  String get avatarSavedMessage => 'Rider salvo.';
  String get defaultImageSavedMessage => 'Mudou para a imagem padrão.';
  String get missingAvatarWarning =>
      'A imagem do rider não foi encontrada, então a imagem padrão será exibida.';
  String get vehicleSelectionTitle => 'Veículo do rider';
  String get vehicleSelectionSubtitle => 'Referência do prompt';
  String get compositePreviewTitle => 'Prévia';
  String get compositePreviewSubtitle => 'Usar este visual no Yamyam Rider?';
  String get defaultPreviewTitle => 'Prévia da imagem padrão';
  String get useDefaultImageButton => 'Usar imagem padrão';
  String get adjustmentTitle => 'Ajustar posição do rider';
  String get faceSizeLabel => 'Tamanho do rosto';
  String get horizontalPositionLabel => 'Posição horizontal';
  String get verticalPositionLabel => 'Posição vertical';
  String get rotationLabel => 'Inclinação';
  String get resetPositionButton => 'Redefinir posição';
  String get confirmAvatarButton => 'Usar este rider';
  String get guideTitle => 'Guia da imagem do rider';
  String get guideIntro =>
      'O app não recorta o rosto automaticamente. Prepare uma imagem do rider usando um dos métodos abaixo.';
  String get promptCopyTitle => 'Prompt da imagem do rider (exemplo)';
  String get promptHelperText =>
      'Ao usar um serviço de IA, copie e cole o prompt adaptado ao veículo escolhido.';
  String get promptGuideHint =>
      'Copie o prompt de exemplo abaixo e cole em um serviço de IA.';
  String get promptExpandLabel => 'Abrir prompt';
  String get promptCollapseLabel => 'Fechar prompt';
  String get promptToggleSemanticLabel => 'Abrir e fechar prompt do rider';
  String get copyPromptButton => 'Copiar prompt';
  String get uploadTitle => 'Enviar imagem do rider';
  String get uploadInstructions =>
      'Envie uma imagem quadrada do rider criada em um serviço externo de IA.\n'
      'Fica mais natural com o rosto centralizado e fundo transparente.';
  String get uploadingButton => 'Enviando';
  String get reuploadButton => 'Enviar de novo';
  String get uploadButton => 'Enviar imagem do rider';
  String get selectedImageFallback => 'Imagem de rider selecionada';
  String get privacyNote =>
      'O app não cria imagens de IA nem envia fotos da criança por conta própria.\n'
      'A seleção de fotos/imagens só abre quando um responsável inicia, e a imagem escolhida fica salva apenas neste dispositivo.\n'
      'Crie a imagem no serviço externo escolhido e adicione ao Yamyam Rider apenas a imagem final do rider.\n'
      'Antes de usar um serviço externo, confira como ele trata fotos e dados pessoais.';

  String get guidePopupTitle => 'Guia para criar o rider';
  String get guideReplayTooltip => 'Ver guia de novo';
  String get guidePopupMethodTitle => '📸 Como preparar a imagem';
  String get guidePopupMethodIntro =>
      'O app não tem recorte automático de rosto. Prepare uma imagem do rosto da criança que encaixe no veículo, como no exemplo.';
  String get guidePopupMethod1Title => '1. Usar o app de fotos do celular';
  String get guidePopupMethod1Body =>
      'Use a função de recortar pessoa ou remover fundo no Galaxy, iPhone ou outro app de fotos para salvar apenas o rosto da criança em um formato perto do quadrado.';
  String get guidePopupMethod2Title => '2. Usar um serviço de IA';
  String get guidePopupMethod2Body =>
      '“Envie uma imagem quadrada do rider criada em um serviço externo de IA.”';
  String get guidePopupPrivacyTitle =>
      '🔒 Por que o app não processa a imagem automaticamente?';
  String get guidePopupPrivacyBody =>
      'Como o app não recorta nem transforma fotos em servidores, ele não envia a foto original para um servidor externo para processamento. A seleção só abre quando um responsável inicia, e a imagem escolhida fica salva apenas neste dispositivo.';
  String get guidePopupSafetyTitle => '🛡️ Usado apenas neste dispositivo';
  String get guidePopupSafetyBody =>
      'A imagem preparada pelo responsável e registrada no app fica salva dentro do celular. Ela é usada localmente, sem servidor, login, publicidade ou analítica.';
  String get guidePopupConfirmButton => 'Confirmar';
}
