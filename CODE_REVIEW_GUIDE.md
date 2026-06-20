# Code Review Guide

This guide is for reviewers who are seeing Yamyam Rider for the first time. It focuses on where behavior lives, what usually breaks, and which tests give useful signal.

## First Pass

Start with these files:

- `README.md`: product summary, app flow, asset layout, and project structure.
- `lib/app.dart`: app root, theme, localization, and initial routing.
- `lib/models/meal_timer_config.dart`: user-facing timer settings, selected vehicle, avatar, and media options.
- `lib/catalogs/vehicle_catalog.dart`: source of truth for vehicle order, labels, assets, and course type.
- `lib/services/local_settings_service.dart`: persisted app settings.
- `lib/services/local_meal_progress_service.dart`: meal history, vehicle sticker inventory, and reward goal persistence.
- `lib/screens/home_screen.dart`, `lib/screens/timer_screen.dart`, `lib/screens/result_screen.dart`: main user flow.

The app is local-first. There is no backend. Most state is stored in `SharedPreferences`, so review persistence changes carefully.

## Main Behavior Map

### Onboarding and Settings

- First-run onboarding and child name setup route through `lib/app.dart`.
- Long-lived user configuration is `MealTimerConfig`.
- Settings persistence is handled by `LocalSettingsService`.
- Custom avatar files are normalized and stored through `LocalAvatarImageService`.
- Vehicle-specific avatar settings are stored per vehicle, not globally.

Review focus:

- Invalid or missing stored values should fall back safely.
- New settings should preserve existing stored settings.
- UI changes should update Korean and English text sets together.

### Vehicle Selection

- Vehicle definitions live in `VehicleCatalog.all`.
- This order drives vehicle selection and sticker collection ordering.
- Unknown vehicle IDs generally fall back to motorcycle for display.
- Motivation/result media use vehicle IDs to select assets.

Review focus:

- Do not hardcode vehicle lists in screens if `VehicleCatalog.all` can be used.
- When adding a vehicle, check assets, prompts, motivation media, result media, tests, and labels.
- Keep vehicle ID strings stable once stored data may depend on them.

### Timer Flow

- Timer state and elapsed-time calculations live in `MealTimerController`.
- Active timer persistence is handled by `ActiveMealTimerSessionStore`.
- UI orchestration lives mostly in `TimerScreen`.
- Completion handoff to result flow uses `TimerCompletionFlowController`.

Review focus:

- Elapsed time should be derived from wall-clock timestamps, not frame counts.
- Pause, resume, app background/foreground, and active session restore are high-risk paths.
- Completion should clear active sessions and pass the selected vehicle and selected ingredients forward.

### Result and Rewards

- `ResultScreen` records the meal once and displays completion feedback.
- `LocalMealProgressService.recordMealResult` creates history entries, awards vehicle stickers, updates inventory, and fills reward goals.
- `RewardCatalog` generates vehicle stickers from `VehicleCatalog.all`.
- Completed meals award exactly one sticker for the selected vehicle. Incomplete meals award none.

Review focus:

- Do not reintroduce random sticker selection.
- Do not award stickers for incomplete meals.
- If selected vehicle resolution changes, verify result display and recorded reward stay aligned.
- Inventory count accumulation should preserve existing counts and order.
- Reward goal filling should only use awarded stickers and should not modify unrelated goals.

### Meal History and Sticker Collection

- Meal history display is in `MealHistoryScreen`.
- Sticker collection display is in `StickerCollectionScreen`.
- Sticker visuals are centralized in `RewardStickerImage`.
- Reward labels come from `RewardDefinition.labelForLanguage`.

Review focus:

- Unknown reward IDs should not crash history or goal displays.
- Locked stickers should remain accessible via semantic labels.
- Sticker collection should follow `VehicleCatalog.all`.
- Do not add migration or cleanup unless the task explicitly asks for it.

### Motivation Media

- Motivation video/voice catalogs are in `MotivationAssetCatalog`.
- Timing rules are in `motivation_video_schedule.dart`.
- Playback orchestration is in timer-related controllers and services.

