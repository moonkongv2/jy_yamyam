import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/widgets/purchases/vehicle_pack_intro_sheet.dart';

void main() {
  testWidgets(
    'Vehicle pack intro sheet is informational before guardian gate',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          supportedLocales: const [Locale('ko'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const Scaffold(body: VehiclePackIntroSheet()),
        ),
      );

      expect(find.text('차량팩 빠방이에요'), findsOneWidget);
      expect(find.text('차량팩을 열면 잠긴 빠방을 모두 사용할 수 있어요.'), findsOneWidget);
      expect(find.text('보호자 확인 후 차량팩 정보를 볼 수 있어요.'), findsOneWidget);
      expect(find.text('보호자와 계속하기'), findsOneWidget);
      expect(find.text('닫기'), findsOneWidget);
      expect(find.textContaining('구매'), findsNothing);
      expect(find.textContaining('복원'), findsNothing);
      expect(find.textContaining('가격'), findsNothing);
    },
  );

  testWidgets('Vehicle pack intro sheet returns continue choice', (
    tester,
  ) async {
    bool? shouldContinue;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        supportedLocales: const [Locale('ko'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () async {
                  shouldContinue = await showVehiclePackIntroSheet(context);
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('vehiclePackIntroContinueButton')),
    );
    await tester.pumpAndSettle();

    expect(shouldContinue, true);
  });
}
