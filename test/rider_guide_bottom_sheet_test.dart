import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/widgets/avatar/rider_guide_bottom_sheet.dart';

void main() {
  testWidgets('Rider guide bottom sheet renders guide content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ko'),
        supportedLocales: [Locale('ko'), Locale('en')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(body: RiderGuideBottomSheet()),
      ),
    );

    expect(find.text('우리 아이 라이더 만들기 안내'), findsOneWidget);
    expect(find.text('📸 라이더 이미지 준비 방법'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '확인'), findsOneWidget);
  });
}
