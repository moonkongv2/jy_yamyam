// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class PurchaseTexts implements PurchaseTextSet {
  const PurchaseTexts();

  String get lockedVehicleSemanticLabel => '잠김';
  String get vehiclePackIntroTitle => '차량팩 빠방이에요';
  String get vehiclePackIntroBody => '차량팩을 열면 잠긴 빠방을 모두 사용할 수 있어요.';
  String get vehiclePackIntroGuardianNote => '보호자 확인 후 차량팩 정보를 볼 수 있어요.';
  String get vehiclePackIntroContinueButton => '보호자와 계속하기';
  String get vehiclePackIntroCloseButton => '닫기';
  String get vehiclePackTitle => '차량팩';
  String get vehiclePackOneTimePurchase => '한 번 구매하면 추가 차량을 계속 사용할 수 있어요.';
  String get vehiclePackPriceTitle => '가격';
  String get vehiclePackLoadingPrice => '가격을 불러오는 중';
  String get vehiclePackOfflineTitle => '오프라인 사용';
  String get vehiclePackOfflineBody => '구매가 완료되면 이 기기에 저장되어 오프라인에서도 사용할 수 있어요.';
  String get vehiclePackIncludedVehiclesTitle => '포함 차량';
  String get vehiclePackLoadingProductMessage => '스토어에서 차량팩 정보를 불러오는 중이에요.';
  String get vehiclePackPendingMessage => '구매가 처리 중이에요. 잠시만 기다려 주세요.';
  String get vehiclePackSuccessMessage => '차량팩이 열렸어요.';
  String get vehiclePackRestoringMessage => '구매 내역을 확인하고 있어요.';
  String get vehiclePackRestoreSuccessMessage => '구매 복원이 완료됐어요.';
  String get vehiclePackRestoreNotFoundMessage => '복원할 차량팩 구매 내역을 찾지 못했어요.';
  String get vehiclePackErrorMessage => '구매를 완료하지 못했어요. 잠시 후 다시 시도해 주세요.';
  String get vehiclePackStoreUnavailableMessage => '지금은 스토어에 연결할 수 없어요.';
  String get vehiclePackProductNotFoundMessage => '스토어에서 차량팩을 찾을 수 없어요.';
  String get vehiclePackCanceledMessage => '구매가 취소됐어요.';
  String get vehiclePackRestoreButton => '구매 복원';
  String get vehiclePackUnlockedButton => '이미 열림';
  String get vehiclePackGuardianNote => '구매와 복원은 보호자 확인 후 진행되는 보호자용 기능입니다.';
  String get guardianGateTitle => '보호자 확인';
  String get guardianGateSubtitle => '차량팩 구매와 복원은 보호자만 진행할 수 있어요.';
  String get guardianGatePrompt => '계속하려면 아래 문제의 답을 입력해 주세요.';
  String get guardianGateAnswerHint => '답 입력';
  String get guardianGateErrorMessage => '답을 다시 확인해 주세요.';
  String get guardianGateCancelButton => '닫기';
  String get guardianGateContinueButton => '계속';
  String get settingsVehiclePackLockedBody =>
      '오토바이와 슈퍼카는 무료로 사용할 수 있어요. 차량팩 보기와 구매 복원은 보호자 확인 후 진행돼요.';
  String get settingsVehiclePackUnlockedBody => '차량팩 열림. 모든 차량을 사용할 수 있어요.';
  String get settingsVehiclePackUnavailableBody => '구매 기능을 준비하는 중이에요.';
  String get settingsVehiclePackUnlockButton => '보호자 구매';
  String get settingsVehiclePackRestoreButton => '구매 복원';

  String vehiclePackBuyButton(String price) => '보호자 구매 $price';
}
