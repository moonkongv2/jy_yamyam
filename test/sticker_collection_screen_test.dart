import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/screens/sticker_collection_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/theme/app_theme.dart';
import 'package:jy_yamyam/widgets/reward_sticker_image.dart';

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
        theme: AppTheme.light(),
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
    expect(tester.takeException(), isNull);
  });

  final widths = [240.0, 320.0, 360.0, 393.0, 600.0, 768.0, 1024.0, 1440.0];
  final scales = [1.0, 1.3, 2.0, 3.0];
  for (var i = 0; i < widths.length; i++) {
    for (var j = 0; j < scales.length; j++) {
      final width = widths[i];
      final scale = scales[j];
      final locale =
          AppTexts.supportedLocales[(i + j) % AppTexts.supportedLocales.length];
      testWidgets('Collection fits width $width, scale $scale, $locale', (
        tester,
      ) async {
        await _pumpCollection(
          tester,
          Size(width, i.isEven ? 844 : 320),
          scale,
          locale,
        );
        _expectContainedCards(tester);
        final cards = find.byType(Card);
        expect(cards, findsNWidgets(VehicleCatalog.all.length));
        final first = tester.getRect(cards.at(0));
        final second = tester.getRect(cards.at(1));
        if (width == 393 && scale == 1) {
          expect(first.top, second.top);
        }
        if (width == 240) {
          expect(second.top, greaterThan(first.bottom));
        }
        await Scrollable.ensureVisible(
          tester.element(cards.last),
          alignment: 1,
        );
        await tester.pumpAndSettle();
        expect(
          tester.getRect(cards.last).bottom,
          lessThanOrEqualTo(tester.view.physicalSize.height + 0.1),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final locale in AppTexts.supportedLocales) {
    testWidgets('Collection wraps long names with large text in $locale', (
      tester,
    ) async {
      await _pumpCollection(tester, const Size(240, 320), 3, locale);
      _expectContainedCards(tester);
      for (final text in tester.widgetList<Text>(
        find.descendant(of: find.byType(Card), matching: find.byType(Text)),
      )) {
        expect(text.maxLines, isNull);
        expect(text.overflow, isNot(TextOverflow.ellipsis));
      }
    });
  }

  testWidgets('Collection reflows across column boundaries and live resize', (
    tester,
  ) async {
    await _pumpCollection(tester, const Size(393, 844), 1, const Locale('ko'));
    for (final width in [
      315.0,
      316.0,
      317.0,
      459.0,
      460.0,
      461.0,
      603.0,
      604.0,
      605.0,
      240.0,
    ]) {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpAndSettle();
      _expectContainedCards(tester);
      final columns = width < 316
          ? 1
          : width < 460
          ? 2
          : width < 604
          ? 3
          : 4;
      final cards = find.byType(Card);
      for (var i = 0; i < columns; i++) {
        expect(
          tester.getRect(cards.at(i)).top,
          tester.getRect(cards.first).top,
        );
      }
      expect(
        tester.getRect(cards.at(columns)).top,
        greaterThan(tester.getRect(cards.first).bottom),
      );
    }
  });

  testWidgets('Only collected cards retain the fountain tap handler', (
    tester,
  ) async {
    await _pumpCollection(tester, const Size(393, 844), 1, const Locale('ko'));
    final cards = find.byType(Card);
    for (var i = 0; i < VehicleCatalog.all.length; i++) {
      final gesture = tester.widget<GestureDetector>(
        find
            .ancestor(of: cards.at(i), matching: find.byType(GestureDetector))
            .first,
      );
      if (i == 0) {
        expect(gesture.onTapUp, isNull);
      } else {
        expect(gesture.onTapUp, isNotNull);
      }
    }
  });

  testWidgets('Collection respects safe areas and live text scaling', (
    tester,
  ) async {
    await _pumpCollection(tester, const Size(393, 844), 1, const Locale('ko'));
    tester.view.padding = const FakeViewPadding(
      top: 24,
      bottom: 34,
      left: 12,
      right: 12,
    );
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    await tester.pumpAndSettle();
    _expectContainedCards(tester);
    final cards = find.byType(Card);
    expect(
      tester.getRect(cards.at(1)).top,
      greaterThan(tester.getRect(cards.first).bottom),
    );
    expect(tester.getRect(cards.first).left, greaterThanOrEqualTo(12));
    expect(tester.getRect(cards.first).right, lessThanOrEqualTo(381));
    await Scrollable.ensureVisible(tester.element(cards.last), alignment: 1);
    await tester.pumpAndSettle();
    expect(tester.getRect(cards.last).bottom, lessThanOrEqualTo(810));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpCollection(
  WidgetTester tester,
  Size size,
  double scale,
  Locale locale,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPadding();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  SharedPreferences.setMockInitialValues({
    'rewardInventory': [
      for (var i = 1; i < VehicleCatalog.all.length; i++)
        jsonEncode({
          'rewardId': 'sticker_vehicle_${VehicleCatalog.all[i].id}',
          'acquiredAt': DateTime(2026, 5, 4).toIso8601String(),
          'count': [1, 2, 5, 999999999][(i - 1) % 4],
        }),
    ],
  });
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppTexts.supportedLocales,
      locale: locale,
      home: StickerCollectionScreen(
        mealProgressService: LocalMealProgressService(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void _expectContainedCards(WidgetTester tester) {
  final cards = find.byType(Card);
  final rects = <Rect>[];
  for (final element in cards.evaluate()) {
    final cardFinder = find.byWidget(element.widget);
    final card = tester.getRect(cardFinder);
    rects.add(card);
    expect(card.left, greaterThanOrEqualTo(0));
    expect(card.right, lessThanOrEqualTo(tester.view.physicalSize.width + 0.1));
    final contents = find.descendant(
      of: cardFinder,
      matching: find.byWidgetPredicate(
        (widget) => widget is Text || widget is RewardStickerImage,
      ),
    );
    for (final content in contents.evaluate()) {
      final box = content.renderObject! as RenderBox;
      for (final point in [
        Offset.zero,
        Offset(box.size.width, 0),
        Offset(0, box.size.height),
        box.size.bottomRight(Offset.zero),
      ]) {
        final position = box.localToGlobal(point);
        expect(
          position.dx,
          inInclusiveRange(card.left - 0.1, card.right + 0.1),
        );
        expect(
          position.dy,
          inInclusiveRange(card.top - 0.1, card.bottom + 0.1),
        );
      }
      if (content.widget is Text) {
        expect((box as RenderParagraph).didExceedMaxLines, isFalse);
      }
    }
  }
  for (var i = 0; i < rects.length; i++) {
    for (var j = i + 1; j < rects.length; j++) {
      expect(rects[i].overlaps(rects[j]), isFalse);
    }
  }
  expect(tester.takeException(), isNull);
}
