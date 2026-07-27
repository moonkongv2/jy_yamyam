# Settings Legal and Support Links Plan

## Goal

Update the Settings screen so legal, support, guide, restore purchase, and app
version entries appear in commercially standard Settings locations.

The app is child-friendly and used by parents/guardians and children, so
external links and purchase-related actions must be protected by the existing
parent/guardian gate.

## Public URLs

- Privacy Policy: https://florencejyrider.github.io/app-legal-pages/privacy/yamyam-rider/
- Support: https://florencejyrider.github.io/app-legal-pages/support/yamyam-rider/

## Commit 1: Add Settings Text Keys

Scope:

- Extend `SettingsTextSet` in `lib/l10n/text_sets.dart`.
- Add or reuse localized strings in:
  - `lib/l10n/ko/settings.dart`
  - `lib/l10n/en/settings.dart`
  - `lib/l10n/ja/settings.dart`
  - `lib/l10n/es/settings.dart`
  - `lib/l10n/pt_BR/settings.dart`

Required labels:

- Help & Support / 도움말 및 지원
- User Guide / 사용 가이드
- Restore Purchase / 구매 복원
- Contact Support / 고객지원
- About / 정보
- Privacy Policy / 개인정보처리방침
- App Version / 앱 버전

Notes:

- Do not hardcode visible Settings labels.
- Reuse existing equivalent keys where appropriate, for example existing user
  guide title or purchase restore text if they match the intended Settings
  label.
- Keep translations natural and concise.
- Do not remove or rename existing localization keys unless necessary.

## Commit 2: Add External Link and Version Plumbing

Scope:

- Add `url_launcher` to open Privacy Policy and Support URLs.
- Prefer adding `package_info_plus` for App Version so the displayed version
  comes from the platform/package metadata instead of a duplicated constant.
- Run `flutter pub get` after dependency changes.

Notes:

- If dependency additions should be minimized, `url_launcher` is required for
  the external links.
- `package_info_plus` is recommended for maintainability, but the fallback is a
  small local version string matching `pubspec.yaml`.

## Commit 3: Rework Settings Screen Sections

Scope:

- Update `lib/screens/settings_screen.dart`.
- Place the new sections below normal app behavior/settings controls.
- Move the existing User Guide entry from the top Settings card into the
  `Help & Support` section near the bottom.
- Add a final `About` section after `Help & Support`.

Target layout:

1. Existing normal app behavior/settings controls.
2. Existing vehicle pack purchase card, if the purchase scope is available.
3. `Help & Support`
   - User Guide
   - Restore Purchase
   - Contact Support
4. `About`
   - Privacy Policy
   - App Version

Behavior:

- User Guide remains an internal app screen and does not require the
  parent/guardian gate.
- Restore Purchase requires the existing parent/guardian gate.
- Contact Support requires the existing parent/guardian gate, then opens the
  Support URL with `url_launcher`.
- Privacy Policy requires the existing parent/guardian gate, then opens the
  Privacy URL with `url_launcher`.
- App Version is plain text only. It should not be a tappable row.

Visual style:

- Keep the current Settings screen style.
- Prefer existing `Card`, `ListTile`, spacing, icon, and typography patterns.
- Keep changes targeted and avoid unrelated refactors.

## Commit 4: Tests

Scope:

- Update or add focused widget/localization tests.

Suggested tests:

- Settings displays `Help & Support` and `About` sections near the bottom.
- User Guide opens the internal `UserGuideScreen` without showing
  `GuardianGateSheet`.
- Restore Purchase shows `GuardianGateSheet` before any purchase restore UI or
  action.
- Contact Support shows `GuardianGateSheet` before launching the external URL.
- Privacy Policy shows `GuardianGateSheet` before launching the external URL.
- App Version is visible as non-interactive plain text.
- New Settings labels are present for Korean, English, Japanese, Spanish, and
  Brazilian Portuguese.

Potential files:

- `test/settings_purchase_section_test.dart`
- `test/purchase_localization_test.dart`
- A new focused Settings legal/support test if URL launch mocking is cleaner in
  a separate file.

## Verification

Run practical checks after implementation:

- `dart format` on changed Dart files.
- `flutter analyze`
- `flutter test test/settings_purchase_section_test.dart test/purchase_localization_test.dart`
- Run any new focused Settings test file added for legal/support links.

If tests fail, report the failing test names, likely cause, and affected scope.

## Manual Checks

After implementation, manually check these app areas/flows:

- Settings screen normal controls still appear and work.
- User Guide opens internally from Settings.
- Restore Purchase prompts the guardian gate first.
- Contact Support prompts the guardian gate, then opens the public Support URL.
- Privacy Policy prompts the guardian gate, then opens the public Privacy URL.
- App Version appears as plain text in the final About section.
- Korean, English, Japanese, Spanish, and Portuguese Settings labels fit without
  overflow.

