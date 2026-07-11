// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaResultTexts implements ResultTextSet {
  const JaResultTexts();

  String get rewardLoading => 'ごほうびを準備中...';
  String get recordSaved => '今日の記録を保存しました。';

  String title(bool mealCompleted) =>
      mealCompleted ? '食事時間を上手に終えました！' : 'もう少し時間が必要でした';

  String primaryMessage(bool mealCompleted, {String? vehicleId}) =>
      mealCompleted
      ? '今日は決めた流れの中で食事を終えました。'
      : _jaFailedPrimaryMessagesByVehicle[vehicleId] ?? '今日は食事にもう少し時間が必要でした。';

  String secondaryMessage(bool mealCompleted) =>
      mealCompleted ? '食事を終えたので、のりものシールをもらいました！' : '次の食事時間は少し調整してみましょう。';

  String get parentTipLabel => '保護者の応援ヒント';

  String parentTipTitle(bool mealCompleted) =>
      mealCompleted ? 'こんな声かけをしてみましょう' : '次の挑戦をやさしく応援しましょう';

  String parentTipSubtitle(bool mealCompleted) =>
      mealCompleted ? 'シールよりも、食事の過程を先にほめてください。' : '思い通りでない結果も、次につなげる記録です。';

  String parentTipSemanticLabel(bool mealCompleted) =>
      mealCompleted ? '完了結果の保護者応援ヒントを見る' : '未完了結果の保護者応援ヒントを見る';

  String helpButtonLabel(bool mealCompleted) =>
      mealCompleted ? '食事完了と応援の案内' : '次の食事調整の案内';

  String helpTitle(bool mealCompleted) =>
      mealCompleted ? '食事完了と応援の案内' : '次の食事調整の案内';

  List<String> helpBodyParagraphs(bool mealCompleted) => mealCompleted
      ? const ['食事を終えたと確認すると、完了として記録されます。']
      : const ['決めた時間が終わっても食事が終わっていない場合は、未完了として記録されます。'];

  List<String> helpBulletItems(bool mealCompleted) => mealCompleted
      ? const ['完了すると、選んだのりもののシールを1枚もらえます。', 'ごほうび目標がある場合、のりものシールで目標マスを埋められます。']
      : const ['未完了の記録は食事記録に残りますが、シールは付与されません。', '未完了は罰ではなく、次の挑戦のための記録です。'];

  String resultHelpMeaningTitle(bool mealCompleted) => '今回の結果にはどんな意味がありますか？';

  List<String> resultHelpMeaningItems(bool mealCompleted) => mealCompleted
      ? const [
          '食事を終えたと確認され、完了として記録されます。',
          '完了した食事では、選んだのりもののシールを1枚もらえます。',
          'ごほうび目標があれば、シールで目標マスを埋められます。',
        ]
      : const [
          '決めた時間は終わりましたが、食事がまだ終わっていないため未完了として記録されます。',
          '未完了の記録は残りますが、シールは付与されません。',
          '未完了は罰ではなく、次の挑戦のための記録です。',
        ];

  String resultHelpSayTitle(bool mealCompleted) => 'こんなふうに言ってみましょう';

  List<String> resultHelpSayItems(bool mealCompleted) => mealCompleted
      ? const [
          '決めた時間のあいだ食べようとしたのがよかったね。',
          '今日のもぐもぐコースを最後までやれたね。すてきだよ。',
          'シールもうれしいけれど、食事を終えられたことがいちばんすてきだね。',
        ]
      : const [
          '今日はのりものが先に着いたね。大丈夫、次にまたやってみよう。',
          'どこまで食べられたか一緒に見てみようか。',
          '今日は少し難しかったね。次は時間を少し長くしてみるね。',
        ];

  String resultHelpAvoidTitle(bool mealCompleted) => '避けたい言い方';

  List<String> resultHelpAvoidItems(bool mealCompleted) => mealCompleted
      ? const ['早く食べられてえらいね。', '次も必ず成功しようね。', 'シールをもらうならもっとがんばらないと。']
      : const ['失敗したね。', 'どうしてこれしか食べられなかったの？', 'シールがもらえなくて悲しいね。'];

  String resultHelpNextCourseTitle(bool mealCompleted) => '次のコースはこう調整してみましょう';

  List<String> resultHelpNextCourseItems(bool mealCompleted) => mealCompleted
      ? const [
          '急いで食べていたようなら、次は時間を少し長くしてもよいです。',
          '余裕をもって完了できたら、同じ時間をくり返して安心感を作りましょう。',
          'シールよりも、食事の流れと挑戦を先にほめてください。',
        ]
      : const [
          '未完了が続く場合は、基本の食事時間を少し長くしてみましょう。',
          '特定の食べ物で止まりやすい場合は、食材を自分で選ぶ設定でコースをなじみやすくしましょう。',
          '記録はお子さまを評価するためではなく、食事パターンを理解するために使いましょう。',
        ];
}

const _jaFailedPrimaryMessagesByVehicle = {
  'motorcycle': 'オートバイが先に通り過ぎました。',
  'fire_truck': '消防車が先に出動しました。',
  'police_car': 'パトカーが先に通り過ぎました。',
  'excavator': 'ショベルカーが先に動きました。',
  'airplane': '飛行機が先に飛んでいきました。',
  'bus': 'バスが先に出発しました。',
  'supercar': 'スーパーカーが先に走っていきました。',
  'train': '電車が先に出発しました。',
  't_rex': 'ティラノが先にどしどし進みました。',
  'shark': 'サメが先に泳いでいきました。',
  'brachio': 'ブラキオが先に歩いていきました。',
  'pteranodon': 'プテラノドンが先に飛んでいきました。',
};
