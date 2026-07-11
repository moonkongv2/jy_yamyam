// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsPurchaseTexts implements PurchaseTextSet {
  const EsPurchaseTexts();

  String get lockedVehicleSemanticLabel => 'Bloqueado';
  String get vehiclePackIntroTitle => 'Este vehículo está en el pack';
  String get vehiclePackIntroBody =>
      'Al abrir el pack de vehículos, podrás usar todos los vehículos bloqueados.';
  String get vehiclePackIntroGuardianNote =>
      'Tras la verificación de un adulto, podrás ver la información del pack.';
  String get vehiclePackIntroContinueButton => 'Continuar con un adulto';
  String get vehiclePackIntroCloseButton => 'Cerrar';
  String get vehiclePackTitle => 'Pack de vehículos';
  String get vehiclePackOneTimePurchase =>
      'Con una sola compra, los vehículos adicionales quedan disponibles.';
  String get vehiclePackPriceTitle => 'Precio';
  String get vehiclePackLoadingPrice => 'Cargando precio';
  String get vehiclePackOfflineTitle => 'Funciona sin conexión';
  String get vehiclePackOfflineBody =>
      'Cuando la compra se completa, se guarda en este dispositivo y funciona sin conexión.';
  String get vehiclePackIncludedVehiclesTitle => 'Vehículos incluidos';
  String get vehiclePackLoadingProductMessage =>
      'Cargando información del pack desde la tienda.';
  String get vehiclePackPendingMessage =>
      'La compra se está procesando. Espera un momento.';
  String get vehiclePackSuccessMessage =>
      'El pack de vehículos está desbloqueado.';
  String get vehiclePackRestoringMessage => 'Revisando historial de compras.';
  String get vehiclePackRestoreSuccessMessage => 'Compra restaurada.';
  String get vehiclePackRestoreNotFoundMessage =>
      'No encontramos una compra del pack para restaurar.';
  String get vehiclePackErrorMessage =>
      'No se pudo completar la compra. Inténtalo de nuevo más tarde.';
  String get vehiclePackStoreUnavailableMessage =>
      'Ahora no se puede conectar con la tienda.';
  String get vehiclePackProductNotFoundMessage =>
      'No se encontró el pack en la tienda.';
  String get vehiclePackCanceledMessage => 'La compra se canceló.';
  String get vehiclePackRestoreButton => 'Restaurar compra';
  String get vehiclePackUnlockedButton => 'Ya desbloqueado';
  String get vehiclePackGuardianNote =>
      'La compra y restauración son funciones para adultos y requieren verificación.';
  String get guardianGateTitle => 'Verificación de adulto';
  String get guardianGateSubtitle =>
      'La compra y restauración del pack solo puede hacerlas un adulto.';
  String get guardianGatePrompt =>
      'Para continuar, escribe la respuesta abajo.';
  String get guardianGateAnswerHint => 'Respuesta';
  String get guardianGateErrorMessage =>
      'Revisa la respuesta e inténtalo otra vez.';
  String get guardianGateCancelButton => 'Cerrar';
  String get guardianGateContinueButton => 'Continuar';
  String get settingsVehiclePackLockedBody =>
      'La moto y el supercoche son gratis. Para ver el pack o restaurar compras, primero se verifica a un adulto.';
  String get settingsVehiclePackUnlockedBody =>
      'Pack desbloqueado. Puedes usar todos los vehículos.';
  String get settingsVehiclePackUnavailableBody =>
      'La función de compra se está preparando.';
  String get settingsVehiclePackUnlockButton => 'Compra de adulto';
  String get settingsVehiclePackRestoreButton => 'Restaurar compra';

  String vehiclePackBuyButton(String price) => 'Compra de adulto $price';
}
