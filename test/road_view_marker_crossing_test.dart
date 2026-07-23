import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_ingredient.dart';
import 'package:jy_yamyam/widgets/road_view.dart';

void main() {
  testWidgets('crossing one ingredient marker reports one callback', (
    tester,
  ) async {
    final passed = <int>[];

    await _pumpRoadView(tester, progress: 0, onPassed: passed.add);
    await _pumpRoadView(tester, progress: 1, onPassed: passed.add);
    await tester.pump();

    expect(passed, [0]);

    await _pumpRoadView(tester, progress: 1, onPassed: passed.add);
    await tester.pump();

    expect(passed, [0]);
  });

  testWidgets('initial mount beyond markers does not replay old markers', (
    tester,
  ) async {
    final passed = <int>[];

    await _pumpRoadView(
      tester,
      progress: 1,
      ingredients: _ingredients(3),
      onPassed: passed.add,
    );
    await tester.pump();

    expect(passed, isEmpty);
  });

  testWidgets('remount at advanced progress does not replay markers', (
    tester,
  ) async {
    final passed = <int>[];

    await _pumpRoadView(
      tester,
      progress: 0,
      ingredients: _ingredients(3),
      onPassed: passed.add,
    );
    await _pumpRoadView(
      tester,
      progress: 1,
      ingredients: _ingredients(3),
      onPassed: passed.add,
    );
    await tester.pump();

    expect(passed, [2]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await _pumpRoadView(
      tester,
      progress: 1,
      ingredients: _ingredients(3),
      onPassed: passed.add,
    );
    await tester.pump();

    expect(passed, [2]);
  });

  testWidgets(
    'jumping across multiple markers reports only the highest index',
    (tester) async {
      final passed = <int>[];

      await _pumpRoadView(
        tester,
        progress: 0,
        ingredients: _ingredients(4),
        onPassed: passed.add,
      );
      await _pumpRoadView(
        tester,
        progress: 1,
        ingredients: _ingredients(4),
        onPassed: passed.add,
      );
      await tester.pump();

      expect(passed, [3]);
    },
  );
}

Future<void> _pumpRoadView(
  WidgetTester tester, {
  required double progress,
  List<MealIngredientDefinition>? ingredients,
  required ValueChanged<int> onPassed,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppTexts.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 420,
          height: 640,
          child: RoadView(
            progress: progress,
            vehicle: VehicleCatalog.motorcycle,
            ingredients: ingredients ?? _ingredients(1),
            ingredientClearProgress: progress,
            onCourseMarkerPassed: onPassed,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

List<MealIngredientDefinition> _ingredients(int count) {
  return [
    for (var index = 0; index < count; index += 1)
      MealIngredientDefinition(
        id: 'ingredient_$index',
        labelKo: '재료 $index',
        labelEn: 'Ingredient $index',
        labelJa: '食材 $index',
        labelEs: 'Ingrediente $index',
        labelPtBr: 'Ingrediente $index',
        emoji: '🍚',
      ),
  ];
}
