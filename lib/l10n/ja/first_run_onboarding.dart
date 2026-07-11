// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaFirstRunOnboardingTexts implements FirstRunOnboardingTextSet {
  const JaFirstRunOnboardingTexts();

  String get title => 'Yamyam Riderを始める前に';
  String get subtitle => '食事時間を、無理のない楽しいライドに変えます。';
  String get previousButtonLabel => '戻る';
  String get nextButtonLabel => '次へ';
  String get startButtonLabel => '始める';
  String get skipButtonLabel => 'すぐ始める';

  List<FirstRunOnboardingSlideText> get slides => const [
    FirstRunOnboardingSlideText(
      emoji: '💛',
      title: '一回の食事でも、保護者には大きなことです',
      body:
          'もう一口をすすめるうちに保護者も疲れ、\n'
          'お子さまにとって食事時間が重く感じられることがあります。\n'
          'Yamyam Riderは急かす代わりに、楽しいコースを進む食事の流れを作ります。',
      bullets: ['時間の流れを目で感じられます。', 'くり返し声をかける負担を減らします。', '今日の小さな挑戦を応援します。'],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🚗',
      title: '食事時間を楽しいライドに',
      body:
          'お子さまが選んだのりものが、決めた時間のあいだコースを走ります。お子さまはのりものを追いながら、食事時間を少しつかみやすくなります。',
      bullets: [
        '15分、25分、35分のコースを選べます。',
        'お子さまに合う時間を自分で設定できます。',
        '最後は保護者が完了したか確認します。',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🧭',
      title: 'こうして始めます',
      body: 'お子さまの名前を入れ、今日乗るのりものと食事時間を選ぶと、もぐもぐコースが始まります。',
      bullets: [
        '名前設定 → のりもの選択 → 時間選択 → 出発',
        '設定により、食材を選べます。',
        '食事中は一時停止して、あとで続けられます。',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🌱',
      title: '完璧でなくても大丈夫',
      body: 'Yamyam Riderはお子さまを評価するアプリではありません。\n食事時間が少し楽しくなるよう手助けする道具です。',
      bullets: [
        '毎日の食事の流れに少しずつ慣れていきます。',
        '未完了は失敗ではなく、次のための記録です。',
        'シールよりも、流れを続けたことを先にほめてください。',
      ],
    ),
  ];

  String pageSemanticLabel({
    required int currentPage,
    required int totalPages,
  }) {
    return '案内 $currentPage/$totalPages';
  }
}
