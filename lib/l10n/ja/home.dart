// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class JaHomeTexts implements HomeTextSet {
  const JaHomeTexts();

  String get subtitle => '今日ももぐもぐコースを走ってみよう。';
  String get heroMissionSubtitle => 'ライダーがおいしいゴールを待っています';
  String get todayVehicleTitle => '今日ののりもの';
  String get morningCourse => '15分コース';
  String get morningCourseSubtitle => '軽くウォームアップ';
  String get slowCourse => '35分コース';
  String get slowCourseSubtitle => 'ゆっくりゴールへ';
  String get quickCourseTitle => 'ほかのコース';
  String get customStartButton => '時間を決めて出発';
  String get customSheetTitle => '時間を決める';
  String get mealSummaryLabel => '食事';
  String get stickerKindSummaryLabel => 'のりもの種類';
  String get stickerSummaryLabel => 'のりものシール';
  String get openStickerCollection => 'のりものシールを見る';
  String get avatarCtaSubtitle => 'お子さまの顔をのりものに乗せられます。';
  String get avatarCtaButton => '作る';
  String get avatarCtaEditButton => '編集';
  String get avatarCtaCreateSemantics => 'ライダーを作る';
  String get avatarCtaEditSemantics => 'ライダーを編集';
  String get avatarInlineDefaultState => '標準の顔を使用中';
  String get avatarInlineCustomState => 'お子さまの顔で走行中';
  String get activeTimerTitle => '進行中の食事タイマー';
  String get activeTimerResumeButton => '続ける';
  String get activeTimerCancelButton => 'キャンセル';
  String get activeTimerCancelDialogTitle => '進行中のタイマーをキャンセルしますか？';
  String get activeTimerCancelDialogMessage => 'キャンセルすると、この食事タイマーは記録されません。';
  String get activeTimerNewTimerDialogTitle => '進行中のタイマーがあります';
  String get activeTimerNewTimerDialogMessage =>
      '新しいタイマーを始めると、進行中のタイマーはキャンセルされます。';
  String get activeTimerStartNewButton => '新しく始める';
  String get activeTimerArrivedSubtitle => '食事時間が終わりました';

  String heroMissionTitle(String childName) => '$childNameのもぐもぐミッション';
  String recentCustomMinutes(int minutes) => '最近の$minutes分';
  String minuteLabel(int minutes) => '$minutes分';
  String activeTimerSubtitle(String remainingTime) => '残り時間 $remainingTime';
  String normalCourse(int minutes) => '$minutes分のいつものコース';
  String alternateCourse(int minutes) => '$minutes分コース';
  String alternateCourseSubtitle(int minutes) {
    return switch (minutes) {
      15 => '軽くウォームアップ',
      25 => 'いつものリズムでゴール',
      35 => 'ゆっくりゴールへ',
      _ => '$minutes分で走る',
    };
  }

  String progressTitle(String childName) => '$childNameのもぐもぐ記録';
  String mealCount(int count) => '$count回';
  String stickerKindCount(int count) => '$count種類';
  String stickerCount(int count) => '$count枚';
}
