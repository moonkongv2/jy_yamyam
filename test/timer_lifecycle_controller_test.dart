import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/controllers/timer_lifecycle_controller.dart';
import 'package:jy_yamyam/services/orientation_service.dart';
import 'package:jy_yamyam/services/screen_awake_service.dart';

void main() {
  test('TimerLifecycleController allows and restores orientations', () async {
    final controller = TimerLifecycleController();
    final orientationService = _FakeOrientationService();

    await controller.allowMealFlowOrientations(orientationService);
    await controller.lockPortraitIfNeeded(orientationService);

    expect(orientationService.calls, [
      'allowMealFlowOrientations',
      'lockPortrait',
    ]);
  });

  test('TimerLifecycleController skips portrait lock after handoff', () async {
    final controller = TimerLifecycleController();
    final orientationService = _FakeOrientationService();

    await controller.allowMealFlowOrientations(orientationService);
    controller.handOffOrientation();
    await controller.lockPortraitIfNeeded(orientationService);

    expect(controller.orientationHandedOff, isTrue);
    expect(orientationService.calls, ['allowMealFlowOrientations']);
  });

  test(
    'TimerLifecycleController applies screen awake only on changes',
    () async {
      final controller = TimerLifecycleController();
      final screenAwakeService = _FakeScreenAwakeService();

      await controller.applyScreenAwakeSetting(
        screenAwakeService: screenAwakeService,
        keepScreenAwake: true,
      );
      await controller.applyScreenAwakeSetting(
        screenAwakeService: screenAwakeService,
        keepScreenAwake: true,
      );
      await controller.applyScreenAwakeSetting(
        screenAwakeService: screenAwakeService,
        keepScreenAwake: false,
      );

      expect(controller.screenAwakeEnabled, isFalse);
      expect(screenAwakeService.enabledValues, [true, false]);
    },
  );

  test('TimerLifecycleController disables old screen awake service', () async {
    final controller = TimerLifecycleController();
    final oldService = _FakeScreenAwakeService();
    final newService = _FakeScreenAwakeService();

    await controller.applyScreenAwakeSetting(
      screenAwakeService: oldService,
      keepScreenAwake: true,
    );
    await controller.replaceScreenAwakeServiceIfNeeded(
      oldService: oldService,
      newService: newService,
    );
    await controller.applyScreenAwakeSetting(
      screenAwakeService: newService,
      keepScreenAwake: true,
    );

    expect(oldService.enabledValues, [true, false]);
    expect(newService.enabledValues, [true]);
  });

  test('TimerLifecycleController disables screen awake on dispose', () async {
    final controller = TimerLifecycleController();
    final screenAwakeService = _FakeScreenAwakeService();

    await controller.applyScreenAwakeSetting(
      screenAwakeService: screenAwakeService,
      keepScreenAwake: true,
    );
    await controller.disableScreenAwakeIfNeeded(screenAwakeService);
    await controller.disableScreenAwakeIfNeeded(screenAwakeService);

    expect(controller.screenAwakeEnabled, isFalse);
    expect(screenAwakeService.enabledValues, [true, false]);
  });
}

class _FakeOrientationService implements OrientationService {
  final List<String> calls = [];

  @override
  Future<void> allowMealFlowOrientations() async {
    calls.add('allowMealFlowOrientations');
  }

  @override
  Future<void> lockPortrait() async {
    calls.add('lockPortrait');
  }
}

class _FakeScreenAwakeService implements ScreenAwakeService {
  final List<bool> enabledValues = [];

  @override
  Future<void> setEnabled(bool enabled) async {
    enabledValues.add(enabled);
  }
}
