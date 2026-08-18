import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/vehicle_avatar_presentation.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/settings_screen.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/widgets/app/app_bouncy_button.dart';
import 'package:jy_yamyam/widgets/avatar/avatar_composite_preview.dart';
import 'package:jy_yamyam/widgets/avatar/rider_guide_bottom_sheet.dart';
import 'package:jy_yamyam/widgets/vehicle_selection_card.dart';

import 'helpers/app_test_harness.dart';
import 'helpers/test_image_fixture.dart';

void main() {
  testWidgets('Home screen vehicle sections render confirmed custom avatar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final avatarFile = createTemporaryAvatarImage();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            avatarMode: AvatarImageMode.custom,
            customAvatarsByVehicle: {
              'motorcycle': VehicleAvatarConfig(
                imagePath: avatarFile.path,
                scale: 1.25,
                offsetX: 0.07,
                offsetY: -0.03,
                rotationDegrees: 5.0,
              ),
            },
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          avatarImageBuilder: (context, imagePath) {
            return const ColoredBox(
              key: ValueKey('avatarCompositeOverlayImage'),
              color: Colors.pink,
            );
          },
        ),
      ),
    );
    await tester.pump();
    for (var attempt = 0; attempt < 10; attempt += 1) {
      if (find.text('아이 얼굴 탑승 중').evaluate().isNotEmpty) {
        break;
      }
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
    }

    expect(find.text('지율이의 냠냠 미션'), findsOneWidget);
    expect(find.text('오늘의 빠방'), findsOneWidget);
    expect(find.text('아이 얼굴 탑승 중'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('avatarCompositeOverlayImage')),
      findsNWidgets(3),
    );
    final customAvatarPreview = find.byWidgetPredicate((widget) {
      return widget is AvatarCompositePreview &&
          widget.avatarScale == 1.25 &&
          widget.avatarOffsetX == 0.07 &&
          widget.avatarOffsetY == -0.03 &&
          widget.avatarRotationDegrees == 5.0;
    });
    expect(customAvatarPreview, findsNWidgets(3));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Home screen falls back when selected custom avatar is missing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            avatarMode: AvatarImageMode.custom,
            customAvatarsByVehicle: const {
              'motorcycle': VehicleAvatarConfig(
                imagePath: '/missing/home-avatar.png',
                scale: 1.0,
                offsetX: 0.0,
                offsetY: 0.0,
                rotationDegrees: 0.0,
              ),
            },
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          avatarImageBuilder: (context, imagePath) {
            return const ColoredBox(
              key: ValueKey('avatarCompositeOverlayImage'),
              color: Colors.pink,
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await tester.pump();

    expect(find.text('기본 얼굴 사용 중'), findsOneWidget);
    expect(find.text('만들기'), findsOneWidget);
    expect(find.text('아이 얼굴 탑승 중'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Home screen shows saved avatar only on its vehicle choice', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final avatarFile = createTemporaryAvatarImage();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            vehicleId: 'excavator',
            avatarMode: AvatarImageMode.custom,
            customAvatarImagePath: avatarFile.path,
            customAvatarVehicleId: 'police_car',
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          avatarImageBuilder: (context, imagePath) {
            return const ColoredBox(
              key: ValueKey('avatarCompositeOverlayImage'),
              color: Colors.pink,
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('avatarCompositeOverlayImage')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((widget) {
        return widget is AvatarCompositePreview &&
            widget.vehicle.id == 'excavator' &&
            widget.avatarMode == AvatarImageMode.custom;
      }),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Home avatar CTA opens avatar setup screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    await tester.ensureVisible(find.text('만들기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('만들기'));
    await tester.pumpAndSettle();

    expect(find.text('우리 아이 라이더 만들기'), findsOneWidget);
    expect(find.text(AppTexts.ko.avatarSetup.intro), findsOneWidget);
    expect(find.text('기본 이미지 미리보기'), findsOneWidget);
    await _dismissAvatarGuideIfVisible(tester);

    await _selectCustomAvatarMode(tester);

    await _scrollAvatarPromptToggleIntoView(tester);
    expect(find.text('라이더 이미지 만들기 가이드'), findsOneWidget);
    expect(find.text('라이더 이미지 프롬프트 (예시)'), findsOneWidget);
    expect(find.byKey(const ValueKey('avatarPromptText')), findsNothing);
    expect(find.text('프롬프트 복사하기'), findsNothing);
  });

  testWidgets('Home settings apply motivation video settings to new timers', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    MealTimerConfig? changedConfig;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (config) => changedConfig = config,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('motivationVideoCustomIntervalSwitch')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    tester
        .widget<SwitchListTile>(
          find.byKey(const ValueKey('motivationVideoCustomIntervalSwitch')),
        )
        .onChanged!(true);
    await tester.pump();

    tester
        .widget<SegmentedButton<int>>(
          find.byKey(const ValueKey('motivationVideoIntervalSegmentedButton')),
        )
        .onSelectionChanged!({5});
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(changedConfig?.motivationVideoUseCustomInterval, isTrue);
    expect(changedConfig?.motivationVideoInterval, const Duration(minutes: 5));

    final regularCourseButton = tester.widget<AppBouncyButton>(
      find.ancestor(
        of: find.textContaining('25분 보통 코스'),
        matching: find.byType(AppBouncyButton),
      ),
    );
    regularCourseButton.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final randomStartButton = find.byKey(
      const ValueKey('randomStartMealIngredientsButton'),
    );
    tester.widget<OutlinedButton>(randomStartButton).onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final timerConfig = tester
        .widget<TimerScreen>(find.byType(TimerScreen))
        .config;
    expect(timerConfig.duration, const Duration(minutes: 25));
    expect(timerConfig.motivationVideoUseCustomInterval, isTrue);
    expect(timerConfig.motivationVideoInterval, const Duration(minutes: 5));
  });

  testWidgets('Settings screen keeps vehicle and avatar actions on home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('라이더 설정'), findsNothing);
    expect(find.text('기본 이미지 사용 중'), findsNothing);
    expect(find.text('라이더 설정하기'), findsNothing);
    expect(find.text('빠방 고르기'), findsNothing);
    expect(_vehicleChoiceFinder('motorcycle'), findsNothing);
  });

  testWidgets('Settings screen hides custom avatar state when active', (
    tester,
  ) async {
    final avatarFile = createTemporaryAvatarImage();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: SettingsScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            avatarMode: AvatarImageMode.custom,
            customAvatarImagePath: avatarFile.path,
            customAvatarVehicleId: 'motorcycle',
          ),
          onConfigChanged: (_) {},
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('라이더 설정'), findsNothing);
    expect(find.text('직접 만든 라이더 사용 중'), findsNothing);
    expect(find.text('빠방 고르기'), findsNothing);
    expect(find.byType(VehicleSelectionCard), findsNothing);
  });

  testWidgets('Home screen shows mission before vehicle choices and courses', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    expect(find.text('빠방 고르기'), findsNothing);
    expect(find.text('오토바이'), findsNothing);
    expect(find.text('소방차'), findsNothing);
    expect(find.text('경찰차'), findsNothing);
    expect(find.text('포크레인'), findsNothing);

    for (final vehicle in VehicleCatalog.all) {
      expect(
        _assetImage(vehicle.selectionImagePath),
        vehicle.id == 'motorcycle' ? findsNWidgets(2) : findsOneWidget,
      );
    }
    expect(
      find.byKey(const ValueKey('selectedVehiclePreview')),
      findsOneWidget,
    );

    final firstRowTop = tester
        .getTopLeft(_vehicleChoiceFinder('motorcycle'))
        .dy;
    expect(tester.getTopLeft(_vehicleChoiceFinder('supercar')).dy, firstRowTop);
    expect(
      tester.getTopLeft(_vehicleChoiceFinder('fire_truck')).dy,
      firstRowTop,
    );
    expect(
      tester.getTopLeft(_vehicleChoiceFinder('police_car')).dy,
      firstRowTop,
    );
    final secondRowTop = tester
        .getTopLeft(_vehicleChoiceFinder('excavator'))
        .dy;
    expect(secondRowTop, greaterThan(firstRowTop));
    expect(
      tester.getTopLeft(_vehicleChoiceFinder('airplane')).dy,
      secondRowTop,
    );
    expect(tester.getTopLeft(_vehicleChoiceFinder('bus')).dy, secondRowTop);
    expect(tester.getTopLeft(_vehicleChoiceFinder('train')).dy, secondRowTop);
    final thirdRowTop = tester.getTopLeft(_vehicleChoiceFinder('t_rex')).dy;
    expect(thirdRowTop, greaterThan(secondRowTop));
    expect(tester.getTopLeft(_vehicleChoiceFinder('shark')).dy, thirdRowTop);
    expect(tester.getTopLeft(_vehicleChoiceFinder('brachio')).dy, thirdRowTop);
    expect(
      tester.getTopLeft(_vehicleChoiceFinder('pteranodon')).dy,
      thirdRowTop,
    );
    expect(
      tester.getSize(_vehicleChoiceFinder('motorcycle')).width,
      tester.getSize(_vehicleChoiceFinder('fire_truck')).width,
    );
    final firstRowCenterX =
        (_vehicleChoiceRect(tester, 'motorcycle').left +
            _vehicleChoiceRect(tester, 'police_car').right) /
        2;
    final thirdRowCenterX =
        (_vehicleChoiceRect(tester, 't_rex').left +
            _vehicleChoiceRect(tester, 'pteranodon').right) /
        2;
    expect((thirdRowCenterX - firstRowCenterX).abs(), lessThan(1.0));

    final missionTitleTop = tester.getTopLeft(find.text('지율이의 냠냠 미션')).dy;
    final vehicleTitleTop = tester.getTopLeft(find.text('오늘의 빠방')).dy;
    final firstCourseTop = tester.getTopLeft(find.text('15분 코스')).dy;
    expect(missionTitleTop, lessThan(vehicleTitleTop));
    expect(vehicleTitleTop, lessThan(firstCourseTop));
  });

  testWidgets('Home mission title handles long child names on narrow screens', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(320, 720));

    const childName = '아주무지긴아이이름테스트지유나';
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: childName),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final missionTitle = find.text('$childName의 냠냠 미션');
    expect(missionTitle, findsOneWidget);
    final titleWidget = tester.widget<Text>(missionTitle);
    expect(titleWidget.maxLines, 2);
    expect(titleWidget.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Vehicle selection card renders custom avatars on saved choices',
    (tester) async {
      final busAvatarFile = createTemporaryAvatarImage();
      final fireTruckAvatarFile = createTemporaryAvatarImage();
      final avatarConfigs = {
        'bus': VehicleAvatarConfig(
          imagePath: busAvatarFile.path,
          scale: 1.2,
          offsetX: 0.08,
          offsetY: -0.04,
          rotationDegrees: 4.0,
        ),
        'fire_truck': VehicleAvatarConfig(
          imagePath: fireTruckAvatarFile.path,
          scale: 1.35,
          offsetX: -0.06,
          offsetY: 0.03,
          rotationDegrees: -8.0,
        ),
      };

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: Scaffold(
            body: SizedBox(
              width: 420,
              child: VehicleSelectionCard(
                title: '차량 선택',
                selectedVehicleId: 'motorcycle',
                onVehicleSelected: (_) {},
                avatarForVehicle: (vehicleId) {
                  final avatarConfig = avatarConfigs[vehicleId];
                  if (avatarConfig == null) {
                    return null;
                  }

                  return VehicleAvatarPresentation(
                    mode: AvatarImageMode.custom,
                    imagePath: avatarConfig.imagePath,
                    scale: avatarConfig.scale,
                    offsetX: avatarConfig.offsetX,
                    offsetY: avatarConfig.offsetY,
                    rotationDegrees: avatarConfig.rotationDegrees,
                  );
                },
                avatarImageBuilder: (context, imagePath) {
                  return ColoredBox(
                    key: ValueKey('customAvatar.$imagePath'),
                    color: Colors.pink,
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(ValueKey('customAvatar.${busAvatarFile.path}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('customAvatar.${fireTruckAvatarFile.path}')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Selected vehicle on home is saved to preferences', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    await tester.tap(_vehicleChoiceFinder('supercar'));
    await tester.pump();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('vehicleId'), 'supercar');
    expect(
      _assetImage(VehicleCatalog.supercar.selectionImagePath),
      findsNWidgets(2),
    );
    expect(
      _assetImage(VehicleCatalog.motorcycle.selectionImagePath),
      findsOneWidget,
    );
  });

  testWidgets('Vehicle selection updates even without parent rebuild', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    MealTimerConfig? changedConfig;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            vehicleId: 'fire_truck',
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (config) => changedConfig = config,
        ),
      ),
    );

    final selectedColor = _vehicleChoiceMaterial(tester, 'fire_truck').color;
    final unselectedColor = _vehicleChoiceMaterial(tester, 'police_car').color;
    expect(selectedColor, isNot(unselectedColor));

    await tester.tap(_vehicleChoiceFinder('police_car'));
    await tester.pump();

    expect(changedConfig?.vehicleId, 'police_car');
    expect(_vehicleChoiceMaterial(tester, 'fire_truck').color, unselectedColor);
    expect(_vehicleChoiceMaterial(tester, 'police_car').color, selectedColor);
  });

  testWidgets('English locale shows English home copy', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('en'));

    expect(find.byKey(const ValueKey('homeLogo')), findsOneWidget);
    expect(find.text(AppTexts.en.home.heroMissionTitle('지율')), findsOneWidget);
    expect(
      find.text('Your rider is waiting for a tasty finish'),
      findsOneWidget,
    );
    expect(find.text("Today's vehicle"), findsOneWidget);
    expect(find.text('15-min Ride'), findsOneWidget);
    expect(find.text('A light warm-up'), findsOneWidget);
    expect(find.textContaining('25-min Regular Ride'), findsOneWidget);
    expect(find.text('Other rides'), findsOneWidget);
    expect(find.text('35-min Ride'), findsOneWidget);
    expect(find.text('Cruise to the finish'), findsOneWidget);
    expect(find.textContaining('Custom time'), findsOneWidget);
  });
}

