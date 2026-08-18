import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/screens/reward_goal_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';

import 'helpers/meal_result_fixture.dart';

void main() {
  testWidgets('Reward goal creation form saves a goal', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: RewardGoalScreen(mealProgressService: service),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ChoiceChip, '7'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ice cream');
    await tester.pump();
    await tester.tap(find.text('Save Goal'));
    await tester.pumpAndSettle();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.activeRewardGoals.single.rewardText, 'ice cream');
    expect(snapshot.activeRewardGoals.single.requiredStickerCount, 7);
  });

  testWidgets('Earned reward use flow asks for confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 1,
      rewardText: 'ice cream',
    );
    await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: RewardGoalScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward'));
    await tester.pumpAndSettle();
    expect(find.text('Give this reward?'), findsOneWidget);

    await tester.tap(find.text('Keep Goal'));
    await tester.pumpAndSettle();
    expect((await service.loadSnapshot()).earnedRewardGoals, hasLength(1));

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward').last);
    await tester.pumpAndSettle();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.earnedRewardGoals, isEmpty);
    expect(snapshot.usedRewardGoals, hasLength(1));
  });
}
