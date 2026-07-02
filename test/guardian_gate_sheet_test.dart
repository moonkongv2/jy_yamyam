import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/widgets/purchases/guardian_gate_sheet.dart';

void main() {
  testWidgets(
    'Guardian gate keeps continue disabled until an answer is entered',
    (tester) async {
      var passed = false;
      await _pumpHost(tester, onPassed: () => passed = true);

      await tester.tap(find.byKey(const ValueKey('openGuardianGateButton')));
      await tester.pumpAndSettle();

      final continueButton = tester.widget<FilledButton>(
        find.byKey(const ValueKey('guardianGateContinueButton')),
      );
      expect(continueButton.onPressed, isNull);
      expect(passed, isFalse);
    },
  );

  testWidgets('Guardian gate blocks wrong answer', (tester) async {
    var passed = false;
    await _pumpHost(
      tester,
      challenge: const GuardianGateChallenge(
        question: '4 + 6 = ?',
        answer: '10',
      ),
      onPassed: () => passed = true,
    );

    await tester.tap(find.byKey(const ValueKey('openGuardianGateButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('guardianGateAnswerField')),
      '11',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guardianGateContinueButton')));
    await tester.pumpAndSettle();

    expect(passed, isFalse);
    expect(find.text('답을 다시 확인해 주세요.'), findsOneWidget);
    expect(find.byType(GuardianGateSheet), findsOneWidget);
  });

  testWidgets('Guardian gate calls callback after correct answer', (
    tester,
  ) async {
    var passed = false;
    await _pumpHost(
      tester,
      challenge: const GuardianGateChallenge(
        question: '4 + 6 = ?',
        answer: '10',
      ),
      onPassed: () => passed = true,
    );

    await tester.tap(find.byKey(const ValueKey('openGuardianGateButton')));
    await tester.pumpAndSettle();
    expect(find.text('4 + 6 = ?'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('guardianGateAnswerField')),
      '10',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guardianGateContinueButton')));
    await tester.pumpAndSettle();

    expect(passed, isTrue);
    expect(find.byType(GuardianGateSheet), findsNothing);
  });

  testWidgets('Guardian gate uses English copy for English locale', (
    tester,
  ) async {
    await _pumpHost(tester, locale: const Locale('en'), onPassed: () {});

    await tester.tap(find.byKey(const ValueKey('openGuardianGateButton')));
    await tester.pumpAndSettle();

    expect(find.text('Guardian Check'), findsOneWidget);
    expect(
      find.text(
        'Vehicle pack purchases and restore are for parents or guardians.',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _pumpHost(
  WidgetTester tester, {
  Locale locale = const Locale('ko'),
  GuardianGateChallenge? challenge,
  required VoidCallback onPassed,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                key: const ValueKey('openGuardianGateButton'),
                onPressed: () => showGuardianGateSheet(
                  context,
                  challenge: challenge,
                  onPassed: onPassed,
                ),
                child: const Text('Open'),
              ),
            ),
          );
        },
      ),
    ),
  );
}
