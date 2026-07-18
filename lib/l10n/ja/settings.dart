// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaSettingsTexts implements SettingsTextSet {
  const JaSettingsTexts();

  String get title => '設定';
  String get showRemainingTime => '残り時間を表示';
  String get soundEnabled => '効果音';
  String get motivationVideoEnabled => '応援動画';
  String get motivationVideoCustomInterval => '動画の間隔を自分で設定';
  String get motivationVideoInterval => '応援動画の間隔';
  String get motivationVideoHelpTitle => '応援動画について';
  String get motivationVideoHelpSummary => '応援動画は、結果やシールとは関係ない食事中の短い声かけです。';
  List<String> get motivationVideoHelpBodyParagraphs => const [
    '応援動画は、食事の途中でお子さまの流れを助ける短い応援です。',
    '成功、未完了、シールの判定とは関係ありません。',
  ];
  List<String> get motivationVideoHelpBulletItems => const [
    '30分以下のコースでは、基本的に10%、20%のような進み具合に合わせて表示されます。',
    'とても短いカスタムコースでは、動画が重ならないよう一部を省くことがあります。',
    '30分を超える長いコースやカスタム間隔では、時間間隔を基準に表示されます。',
    'カスタム間隔は3分、5分、10分から選べます。',
    '効果音と動画の設定は別々に動作します。',
    '動画が出すぎないよう、アプリが表示間隔を調整します。',
  ];
  String get keepScreenAwake => '画面をつけたままにする';
  String get savedOnlySubtitle => 'タイマー中の音をオン/オフします';
  String get keepScreenAwakeSubtitle => '食事タイマー中に適用されます';
  String get courseIngredientModeTitle => '道の食材';
  String get courseIngredientModeOff => '使わない';
  String get courseIngredientModeManual => '自分で選ぶ';
  String get courseIngredientModeRandom => '自動で選ぶ';
  String get courseIngredientModeDescription =>
      '自分で選んだ食材だけが食事記録に残ります。自動選択は道にだけ表示されます。';
  String get defaultMealDuration => '基本の食事時間';
  String get vehicleSelection => 'のりものを選ぶ';
  String get childNameTitle => 'お子さまの名前';
  String get childNameFieldLabel => '名前';
  String get childNameSetupTitle => '今日はだれがYamyam Riderに乗る？';
  String get childNameSetupSubtitle => 'まずお子さまの名前を教えてください。';
  String get saveChildName => '名前を保存';
  String get childNameRequiredMessage => 'お子さまの名前を入力してください。';
  String get childNameSavedMessage => '名前を保存しました。';
  String get avatarSettingsTitle => 'ライダー設定';
  String get avatarDefaultState => '標準画像を使用中';
  String get avatarCustomState => '作成したライダーを使用中';
  String get avatarSettingsButton => 'ライダーを設定';
  String get helpSupportTitle => 'ヘルプとサポート';
  String get userGuide => '使い方ガイド';
  String get restorePurchase => '購入を復元';
  String get contactSupport => 'サポートに問い合わせ';
  String get aboutTitle => '情報';
  String get privacyPolicy => 'プライバシーポリシー';
  String get appVersion => 'アプリバージョン';

  String durationSegmentLabel(int minutes) => '$minutes分';
  String motivationVideoIntervalSegmentLabel(int minutes) => '$minutes分';
}
