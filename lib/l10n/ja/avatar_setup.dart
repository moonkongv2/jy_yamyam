// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaAvatarSetupTexts implements AvatarSetupTextSet {
  const JaAvatarSetupTexts();

  String get title => 'お子さまのライダーを作る';
  String get intro => 'Yamyam Riderで使うお子さまのライダー画像を作成し、アップロードしてください。';
  String get selectedVehicleTitle => '現在選んでいるのりもの';
  String get currentAvatarModeTitle => '現在のライダーモード';
  String get defaultImageMode => '標準画像を使う';
  String get customAvatarMode => '作成したライダーを使う';
  String get copyPromptMessage => 'プロンプトをコピーしました。外部AIサービスに貼り付けて使ってください。';
  String get avatarSaveFailureMessage => 'ライダー画像を保存できませんでした。';
  String get avatarSavedMessage => 'ライダーを保存しました。';
  String get defaultImageSavedMessage => '標準画像に切り替えました。';
  String get missingAvatarWarning => 'ライダー画像が見つからないため、標準画像を表示します。';
  String get vehicleSelectionTitle => 'ライダーを乗せるのりもの';
  String get vehicleSelectionSubtitle => 'プロンプトの基準';
  String get compositePreviewTitle => '合成プレビュー';
  String get compositePreviewSubtitle => 'この姿でYamyam Riderに乗りますか？';
  String get defaultPreviewTitle => '標準画像プレビュー';
  String get useDefaultImageButton => '標準画像を使う';
  String get adjustmentTitle => 'ライダーの位置調整';
  String get faceSizeLabel => '顔の大きさ';
  String get horizontalPositionLabel => '左右の位置';
  String get verticalPositionLabel => '上下の位置';
  String get rotationLabel => '傾き';
  String get resetPositionButton => '位置をリセット';
  String get confirmAvatarButton => 'このライダーを使う';
  String get guideTitle => 'ライダー画像の作り方';
  String get guideIntro => 'アプリ内で顔を自動切り抜きしないため、下の方法でのりものに入れるライダー画像を準備してください。';
  String get promptCopyTitle => 'ライダー画像プロンプト（例）';
  String get promptHelperText =>
      'AIサービスで作る場合は、選んだのりものに合わせた下のプロンプトをコピーして貼り付けてください。';
  String get promptGuideHint => '下の例プロンプトをコピーし、AIサービスに貼り付けて使えます。';
  String get promptExpandLabel => 'プロンプトを開く';
  String get promptCollapseLabel => 'プロンプトを閉じる';
  String get promptToggleSemanticLabel => 'ライダー画像プロンプトを開閉';
  String get copyPromptButton => 'プロンプトをコピー';
  String get uploadTitle => 'ライダー画像をアップロード';
  String get uploadInstructions =>
      '外部AIサービスで作った正方形のライダー画像をアップロードしてください。\n'
      '顔が中央にあり、透明背景だと自然に見えます。';
  String get uploadingButton => 'アップロード中';
  String get reuploadButton => 'もう一度アップロード';
  String get uploadButton => 'ライダー画像をアップロード';
  String get selectedImageFallback => '選択したライダー画像';
  String get privacyNote =>
      'アプリがAI画像を直接作成したり、お子さまの写真をアップロードしたりすることはありません。\n'
      '写真/画像の選択は保護者が操作したときだけ開き、選んだライダー画像はこの端末内にだけ保存されます。\n'
      '利用する外部AIサービスで画像を作成し、完成したライダー画像だけをYamyam Riderに追加してください。\n'
      '外部サービスを使う前に、写真や個人情報の扱いを確認してください。';

  String get guidePopupTitle => 'お子さまのライダー作成ガイド';
  String get guideReplayTooltip => 'ガイドをもう一度見る';
  String get guidePopupMethodTitle => '📸 ライダー画像の準備方法';
  String get guidePopupMethodIntro =>
      'アプリ内には顔だけを切り抜く機能がありません。例のように、のりものに入れやすいお子さまの顔画像を準備してください。';
  String get guidePopupMethod1Title => '1. スマートフォンの写真アプリを使う';
  String get guidePopupMethod1Body =>
      'GalaxyやiPhoneの写真アプリにある被写体切り抜き/背景削除機能で、お子さまの顔部分だけを正方形に近い形で保存してください。';
  String get guidePopupMethod2Title => '2. AIサービスを使う';
  String get guidePopupMethod2Body => '「外部AIサービスで作った正方形のライダー画像をアップロードしてください。」';
  String get guidePopupPrivacyTitle => '🔒 なぜアプリ内で自動処理しないのですか？';
  String get guidePopupPrivacyBody =>
      'アプリ内で写真を精密に切り抜いたり変換したりしないため、元の写真を外部サーバーへ送って処理しません。写真/画像の選択は保護者が開始したときだけ開き、選んだライダー画像はこの端末内にだけ保存されます。';
  String get guidePopupSafetyTitle => '🛡️ 端末内だけで使います';
  String get guidePopupSafetyBody =>
      '保護者が準備してこのアプリに登録したライダー画像は、使用中のスマートフォン内に保存されます。サーバー、ログイン、広告、分析ツールなしでローカルだけで使います。';
  String get guidePopupConfirmButton => '確認';
}
