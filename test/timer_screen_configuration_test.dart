import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/meal_ingredient_catalog.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/widgets/road_view.dart';

import 'helpers/test_image_fixture.dart';

void main() {
  test('Arrival dialog copy uses the selected vehicle label', () {
    final timerTexts = AppTexts.ko.timer;

    expect(timerTexts.arrivalDialogMessage('경찰차'), '경찰차가 지나갔어. 식사를 마무리했어?');
    expect(timerTexts.arrivalDialogMessage('포크레인'), '포크레인이 지나갔어. 식사를 마무리했어?');
  });

  test('Timer arrival dialog copy uses the configured vehicle', () {
    expect(
      timerArrivalDialogMessage(
        texts: AppTexts.ko.timer,
        vehicleId: 'excavator',
        languageCode: 'ko',
      ),
      '포크레인이 지나갔어. 식사를 마무리했어?',
    );
    expect(
      timerArrivalDialogMessage(
        texts: AppTexts.en.timer,
        vehicleId: 'police_car',
        languageCode: 'en',
      ),
      'Time is up. Did you finish your meal?',
    );
  });

  testWidgets('Timer screen does not apply avatar saved for another vehicle', (
    tester,
  ) async {
    final avatarFile = createTemporaryAvatarImage();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            vehicleId: 'excavator',
            avatarMode: AvatarImageMode.custom,
            customAvatarImagePath: avatarFile.path,
            customAvatarVehicleId: 'police_car',
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RoadView), findsOneWidget);
    expect(
      tester.widget<RoadView>(find.byType(RoadView)).avatar.mode,
      AvatarImageMode.defaultImage,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Timer screen applies avatar config for selected vehicle', (
    tester,
  ) async {
    final avatarFile = createTemporaryAvatarImage();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            vehicleId: 'fire_truck',
            avatarMode: AvatarImageMode.custom,
            customAvatarsByVehicle: {
              'fire_truck': VehicleAvatarConfig(
                imagePath: avatarFile.path,
                scale: 1.4,
                offsetX: 0.11,
                offsetY: -0.07,
                rotationDegrees: 9.0,
              ),
            },
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.avatar.mode, AvatarImageMode.custom);
    expect(roadView.avatar.imagePath, avatarFile.path);
    expect(roadView.avatar.scale, 1.4);
    expect(roadView.avatar.offsetX, 0.11);
    expect(roadView.avatar.offsetY, -0.07);
    expect(roadView.avatar.rotationDegrees, 9.0);
  });

  testWidgets('TimerScreen passes course ingredient ids to road ingredients', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            courseIngredientIds: const ['carrot', 'egg'],
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(
      roadView.ingredients,
      hasLength(
        MealIngredientCatalog.courseSlotCountForDuration(
          MealTimerConfig.defaults().duration,
        ),
      ),
    );
    expect(roadView.ingredients.map((ingredient) => ingredient.id).toSet(), {
      'carrot',
      'egg',
    });
    expect(tester.takeException(), isNull);
  });

  testWidgets('TimerScreen hides road ingredients when course mode is off', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            courseIngredientMode: CourseIngredientMode.off,
            courseIngredientIds: const [],
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.ingredients, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TimerScreen passes configured duration to the road course', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 60),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.courseDuration, const Duration(minutes: 60));
    expect(tester.takeException(), isNull);
  });
}
