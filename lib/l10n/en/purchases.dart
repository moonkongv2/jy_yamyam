// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EnPurchaseTexts implements PurchaseTextSet {
  const EnPurchaseTexts();

  String get lockedVehicleSemanticLabel => 'Locked';
  String get vehiclePackIntroTitle => 'This ride is in the Vehicle Pack';
  String get vehiclePackIntroBody =>
      'Unlock the Vehicle Pack to use all locked rides.';
  String get vehiclePackIntroGuardianNote =>
      'A parent or guardian can view the pack details after a quick check.';
  String get vehiclePackIntroContinueButton => 'Continue with a Guardian';
  String get vehiclePackIntroCloseButton => 'Close';
  String get vehiclePackTitle => 'Vehicle Pack';
  String get vehiclePackOneTimePurchase =>
      'Buy once to keep using the extra vehicles.';
  String get vehiclePackPriceTitle => 'Price';
  String get vehiclePackLoadingPrice => 'Loading price';
  String get vehiclePackOfflineTitle => 'Works offline';
  String get vehiclePackOfflineBody =>
      'After purchase, access is saved on this device for offline use.';
  String get vehiclePackIncludedVehiclesTitle => 'Included vehicles';
  String get vehiclePackLoadingProductMessage =>
      'Loading vehicle pack details from the store.';
  String get vehiclePackPendingMessage =>
      'The purchase is pending. Please wait a moment.';
  String get vehiclePackSuccessMessage => 'The vehicle pack is unlocked.';
  String get vehiclePackRestoreSuccessMessage =>
      'Purchases have been restored.';
  String get vehiclePackErrorMessage =>
      'The purchase could not be completed. Please try again.';
  String get vehiclePackStoreUnavailableMessage =>
      'The store is not available right now.';
  String get vehiclePackProductNotFoundMessage =>
      'The vehicle pack was not found in the store.';
  String get vehiclePackCanceledMessage => 'The purchase was canceled.';
  String get vehiclePackRestoreButton => 'Restore Purchase';
  String get vehiclePackUnlockedButton => 'Already Unlocked';
  String get vehiclePackGuardianNote =>
      'Purchases and restore are guardian-only actions after guardian check.';
  String get guardianGateTitle => 'Guardian Check';
  String get guardianGateSubtitle =>
      'Vehicle pack purchases and restore are for parents or guardians.';
  String get guardianGatePrompt => 'To continue, enter the answer below.';
  String get guardianGateAnswerHint => 'Answer';
  String get guardianGateErrorMessage =>
      'Please check the answer and try again.';
  String get guardianGateCancelButton => 'Close';
  String get guardianGateContinueButton => 'Continue';
  String get settingsVehiclePackLockedBody =>
      'Motorcycle and Supercar are free. A guardian can view the pack or restore a purchase after the check.';
  String get settingsVehiclePackUnlockedBody =>
      'Vehicle Pack unlocked. All vehicles are available.';
  String get settingsVehiclePackUnavailableBody =>
      'Purchase features are still getting ready.';
  String get settingsVehiclePackUnlockButton => 'Guardian Purchase';
  String get settingsVehiclePackRestoreButton => 'Restore Purchase';

  String vehiclePackBuyButton(String price) => 'Guardian Purchase $price';
}
