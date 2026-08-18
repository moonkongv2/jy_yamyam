import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_completion_status.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/result_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/services/orientation_service.dart';
import 'package:jy_yamyam/services/result_audio_service.dart';
import 'package:jy_yamyam/widgets/reward_sticker_image.dart';
import 'package:jy_yamyam/widgets/result_sticker_album_button.dart';

import 'helpers/meal_result_fixture.dart';

void main() {
  testWidgets('Completed-before-arrival result shows intro video screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final introVideoPaths = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          introControllerFactory: (assetPath) {
            introVideoPaths.add(assetPath);
            return VideoPlayerController.asset(assetPath);
          },
        ),
      ),
    );
    await tester.pump();

    expect(introVideoPaths, [
      resultVideoAssetPathForVehicle(vehicleId: 'motorcycle'),
    ]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Completed-after-arrival result also shows intro video screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final introVideoPaths = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: false),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          introControllerFactory: (assetPath) {
            introVideoPaths.add(assetPath);
            return VideoPlayerController.asset(assetPath);
          },
        ),
      ),
    );
    await tester.pump();

    expect(introVideoPaths, [
      resultVideoAssetPathForVehicle(vehicleId: 'motorcycle'),
    ]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'Completed result intro plays crowd cheering when sound enabled',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final resultAudioService = _FakeResultAudioService();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: ResultScreen(
            result: mealResult(completedBeforeArrival: true),
            config: MealTimerConfig.defaults(),
            mealProgressService: LocalMealProgressService(),
            onConfigChanged: (_) {},
            resultAudioService: resultAudioService,
            introControllerFactory: (_) => _FakeResultIntroController(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(resultAudioService.playCrowdCheeringCount, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(resultAudioService.stopCount, greaterThanOrEqualTo(1));
    },
  );

  testWidgets('Result intro skips crowd cheering when sound is disabled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final resultAudioService = _FakeResultAudioService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults().copyWith(soundEnabled: false),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          resultAudioService: resultAudioService,
          introControllerFactory: (_) => _FakeResultIntroController(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(resultAudioService.playCrowdCheeringCount, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Completed result plays sticker collect when sticker lands', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final resultAudioService = _FakeResultAudioService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          resultAudioService: resultAudioService,
          introControllerFactory: (_) {
            return VideoPlayerController.asset(
              'assets/videos/missing_result_success.mp4',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(resultAudioService.playStickerCollectCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Sticker collect skips when result sound is disabled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final resultAudioService = _FakeResultAudioService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults().copyWith(soundEnabled: false),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          resultAudioService: resultAudioService,
          introControllerFactory: (_) {
            return VideoPlayerController.asset(
              'assets/videos/missing_result_success.mp4',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(resultAudioService.playStickerCollectCount, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Failed result screen skips the intro video', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final service = LocalMealProgressService();
    final introVideoPaths = <String>[];
    final resultAudioService = _FakeResultAudioService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(mealCompleted: false),
          config: MealTimerConfig.defaults(),
          mealProgressService: service,
          onConfigChanged: (_) {},
          resultAudioService: resultAudioService,
          introControllerFactory: (assetPath) {
            introVideoPaths.add(assetPath);
            return VideoPlayerController.asset(assetPath);
          },
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });
    await tester.pump();

    expect(introVideoPaths, isEmpty);
    expect(resultAudioService.playCrowdCheeringCount, 0);
    expect(resultAudioService.playStickerCollectCount, 0);
    expect(find.byKey(const ValueKey('resultIntroScreen')), findsNothing);
    expect(find.text('조금 더 시간이 필요했어'), findsOneWidget);
    expect(find.text('오토바이가 먼저 지나갔어.'), findsOneWidget);
    expect(
      _assetImage('assets/images/result_failed_bg_portrait.png'),
      findsOneWidget,
    );
    expect(
      _assetImage(failureRiderAssetPathForVehicle(vehicleId: 'motorcycle')),
      findsOneWidget,
    );

    final snapshot = await service.loadSnapshot();
    expect(snapshot.history, hasLength(1));
    expect(snapshot.history.single.mealCompleted, isFalse);
    expect(
      snapshot.history.single.completionStatus,
      MealCompletionStatus.notCompleted,
    );
  });

  testWidgets('Success result screen uses portrait background after intro', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          introControllerFactory: (_) {
            return VideoPlayerController.asset(
              'assets/videos/missing_result_success.mp4',
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('식사 시간을 잘 마무리했어!'), findsOneWidget);
    expect(
      _assetImage('assets/images/result_success_bg_portrait.png'),
      findsOneWidget,
    );
  });

  final portraitResultLayoutCases = [
    for (final locale in AppTexts.supportedLocales)
      (locale: locale, size: const Size(393, 852), textScale: 1.0),
    (locale: const Locale('es'), size: const Size(430, 932), textScale: 1.3),
    (
      locale: const Locale('pt', 'BR'),
      size: const Size(430, 932),
      textScale: 1.3,
    ),
  ];

  for (final layoutCase in portraitResultLayoutCases) {
    testWidgets('Portrait result title stays clear of sticker album for '
        '${layoutCase.locale.toLanguageTag()} at '
        '${layoutCase.textScale}x text scale', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = layoutCase.size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetPadding();
      });

      final service = LocalMealProgressService();
      await service.createRewardGoal(
        requiredStickerCount: 5,
        rewardText: 'Reward',
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: layoutCase.locale,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(layoutCase.textScale)),
              child: child!,
            );
          },
          home: ResultScreen(
            result: mealResult(completedBeforeArrival: true),
            config: MealTimerConfig.defaults().copyWith(soundEnabled: false),
            mealProgressService: service,
            onConfigChanged: (_) {},
            introControllerFactory: (_) {
              return VideoPlayerController.asset(
                'assets/videos/missing_result_success.mp4',
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final title = find.text(
        AppTexts.forLocale(layoutCase.locale).result.title(true),
      );
      final stickerAlbumButton = find.byType(ResultStickerAlbumButton);

      expect(title, findsOneWidget);
      expect(stickerAlbumButton, findsOneWidget);
      expect(
        tester.getRect(title).overlaps(tester.getRect(stickerAlbumButton)),
        isFalse,
      );
      expect(tester.takeException(), isNull);

      final homeButton = find.byType(OutlinedButton).last;
      await tester.ensureVisible(homeButton);
      await tester.pumpAndSettle();

      final homeRect = tester.getRect(homeButton);
      expect(homeRect.top, greaterThanOrEqualTo(59));
      expect(homeRect.bottom, lessThanOrEqualTo(layoutCase.size.height - 34));
    });
  }

  testWidgets('Completed result help explains sticker reward', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          introControllerFactory: (_) {
            return VideoPlayerController.asset(
              'assets/videos/missing_result_success.mp4',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('부모님 응원 팁'), findsOneWidget);
    expect(find.text('아이에게 이렇게 말해보세요'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('completedResultGuardianTipCard')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('completedResultGuardianTipCard')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('appHelpSheet')), findsOneWidget);
    expect(find.text('아이에게 이렇게 말해보세요'), findsWidgets);
    expect(find.text('정해둔 시간 동안 먹어보려고 한 게 정말 좋았어.'), findsOneWidget);
    expect(find.text('빨리 먹어서 잘했어.'), findsOneWidget);
    expect(find.textContaining('스티커 1개'), findsOneWidget);
  });

  testWidgets(
    'Completed result shows a large sticker without an outer circle',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: ResultScreen(
            result: mealResult(completedBeforeArrival: true),
            config: MealTimerConfig.defaults().copyWith(vehicleId: 'supercar'),
            mealProgressService: LocalMealProgressService(),
            onConfigChanged: (_) {},
            introControllerFactory: (_) {
              return VideoPlayerController.asset(
                'assets/videos/missing_result_success.mp4',
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final stickerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RewardStickerImage &&
            widget.size == 132 &&
            !widget.framed,
      );
      final outerCircleFinder = find.ancestor(
        of: stickerFinder,
        matching: find.byWidgetPredicate((widget) {
          final decoration = widget is DecoratedBox ? widget.decoration : null;
          return decoration is BoxDecoration &&
              decoration.shape == BoxShape.circle;
        }),
      );

      expect(find.text('슈퍼카 스티커'), findsOneWidget);
      expect(stickerFinder, findsOneWidget);
      expect(outerCircleFinder, findsNothing);
    },
  );

  testWidgets('Incomplete result help explains record without sticker', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(mealCompleted: false),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('부모님 응원 팁'), findsOneWidget);
    expect(find.text('다음 도전을 부드럽게 응원해요'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('incompleteResultGuardianTipCard')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('incompleteResultGuardianTipCard')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('appHelpSheet')), findsOneWidget);
    expect(find.text('아이에게 이렇게 말해보세요'), findsOneWidget);
    expect(find.textContaining('오늘은 빠방이 먼저 도착했네'), findsOneWidget);
    expect(find.textContaining('미완료는 벌이 아니라 다음 도전을 위한 기록'), findsOneWidget);
    expect(find.text('실패했네.'), findsOneWidget);
  });

  testWidgets('English completed result help shows coaching sections', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          introControllerFactory: (_) {
            return VideoPlayerController.asset(
              'assets/videos/missing_result_success.mp4',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Parent tips'), findsOneWidget);
    expect(find.text('Try saying this'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('completedResultGuardianTipCard')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('appHelpSheet')), findsOneWidget);
    expect(
      find.textContaining('When you confirm the meal is finished'),
      findsOneWidget,
    );
    expect(find.text('Try saying this'), findsWidgets);
    expect(find.text('Try to avoid'), findsOneWidget);
  });

  testWidgets('English incomplete result help frames incomplete as guidance', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: ResultScreen(
          result: mealResult(mealCompleted: false),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Parent tips'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('incompleteResultGuardianTipCard')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('appHelpSheet')), findsOneWidget);
    expect(find.textContaining('not a punishment'), findsWidgets);
  });

  testWidgets('Failed result screen uses selected rider image in landscape', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(852, 393);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(mealCompleted: false),
          config: MealTimerConfig.defaults().copyWith(vehicleId: 'bus'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('compactLandscapeResultCard')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('incompleteResultGuardianTipButton')),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, '다시 출발'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '홈으로'), findsOneWidget);
    expect(find.text('버스가 먼저 출발했어.'), findsOneWidget);
    expect(
      _assetImage('assets/images/result_failed_bg_landscape.png'),
      findsOneWidget,
    );
    expect(
      _assetImage(failureRiderAssetPathForVehicle(vehicleId: 'bus')),
      findsOneWidget,
    );
  });

  testWidgets('Success result keeps actions visible in compact landscape', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(852, 393);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          introControllerFactory: (_) {
            return VideoPlayerController.asset(
              'assets/videos/missing_result_success.mp4',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cardRect = tester.getRect(
      find.byKey(const ValueKey('compactLandscapeResultCard')),
    );
    final restartButton = find.widgetWithText(FilledButton, '다시 출발');
    final homeButton = find.widgetWithText(OutlinedButton, '홈으로');

    final title = find.text('식사 시간을 잘 마무리했어!');
    final secondaryMessage = find.text('식사를 잘 마쳐서 차량 스티커를 받았어!');
    final guardianTipButton = find.byKey(
      const ValueKey('completedResultGuardianTipButton'),
    );
    final rewardBox = find.byKey(const ValueKey('compactLandscapeRewardBox'));
    final messageBox = find.byKey(const ValueKey('compactLandscapeMessageBox'));
    final stickerAlbumButton = find.byType(ResultStickerAlbumButton);

    expect(title, findsOneWidget);
    expect(guardianTipButton, findsOneWidget);
    expect(rewardBox, findsOneWidget);
    expect(messageBox, findsOneWidget);
    expect(
      _assetImage('assets/images/result_success_bg_landscape.png'),
      findsOneWidget,
    );
    expect(restartButton, findsOneWidget);
    expect(homeButton, findsOneWidget);
    expect(stickerAlbumButton, findsOneWidget);
    expect(
      tester.getRect(title).bottom,
      lessThan(tester.getRect(guardianTipButton).top),
    );
    expect(
      tester.getRect(guardianTipButton).bottom,
      greaterThan(tester.getRect(secondaryMessage).bottom),
    );
    expect(
      tester.getRect(guardianTipButton).bottom,
      lessThan(tester.getRect(restartButton).top),
    );
    final rewardRect = tester.getRect(rewardBox);
    final messageRect = tester.getRect(messageBox);
    final restartRect = tester.getRect(restartButton);
    final homeRect = tester.getRect(homeButton);
    final tipRect = tester.getRect(guardianTipButton);

    expect(restartRect.left, closeTo(rewardRect.left, 0.1));
    expect(homeRect.right, closeTo(messageRect.right, 0.1));
    expect(
      tester.getSize(restartButton).width,
      closeTo(tester.getSize(homeButton).width, 0.1),
    );
    expect(tipRect.left, closeTo(messageRect.left, 0.1));
    expect(tipRect.right, closeTo(messageRect.right, 0.1));
    expect(cardRect.contains(tester.getCenter(restartButton)), isTrue);
    expect(cardRect.contains(tester.getCenter(homeButton)), isTrue);
    expect(
      tester.getRect(restartButton).bottom,
      lessThanOrEqualTo(tester.view.physicalSize.height),
    );
    expect(
      tester.getRect(homeButton).bottom,
      lessThanOrEqualTo(tester.view.physicalSize.height),
    );
  });

  testWidgets('Result records the resolved vehicle sticker', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(completedBeforeArrival: true),
          config: MealTimerConfig.defaults().copyWith(
            vehicleId: 'missing_vehicle',
          ),
          mealProgressService: service,
          onConfigChanged: (_) {},
          introControllerFactory: (_) {
            return VideoPlayerController.asset(
              'assets/videos/missing_result_success.mp4',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.history.single.rewardIds, ['sticker_vehicle_motorcycle']);
    expect(snapshot.inventory.single.rewardId, 'sticker_vehicle_motorcycle');
  });

  testWidgets('Result screen allows landscape until disposed', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final orientationService = _FakeOrientationService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: ResultScreen(
          result: mealResult(mealCompleted: false),
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          orientationService: orientationService,
        ),
      ),
    );
    await tester.pump();

    expect(orientationService.calls, ['allowMealFlowOrientations']);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(orientationService.calls, [
      'allowMealFlowOrientations',
      'lockPortrait',
    ]);
  });

  test('Result intro video contains in landscape and covers in portrait', () {
    expect(resultIntroMediaFitForSize(const Size(844, 390)), BoxFit.contain);
    expect(resultIntroMediaFitForSize(const Size(390, 844)), BoxFit.cover);
  });
}

