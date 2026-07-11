// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaPurchaseTexts implements PurchaseTextSet {
  const JaPurchaseTexts();

  String get lockedVehicleSemanticLabel => 'ロック中';
  String get vehiclePackIntroTitle => 'のりものパックののりものです';
  String get vehiclePackIntroBody => 'のりものパックを開くと、ロックされたのりものをすべて使えます。';
  String get vehiclePackIntroGuardianNote => '保護者確認のあと、のりものパック情報を表示します。';
  String get vehiclePackIntroContinueButton => '保護者と続ける';
  String get vehiclePackIntroCloseButton => '閉じる';
  String get vehiclePackTitle => 'のりものパック';
  String get vehiclePackOneTimePurchase => '一度購入すると、追加のりものを続けて使えます。';
  String get vehiclePackPriceTitle => '価格';
  String get vehiclePackLoadingPrice => '価格を読み込み中';
  String get vehiclePackOfflineTitle => 'オフラインで使用';
  String get vehiclePackOfflineBody => '購入が完了するとこの端末に保存され、オフラインでも使えます。';
  String get vehiclePackIncludedVehiclesTitle => '含まれるのりもの';
  String get vehiclePackLoadingProductMessage => 'ストアからのりものパック情報を読み込んでいます。';
  String get vehiclePackPendingMessage => '購入を処理中です。少しお待ちください。';
  String get vehiclePackSuccessMessage => 'のりものパックが開きました。';
  String get vehiclePackRestoringMessage => '購入履歴を確認しています。';
  String get vehiclePackRestoreSuccessMessage => '購入の復元が完了しました。';
  String get vehiclePackRestoreNotFoundMessage =>
      '復元できるのりものパックの購入履歴が見つかりませんでした。';
  String get vehiclePackErrorMessage => '購入を完了できませんでした。少しあとで再試行してください。';
  String get vehiclePackStoreUnavailableMessage => '現在ストアに接続できません。';
  String get vehiclePackProductNotFoundMessage => 'ストアでのりものパックが見つかりません。';
  String get vehiclePackCanceledMessage => '購入はキャンセルされました。';
  String get vehiclePackRestoreButton => '購入を復元';
  String get vehiclePackUnlockedButton => '開放済み';
  String get vehiclePackGuardianNote => '購入と復元は、保護者確認のあとに行う保護者向け機能です。';
  String get guardianGateTitle => '保護者確認';
  String get guardianGateSubtitle => 'のりものパックの購入と復元は保護者だけが行えます。';
  String get guardianGatePrompt => '続けるには、下の問題の答えを入力してください。';
  String get guardianGateAnswerHint => '答え';
  String get guardianGateErrorMessage => '答えをもう一度確認してください。';
  String get guardianGateCancelButton => '閉じる';
  String get guardianGateContinueButton => '続ける';
  String get settingsVehiclePackLockedBody =>
      'オートバイとスーパーカーは無料で使えます。のりものパックの表示と購入復元は保護者確認のあとに進みます。';
  String get settingsVehiclePackUnlockedBody => 'のりものパック開放済み。すべてののりものを使えます。';
  String get settingsVehiclePackUnavailableBody => '購入機能を準備しています。';
  String get settingsVehiclePackUnlockButton => '保護者購入';
  String get settingsVehiclePackRestoreButton => '購入を復元';

  String vehiclePackBuyButton(String price) => '保護者購入 $price';
}
