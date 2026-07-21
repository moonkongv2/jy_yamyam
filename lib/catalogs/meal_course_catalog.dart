abstract final class MealCourseCatalog {
  static const presetMinutes = [15, 25, 35];
  static const defaultDuration = Duration(minutes: 25);

  static bool isPresetMinutes(int minutes) {
    return presetMinutes.contains(minutes);
  }
}
