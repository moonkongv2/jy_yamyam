import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/reward_goal_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';

void main() {
  testWidgets('Home screen shows reward goal CTA', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: 'Jiyul'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Create Reward Goal'), findsOneWidget);
  });

  testWidgets(
    'Home reward summary refreshes after returning from reward goal',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final service = LocalMealProgressService();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('en'),
          home: HomeScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(childName: 'Jiyul'),
            mealProgressService: service,
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Reward Goal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ice cream');
      await tester.pump();
      await tester.tap(find.text('Save Goal'));
      await tester.pumpAndSettle();

      expect(find.byType(RewardGoalScreen), findsOneWidget);
      expect(find.text('ice cream'), findsOneWidget);

      Navigator.of(tester.element(find.byType(RewardGoalScreen))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('ice cream · 0/5'), findsOneWidget);
      expect(find.text('Create Reward Goal'), findsNothing);
    },
  );
}
