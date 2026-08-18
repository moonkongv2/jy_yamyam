import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/avatar_setup_screen.dart';
import 'package:jy_yamyam/services/avatar_image_picker.dart';
import 'package:jy_yamyam/services/local_avatar_image_service.dart';
import 'package:jy_yamyam/widgets/avatar/rider_guide_bottom_sheet.dart';

import 'helpers/test_image_fixture.dart';

void main() {
  testWidgets('Avatar setup screen shows guide text and prompt copy button', (
    tester,
  ) async {
    await _pumpAvatarSetupScreen(tester, MealTimerConfig.defaults());

    await _selectCustomAvatarMode(tester);

    await _expandAvatarPrompt(tester);
    expect(_avatarPromptText(tester), contains('첨부한 아이 사진을 참고'));
    expect(_avatarPromptText(tester), contains('정사각형 1:1 헤드샷'));
    expect(_avatarPromptText(tester), contains('머리 전체와 얼굴만'));
    expect(_avatarPromptText(tester), contains('텍스트, 로고, 워터마크'));
    expect(find.text('프롬프트 복사하기'), findsOneWidget);
  });

  testWidgets('English locale shows English avatar setup copy', (tester) async {
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults(),
      locale: const Locale('en'),
    );

    expect(find.text(AppTexts.en.avatarSetup.title), findsOneWidget);
    expect(find.text('우리 아이 라이더 만들기'), findsNothing);
    expect(find.text('Selected vehicle'), findsOneWidget);
    expect(find.text('Default image preview'), findsOneWidget);

    await tester.tap(find.text('Use custom rider'));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text(AppTexts.en.avatarSetup.guideTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.en.avatarSetup.guideTitle), findsOneWidget);

    await _scrollAvatarPromptToggleIntoView(tester);
    expect(find.text('Rider image prompt (example)'), findsOneWidget);
    expect(find.text('Open prompt'), findsNothing);
    expect(find.text('Copy prompt'), findsNothing);
    expect(find.byKey(const ValueKey('avatarPromptCopyButton')), findsNothing);

    await _expandAvatarPrompt(tester);
    expect(find.text('Copy prompt'), findsOneWidget);
  });

  testWidgets('Avatar setup fire truck prompt includes firefighter guidance', (
    tester,
  ) async {
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(vehicleId: 'fire_truck'),
    );

    await _selectCustomAvatarMode(tester);
    await _expandAvatarPrompt(tester);
    expect(_avatarPromptText(tester), contains('소방관'));
  });

  testWidgets('Avatar setup police car prompt includes police guidance', (
    tester,
  ) async {
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(vehicleId: 'police_car'),
    );

    await _selectCustomAvatarMode(tester);
    await _expandAvatarPrompt(tester);
    expect(_avatarPromptText(tester), contains('경찰'));
  });

  testWidgets('Avatar setup vehicle selection updates prompt and config', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults(),
      onConfigChanged: (config) => changedConfig = config,
    );

    await _selectCustomAvatarMode(tester);
    await _scrollAvatarVehicleSelectionIntoView(tester);
    expect(find.text('라이더를 태울 차량'), findsOneWidget);

    await _tapVisible(tester, _vehicleChoiceFinder('fire_truck'));
    await tester.pump();
    await _expandAvatarPrompt(tester);

    expect(changedConfig?.vehicleId, 'fire_truck');
    expect(_avatarPromptText(tester), contains('소방관'));
  });

  testWidgets('Avatar setup shows upload button in custom mode', (
    tester,
  ) async {
    await _pumpAvatarSetupScreen(tester, MealTimerConfig.defaults());

    await _selectCustomAvatarMode(tester);
    await _scrollAvatarUploadButtonIntoView(tester, '라이더 이미지 업로드');

    expect(find.widgetWithText(FilledButton, '라이더 이미지 업로드'), findsOneWidget);
    expect(
      find.textContaining('외부 AI 서비스에서 만든 정사각형 라이더 이미지를 업로드해 주세요.'),
      findsWidgets,
    );

    await _scrollAvatarSetupToBottom(tester);
    expect(find.text('합성 미리보기'), findsNothing);
    expect(find.text('라이더 위치 조정'), findsNothing);
    expect(find.byKey(const ValueKey('avatarConfirmButton')), findsNothing);
  });

  testWidgets('Avatar setup picker cancellation does not update config', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults(),
      imagePicker: _FakeAvatarImagePicker(),
      avatarImageService: _FakeLocalAvatarImageService('/tmp/avatar.png'),
      onConfigChanged: (config) => changedConfig = config,
    );

    await _selectCustomAvatarMode(tester);
    await _scrollAvatarUploadButtonIntoView(tester, '라이더 이미지 업로드');
    await tester.tap(find.widgetWithText(FilledButton, '라이더 이미지 업로드'));
    await tester.pumpAndSettle();

    expect(changedConfig, isNull);
    expect(
      find.byKey(const ValueKey('pendingAvatarImagePreview')),
      findsNothing,
    );
  });

  testWidgets('Avatar setup successful upload shows pending preview', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    final avatarFile = createTemporaryAvatarImage();
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults(),
      imagePicker: _FakeAvatarImagePicker(
        XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          path: 'picked/avatar.png',
        ),
      ),
      avatarImageService: _FakeLocalAvatarImageService(avatarFile.path),
      onConfigChanged: (config) => changedConfig = config,
    );

    await _selectCustomAvatarMode(tester);
    await _scrollAvatarUploadButtonIntoView(tester, '라이더 이미지 업로드');
    await tester.tap(find.widgetWithText(FilledButton, '라이더 이미지 업로드'));
    await tester.pumpAndSettle();

    expect(changedConfig, isNull);
    expect(
      find.byKey(const ValueKey('pendingAvatarImagePreview')),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, '다시 업로드'), findsOneWidget);
    await _scrollAvatarCompositeIntoView(tester);
    expect(find.text('합성 미리보기'), findsOneWidget);
    expect(find.text('이 모습으로 냠냠 라이더를 탈까요?'), findsOneWidget);
  });

  testWidgets('Avatar setup initializes from custom config', (tester) async {
    final avatarFile = createTemporaryAvatarImage();
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(
        avatarMode: AvatarImageMode.custom,
        customAvatarImagePath: avatarFile.path,
        customAvatarVehicleId: 'motorcycle',
      ),
    );

    expect(find.text('직접 만든 라이더 사용'), findsWidgets);
    await _scrollAvatarUploadButtonIntoView(tester, '다시 업로드');
    expect(find.widgetWithText(FilledButton, '다시 업로드'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('pendingAvatarImagePreview')),
      findsOneWidget,
    );
    await _scrollAvatarCompositeIntoView(tester);
    expect(find.text('합성 미리보기'), findsOneWidget);
  });

  testWidgets('Avatar setup warns when saved custom file is missing', (
    tester,
  ) async {
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(
        avatarMode: AvatarImageMode.custom,
        customAvatarImagePath: '/missing/avatar.png',
        customAvatarVehicleId: 'motorcycle',
      ),
    );

    await _scrollAvatarSetupToBottom(tester);
    expect(find.text('라이더 이미지를 찾을 수 없어 기본 이미지로 보여드려요.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('pendingAvatarImagePreview')),
      findsNothing,
    );
  });

  testWidgets('Avatar setup size slider updates local adjustment state', (
    tester,
  ) async {
    final avatarFile = createTemporaryAvatarImage();
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(
        avatarMode: AvatarImageMode.custom,
        customAvatarImagePath: avatarFile.path,
        customAvatarVehicleId: 'motorcycle',
      ),
    );

    await _scrollAvatarAdjustmentIntoView(tester);
    expect(_avatarSliderValue(tester, 'avatarScaleSlider'), 1.0);

    _avatarSlider(tester, 'avatarScaleSlider').onChanged!(1.2);
    await tester.pump();

    expect(_avatarSliderValue(tester, 'avatarScaleSlider'), 1.2);
  });

  testWidgets('Avatar setup reset button resets adjustment controls', (
    tester,
  ) async {
    final avatarFile = createTemporaryAvatarImage();
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(
        avatarMode: AvatarImageMode.custom,
        customAvatarImagePath: avatarFile.path,
        customAvatarVehicleId: 'motorcycle',
      ),
    );

    await _scrollAvatarAdjustmentIntoView(tester);
    _avatarSlider(tester, 'avatarScaleSlider').onChanged!(1.25);
    _avatarSlider(tester, 'avatarOffsetXSlider').onChanged!(0.12);
    _avatarSlider(tester, 'avatarOffsetYSlider').onChanged!(0.08);
    _avatarSlider(tester, 'avatarRotationSlider').onChanged!(9.0);
    await tester.pump();

    await _tapVisible(tester, find.byKey(const ValueKey('avatarResetButton')));
    await tester.pump();

    expect(_avatarSliderValue(tester, 'avatarScaleSlider'), 1.0);
    expect(_avatarSliderValue(tester, 'avatarOffsetXSlider'), 0.0);
    expect(_avatarSliderValue(tester, 'avatarOffsetYSlider'), 0.0);
    expect(_avatarSliderValue(tester, 'avatarRotationSlider'), 0.0);
  });

  testWidgets('Avatar setup confirm saves custom avatar adjustment', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    final avatarFile = createTemporaryAvatarImage();
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(
        avatarMode: AvatarImageMode.custom,
        customAvatarImagePath: avatarFile.path,
        customAvatarVehicleId: 'motorcycle',
      ),
      onConfigChanged: (config) => changedConfig = config,
    );

    await _scrollAvatarAdjustmentIntoView(tester);
    _avatarSlider(tester, 'avatarScaleSlider').onChanged!(1.3);
    _avatarSlider(tester, 'avatarOffsetXSlider').onChanged!(0.1);
    _avatarSlider(tester, 'avatarOffsetYSlider').onChanged!(0.05);
    _avatarSlider(tester, 'avatarRotationSlider').onChanged!(7.0);
    await tester.pump();

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('avatarConfirmButton')),
    );
    await tester.pump();

    expect(changedConfig?.avatarMode, AvatarImageMode.custom);
    expect(changedConfig?.customAvatarImagePath, avatarFile.path);
    expect(changedConfig?.customAvatarVehicleId, 'motorcycle');
    expect(changedConfig?.avatarScale, 1.3);
    expect(changedConfig?.avatarOffsetX, 0.1);
    expect(changedConfig?.avatarOffsetY, -0.05);
    expect(changedConfig?.avatarRotationDegrees, 7.0);
    final savedAvatar = changedConfig?.customAvatarConfigForVehicle(
      'motorcycle',
    );
    expect(savedAvatar?.imagePath, avatarFile.path);
    expect(savedAvatar?.scale, 1.3);
    expect(savedAvatar?.offsetX, 0.1);
    expect(savedAvatar?.offsetY, -0.05);
    expect(savedAvatar?.rotationDegrees, 7.0);
    expect(find.text('라이더를 저장했어요.'), findsOneWidget);
  });

  testWidgets('Avatar setup default image button saves default avatar mode', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    final avatarFile = createTemporaryAvatarImage();
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(
        avatarMode: AvatarImageMode.custom,
        customAvatarImagePath: avatarFile.path,
        customAvatarVehicleId: 'motorcycle',
        avatarScale: 1.2,
        avatarOffsetX: 0.1,
        avatarOffsetY: -0.1,
        avatarRotationDegrees: 6.0,
      ),
      onConfigChanged: (config) => changedConfig = config,
    );

    await _scrollAvatarAdjustmentIntoView(tester);
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('avatarUseDefaultButton')),
    );
    await tester.pump();

    expect(changedConfig?.avatarMode, AvatarImageMode.defaultImage);
    expect(changedConfig?.customAvatarImagePath, isNull);
    expect(changedConfig?.customAvatarVehicleId, isNull);
    expect(changedConfig?.avatarScale, 1.0);
    expect(changedConfig?.avatarOffsetX, 0.0);
    expect(changedConfig?.avatarOffsetY, 0.0);
    expect(changedConfig?.avatarRotationDegrees, 0.0);
    expect(changedConfig?.customAvatarConfigForVehicle('motorcycle'), isNull);
    expect(find.text('기본 이미지로 변경했어요.'), findsOneWidget);
  });

  testWidgets('Avatar setup stores custom avatars per vehicle', (tester) async {
    MealTimerConfig? changedConfig;
    final busAvatarFile = createTemporaryAvatarImage();
    final fireTruckAvatarFile = createTemporaryAvatarImage();
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults().copyWith(
        vehicleId: 'bus',
        avatarMode: AvatarImageMode.custom,
        customAvatarsByVehicle: {
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
        },
      ),
      onConfigChanged: (config) => changedConfig = config,
    );

    await _scrollAvatarAdjustmentIntoView(tester);
    expect(_avatarSliderValue(tester, 'avatarScaleSlider'), 1.2);

    await _scrollAvatarVehicleSelectionBackIntoView(tester);
    await _tapVisible(tester, _vehicleChoiceFinder('fire_truck'));
    await tester.pump();
    await _scrollAvatarAdjustmentIntoView(tester);

    expect(_avatarSliderValue(tester, 'avatarScaleSlider'), 1.35);
    _avatarSlider(tester, 'avatarScaleSlider').onChanged!(1.45);
    await tester.pump();

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('avatarConfirmButton')),
    );
    await tester.pump();

    expect(
      changedConfig?.customAvatarConfigForVehicle('bus')?.imagePath,
      busAvatarFile.path,
    );
    expect(changedConfig?.customAvatarConfigForVehicle('bus')?.scale, 1.2);
    expect(
      changedConfig?.customAvatarConfigForVehicle('fire_truck')?.imagePath,
      fireTruckAvatarFile.path,
    );
    expect(
      changedConfig?.customAvatarConfigForVehicle('fire_truck')?.scale,
      1.45,
    );
  });

  testWidgets(
    'Avatar setup default image clears only selected vehicle avatar',
    (tester) async {
      MealTimerConfig? changedConfig;
      final busAvatarFile = createTemporaryAvatarImage();
      final fireTruckAvatarFile = createTemporaryAvatarImage();
      await _pumpAvatarSetupScreen(
        tester,
        MealTimerConfig.defaults().copyWith(
          vehicleId: 'fire_truck',
          avatarMode: AvatarImageMode.custom,
          customAvatarsByVehicle: {
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
          },
        ),
        onConfigChanged: (config) => changedConfig = config,
      );

      await _scrollAvatarAdjustmentIntoView(tester);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('avatarUseDefaultButton')),
      );
      await tester.pump();

      expect(
        changedConfig?.customAvatarConfigForVehicle('bus')?.imagePath,
        busAvatarFile.path,
      );
      expect(changedConfig?.customAvatarConfigForVehicle('fire_truck'), isNull);
      expect(changedConfig?.avatarMode, AvatarImageMode.custom);
    },
  );

  testWidgets('Avatar setup default mode save keeps default avatar mode', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults(),
      onConfigChanged: (config) => changedConfig = config,
    );

    expect(find.text('기본 이미지 미리보기'), findsOneWidget);
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('avatarUseDefaultButton')),
    );
    await tester.pump();

    expect(changedConfig?.avatarMode, AvatarImageMode.defaultImage);
    expect(find.text('기본 이미지로 변경했어요.'), findsOneWidget);
  });

  testWidgets('Avatar setup confirm without image is disabled and safe', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    await _pumpAvatarSetupScreen(
      tester,
      MealTimerConfig.defaults(),
      onConfigChanged: (config) => changedConfig = config,
    );

    await _selectCustomAvatarMode(tester);

    expect(find.byKey(const ValueKey('avatarConfirmButton')), findsNothing);
    expect(changedConfig, isNull);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpAvatarSetupScreen(
  WidgetTester tester,
  MealTimerConfig config, {
  Locale locale = const Locale('ko'),
  ValueChanged<MealTimerConfig>? onConfigChanged,
  AvatarImagePicker? imagePicker,
  LocalAvatarImageService? avatarImageService,
  bool dismissInitialGuide = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppTexts.supportedLocales,
      locale: locale,
      home: AvatarSetupScreen(
        config: config,
        onConfigChanged: onConfigChanged ?? (_) {},
        imagePicker: imagePicker,
        avatarImageService: avatarImageService,
      ),
    ),
  );
  await tester.pump();
  if (dismissInitialGuide) {
    await _dismissAvatarGuideIfVisible(tester);
  }
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

Future<void> _expandAvatarPrompt(WidgetTester tester) async {
  await _scrollAvatarPromptToggleIntoView(tester);
  await tester.tap(find.byKey(const ValueKey('avatarPromptToggle')));
  await tester.pumpAndSettle();
}

Future<void> _scrollAvatarVehicleSelectionIntoView(WidgetTester tester) async {
  for (var index = 0; index < 4; index += 1) {
    if (find.text('라이더를 태울 차량').evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
  }
}

Future<void> _scrollAvatarVehicleSelectionBackIntoView(
  WidgetTester tester,
) async {
  for (var index = 0; index < 6; index += 1) {
    if (find.text('라이더를 태울 차량').evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();
  }
  fail('Avatar vehicle selection was not found.');
}

Future<void> _scrollAvatarCompositeIntoView(WidgetTester tester) async {
  for (var index = 0; index < 4; index += 1) {
    if (find.text('합성 미리보기').evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
  }
}

Future<void> _scrollAvatarAdjustmentIntoView(WidgetTester tester) async {
  for (var index = 0; index < 6; index += 1) {
    if (find.byKey(const ValueKey('avatarScaleSlider')).evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
  }
}

Future<void> _scrollAvatarSetupToBottom(WidgetTester tester) async {
  for (var index = 0; index < 6; index += 1) {
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
  }
}

Future<void> _scrollAvatarUploadButtonIntoView(
  WidgetTester tester,
  String label,
) async {
  final uploadButton = find.widgetWithText(FilledButton, label);
  for (var index = 0; index < 6; index += 1) {
    if (uploadButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(uploadButton);
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  fail('Avatar upload button "$label" was not found.');
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

Slider _avatarSlider(WidgetTester tester, String keyValue) {
  return tester.widget<Slider>(find.byKey(ValueKey(keyValue)));
}

double _avatarSliderValue(WidgetTester tester, String keyValue) {
  return _avatarSlider(tester, keyValue).value;
}

Finder _vehicleChoiceFinder(String vehicleId) {
  return find.byKey(ValueKey('vehicleChoice.$vehicleId'));
}

String _avatarPromptText(WidgetTester tester) {
  return tester
      .widget<SelectableText>(find.byKey(const ValueKey('avatarPromptText')))
      .data!;
}

class _FakeAvatarImagePicker implements AvatarImagePicker {
  const _FakeAvatarImagePicker([this.pickedFile]);

  final XFile? pickedFile;

  @override
  Future<XFile?> pickAvatarImage() async {
    return pickedFile;
  }
}

class _FakeLocalAvatarImageService extends LocalAvatarImageService {
  const _FakeLocalAvatarImageService(this.savedPath);

  final String savedPath;

  @override
  Future<String> savePickedAvatarImage(XFile pickedFile) async {
    return savedPath;
  }
}
