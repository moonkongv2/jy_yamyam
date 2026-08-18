import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/screens/sticker_collection_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';

void main() {
  testWidgets('Sticker collection shows motorcycle and supercar first', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'rewardInventory': [
        jsonEncode({
          'rewardId': 'sticker_vehicle_motorcycle',
          'acquiredAt': DateTime(2026, 5, 4, 12).toIso8601String(),
          'count': 1,
        }),
        jsonEncode({
          'rewardId': 'sticker_vehicle_supercar',
          'acquiredAt': DateTime(2026, 5, 4, 13).toIso8601String(),
          'count': 1,
        }),
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: StickerCollectionScreen(
          mealProgressService: LocalMealProgressService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('오토바이 스티커')).dy,
      tester.getTopLeft(find.text('슈퍼카 스티커')).dy,
    );
  });
}
