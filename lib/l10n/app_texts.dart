import 'package:flutter/widgets.dart';

import 'en/common.dart';
import 'en/avatar_setup.dart';
import 'en/first_run_onboarding.dart';
import 'en/home.dart';
import 'en/meal_ingredient.dart';
import 'en/meal_history.dart';
import 'en/purchases.dart';
import 'en/result.dart';
import 'en/rewards.dart';
import 'en/settings.dart';
import 'en/timer.dart';
import 'en/user_guide.dart';
import 'ko/common.dart';
import 'ko/avatar_setup.dart';
import 'ko/first_run_onboarding.dart';
import 'ko/home.dart';
import 'ko/meal_ingredient.dart';
import 'ko/meal_history.dart';
import 'ko/purchases.dart';
import 'ko/result.dart';
import 'ko/rewards.dart';
import 'ko/settings.dart';
import 'ko/timer.dart';
import 'ko/user_guide.dart';
import 'ja/common.dart';
import 'ja/avatar_setup.dart';
import 'ja/first_run_onboarding.dart';
import 'ja/home.dart';
import 'ja/meal_ingredient.dart';
import 'ja/meal_history.dart';
import 'ja/purchases.dart';
import 'ja/result.dart';
import 'ja/rewards.dart';
import 'ja/settings.dart';
import 'ja/timer.dart';
import 'ja/user_guide.dart';
import 'es/common.dart';
import 'es/avatar_setup.dart';
import 'es/first_run_onboarding.dart';
import 'es/home.dart';
import 'es/meal_ingredient.dart';
import 'es/meal_history.dart';
import 'es/purchases.dart';
import 'es/result.dart';
import 'es/rewards.dart';
import 'es/settings.dart';
import 'es/timer.dart';
import 'es/user_guide.dart';
import 'pt_BR/common.dart';
import 'pt_BR/avatar_setup.dart';
import 'pt_BR/first_run_onboarding.dart';
import 'pt_BR/home.dart';
import 'pt_BR/meal_ingredient.dart';
import 'pt_BR/meal_history.dart';
import 'pt_BR/purchases.dart';
import 'pt_BR/result.dart';
import 'pt_BR/rewards.dart';
import 'pt_BR/settings.dart';
import 'pt_BR/timer.dart';
import 'pt_BR/user_guide.dart';
import 'text_sets.dart';

class AppTextBundle {
  const AppTextBundle({
    required this.avatarSetup,
    required this.common,
    required this.firstRunOnboarding,
    required this.home,
    required this.mealIngredient,
    required this.mealHistory,
    required this.purchases,
    required this.result,
    required this.rewards,
    required this.settings,
    required this.timer,
    required this.userGuide,
  });

  final AvatarSetupTextSet avatarSetup;
  final CommonTextSet common;
  final FirstRunOnboardingTextSet firstRunOnboarding;
  final HomeTextSet home;
  final MealIngredientTextSet mealIngredient;
  final MealHistoryTextSet mealHistory;
  final PurchaseTextSet purchases;
  final ResultTextSet result;
  final RewardTextSet rewards;
  final SettingsTextSet settings;
  final TimerTextSet timer;
  final UserGuideTextSet userGuide;
}

abstract final class AppTexts {
  static const supportedLocales = [
    Locale('en'),
    Locale('ko'),
    Locale('ja'),
    Locale('es'),
    Locale('pt', 'BR'),
  ];

  static const ko = AppTextBundle(
    avatarSetup: AvatarSetupTexts(),
    common: CommonTexts(),
    firstRunOnboarding: FirstRunOnboardingTexts(),
    home: HomeTexts(),
    mealIngredient: MealIngredientTexts(),
    mealHistory: MealHistoryTexts(),
    purchases: PurchaseTexts(),
    result: ResultTexts(),
    rewards: RewardTexts(),
    settings: SettingsTexts(),
    timer: TimerTexts(),
    userGuide: UserGuideTexts(),
  );

  static const en = AppTextBundle(
    avatarSetup: EnAvatarSetupTexts(),
    common: EnCommonTexts(),
    firstRunOnboarding: EnFirstRunOnboardingTexts(),
    home: EnHomeTexts(),
    mealIngredient: EnMealIngredientTexts(),
    mealHistory: EnMealHistoryTexts(),
    purchases: EnPurchaseTexts(),
    result: EnResultTexts(),
    rewards: EnRewardTexts(),
    settings: EnSettingsTexts(),
    timer: EnTimerTexts(),
    userGuide: EnUserGuideTexts(),
  );

  static const ja = AppTextBundle(
    avatarSetup: JaAvatarSetupTexts(),
    common: JaCommonTexts(),
    firstRunOnboarding: JaFirstRunOnboardingTexts(),
    home: JaHomeTexts(),
    mealIngredient: JaMealIngredientTexts(),
    mealHistory: JaMealHistoryTexts(),
    purchases: JaPurchaseTexts(),
    result: JaResultTexts(),
    rewards: JaRewardTexts(),
    settings: JaSettingsTexts(),
    timer: JaTimerTexts(),
    userGuide: JaUserGuideTexts(),
  );

  static const es = AppTextBundle(
    avatarSetup: EsAvatarSetupTexts(),
    common: EsCommonTexts(),
    firstRunOnboarding: EsFirstRunOnboardingTexts(),
    home: EsHomeTexts(),
    mealIngredient: EsMealIngredientTexts(),
    mealHistory: EsMealHistoryTexts(),
    purchases: EsPurchaseTexts(),
    result: EsResultTexts(),
    rewards: EsRewardTexts(),
    settings: EsSettingsTexts(),
    timer: EsTimerTexts(),
    userGuide: EsUserGuideTexts(),
  );

  static const ptBr = AppTextBundle(
    avatarSetup: PtBrAvatarSetupTexts(),
    common: PtBrCommonTexts(),
    firstRunOnboarding: PtBrFirstRunOnboardingTexts(),
    home: PtBrHomeTexts(),
    mealIngredient: PtBrMealIngredientTexts(),
    mealHistory: PtBrMealHistoryTexts(),
    purchases: PtBrPurchaseTexts(),
    result: PtBrResultTexts(),
    rewards: PtBrRewardTexts(),
    settings: PtBrSettingsTexts(),
    timer: PtBrTimerTexts(),
    userGuide: PtBrUserGuideTexts(),
  );

  static AppTextBundle of(BuildContext context) {
    return forLocale(Localizations.localeOf(context));
  }

  static AppTextBundle forLocale(Locale locale) {
    return switch (locale.languageCode) {
      'ko' => ko,
      'ja' => ja,
      'es' => es,
      'pt' => ptBr,
      _ => en,
    };
  }
}
