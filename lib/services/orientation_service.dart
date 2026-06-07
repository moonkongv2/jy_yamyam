import 'package:flutter/services.dart';

abstract interface class OrientationService {
  Future<void> lockPortrait();

  Future<void> allowMealFlowOrientations();
}

class SystemOrientationService implements OrientationService {
  const SystemOrientationService();

  @override
  Future<void> lockPortrait() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Future<void> allowMealFlowOrientations() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
