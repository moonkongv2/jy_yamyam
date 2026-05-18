import 'package:wakelock_plus/wakelock_plus.dart';

abstract interface class ScreenAwakeService {
  Future<void> setEnabled(bool enabled);
}

class WakelockScreenAwakeService implements ScreenAwakeService {
  const WakelockScreenAwakeService();

  @override
  Future<void> setEnabled(bool enabled) {
    return WakelockPlus.toggle(enable: enabled);
  }
}
