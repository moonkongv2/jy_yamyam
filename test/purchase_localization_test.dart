import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';

void main() {
  test('Purchase localization includes required Korean copy', () {
    final purchases = AppTexts.ko.purchases;

    expect(purchases.lockedVehicleSemanticLabel, '잠김');
    expect(purchases.vehiclePackTitle, '차량팩');
    expect(purchases.guardianGateTitle, '보호자 확인');
    expect(purchases.settingsVehiclePackUnlockButton, '보호자 구매');
    expect(purchases.settingsVehiclePackLockedBody, contains('보호자 확인'));
    expect(purchases.settingsVehiclePackUnlockedBody, contains('차량팩 열림'));
    expect(purchases.vehiclePackRestoreButton, '구매 복원');
    expect(purchases.vehiclePackPendingMessage, contains('처리 중'));
    expect(purchases.vehiclePackSuccessMessage, contains('열렸어요'));
    expect(purchases.vehiclePackErrorMessage, contains('완료하지 못했어요'));
    expect(purchases.vehiclePackCanceledMessage, contains('취소'));
    expect(purchases.vehiclePackOfflineBody, contains('오프라인'));
  });

  test('Purchase localization includes required English copy', () {
    final purchases = AppTexts.en.purchases;

    expect(purchases.lockedVehicleSemanticLabel, 'Locked');
    expect(purchases.vehiclePackTitle, 'Vehicle Pack');
    expect(purchases.guardianGateTitle, 'Guardian Check');
    expect(purchases.settingsVehiclePackUnlockButton, 'Guardian Purchase');
    expect(purchases.settingsVehiclePackLockedBody, contains('guardian'));
    expect(purchases.settingsVehiclePackUnlockedBody, contains('unlocked'));
    expect(purchases.vehiclePackRestoreButton, 'Restore Purchase');
    expect(purchases.vehiclePackPendingMessage, contains('pending'));
    expect(purchases.vehiclePackSuccessMessage, contains('unlocked'));
    expect(
      purchases.vehiclePackErrorMessage,
      contains('could not be completed'),
    );
    expect(purchases.vehiclePackCanceledMessage, contains('canceled'));
    expect(purchases.vehiclePackOfflineBody, contains('offline'));
  });

  test('Avatar privacy copy describes optional local image selection', () {
    expect(AppTexts.ko.avatarSetup.privacyNote, contains('직접 누를 때만'));
    expect(AppTexts.ko.avatarSetup.privacyNote, contains('기기 안에만 저장'));
    expect(
      AppTexts.en.avatarSetup.privacyNote,
      contains('only when a guardian starts it'),
    );
    expect(
      AppTexts.en.avatarSetup.privacyNote,
      contains('saved on this device only'),
    );
    expect(
      AppTexts.en.avatarSetup.privacyNote,
      isNot(contains('never accesses photos')),
    );
  });
}
