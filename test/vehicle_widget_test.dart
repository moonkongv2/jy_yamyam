import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/vehicle.dart';
import 'package:jy_yamyam/widgets/vehicle_widget.dart';

void main() {
  testWidgets('Vehicle widget falls back to emoji for missing assets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: VehicleWidget(
            vehicle: VehicleDefinition(
              id: 'missing_vehicle',
              labelKo: '없는 차',
              labelEn: 'Missing vehicle',
              labelJa: '存在しないのりもの',
              labelEs: 'Vehiculo faltante',
              labelPtBr: 'Veiculo ausente',
              emoji: '🚒',
              assetPath: 'assets/images/missing_vehicle.png',
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('🚒'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
