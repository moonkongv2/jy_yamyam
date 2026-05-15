class VehicleAvatarSlot {
  const VehicleAvatarSlot({
    required this.centerX,
    required this.centerY,
    required this.sizeRatio,
    this.rotationDegrees = 0.0,
  });

  final double centerX;
  final double centerY;
  final double sizeRatio;
  final double rotationDegrees;
}

class VehicleDefinition {
  const VehicleDefinition({
    required this.id,
    required this.labelKo,
    required this.labelEn,
    required this.emoji,
    required this.assetPath,
    this.selectionAssetPath,
    this.avatarSlot,
  });

  final String id;
  final String labelKo;
  final String labelEn;
  final String emoji;
  final String assetPath;
  final String? selectionAssetPath;
  final VehicleAvatarSlot? avatarSlot;

  String get selectionImagePath => selectionAssetPath ?? assetPath;

  String labelForLanguage(String languageCode) {
    return languageCode == 'ko' ? labelKo : labelEn;
  }
}