Finder _assetImage(String assetName) {
  return find.byWidgetPredicate((widget) {
    return widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == assetName;
  });
}

class _FakeOrientationService implements OrientationService {
  final List<String> calls = [];

  @override
  Future<void> lockPortrait() async {
    calls.add('lockPortrait');
  }

  @override
  Future<void> allowMealFlowOrientations() async {
    calls.add('allowMealFlowOrientations');
  }
}

class _FakeResultAudioService implements ResultAudioService {
  var playCrowdCheeringCount = 0;
  var playStickerCollectCount = 0;
  var stopCount = 0;
  var disposeCount = 0;

  @override
  Future<void> playCrowdCheering() async {
    playCrowdCheeringCount += 1;
  }

  @override
  Future<void> playStickerCollect() async {
    playStickerCollectCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Future<void> dispose() async {
    disposeCount += 1;
  }
}

class _FakeResultIntroController extends VideoPlayerController {
  _FakeResultIntroController() : super.asset('assets/videos/fake_result.mp4');

  var disposeCount = 0;

  @override
  Future<void> initialize() async {
    value = value.copyWith(
      duration: const Duration(seconds: 4),
      size: const Size(640, 360),
      isInitialized: true,
    );
  }

  @override
  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
  }

  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> dispose() async {
    disposeCount += 1;
    await super.dispose();
  }
}
