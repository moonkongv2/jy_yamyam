import 'dart:math' as math;

import '../models/meal_ingredient.dart';

abstract final class MealIngredientCatalog {
  static const maxSelectableIngredientCount = 5;
  static const minCourseSlotCount = 30;
  static const maxCourseSlotCount = 144;
  static const referenceCourseDuration = Duration(minutes: 5);

  static const carrot = MealIngredientDefinition(
    id: 'carrot',
    labelKo: '당근',
    labelEn: 'Carrot',
    labelJa: 'にんじん',
    labelEs: 'Zanahoria',
    labelPtBr: 'Cenoura',
    emoji: '🥕',
  );

  static const egg = MealIngredientDefinition(
    id: 'egg',
    labelKo: '달걀',
    labelEn: 'Egg',
    labelJa: 'たまご',
    labelEs: 'Huevo',
    labelPtBr: 'Ovo',
    emoji: '🍳',
    assetPath: 'assets/images/ingredients/egg.png',
  );

  static const meat = MealIngredientDefinition(
    id: 'meat',
    labelKo: '고기',
    labelEn: 'Meat',
    labelJa: 'お肉',
    labelEs: 'Carne',
    labelPtBr: 'Carne',
    emoji: '🥩',
  );

  static const onion = MealIngredientDefinition(
    id: 'onion',
    labelKo: '양파',
    labelEn: 'Onion',
    labelJa: '玉ねぎ',
    labelEs: 'Cebolla',
    labelPtBr: 'Cebola',
    emoji: '🧅',
  );

  static const cucumber = MealIngredientDefinition(
    id: 'cucumber',
    labelKo: '오이',
    labelEn: 'Cucumber',
    labelJa: 'きゅうり',
    labelEs: 'Pepino',
    labelPtBr: 'Pepino',
    emoji: '🥒',
  );

  static const rice = MealIngredientDefinition(
    id: 'rice',
    labelKo: '밥',
    labelEn: 'Rice',
    labelJa: 'ごはん',
    labelEs: 'Arroz',
    labelPtBr: 'Arroz',
    emoji: '🍚',
  );

  static const seaweed = MealIngredientDefinition(
    id: 'seaweed',
    labelKo: '김',
    labelEn: 'Seaweed',
    labelJa: 'のり',
    labelEs: 'Alga',
    labelPtBr: 'Alga',
    emoji: '🟩',
    assetPath: 'assets/images/ingredients/seaweed.png',
  );

  static const tofu = MealIngredientDefinition(
    id: 'tofu',
    labelKo: '두부',
    labelEn: 'Tofu',
    labelJa: '豆腐',
    labelEs: 'Tofu',
    labelPtBr: 'Tofu',
    emoji: '⬜',
    assetPath: 'assets/images/ingredients/tofu.png',
  );

  static const broccoli = MealIngredientDefinition(
    id: 'broccoli',
    labelKo: '브로콜리',
    labelEn: 'Broccoli',
    labelJa: 'ブロッコリー',
    labelEs: 'Brócoli',
    labelPtBr: 'Brócolis',
    emoji: '🥦',
  );

  static const tomato = MealIngredientDefinition(
    id: 'tomato',
    labelKo: '토마토',
    labelEn: 'Tomato',
    labelJa: 'トマト',
    labelEs: 'Tomate',
    labelPtBr: 'Tomate',
    emoji: '🍅',
  );

  static const potato = MealIngredientDefinition(
    id: 'potato',
    labelKo: '감자',
    labelEn: 'Potato',
    labelJa: 'じゃがいも',
    labelEs: 'Patata',
    labelPtBr: 'Batata',
    emoji: '🥔',
  );

  static const fish = MealIngredientDefinition(
    id: 'fish',
    labelKo: '생선',
    labelEn: 'Fish',
    labelJa: '魚',
    labelEs: 'Pescado',
    labelPtBr: 'Peixe',
    emoji: '🐟',
  );

  static const mushroom = MealIngredientDefinition(
    id: 'mushroom',
    labelKo: '버섯',
    labelEn: 'Mushroom',
    labelJa: 'きのこ',
    labelEs: 'Champiñón',
    labelPtBr: 'Cogumelo',
    emoji: '🍄',
  );