Material _vehicleChoiceMaterial(WidgetTester tester, String vehicleId) {
  return tester.widget<Material>(_vehicleChoiceFinder(vehicleId));
}

Rect _vehicleChoiceRect(WidgetTester tester, String vehicleId) {
  return tester.getRect(_vehicleChoiceFinder(vehicleId));
}

Finder _vehicleChoiceFinder(String vehicleId) {
  return find.byKey(ValueKey('vehicleChoice.$vehicleId'));
}

Finder _assetImage(String assetName) {
  return find.byWidgetPredicate((widget) {
    return widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == assetName;
  });
}

Future<void> _dismissAvatarGuideIfVisible(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final guide = find.byType(RiderGuideBottomSheet);
  if (guide.evaluate().isEmpty) {
    return;
  }
  Navigator.of(tester.element(guide)).pop();
  await tester.pumpAndSettle();
}

Future<void> _selectCustomAvatarMode(WidgetTester tester) async {
  tester
      .widget<SegmentedButton<AvatarImageMode>>(
        find.byType(SegmentedButton<AvatarImageMode>),
      )
      .onSelectionChanged!({AvatarImageMode.custom});
  await tester.pump();
}

Future<void> _scrollAvatarPromptToggleIntoView(WidgetTester tester) async {
  final promptToggle = find.byKey(const ValueKey('avatarPromptToggle'));
  for (var index = 0; index < 4; index += 1) {
    if (promptToggle.evaluate().isNotEmpty) {
      await tester.ensureVisible(promptToggle);
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  fail('Avatar prompt toggle was not found.');
}
