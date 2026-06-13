// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EnFirstRunOnboardingTexts implements FirstRunOnboardingTextSet {
  const EnFirstRunOnboardingTexts();

  String get title => 'Before your first Yamyam ride';
  String get subtitle => 'Turn mealtime into a gentle little journey.';
  String get previousButtonLabel => 'Back';
  String get nextButtonLabel => 'Next';
  String get startButtonLabel => 'Start';
  String get skipButtonLabel => 'Start now';

  List<FirstRunOnboardingSlideText> get slides => const [
    FirstRunOnboardingSlideText(
      emoji: '💛',
      title: 'Mealtime can be hard for parents too',
      body:
          'Some days, even one more bite can feel far away. Parents can feel tired, and children can start to feel pressured. Yamyam Rider helps replace repeated reminders with a gentle meal flow.',
      bullets: [
        'Children can see time moving forward.',
        'Parents can rely on a simple visual rhythm.',
        'Small attempts are encouraged, not judged.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🚗',
      title: 'Turn mealtime into a small ride',
      body:
          'Your child chooses a vehicle and follows a course for the set meal time. The ride helps the meal feel more playful and predictable.',
      bullets: [
        'Choose a 15, 25, or 35 minute course.',
        'Set a custom time that fits your child.',
        'A caregiver confirms completion at the end.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🧭',
      title: 'How to start',
      body:
          'Enter the child’s name, choose today’s vehicle and meal time, then start the Yamyam course.',
      bullets: [
        'Name → Vehicle → Time → Start',
        'Ingredients can appear depending on settings.',
        'You can pause and resume during a meal.',
      ],
    ),
    FirstRunOnboardingSlideText(
      emoji: '🌱',
      title: 'It does not have to be perfect',
      body:
          'Yamyam Rider is not here to judge your child. It is a gentle tool for supporting today’s meal rhythm.',
      bullets: [
        'Pausing is not a failure.',
        'Incomplete records are guidance for the next try.',
        'Praise the meal rhythm first, not only the sticker.',
      ],
    ),
  ];

  String pageSemanticLabel({
    required int currentPage,
    required int totalPages,
  }) {
    return 'Guide $currentPage of $totalPages';
  }
}
