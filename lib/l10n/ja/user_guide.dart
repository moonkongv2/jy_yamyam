// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaUserGuideTexts implements UserGuideTextSet {
  const JaUserGuideTexts();

  String get title => '使い方';
  String get subtitle => '食材、応援動画、シールのルールを確認します。';
  String get introTitle => '保護者ガイド';
  String get introBody =>
      'Yamyam Riderを始める前に、食事の流れとアプリのルールを確認できます。保護者だけでなく、食事を一緒に支える方にも役立ちます。';
  String get basicFlowTitle => startCourseTitle;
  String get ingredientsTitle => roadIngredientsTitle;
  String get motivationTitle => '応援動画';
  String get resultRewardsTitle => completionTitle;
  String get historyTitle => historyRewardsTitle;
  String get guardianTipsTitle => '保護者の使い方ヒント';

  String get whatIsYamyamTitle => 'Yamyam Riderはどんなアプリですか？';
  List<String> get whatIsYamyamItems => const [
    '食事時間をただのカウントダウンではなく、楽しいコース走行のように感じられるアプリです。',
    'お子さまがのりものを選び、決めた時間のあいだコースを進みながら食事のペースを合わせます。',
    '最後に保護者が食事を終えたか確認し、完了かどうかを決めます。',
  ];

  String get startCourseTitle => '食事コースを始める';
  List<String> get startCourseItems => const [
    'お子さまの名前を設定したあと、ホームでのりものを選べます。',
    '15分、25分、35分のコースや、自分で設定した時間を選んで始めます。',
    '設定により、コース開始前に食材を選ぶか、アプリが自動で表示できます。',
    'タイマー中の一時停止は失敗ではなく、食事の流れに合わせて少し休めます。',
  ];

  String get roadIngredientsTitle => '道の食材';
  List<String> get roadIngredientsItems => const [
    '食材は、お子さまが今日食べるものを思い出すための視覚的な目印です。',
    '栄養評価や成功/失敗の判定ではありません。',
    '使わない: 道に食材を表示しません。',
    '自分で選ぶ: コース開始前に最大5個まで選びます。選んだ食材は食事記録に残ります。',
    '自動で選ぶ: アプリがランダムな食材を道に表示します。記録には残りません。',
    '食事記録には自分で選んだ食材だけが残ります。',
  ];

  List<String> get motivationItems => const [
    '食事の途中に表示される短い応援動画です。',
    '報酬判定や成功/未完了の判定とは関係ありません。',
    '30分以下のコースでは、基本的に10%、20%のような進み具合に合わせて表示されます。',
    'とても短いカスタムコースでは、動画が重ならないよう一部を省くことがあります。',
    '長いコースやカスタム間隔では、時間間隔を基準に表示されることがあります。',
    '動画の間隔は3分、5分、10分から選べます。',
    '音の設定がオフの場合、動画だけが表示されたり音声が再生されなかったりします。',
  ];

  String get completionTitle => '完了、未完了、のりものシール';
  List<String> get completionItems => const [
    '食事を終えたと確認すると、完了として記録されます。',
    '完了すると、選んだのりもののシールを1枚もらえます。',
    '決めた時間が終わったときに食事が終わっていなければ、「まだ」を押します。この場合、未完了として記録されます。',
    '未完了の記録は残りますが、シールはもらえません。',
    'お子さまの画面では強い失敗表現を避け、次の挑戦を思い出せるトーンを保ちます。',
  ];

  String get historyRewardsTitle => '食事記録とごほうび目標';
  List<String> get historyRewardsItems => const [
    '食事記録では、目標時間、実際の時間、完了状態を確認できます。もらったシールと選んだ食材も表示されます。',
    'もらったのりものシールは、シールコレクションにたまります。',
    'ごほうび目標がある場合、のりものシールで目標マスを埋められます。',
  ];

  String get exitResumeTitle => 'タイマー中の退出と再開';
  List<String> get exitResumeItems => const [
    'タイマー中に戻る場合は、確認してから処理されます。',
    '一時停止は失敗ではなく、少し休んでから続けられます。',
    '進行中のタイマーが保存されていると、ホームにカードが表示されます。カードから続けるかキャンセルできます。',
  ];

  List<String> get guardianTipsItems => const [
    'シールよりも、食事の流れを続けたことを先にほめてください。',
    '短すぎる目標より、お子さまに合う時間を基本の食事時間に設定してください。',
    '未完了の結果は罰ではなく、次の挑戦のための記録として伝えてください。',
  ];
}
