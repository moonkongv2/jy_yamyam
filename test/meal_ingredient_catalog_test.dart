import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/meal_ingredient_catalog.dart';

void main() {
  test('Meal ingredient catalog has non-empty unique ids', () {
    final ids = MealIngredientCatalog.all
        .map((ingredient) => ingredient.id)
        .toList();

    expect(ids, isNotEmpty);
    expect(ids.every((id) => id.trim().isNotEmpty), isTrue);
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('Meal ingredient image asset paths point to existing files', () {
    final imageIngredients = [
      MealIngredientCatalog.egg,
      MealIngredientCatalog.seaweed,
      MealIngredientCatalog.tofu,
      MealIngredientCatalog.radish,
    ];

    expect(MealIngredientCatalog.egg.emoji, '🍳');
    for (final ingredient in imageIngredients) {
      final assetPath = ingredient.assetPath;
      expect(assetPath, isNotNull);
      expect(File(assetPath!).existsSync(), isTrue);
    }
  });

  test('Meal ingredient random selection returns valid ids', () {
    final ids = MealIngredientCatalog.randomSelectionIds();

    expect(ids, isNotEmpty);
    expect(ids, hasLength(5));
    for (final id in ids) {
      expect(MealIngredientCatalog.findById(id), isNotNull);
    }
  });

  test('Meal ingredient course slots returns exactly 30 ingredients', () {
    final slots = MealIngredientCatalog.courseSlotsFor(['carrot', 'egg']);

    expect(slots, hasLength(30));
  });

  test('Meal ingredient course slot count scales with duration', () {
    expect(
      MealIngredientCatalog.courseSlotCountForDuration(
        const Duration(minutes: 1),
      ),
      30,
    );
    expect(
      MealIngredientCatalog.courseSlotCountForDuration(
        const Duration(minutes: 5),
      ),
      30,
    );
    expect(
      MealIngredientCatalog.courseSlotCountForDuration(
        const Duration(minutes: 15),
      ),
      54,
    );
    expect(
      MealIngredientCatalog.courseSlotCountForDuration(
        const Duration(minutes: 25),
      ),
      90,
    );
    expect(
      MealIngredientCatalog.courseSlotCountForDuration(
        const Duration(minutes: 35),
      ),
      126,
    );
    expect(
      MealIngredientCatalog.courseSlotCountForDuration(
        const Duration(minutes: 60),
      ),
      144,
    );
  });

  test('Meal ingredient course slots only uses selected ids', () {
    const selectedIds = ['egg', 'rice', 'tomato'];
    final slots = MealIngredientCatalog.courseSlotsFor(selectedIds);

    expect(slots.map((ingredient) => ingredient.id).toSet(), {
      'egg',
      'rice',
      'tomato',
    });
  });

  test('Meal ingredient course slots fall back for invalid selected ids', () {
    final slots = MealIngredientCatalog.courseSlotsFor(['missing']);

    expect(
      slots.map((ingredient) => ingredient.id).toSet(),
      MealIngredientCatalog.defaultSelectionIds.toSet(),
    );
  });

  test(
    'Meal ingredient course slots avoids 3 consecutive identical ids when possible',
    () {
      final slots = MealIngredientCatalog.courseSlotsFor([
        'carrot',
        'carrot',
        'egg',
      ]);

      for (var index = 2; index < slots.length; index += 1) {
        expect(
          slots[index].id == slots[index - 1].id &&
              slots[index].id == slots[index - 2].id,
          isFalse,
        );
      }
    },
  );
}
