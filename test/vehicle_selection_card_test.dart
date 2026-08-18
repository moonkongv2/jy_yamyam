import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/theme/app_spacing.dart';
import 'package:jy_yamyam/widgets/vehicle_selection_card.dart';

void main() {
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
