// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class FirstRunOnboardingTexts implements FirstRunOnboardingTextSet {
  const FirstRunOnboardingTexts();

  String get title => '냠냠 라이더 시작 전 안내';
  String get subtitle => '식사 시간을 부담 없고 신나는 라이딩으로 바꿔요.';
  String get previousButtonLabel => '이전';
  String get nextButtonLabel => '다음';
  String get startButtonLabel => '지금 시작';
  String get skipButtonLabel => '바로 시작';

  List<FirstRunOnboardingSlideText> get slides => const [
    FirstRunOnboardingSlideText(
      emoji: '💛',
      title: '밥 한 끼 먹이는 일도 참 큰일이에요',
      body:
          '아이에게 한 입만 더 권하다 보면 부모도 지치고,\n'
          '아이도 식사 시간이 부담스러워질 때가 있어요.\n'
          '냠냠 라이더는 재촉 대신 신나는 코스를 따라가는 식사 흐름을 만들어줘요.',
      bullets: ['아이가 시간을 눈으로 느껴요.', '부모의 반복적인 재촉을 줄여요.', '오늘의 작은 시도를 응원해요.'],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🚗',
      title: '식사 시간을 신나는 라이딩으로',
      body:
          '아이가 고른 탈것이 정해진 시간 동안 코스를 달려요. 아이는 빠방이를 따라가며 식사 시간을 조금 더 쉽게 느낄 수 있어요.',
      bullets: [
        '15분, 25분, 35분 코스를 고를 수 있어요.',
        '아이에게 맞는 시간을 직접 설정할 수도 있어요.',
        '마지막에는 보호자가 완료 여부를 확인해요.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🧭',
      title: '이렇게 시작해요',
      body: '아이 이름을 입력하고, 오늘 탈 빠방이와 식사 시간을 고르면 냠냠 코스가 시작돼요.',
      bullets: [
        '이름 설정 → 탈것 선택 → 시간 선택 → 출발',
        '설정에 따라 식재료를 고를 수 있어요.',
        '식사 중에는 잠깐 멈췄다가 다시 이어갈 수 있어요.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🌱',
      title: '완벽하지 않아도 괜찮아요',
      body: '냠냠 라이더는 아이를 평가하는 앱이 아니에요.\n아이의 식사 시간이 더 즐거워지도록 도와주는 도구예요.',
      bullets: [
        '매일 냠냠 라이더와 함께 식사 시간의 흐름을 익혀가요.',
        '미완료는 실패가 아니라 다음 도전을 위한 기록이에요.',
        '스티커보다 식사 흐름을 이어간 점을 먼저 칭찬해 주세요.',
      ],
    ),
  ];

  String pageSemanticLabel({
    required int currentPage,
    required int totalPages,
  }) {
    return '안내 $currentPage/$totalPages';
  }
}
