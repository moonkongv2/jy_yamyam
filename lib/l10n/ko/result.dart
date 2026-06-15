// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class ResultTexts implements ResultTextSet {
  const ResultTexts();

  String get rewardLoading => '보상 정리 중...';
  String get recordSaved => '오늘의 기록을 저장했어';

  String title(bool mealCompleted) =>
      mealCompleted ? '식사 완주 성공!' : '아쉽지만 조금 늦었어';

  String primaryMessage(bool mealCompleted, {String? vehicleId}) =>
      mealCompleted
      ? '오늘의 냠냠코스를 끝까지 잘 마쳤어.'
      : _failedPrimaryMessagesByVehicle[vehicleId] ?? '오토바이가 먼저 지나갔어.';

  String secondaryMessage(bool mealCompleted) =>
      mealCompleted ? '지나가기 전에 식사를 잘 마쳐서 선물을 받았어!' : '다음 냠냠코스에서 다시 도전해보자.';

  String get parentTipLabel => '부모님 응원 팁';

  String parentTipTitle(bool mealCompleted) =>
      mealCompleted ? '아이에게 이렇게 말해보세요' : '다음 도전을 부드럽게 응원해요';

  String parentTipSubtitle(bool mealCompleted) =>
      mealCompleted ? '스티커보다 식사 과정을 먼저 칭찬해 주세요.' : '아쉬운 결과도 다음 도전을 위한 기록이에요.';

  String parentTipSemanticLabel(bool mealCompleted) =>
      mealCompleted ? '성공 결과 부모님 응원 팁 보기' : '미완료 결과 부모님 응원 팁 보기';

  String helpButtonLabel(bool mealCompleted) =>
      mealCompleted ? '성공과 격려 안내' : '미완료와 다음 도전 안내';

  String helpTitle(bool mealCompleted) =>
      mealCompleted ? '성공과 격려 안내' : '미완료와 다음 도전 안내';

  List<String> helpBodyParagraphs(bool mealCompleted) => mealCompleted
      ? const ['식사를 마쳤다고 확인하면 성공으로 기록돼요.']
      : const ['타이머가 먼저 도착했는데 아직 식사가 끝나지 않았으면 미완료로 기록돼요.'];

  List<String> helpBulletItems(bool mealCompleted) => mealCompleted
      ? const [
          '완료하면 선택한 빠방의 차량 스티커 1개를 받아요.',
          '보상 목표가 있으면 차량 스티커가 목표 칸을 채울 수 있어요.',
        ]
      : const [
          '미완료 기록은 식사 기록에 남지만 스티커는 지급되지 않아요.',
          '미완료는 벌이 아니라 다음 도전을 위한 기록이에요.',
        ];

  String resultHelpMeaningTitle(bool mealCompleted) => '이번 결과는 어떤 의미인가요?';

  List<String> resultHelpMeaningItems(bool mealCompleted) => mealCompleted
      ? const [
          '식사를 마쳤다고 확인되어 성공으로 기록돼요.',
          '완료한 식사는 선택한 빠방의 차량 스티커 1개를 받아요.',
          '보상 목표가 있으면 차량 스티커가 목표 칸을 채울 수 있어요.',
        ]
      : const [
          '타이머가 먼저 도착했지만 아직 식사가 끝나지 않아 미완료로 기록돼요.',
          '미완료 기록은 식사 기록에 남지만 스티커는 지급되지 않아요.',
          '미완료는 벌이 아니라 다음 도전을 위한 기록이에요.',
        ];

  String resultHelpSayTitle(bool mealCompleted) => '아이에게 이렇게 말해보세요';

  List<String> resultHelpSayItems(bool mealCompleted) => mealCompleted
      ? const [
          '끝까지 먹어보려고 한 게 정말 좋았어.',
          '오늘 냠냠코스를 끝까지 해낸 게 정말 멋져.',
          '스티커도 좋지만, 식사를 마친 게 제일 멋져.',
        ]
      : const [
          '오늘은 빠방이 먼저 도착했네. 괜찮아, 다음에 다시 해보자.',
          '어디까지 먹었는지 같이 봐볼까?',
          '오늘은 조금 어려웠구나. 다음에는 시간을 조금 늘려볼게.',
        ];

  String resultHelpAvoidTitle(bool mealCompleted) => '이런 말은 피해주세요';

  List<String> resultHelpAvoidItems(bool mealCompleted) => mealCompleted
      ? const ['빨리 먹어서 잘했어.', '다음에도 무조건 성공해야 해.', '스티커 받으려면 더 잘해야지.']
      : const ['실패했네.', '왜 이것밖에 못 먹었어?', '스티커 못 받았으니까 속상하지?'];

  String resultHelpNextCourseTitle(bool mealCompleted) => '다음 코스는 이렇게 조절해보세요';

  List<String> resultHelpNextCourseItems(bool mealCompleted) => mealCompleted
      ? const [
          '너무 급하게 먹은 것 같다면 다음에는 시간을 조금 늘려도 좋아요.',
          '여유 있게 성공했다면 같은 시간을 반복해 안정감을 만들어 주세요.',
          '스티커보다 식사 흐름과 시도를 먼저 칭찬해 주세요.',
        ]
      : const [
          '미완료가 자주 나온다면 기본 식사 시간을 조금 늘려보세요.',
          '특정 음식에서 오래 멈춘다면 직접 식재료 선택으로 코스를 더 익숙하게 만들어 주세요.',
          '기록은 아이를 평가하기보다 식사 패턴을 이해하는 데 사용해 주세요.',
        ];
}

const _failedPrimaryMessagesByVehicle = {
  'motorcycle': '오토바이가 먼저 지나갔어.',
  'fire_truck': '소방차가 먼저 출동했어.',
  'police_car': '경찰차가 먼저 지나갔어.',
  'excavator': '포크레인이 먼저 움직였어.',
  'airplane': '비행기가 먼저 날아갔어.',
  'bus': '버스가 먼저 출발했어.',
  'supercar': '슈퍼카가 먼저 달려갔어.',
  'train': '기차가 먼저 떠났어.',
  't_rex': '티렉스가 먼저 쿵쿵 지나갔어.',
  'shark': '상어가 먼저 헤엄쳐 갔어.',
  'brachio': '브라키오가 먼저 걸어갔어.',
  'pteranodon': '프테라노돈이 먼저 날아갔어.',
};
