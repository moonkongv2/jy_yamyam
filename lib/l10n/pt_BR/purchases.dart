// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PtBrPurchaseTexts implements PurchaseTextSet {
  const PtBrPurchaseTexts();

  String get lockedVehicleSemanticLabel => 'Bloqueado';
  String get vehiclePackIntroTitle => 'Este veículo está no pacote';
  String get vehiclePackIntroBody =>
      'Ao abrir o pacote de veículos, todos os veículos bloqueados ficam disponíveis.';
  String get vehiclePackIntroGuardianNote =>
      'Depois da confirmação de um responsável, você verá as informações do pacote.';
  String get vehiclePackIntroContinueButton => 'Continuar com responsável';
  String get vehiclePackIntroCloseButton => 'Fechar';
  String get vehiclePackTitle => 'Pacote de veículos';
  String get vehiclePackOneTimePurchase =>
      'Com uma única compra, os veículos extras ficam disponíveis.';
  String get vehiclePackPriceTitle => 'Preço';
  String get vehiclePackLoadingPrice => 'Carregando preço';
  String get vehiclePackOfflineTitle => 'Funciona offline';
  String get vehiclePackOfflineBody =>
      'Quando a compra é concluída, ela fica salva neste dispositivo e funciona offline.';
  String get vehiclePackIncludedVehiclesTitle => 'Veículos incluídos';
  String get vehiclePackLoadingProductMessage =>
      'Carregando informações do pacote na loja.';
  String get vehiclePackPendingMessage =>
      'A compra está em processamento. Aguarde um momento.';
  String get vehiclePackSuccessMessage =>
      'O pacote de veículos foi desbloqueado.';
  String get vehiclePackRestoringMessage => 'Verificando histórico de compras.';
  String get vehiclePackRestoreSuccessMessage => 'Compra restaurada.';
  String get vehiclePackRestoreNotFoundMessage =>
      'Não encontramos uma compra do pacote para restaurar.';
  String get vehiclePackErrorMessage =>
      'Não foi possível concluir a compra. Tente novamente mais tarde.';
  String get vehiclePackStoreUnavailableMessage =>
      'Não foi possível conectar à loja agora.';
  String get vehiclePackProductNotFoundMessage =>
      'O pacote não foi encontrado na loja.';
  String get vehiclePackCanceledMessage => 'A compra foi cancelada.';
  String get vehiclePackRestoreButton => 'Restaurar compra';
  String get vehiclePackUnlockedButton => 'Já desbloqueado';
  String get vehiclePackGuardianNote =>
      'Compra e restauração são funções para responsáveis e exigem confirmação.';
  String get guardianGateTitle => 'Confirmação do responsável';
  String get guardianGateSubtitle =>
      'A compra e a restauração do pacote devem ser feitas por um responsável.';
  String get guardianGatePrompt => 'Para continuar, digite a resposta abaixo.';
  String get guardianGateAnswerHint => 'Resposta';
  String get guardianGateErrorMessage => 'Confira a resposta e tente de novo.';
  String get guardianGateCancelButton => 'Fechar';
  String get guardianGateContinueButton => 'Continuar';
  String get settingsVehiclePackLockedBody =>
      'A moto e o supercarro são grátis. Para ver o pacote ou restaurar compras, primeiro há confirmação do responsável.';
  String get settingsVehiclePackUnlockedBody =>
      'Pacote desbloqueado. Todos os veículos estão disponíveis.';
  String get settingsVehiclePackUnavailableBody =>
      'A função de compra está sendo preparada.';
  String get settingsVehiclePackUnlockButton => 'Compra do responsável';
  String get settingsVehiclePackRestoreButton => 'Restaurar compra';

  String vehiclePackBuyButton(String price) => 'Compra do responsável $price';
}