Review focus:

- Missing vehicle media should fall back safely.
- Sound-disabled mode should not play voice.
- Timing changes should keep the minimum interval behavior covered by tests.

## Localization Review

Text is not generated from ARB files. It is implemented through typed text sets:

- Interfaces: `lib/l10n/text_sets.dart`
- Wiring: `lib/l10n/app_texts.dart`
- Korean: `lib/l10n/ko/`
- English: `lib/l10n/en/`

Review checklist:

- Interface changes must update both Korean and English implementations.
- User-facing behavior changes should update guide/help copy if needed.
- Avoid hardcoded display text in screens unless existing local pattern does so.
- Reward names should use `RewardDefinition.labelForLanguage`.

## Persistence Review

Important local stores:

- Settings: `LocalSettingsService`
- Active timer: `ActiveMealTimerSessionStore`
- Progress, history, inventory, goals: `LocalMealProgressService`

Review checklist:

- Stored decode paths should tolerate malformed local data where practical.
- Valid stored data should keep the same behavior and ordering.
- Avoid deleting or rewriting stored data unless the task requires migration.
- New stored fields should have safe fallbacks for old data.
- Date and duration values should remain parseable and deterministic in tests.

## UI Review

The UI uses shared design tokens and reusable app widgets:

- Colors, spacing, radius, shadows, motion: `lib/theme/`
- Shared UI primitives: `lib/widgets/app/`

Review checklist:

- Check portrait and landscape layouts for timer/result changes.
- Check compact viewports for text overflow.
- Preserve semantic labels for image-only or icon-heavy controls.
- Prefer existing app widgets and theme tokens over one-off styling.
- Result, sticker collection, reward goal, and meal history should show consistent reward imagery.

## Tests to Know

Run the standard checks:

```bash
dart format lib test
flutter analyze
flutter test
```

Focused test files:

- `test/meal_timer_controller_test.dart`: timer restore and elapsed-time behavior.
- `test/timer_active_session_controller_test.dart`: mapping persisted active sessions.
- `test/timer_completion_flow_controller_test.dart`: completion flow decisions.
- `test/active_meal_timer_session_store_test.dart`: active session persistence.
- `test/local_avatar_image_service_test.dart`: avatar file normalization/storage.
- `test/reward_sticker_image_test.dart`: sticker image rendering variants.
- `test/widget_test.dart`: app flow, localization, vehicle catalog, result, rewards, history, and screen integration.

When a PR touches a specific flow, prefer adding a focused test near the existing coverage instead of creating broad brittle tests.

## High-Risk Review Areas

- Timer lifecycle: pause/resume, app resume, active session restore, fast finish, arrival.
- Local persistence decode/encode behavior.
- Reward awarding and reward goal slot filling.
- Vehicle ID propagation from home to timer to result to history.
- Custom avatar per-vehicle storage and fallback.
- Localization interface churn.
- Media asset catalogs and missing asset fallbacks.
- Layout changes in compact portrait or landscape result/timer screens.

## PR Review Checklist

- Behavior matches the product rule, not only the visible UI.
- Korean and English copy both compile and stay consistent.
- Shared catalog sources are used instead of duplicated lists.
- Local stored data remains backward-tolerant unless migration is intentional.
- Unknown IDs and missing assets fall back safely.
- Tests cover the changed behavior at the right level.
- `flutter analyze` and relevant tests pass.
- The change avoids unrelated refactoring or asset churn.

## Useful Manual Checks

For UI or flow changes, manually exercise the smallest matching flow:

- First launch: onboarding -> child name -> home.
- Vehicle change: select vehicle -> start timer -> complete -> result sticker.
- Incomplete meal: complete as incomplete -> result -> history shows no sticker.
- Sticker collection: uncollected silhouettes, collected counts, catalog order.
- Reward goal: create goal -> complete meal -> goal slot fills -> goal earned.
- Timer lifecycle: start -> pause -> resume -> background/restore -> complete.
- Localization: repeat the affected screen in Korean and English.
