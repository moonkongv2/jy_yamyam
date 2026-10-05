import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/theme/app_spacing.dart';
import 'package:jy_yamyam/widgets/vehicle_selection_card.dart';

void main() {
  for (final compact in [false, true]) {
    for (final screenWidth in [
      200.0,
      240.0,
      280.0,
      320.0,
      375.0,
      376.0,
      390.0,
      430.0,
      768.0,
      812.0,
      1024.0,
    ]) {
      testWidgets(
        'Vehicle rows are centered in ${compact ? 'compact' : 'regular'} mode at ${screenWidth.toInt()}pt',
        (tester) async {
          tester.view.physicalSize = Size(screenWidth, 1024);
          tester.view.devicePixelRatio = 1;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: AppTexts.supportedLocales,
              locale: const Locale('ko'),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: SizedBox(
                      key: const ValueKey('vehicleCardBounds'),
                      width: screenWidth - AppSpacing.xl * 2,
                      child: VehicleSelectionCard(
                        title: '차량 선택',
                        selectedVehicleId: 'motorcycle',
                        compact: compact,
                        onVehicleSelected: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          final contentRect = tester
              .getRect(find.byKey(const ValueKey('vehicleCardBounds')))
              .deflate(AppSpacing.md);
          final rows = <List<Rect>>[];
          for (final vehicle in VehicleCatalog.all) {
            final rect = tester.getRect(
              find.byKey(ValueKey('vehicleChoice.${vehicle.id}')),
            );
            expect(rect.left, greaterThanOrEqualTo(contentRect.left - 0.5));
            expect(rect.right, lessThanOrEqualTo(contentRect.right + 0.5));
            expect(rect.top, greaterThanOrEqualTo(contentRect.top - 0.5));
            expect(rect.bottom, lessThanOrEqualTo(contentRect.bottom + 0.5));
            if (rows.isEmpty || (rect.top - rows.last.first.top).abs() > 0.5) {
              rows.add([]);
            }
            rows.last.add(rect);
          }

          for (final row in rows) {
            expect(
              (row.first.left + row.last.right) / 2,
              closeTo(contentRect.center.dx, 0.5),
            );
            if (row.length == rows.first.length) {
              expect(row.first.left, closeTo(contentRect.left, 0.5));
              expect(row.last.right, closeTo(contentRect.right, 0.5));
            }
          }
          final rowCounts = rows.map((row) => row.length).toList();
          if (compact && screenWidth == 200) {
            expect(rowCounts, [2, 2, 2, 2, 2, 2]);
          } else if (compact && screenWidth == 240) {
            expect(rowCounts, [3, 3, 3, 3]);
          } else if (compact || screenWidth == 376) {
            expect(rowCounts, [4, 4, 4]);
          } else if (screenWidth == 375) {
            expect(rowCounts, [3, 3, 3, 3]);
          } else if (screenWidth == 768) {
            expect(rowCounts, [7, 5]);
          }
          if (!compact && screenWidth == 375) {
            expect(rows.first.first.width, closeTo(98.333, 0.01));
          }
          if (!compact && screenWidth == 376) {
            expect(rows.first.first.width, 72);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final compact in [false, true]) {
    testWidgets(
      'Vehicle choices fill the card after rotation (compact=$compact)',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: VehicleSelectionCard(
                    key: const ValueKey('rotatingVehicleCard'),
                    title: '차량 선택',
                    selectedVehicleId: 'motorcycle',
                    compact: compact,
                    onVehicleSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );

        for (final size in [const Size(375, 812), const Size(812, 375)]) {
          tester.view.physicalSize = size;
          await tester.pump();
          final card = tester.getRect(
            find.byKey(const ValueKey('rotatingVehicleCard')),
          );
          final first = tester.getRect(
            find.byKey(const ValueKey('vehicleChoice.motorcycle')),
          );
          final firstRow = VehicleCatalog.all
              .map(
                (vehicle) => tester.getRect(
                  find.byKey(ValueKey('vehicleChoice.${vehicle.id}')),
                ),
              )
              .where((rect) => (rect.top - first.top).abs() < 0.5)
              .toList();
          expect(firstRow.first.left, closeTo(card.left + AppSpacing.md, 0.5));
          expect(firstRow.last.right, closeTo(card.right - AppSpacing.md, 0.5));
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('Vehicle selection card supports compact layout', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: VehicleSelectionCard(
                title: '오늘의 빠방',
                selectedVehicleId: 'motorcycle',
                onVehicleSelected: (_) {},
                showSelectedPreview: true,
                compact: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester
          .getSize(find.byKey(const ValueKey('selectedVehiclePreview')))
          .height,
      92,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('vehicleChoice.motorcycle')))
          .width,
      closeTo((360 - (AppSpacing.md * 2) - (AppSpacing.sm * 3)) / 4, 0.1),
    );
  });

  testWidgets('Vehicle selection card separates locked vehicle taps', (
    tester,
  ) async {
    String? selectedVehicleId;
    String? lockedVehicleId;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: Scaffold(
          body: SizedBox(
            width: 420,
            child: VehicleSelectionCard(
              title: '차량 선택',
              selectedVehicleId: 'motorcycle',
              lockedVehicleIds: const {'bus'},
              lockedSemanticLabel: '잠김',
              onVehicleSelected: (vehicleId) {
                selectedVehicleId = vehicleId;
              },
              onLockedVehiclePressed: (vehicleId) {
                lockedVehicleId = vehicleId;
              },
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('vehicleChoiceLockOverlay.bus')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('vehicleChoiceLockBadge.bus')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('vehicleChoice.bus')));
    await tester.pump();

    expect(selectedVehicleId, isNull);
    expect(lockedVehicleId, 'bus');

    await tester.tap(find.byKey(const ValueKey('vehicleChoice.supercar')));
    await tester.pump();

    expect(selectedVehicleId, 'supercar');
    expect(lockedVehicleId, 'bus');
  });
}
