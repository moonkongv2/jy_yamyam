// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EnResultTexts implements ResultTextSet {
  const EnResultTexts();

  String get rewardLoading => 'Getting your reward ready...';
  String get recordSaved => "Today's record is saved.";

  String title(bool mealCompleted) => mealCompleted
      ? 'Mealtime wrapped up well!'
      : 'A little more time was needed';

  String primaryMessage(bool mealCompleted, {String? vehicleId}) =>
      mealCompleted
      ? 'You finished your meal within the planned time.'
      : _failedPrimaryMessagesByVehicle[vehicleId] ??
            'This meal needed a little more time today.';

  String secondaryMessage(bool mealCompleted) => mealCompleted
      ? 'You did a great job finishing your meal and earned a sticker!'
      : "Let's adjust the next mealtime a little.";

  String get parentTipLabel => 'Parent tips';

  String parentTipTitle(bool mealCompleted) =>
      mealCompleted ? 'Try saying this' : 'Encourage the next try';

  String parentTipSubtitle(bool mealCompleted) => mealCompleted
      ? 'Focus on the effort, not just the sticker.'
      : 'It’s a clue for the next ride, not a punishment.';

  String parentTipSemanticLabel(bool mealCompleted) => mealCompleted
      ? 'View parent tips for a completed meal'
      : 'View parent tips for an incomplete meal';

  String helpButtonLabel(bool mealCompleted) => mealCompleted
      ? 'Mealtime wrap-up and encouragement tips'
      : 'Next mealtime adjustment tips';

  String helpTitle(bool mealCompleted) => mealCompleted
      ? 'Mealtime wrap-up and encouragement tips'
      : 'Next mealtime adjustment tips';

  List<String> helpBodyParagraphs(bool mealCompleted) => mealCompleted
      ? const [
          'When you confirm the meal is finished, it’s recorded as complete.',
        ]
      : const [
          'If the planned time ends and the meal is not finished, it is saved as incomplete.',
        ];

  List<String> helpBulletItems(bool mealCompleted) => mealCompleted
      ? const [
          'A completed meal earns 1 sticker for the selected vehicle.',
          'If a reward goal is active, the sticker can fill one goal slot.',
        ]
      : const [
          'Incomplete meals stay in meal history, but no sticker is awarded.',
          'An incomplete result is a record for the next try, not a punishment.',
        ];

  String resultHelpMeaningTitle(bool mealCompleted) =>
      'What does this result mean?';

  List<String> resultHelpMeaningItems(bool mealCompleted) => mealCompleted
      ? const [
          'When you confirm the meal is finished, it is recorded as complete.',
          'A completed meal earns one sticker for the selected vehicle.',
          'If a reward goal is active, the sticker can fill one goal slot.',
        ]
      : const [
          'The planned time ended while the meal was still unfinished, so it was recorded as incomplete.',
          'Incomplete meals stay in meal history, but no sticker is awarded.',
          'An incomplete result is a record for the next try, not a punishment.',
        ];

  String resultHelpSayTitle(bool mealCompleted) => 'Try saying this';

  List<String> resultHelpSayItems(bool mealCompleted) => mealCompleted
      ? const [
          'I really liked how you kept trying during your mealtime.',
          'You stuck with today’s ride all the way to the end.',
          'The sticker is fun, but finishing your meal is the biggest win.',
        ]
      : const [
          'The rider arrived first today. That’s okay—we can try again next time.',
          'Let’s look at how far you got.',
          'Today felt a little hard. I can give you more time next time.',
        ];

  String resultHelpAvoidTitle(bool mealCompleted) => 'Try to avoid';

  List<String> resultHelpAvoidItems(bool mealCompleted) => mealCompleted
      ? const [
          'Good job eating fast.',
          'You have to succeed every time.',
          'You need to do better if you want a sticker.',
        ]
      : const [
          'You failed.',
          'Why did you only eat this much?',
          'You didn’t get a sticker because you didn’t do well.',
        ];

  String resultHelpNextCourseTitle(bool mealCompleted) => 'For the next ride';

  List<String> resultHelpNextCourseItems(bool mealCompleted) => mealCompleted
      ? const [
          'If the meal felt rushed, try a slightly longer timer next time.',
          'If your child seemed comfortable, repeat the same duration to build confidence.',
          'Praise the mealtime rhythm and effort more than the sticker.',
        ]
      : const [
          'If incomplete results happen often, try a longer default meal duration.',
          'If your child gets stuck on certain foods, use manual ingredient selection to make the course feel more familiar.',
          'Use the record to understand mealtime patterns, not to grade the child.',
        ];
}

const _failedPrimaryMessagesByVehicle = {
  'motorcycle': 'This meal needed a little more time today.',
  'fire_truck': 'This meal needed a little more time today.',
  'police_car': 'This meal needed a little more time today.',
  'excavator': 'This meal needed a little more time today.',
  'airplane': 'This meal needed a little more time today.',
  'bus': 'This meal needed a little more time today.',
  'supercar': 'This meal needed a little more time today.',
  'train': 'This meal needed a little more time today.',
  't_rex': 'This meal needed a little more time today.',
  'shark': 'This meal needed a little more time today.',
  'brachio': 'This meal needed a little more time today.',
  'pteranodon': 'This meal needed a little more time today.',
};
