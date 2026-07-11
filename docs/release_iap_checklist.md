# Release IAP Checklist

This checklist tracks the first-release in-app purchase setup for Yamyam Rider.
It is written for the current client-only design: no ads, no login, no backend,
and local-first app progress.

Policy references were checked on 2026-07-03:

- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple Kids apps guidance: https://developer.apple.com/kids/
- Apple In-App Purchase overview: https://developer.apple.com/in-app-purchase/
- Google Play Families policies: https://support.google.com/googleplay/android-developer/answer/9893335
- Google Play Billing: https://developer.android.com/google/play/billing

## Verification Status

Checked on 2026-07-03:

- `flutter analyze`: passed.
- Focused IAP and vehicle entitlement tests: passed.
- `VehicleSelectionCard` locked tap widget test: passed.
- Full `flutter test`: not green yet because of existing broad `test/widget_test.dart` failures outside the IAP vehicle pack scope.

Known full-suite failure areas to resolve before release:

- Outdated result screen copy expectations.
- Timer preview sequence tests leaving pending fake timers.
- Outdated English locale copy expectations.
- Existing avatar setup guide visibility/scroll expectation.
- Reward goal confirmation copy expectation.

## Product

- Product ID: `vehicle_pack`
- Product type: one-time purchase / non-consumable
- Unlock behavior: unlock all premium vehicles on this device after purchase or restore
- Free vehicles:
  - `motorcycle`
  - `supercar`
- Premium vehicles:
  - `fire_truck`
  - `police_car`
  - `excavator`
  - `airplane`
  - `bus`
  - `train`
  - `t_rex`
  - `shark`
  - `brachio`
  - `pteranodon`

## Current App Behavior

- Locked vehicles stay visible in the vehicle picker.
- Tapping a locked vehicle does not select it directly.
- Locked vehicle flow:
  1. Vehicle pack intro sheet
  2. Guardian gate
  3. Vehicle pack purchase/restore sheet
- Settings shows the vehicle pack card lower in the settings list.
- When the pack is locked, Settings exposes vehicle pack purchase and restore behind the guardian gate.
- When the pack is unlocked, Settings shows only the unlocked status and hides purchase/restore actions.
- Purchase state is kept separate from `MealTimerConfig`.
- The local entitlement cache is stored through `LocalPurchaseEntitlementStore`.
- Normal settings, progress, stickers, rewards, active timer state, and avatars remain local-first.
- A saved premium `vehicleId` falls back to `motorcycle` while entitlement is locked, without rewriting the saved setting.

## Client-Only IAP Limitations

This release intentionally has no backend server. The app relies on the store
purchase stream plus a local entitlement cache.

Known limitations:

- There is no server-side receipt or purchase token validation.
- A modified device, tampered app build, or edited local storage could fake the local entitlement.
- The app cannot centrally revoke access if a purchase is refunded or reversed and the device stays offline.
- Cross-device restore depends on App Store / Google Play restore behavior, not an app account.
- Support cannot look up purchases in an app backend because no user account or backend exists.

Accepted first-release tradeoff:

- The product is a low-risk, one-time vehicle pack for a kids app.
- The app stores no personal account data and avoids login, analytics, ads, backend, and remote config.
- Offline access after a successful purchase is required, so the local cache is part of the intended behavior.

Future trigger for server validation:

- Add backend receipt validation if the app adds higher-value purchases, account-based sync, family account management, fraud handling, refund-aware revocation, or customer support workflows that require authoritative purchase lookup.

## Store Setup

Before submitting a release build:

- Create the non-consumable product `vehicle_pack` in App Store Connect.
- Create the matching one-time managed product `vehicle_pack` in Play Console.
- Use the exact same product ID in both stores and in `lib/constants/iap_product_ids.dart`.
- Add localized product name, description, and price in each store.
- Make the IAP product reviewable and available to the build submitted for review.
- Include review notes explaining that locked vehicles open an info sheet, then a guardian gate, then purchase/restore UI.
- Test restore on both platforms.
- Test purchase cancel, pending, failed, purchased, and restored states where platform tools allow.

Suggested product metadata:

- Korean name: `차량팩`
- English name: `Vehicle Pack`
- Korean description: `한 번 구매하면 잠긴 빠방을 모두 사용할 수 있어요.`
- English description: `Unlock all locked rider vehicles with one purchase.`

## Local StoreKit Testing

The repo includes `ios/Runner/VehiclePack.storekit` for local iOS simulator
testing before the App Store Connect product is available.

