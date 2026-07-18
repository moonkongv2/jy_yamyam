import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/avatar_prompt_catalog.dart';
import 'package:jy_yamyam/catalogs/meal_ingredient_catalog.dart';
import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/reward_item.dart';

void main() {
  test(
    'Supported locales include Japanese, Spanish, and Brazilian Portuguese',
    () {
      expect(AppTexts.supportedLocales, contains(const Locale('ja')));
      expect(AppTexts.supportedLocales, contains(const Locale('es')));
      expect(AppTexts.supportedLocales, contains(const Locale('pt', 'BR')));
    },
  );

  test('AppTexts routes new locales and falls back to English', () {
    expect(AppTexts.forLocale(const Locale('ja')).common.start, 'スタート');
    expect(AppTexts.forLocale(const Locale('es')).common.start, 'Empezar');
    expect(
      AppTexts.forLocale(const Locale('pt', 'BR')).common.start,
      'Começar',
    );
    expect(AppTexts.forLocale(const Locale('pt')).common.start, 'Começar');
    expect(AppTexts.forLocale(const Locale('fr')).common.start, 'Start');
  });

  test('Catalog labels return Japanese, Spanish, and Brazilian Portuguese', () {
    final vehicle = VehicleCatalog.motorcycle;
    expect(vehicle.labelForLanguage('ja'), 'オートバイ');
    expect(vehicle.labelForLanguage('es'), 'Moto');
    expect(vehicle.labelForLanguage('pt'), 'Moto');
    expect(vehicle.labelForLanguage('fr'), 'Motorcycle');

    final ingredient = MealIngredientCatalog.carrot;
    expect(ingredient.labelForLanguage('ja'), 'にんじん');
    expect(ingredient.labelForLanguage('es'), 'Zanahoria');
    expect(ingredient.labelForLanguage('pt'), 'Cenoura');
    expect(ingredient.labelForLanguage('fr'), 'Carrot');
  });

  test('Reward sticker labels use supported locale vehicle names', () {
    final sticker = RewardCatalog.findVehicleStickerByVehicleId('motorcycle');

    expect(sticker, isNotNull);
    expect(sticker!.labelForLanguage('ko'), '오토바이 스티커');
    expect(sticker.labelForLanguage('en'), 'Motorcycle Sticker');
    expect(sticker.labelForLanguage('ja'), 'オートバイステッカー');
    expect(sticker.labelForLanguage('es'), 'Pegatina de moto');
    expect(sticker.labelForLanguage('pt'), 'Adesivo de moto');
    expect(sticker.labelForLanguage('fr'), 'Motorcycle Sticker');
  });

  test('Avatar prompts are localized and keep vehicle concepts', () {
    final jaPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.motorcycle,
      'ja',
    );
    expect(jaPrompt, contains('オートバイ'));
    expect(jaPrompt, contains('ヘルメット'));
    expect(jaPrompt, isNot(contains('Use the attached child photo')));

    final esPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.fireTruck,
      'es',
    );
    expect(esPrompt, contains('bombero'));
    expect(esPrompt, contains('casco'));
    expect(esPrompt, isNot(contains('Use the attached child photo')));

    final ptPrompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.shark,
      'pt',
    );
    expect(ptPrompt, contains('tubarão'));
    expect(ptPrompt, contains('oceânico'));
    expect(ptPrompt, isNot(contains('Use the attached child photo')));
  });

  test('Avatar prompts fall back to English for unsupported languages', () {
    final prompt = AvatarPromptCatalog.promptForVehicle(
      VehicleCatalog.train,
      'fr',
    );

    expect(prompt, contains('Use the attached child photo'));
    expect(prompt, contains('train engineer'));
  });

  test('Purchase localization includes required Korean copy', () {
    final purchases = AppTexts.ko.purchases;

    expect(purchases.lockedVehicleSemanticLabel, '잠김');
    expect(purchases.vehiclePackTitle, '차량팩');
    expect(purchases.guardianGateTitle, '보호자 확인');
    expect(purchases.settingsVehiclePackUnlockButton, '보호자 구매');
    expect(purchases.settingsVehiclePackLockedBody, contains('보호자 확인'));
    expect(purchases.settingsVehiclePackUnlockedBody, contains('차량팩 열림'));
    expect(purchases.vehiclePackRestoreButton, '구매 복원');
    expect(purchases.vehiclePackPendingMessage, contains('처리 중'));
    expect(purchases.vehiclePackRestoringMessage, contains('구매 내역'));
    expect(purchases.vehiclePackRestoreNotFoundMessage, contains('찾지 못했어요'));
    expect(purchases.vehiclePackSuccessMessage, contains('열렸어요'));
    expect(purchases.vehiclePackErrorMessage, contains('완료하지 못했어요'));
    expect(purchases.vehiclePackCanceledMessage, contains('취소'));
    expect(purchases.vehiclePackOfflineBody, contains('오프라인'));
  });

  test('Purchase localization includes required English copy', () {
    final purchases = AppTexts.en.purchases;

    expect(purchases.lockedVehicleSemanticLabel, 'Locked');
    expect(purchases.vehiclePackTitle, 'Vehicle Pack');
    expect(purchases.guardianGateTitle, 'Guardian Check');
    expect(purchases.settingsVehiclePackUnlockButton, 'Guardian Purchase');
    expect(purchases.settingsVehiclePackLockedBody, contains('guardian'));
    expect(purchases.settingsVehiclePackUnlockedBody, contains('unlocked'));
    expect(purchases.vehiclePackRestoreButton, 'Restore Purchase');
    expect(purchases.vehiclePackPendingMessage, contains('pending'));
    expect(purchases.vehiclePackRestoringMessage, contains('purchase history'));
    expect(
      purchases.vehiclePackRestoreNotFoundMessage,
      contains('No Vehicle Pack purchase'),
    );
    expect(purchases.vehiclePackSuccessMessage, contains('unlocked'));
    expect(
      purchases.vehiclePackErrorMessage,
      contains('could not be completed'),
    );
    expect(purchases.vehiclePackCanceledMessage, contains('canceled'));
    expect(purchases.vehiclePackOfflineBody, contains('offline'));
  });

  test('Settings legal and support labels are localized', () {
    final expectedLabelsByLocale = {
      const Locale('ko'): [
        '도움말 및 지원',
        '사용 가이드',
        '구매 복원',
        '고객지원',
        '정보',
        '개인정보처리방침',
        '앱 버전',
      ],
      const Locale('en'): [
        'Help & Support',
        'User Guide',
        'Restore Purchase',
        'Contact Support',
        'About',
        'Privacy Policy',
        'App Version',
      ],
      const Locale('ja'): [
        'ヘルプとサポート',
        '使い方ガイド',
        '購入を復元',
        'サポートに問い合わせ',
        '情報',
        'プライバシーポリシー',
        'アプリバージョン',
      ],
      const Locale('es'): [
        'Ayuda y soporte',
        'Guía de uso',
        'Restaurar compra',
        'Contactar con soporte',
        'Acerca de',
        'Política de privacidad',
        'Versión de la app',
      ],
      const Locale('pt', 'BR'): [
        'Ajuda e suporte',
        'Guia de uso',
        'Restaurar compra',
        'Falar com o suporte',
        'Sobre',
        'Política de privacidade',
        'Versão do app',
      ],
    };

    for (final entry in expectedLabelsByLocale.entries) {
      final settings = AppTexts.forLocale(entry.key).settings;

      expect([
        settings.helpSupportTitle,
        settings.userGuide,
        settings.restorePurchase,
        settings.contactSupport,
        settings.aboutTitle,
        settings.privacyPolicy,
        settings.appVersion,
      ], entry.value);
    }
  });

  test('Avatar privacy copy describes optional local image selection', () {
    expect(AppTexts.ko.avatarSetup.privacyNote, contains('직접 누를 때만'));
    expect(AppTexts.ko.avatarSetup.privacyNote, contains('기기 안에만 저장'));
    expect(
      AppTexts.en.avatarSetup.privacyNote,
      contains('only when a guardian starts it'),
    );
    expect(
      AppTexts.en.avatarSetup.privacyNote,
      contains('saved on this device only'),
    );
    expect(
      AppTexts.en.avatarSetup.privacyNote,
      isNot(contains('never accesses photos')),
    );
  });
}
