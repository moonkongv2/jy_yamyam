# Meal Timer Duration Policy Plan

## Commit 1: Add Centralized Timer Policy

Goal: create one authoritative source for meal timer duration limits.

- Add a shared policy file under the existing config layer.
- Define production minimum as 5 minutes.
- Define explicit short-test minimum as 1 minute.
- Define maximum as 60 minutes.
- Make `kReleaseMode` override `ALLOW_SHORT_TIMER=true`.
- Split compile-time environment reading from pure range normalization so tests can cover policy logic without mutating compile-time defines.
- Keep preset/default course values in `MealCourseCatalog`; do not change `15/25/35` presets or the 25-minute default.
- Avoid deleting `MealCourseCatalog` custom range constants until all usage and ownership are confirmed.

Tests:

- Default non-release policy minimum is 5 when no define is provided.
- Maximum remains 60.
- Normalization maps `1 -> 5`, `4 -> 5`, `5 -> 5`, `60 -> 60`, and values above `60 -> 60`.
- Pure environment selection proves release mode returns 5 even when short timer is allowed.

## Commit 2: Normalize Settings Persistence

Goal: prevent stored settings from carrying invalid durations into app state.

- In `LocalSettingsService.loadConfig`, normalize loaded `durationMinutes` through the policy.
- Preserve existing fallback behavior for missing or malformed values.
- In `LocalSettingsService.saveConfig`, save the normalized duration.
- Add tests for stored values below 5 and above 60.

## Commit 3: Apply Policy to UI and Start Boundaries

Goal: keep selectors and timer starts valid for both `5-60` and explicit `1-60` modes.

- Normalize `_customMinutes` initialization and updates in `HomeScreen`.
- Use policy min/max for the custom duration sheet Slider and adjustment buttons.
- Normalize selected custom minutes before starting.
- Normalize `_startTimer` input before creating `MealTimerConfig`.
- Normalize active session resume config before passing it to `TimerScreen`.
- Normalize duration updates in `SettingsScreen`; leave preset options unchanged.
- Add focused widget/controller tests for Slider validity and start-boundary clamping.

## Commit 4: Normalize Active Session Persistence

Goal: release builds must not resume or persist a 1-4 minute active timer.

- Normalize `durationMs` when active session JSON is decoded.
- Normalize snapshot config before active sessions are persisted.
- Keep saved elapsed/start timing unchanged; only target duration is policy-normalized.
- Add tests that restored 1-4 minute sessions become 5-minute sessions while elapsed time remains wall-clock based.

## Commit 5: Documentation and Verification

Goal: document the local short-timer mode and verify the change.

- Update `README.md` to say normal runs use a 5-minute minimum.
- Document `flutter run --dart-define=ALLOW_SHORT_TIMER=true` for local 1-minute testing.
- State that release builds always enforce a 5-minute minimum.
- Run:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`

Manual check areas:

- Home preset course start.
- Home custom duration sheet.
- Settings default meal duration.
- Active timer resume.
- `flutter run` minimum: 5 minutes.
- `flutter run --dart-define=ALLOW_SHORT_TIMER=true` minimum: 1 minute.
