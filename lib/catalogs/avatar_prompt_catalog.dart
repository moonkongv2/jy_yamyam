import '../models/vehicle.dart';

abstract final class AvatarPromptCatalog {
  static const _koreanBasePrompt = '''
첨부한 아이 사진을 참고해서 아이의 주요 얼굴 특징은 유지해 주세요.
귀엽고 친근한 캐릭터 스타일로 만들어 주세요.
정사각형 1:1 헤드샷 구도로, 얼굴 중앙에 배치해 주세요.
머리 전체 + 얼굴 + 목 일부가 보이게 하고, 어깨/몸통은 최소화해 주세요.
모바일 앱에 어울리는 단순하고 선명한 캐릭터풍 또는 부드러운 3D 캐릭터풍으로 만들어 주세요.
투명 배경을 권장합니다.
투명 배경이 어렵다면 단순한 흰색 또는 밝은 단색 배경으로 만들어 주세요.
텍스트, 로고, 워터마크 금지.
전신, 여러 사람, 복잡한 배경은 금지해 주세요.
''';

  static const _englishBasePrompt = '''
Use the attached child photo as reference and keep the child's main facial features.
Create a cute, friendly character-style square 1:1 headshot.
Place the face in the center, showing the full head, face, and a small part of the neck.
Minimize shoulders and torso.
Use a simple, clear character style or a soft 3D character style suitable for a mobile app.
A transparent background is recommended.
If transparency is difficult, use a simple white or bright solid background.
Do not include text, logos, or watermarks.
Avoid full-body images, multiple people, or complex backgrounds.
''';

  static const _koreanAdditionsByVehicleId = {
    'motorcycle': '''
오토바이 라이더 컨셉으로 만들어 주세요.
귀여운 헬멧을 씌워 주세요.
필요하면 고글/선글라스를 추가해도 됩니다.
얼굴은 가리지 않게 해 주세요.
''',
    'fire_truck': '''
소방관 라이더 컨셉으로 만들어 주세요.
소방관 헬멧 또는 소방관 모자를 씌워 주세요.
밝고 든든한 느낌으로 만들어 주세요.
''',
    'police_car': '''
경찰관 라이더 컨셉으로 만들어 주세요.
경찰 모자 또는 경찰 헬멧을 씌워 주세요.
밝고 자신감 있는 표정으로 만들어 주세요.
''',
    'excavator': '''
포크레인 기사 컨셉으로 만들어 주세요.
노란 안전모를 씌워 주세요.
필요하면 작업복 느낌은 아주 약하게 넣어 주세요.
얼굴 중심을 유지해 주세요.
''',
  };

  static const _englishAdditionsByVehicleId = {
    'motorcycle': '''
Use a motorcycle rider concept.
Add a cute helmet.
Goggles or sunglasses are okay if needed.
Do not cover the face.
''',
    'fire_truck': '''
Use a firefighter rider concept.
Add a firefighter helmet or firefighter hat.
Make the character feel bright and dependable.
''',
    'police_car': '''
Use a police officer rider concept.
Add a police hat or police helmet.
Use a bright, confident expression.
''',
    'excavator': '''
Use an excavator operator concept.
Add a yellow safety helmet.
If needed, add only a very subtle workwear feeling.
Keep the face centered.
''',
  };

  static String promptForVehicle(
    VehicleDefinition vehicle,
    String languageCode,
  ) {
    final isKorean = languageCode == 'ko';
    final basePrompt = isKorean ? _koreanBasePrompt : _englishBasePrompt;
    final additions = isKorean
        ? _koreanAdditionsByVehicleId
        : _englishAdditionsByVehicleId;
    final vehiclePrompt = additions[vehicle.id] ?? '';

    return '$basePrompt\n$vehiclePrompt'.trim();
  }
}
