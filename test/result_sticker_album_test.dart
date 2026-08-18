import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/reward_item.dart';
import 'package:jy_yamyam/theme/app_theme.dart';
import 'package:jy_yamyam/widgets/reward_sticker_image.dart';
import 'package:jy_yamyam/widgets/result_sticker_album_sheet.dart';

void main() {
  testWidgets('Result sticker album uses bounded three-column landscape grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(852, 393);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpOpenResultStickerAlbumSheet(tester);

    expect(find.text('차량 스티커 보관함'), findsOneWidget);
    expect(find.text('오토바이 스티커'), findsOneWidget);

    final firstCard = tester.getRect(find.byType(Card).at(0));
    final secondCard = tester.getRect(find.byType(Card).at(1));
    final thirdCard = tester.getRect(find.byType(Card).at(2));
    final stickerSizes = tester
        .widgetList<RewardStickerImage>(find.byType(RewardStickerImage))
        .map((widget) => widget.size);

    expect((firstCard.top - secondCard.top).abs(), lessThan(0.1));
    expect((firstCard.top - thirdCard.top).abs(), lessThan(0.1));
    expect(firstCard.left, greaterThan(70));
    expect(thirdCard.right, lessThan(780));
    expect(firstCard.width, lessThan(240));
    expect(stickerSizes.every((size) => size <= 96), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Result sticker album keeps two-column portrait grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpOpenResultStickerAlbumSheet(tester);

    expect(find.text('차량 스티커 보관함'), findsOneWidget);
    expect(find.text('오토바이 스티커'), findsOneWidget);

    final firstCard = tester.getRect(find.byType(Card).at(0));
    final secondCard = tester.getRect(find.byType(Card).at(1));
    final thirdCard = tester.getRect(find.byType(Card).at(2));
    final firstSticker = tester.widget<RewardStickerImage>(
      find.byType(RewardStickerImage).first,
    );

    expect((firstCard.top - secondCard.top).abs(), lessThan(0.1));
    expect(thirdCard.top, greaterThan(firstCard.bottom));
    expect(firstCard.width, lessThan(180));
    expect(firstSticker.size, 85);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpOpenResultStickerAlbumSheet(WidgetTester tester) async {
  final inventory = [
    RewardInventoryItem(
      rewardId: RewardCatalog.vehicleStickerIdForVehicle('motorcycle'),
      acquiredAt: DateTime(2026),
      count: 2,
    ),
  ];

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppTexts.supportedLocales,
      locale: const Locale('ko'),
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () {
              showResultStickerAlbumSheet(context, inventory: inventory);
            },
            child: const Text('openAlbum'),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('openAlbum'));
  await tester.pumpAndSettle();
}