Use it only for local development:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the `Runner` scheme.
3. Open `Edit Scheme...` > `Run` > `Options`.
4. Set `StoreKit Configuration` to `VehiclePack.storekit`.
5. Run the app on an iOS simulator.
6. Tap a locked vehicle, pass the guardian gate, and verify the purchase sheet loads the `vehicle_pack` test product.
7. Complete a local StoreKit purchase and verify the selected premium vehicle unlocks.
8. Restart the app and verify the local entitlement cache keeps premium vehicles unlocked.
9. Use the post-gate restore button and locked-state Settings restore flow to verify restore handling.

Local StoreKit testing does not replace App Store sandbox or TestFlight testing.
Before release, still create the real App Store Connect non-consumable product
with the same `vehicle_pack` product ID and test against Apple's sandbox store.

If the purchase sheet shows the generic purchase failure message while loading
the price, stop the app and run it from Xcode with the `Runner` scheme. A plain
`flutter run` launch may not attach the StoreKit configuration, which makes the
simulator query the real App Store environment where `vehicle_pack` does not
exist yet.

## Platform Project TODOs

Android and iOS production identifiers have been set in the project. Do not
submit until the matching store records and signing setup are complete.

- Android:
  - Current `applicationId`: `com.yamyamrider.app`
  - Current `namespace`: `com.yamyamrider.app`
  - TODO: create the matching Play Console app record.
  - TODO: configure release signing. The current release build uses debug signing.
- iOS:
  - Current bundle ID: `com.yamyamrider.app`
  - TODO: configure the App Store Connect app record with that bundle ID.
  - TODO: enable In-App Purchase capability if the final Xcode/App Store setup requires it.

## Kids App Review Checklist

- No ads.
- No third-party analytics.
- No login.
- No backend server.
- No external purchase links.
- No direct purchase opportunity before a guardian gate.
- Gate-before-purchase behavior is required for:
  - locked vehicle purchase entry from Home
  - locked vehicle purchase entry from Avatar setup
  - locked-state Settings purchase entry
  - locked-state Settings restore entry
- The pre-gate intro sheet must stay informational only:
  - allowed: vehicle pack context and guardian continuation
  - avoid before gate: price, buy button, restore action, sales pressure, external links
- The purchase sheet may show price, buy, and restore only after guardian gate success.
- The guardian gate should remain adult-oriented and not become a child-facing game.

## Privacy And Data Safety

Store privacy/data-safety answers should reflect the actual app behavior:

- The app has no ads.
- The app has no analytics SDK.
- The app has no login or account system.
- The app has no backend server.
- Meal progress, settings, stickers, reward goals, active timer state, and purchase entitlement cache are stored locally.
- Avatar image selection is optional, user-initiated, and local-only.
- Do not claim that the app never accesses photos. The app uses `image_picker` when a guardian starts custom avatar image selection.
- If photo/media permission wording is required by a store form, describe it as optional and used only to select a custom local rider image.
- In-app purchase transactions are handled by Apple / Google store systems.

Suggested privacy wording:

- Korean: `사진 선택은 보호자가 직접 시작할 때만 열리며, 선택한 라이더 이미지는 이 기기 안에만 저장됩니다.`
- English: `Photo selection opens only when a guardian starts it, and the selected rider image is saved on this device only.`

## Manual Test Before Submission

- Fresh install: free vehicles can be selected without purchase.
- Fresh install: premium vehicles are visible with locked state.
- Home locked vehicle tap: intro sheet appears before guardian gate.
- Avatar setup locked vehicle tap: intro sheet appears before guardian gate.
- Guardian gate wrong answer: purchase UI is not shown.
- Guardian gate correct answer: purchase UI is shown.
- Purchase cancel/failure: current selected vehicle remains unchanged.
- Purchase success: entitlement is saved and premium vehicle selection works.
- Restore success: entitlement is saved and premium vehicle selection works.
- App restart after purchase: premium vehicles remain unlocked from local cache.
- Offline after cached purchase: unlocked vehicles remain available.
- Locked saved `vehicleId` without entitlement: timer uses `motorcycle` fallback without overwriting the saved setting.
- Locked-state Settings: vehicle pack card appears lower in the settings list, not on the first screen.
- Locked-state Settings purchase entry requires guardian gate.
- Locked-state Settings restore entry requires guardian gate.
- Unlocked-state Settings: vehicle pack card appears lower in the settings list as a status-only card.
- Unlocked-state Settings: purchase and restore actions are hidden.
- Korean and English purchase/privacy copy fit on small devices.