  static const cheese = MealIngredientDefinition(
    id: 'cheese',
    labelKo: '치즈',
    labelEn: 'Cheese',
    labelJa: 'チーズ',
    labelEs: 'Queso',
    labelPtBr: 'Queijo',
    emoji: '🧀',
  );

  static const apple = MealIngredientDefinition(
    id: 'apple',
    labelKo: '사과',
    labelEn: 'Apple',
    labelJa: 'りんご',
    labelEs: 'Manzana',
    labelPtBr: 'Maçã',
    emoji: '🍎',
  );

  static const cabbage = MealIngredientDefinition(
    id: 'cabbage',
    labelKo: '배추',
    labelEn: 'Cabbage',
    labelJa: '白菜',
    labelEs: 'Col',
    labelPtBr: 'Repolho',
    emoji: '🥬',
  );

  static const radish = MealIngredientDefinition(
    id: 'radish',
    labelKo: '무',
    labelEn: 'Radish',
    labelJa: '大根',
    labelEs: 'Rábano',
    labelPtBr: 'Nabo',
    emoji: '⚪',
    assetPath: 'assets/images/ingredients/radish.png',
  );

  static const bean = MealIngredientDefinition(
    id: 'bean',
    labelKo: '콩',
    labelEn: 'Beans',
    labelJa: '豆',
    labelEs: 'Judías',
    labelPtBr: 'Feijão',
    emoji: '🫘',
  );

  static const all = [
    carrot,
    egg,
    meat,
    onion,
    cucumber,
    rice,
    seaweed,
    tofu,
    broccoli,
    tomato,
    potato,
    fish,
    mushroom,
    cheese,
    apple,
    cabbage,
    radish,
    bean,
  ];

  static const defaultSelectionIds = [
    'carrot',
    'egg',
    'rice',
    'broccoli',
    'apple',
  ];

  static MealIngredientDefinition? findById(String id) {
    for (final ingredient in all) {
      if (ingredient.id == id) {
        return ingredient;
      }
    }
    return null;
  }

  static List<String> randomSelectionIds({
    int count = maxSelectableIngredientCount,
    math.Random? random,
  }) {
    if (count <= 0) {
      return const [];
    }

    final shuffled = all.map((ingredient) => ingredient.id).toList();
    shuffled.shuffle(random ?? math.Random());
    return List.unmodifiable(shuffled.take(math.min(count, shuffled.length)));
  }

  static List<MealIngredientDefinition> courseSlotsFor(
    List<String> selectedIds, {
    int slotCount = minCourseSlotCount,
  }) {
    if (slotCount <= 0) {
      return const [];
    }

    final selectedIngredients = _ingredientsForIds(selectedIds);
    final ingredients = selectedIngredients.isEmpty
        ? _ingredientsForIds(defaultSelectionIds)
        : selectedIngredients;
    final slots = <MealIngredientDefinition>[];

    for (var index = 0; index < slotCount; index += 1) {
      var ingredient = ingredients[index % ingredients.length];
      if (ingredients.length >= 2 &&
          slots.length >= 2 &&
          slots[slots.length - 1].id == ingredient.id &&
          slots[slots.length - 2].id == ingredient.id) {
        ingredient = ingredients[(index + 1) % ingredients.length];
      }
      slots.add(ingredient);
    }

    return List.unmodifiable(slots);
  }

  static int courseSlotCountForDuration(Duration duration) {
    if (duration <= Duration.zero) {
      return minCourseSlotCount;
    }

    final durationFactor =
        duration.inMilliseconds / referenceCourseDuration.inMilliseconds;
    final clampedFactor = math.max(1.0, durationFactor);
    final targetSlotCount = (18 * clampedFactor).round();
    return targetSlotCount
        .clamp(minCourseSlotCount, maxCourseSlotCount)
        .toInt();
  }

  static List<MealIngredientDefinition> _ingredientsForIds(List<String> ids) {
    final ingredients = <MealIngredientDefinition>[];
    final seenIds = <String>{};
    for (final id in ids) {
      final ingredient = findById(id);
      if (ingredient == null || !seenIds.add(ingredient.id)) {
        continue;
      }
      ingredients.add(ingredient);
    }
    return ingredients;
  }
}
