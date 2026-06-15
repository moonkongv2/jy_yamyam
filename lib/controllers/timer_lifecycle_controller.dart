import '../services/orientation_service.dart';
import '../services/screen_awake_service.dart';

class TimerLifecycleController {
  bool _screenAwakeEnabled = false;
  bool _orientationHandedOff = false;

  bool get screenAwakeEnabled => _screenAwakeEnabled;
  bool get orientationHandedOff => _orientationHandedOff;

  Future<void> allowMealFlowOrientations(
    OrientationService orientationService,
  ) {
    return orientationService.allowMealFlowOrientations();
  }

  Future<void> replaceScreenAwakeServiceIfNeeded({
    required ScreenAwakeService oldService,
    required ScreenAwakeService newService,
  }) async {
    if (oldService == newService || !_screenAwakeEnabled) {
      return;
    }

    _screenAwakeEnabled = false;
    await oldService.setEnabled(false);
  }

  Future<void> applyScreenAwakeSetting({
    required ScreenAwakeService screenAwakeService,
    required bool keepScreenAwake,
  }) async {
    if (_screenAwakeEnabled == keepScreenAwake) {
      return;
    }

    _screenAwakeEnabled = keepScreenAwake;
    await screenAwakeService.setEnabled(keepScreenAwake);
  }

  void handOffOrientation() {
    _orientationHandedOff = true;
  }

  Future<void> lockPortraitIfNeeded(OrientationService orientationService) {
    if (_orientationHandedOff) {
      return Future<void>.value();
    }

    return orientationService.lockPortrait();
  }

  Future<void> disableScreenAwakeIfNeeded(
    ScreenAwakeService screenAwakeService,
  ) {
    if (!_screenAwakeEnabled) {
      return Future<void>.value();
    }

    _screenAwakeEnabled = false;
    return screenAwakeService.setEnabled(false);
  }
}
