// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaTimerTexts implements TimerTextSet {
  const JaTimerTexts();

  String get courseTitle => '今日のもぐもぐコース';
  String get progressJustStarted => '出発しました！';
  String get progressGoingWell => 'いい調子です！';
  String get progressPastHalfway => 'もう半分をこえました！';
  String get progressAlmostThere => 'もうすぐ到着！';
  String get progressArrived => '到着しました！';
  String get completeDialogTitle => '食事は終わりましたか？';
  String get completeDialogMessage => '今日のもぐもぐコースを終わりますか？';
  String get exitDialogTitle => 'コースをやめますか？';
  String get exitDialogMessage => '今出ると、進行中のもぐもぐコースは保存されません。';
  String get exitDialogCancelButton => '続ける';
  String get exitDialogConfirmButton => 'やめる';
  String get pauseButton => '一時停止';
  String get completeMealButton => '食事完了';
  String get runningArrivalLabel => '残りの食事時間';
  String get pausedTimeLabel => 'ひと休み中';
  String get arrivedTimeLabel => '到着済み';
  String get idleTimeLabel => '準備中';
  String get pausedProgressMessage => '少し休みましょう';
  String get arrivedProgressMessage => '到着しました！';
  String get idleProgressMessage => '出発準備中';
  String get finishDriveProgressMessage => '仕上げに向かっています！';
  String get finishDriveTimeLabel => '仕上げ中';
  String get previewReady => '準備... 🚦';
  String get previewGo => '出発！ 🌟';

  String arrivalDialogMessage(String vehicleLabel) {
    return '$vehicleLabelが先に到着しました。食事は終わりましたか？';
  }

  String remainingTime(String remaining) => '残り時間 $remaining';
  String remainingTimeSemanticLabel(String label, String remaining) {
    return '$label、残り時間 $remaining';
  }
}
