// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaMealIngredientTexts implements MealIngredientTextSet {
  const JaMealIngredientTexts();

  String get title => '今日食べる食材を選ぼう';
  String get subtitle => '選んだ食材がもぐもぐコースに順番に出てきます。';
  String get helpLinkLabel => '食材にはどんな意味がありますか？';
  String get helpTitle => '道の食材について';
  List<String> get helpBodyParagraphs => const [
    '食材は、お子さまが今日食べるものを思い出しやすくする道の目印です。',
    '栄養評価や成功/失敗の判定ではなく、シール報酬とも直接つながりません。',
  ];
  List<String> get helpBulletItems => const [
    '使わない: 道に食材を表示しません。',
    '自分で選ぶ: コース開始前に最大5個まで選びます。選んだ食材は食事記録に残ります。',
    '自動で選ぶ: アプリがランダムな食材を道に表示します。記録には残りません。',
    '食事記録には自分で選んだ食材だけが残ります。',
  ];
  String get randomStartButton => 'ランダムで開始';
  String get selectedStartButton => '選んで開始';

  String selectedCount(int selectedCount, int maxCount) {
    return '$selectedCount/$maxCount個選択';
  }
}
