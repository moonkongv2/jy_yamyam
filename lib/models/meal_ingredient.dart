class MealIngredientDefinition {
  const MealIngredientDefinition({
    required this.id,
    required this.labelKo,
    required this.labelEn,
    required this.labelJa,
    required this.labelEs,
    required this.labelPtBr,
    required this.emoji,
    this.assetPath,
  });

  final String id;
  final String labelKo;
  final String labelEn;
  final String labelJa;
  final String labelEs;
  final String labelPtBr;
  final String emoji;
  final String? assetPath;

  String labelForLanguage(String languageCode) {
    return switch (languageCode) {
      'ko' => labelKo,
      'ja' => labelJa,
      'es' => labelEs,
      'pt' => labelPtBr,
      _ => labelEn,
    };
  }
}
