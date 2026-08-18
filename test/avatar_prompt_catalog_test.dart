import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/avatar_prompt_catalog.dart';
import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';

void main() {
  test('Avatar prompt catalog returns prompts for every vehicle', () {
    for (final vehicle in VehicleCatalog.all) {
      final prompt = AvatarPromptCatalog.promptForVehicle(vehicle, 'ko');

      expect(prompt.trim(), isNotEmpty, reason: vehicle.id);
      expect(prompt, contains('첨부한 아이 사진을 참고'));
      expect(prompt, contains('아이의 주요 얼굴 특징은 유지'));
      expect(prompt, contains('정사각형 1:1 헤드샷'));
      expect(prompt, contains('텍스트, 로고, 워터마크 금지'));
    }
  });

  test('Avatar prompt catalog includes vehicle-specific Korean guidance', () {
    final motorcyclePrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.motorcycle,
      'ko',
    );
    final fireTruckPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.fireTruck,
      'ko',
    );
    final policeCarPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.policeCar,
      'ko',
    );
    final excavatorPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.excavator,
      'ko',
    );
    final airplanePrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.airplane,
      'ko',
    );
    final busPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.bus,
      'ko',
    );
    final supercarPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.supercar,
      'ko',
    );
    final trainPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.train,
      'ko',
    );
    final brachioPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.brachio,
      'ko',
    );
    final pteranodonPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.pteranodon,
      'ko',
    );

    expect(
      motorcyclePrompt.contains('오토바이') || motorcyclePrompt.contains('라이더'),
      isTrue,
    );
    expect(fireTruckPrompt, contains('소방관'));
    expect(policeCarPrompt, contains('경찰'));
    expect(
      excavatorPrompt.contains('안전모') || excavatorPrompt.contains('포크레인'),
      isTrue,
    );
    expect(airplanePrompt, contains('조종사'));
    expect(busPrompt, contains('버스 기사'));
    expect(supercarPrompt, contains('레이서'));
    expect(trainPrompt, contains('기관사'));
    expect(brachioPrompt, contains('브라키오'));
    expect(pteranodonPrompt, contains('프테라노돈'));
  });
}
