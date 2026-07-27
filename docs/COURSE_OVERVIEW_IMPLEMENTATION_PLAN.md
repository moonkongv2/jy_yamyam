# Course Overview Implementation Plan

## Commit 1: Separate Startup Preview From Reusable Course Overview State

- Add a private preview/overview mode enum in `lib/screens/timer_screen.dart`, e.g. `_CoursePreviewMode.none/startup/overview`.
- Replace broad `_isPreviewing` checks with focused helpers such as `_isStartupPreviewing`, `_isCourseOverviewing`, and `_isCameraPreviewActive`.
- Keep startup behavior identical: long courses animate camera `0 -> 1 -> 0`, show Ready/Go, then start the timer.
- Add a new handler for already-started timers longer than 5 minutes.
- Course overview should animate the camera from current timer progress to `1`, pause briefly, then return the camera to the latest real timer progress.
- During course overview, keep `vehicleProgress` on the live timer progress so the vehicle does not jump back to the start.
- If the timer arrives while overview is active, cancel the overview and continue the existing arrival/completion flow.
- If pause or complete is requested while overview is active, cancel the overview first and then perform the requested action.
- Prevent camera-only marker crossings from producing duplicate SFX, while preserving SFX for real vehicle progress.

## Commit 2: Add Course Overview Buttons In All Timer Layouts

- Extend `TimerTextSet` and all language implementations with a short tooltip/semantic label.
  - Korean: `코스 보기`
  - English: `View course`
- Add an icon button using `Icons.route_rounded` or `Icons.map_rounded`.
- Portrait: add the button to AppBar actions beside sound and motivation settings.
- Landscape: add the button to `_LandscapeCourseCanvas` top icon row beside sound/settings.
- Compact landscape: add the button to `_CompactLandscapeControls`.
- Enable only when:
  - the timer has started,
  - duration is longer than 5 minutes,
  - finish drive is not active,
  - no camera preview or overview is currently active.
- Hide or disable the button for courses of 5 minutes or shorter.

## Commit 3: Add Focused Tests And Verification

- Add a widget test that a timer longer than 5 minutes exposes the course overview button after startup preview.
- Add a widget test that tapping the button changes `RoadView.cameraProgress` while `RoadView.vehicleProgress` remains close to the live timer progress.
- Add a widget test that timers of 5 minutes or shorter do not expose or enable the course overview button.
- Add coverage for overview cancellation by pause/complete.
- Add coverage for overview cancellation when the timer arrives during overview.
- Update compact landscape coverage so the extra action still fits in the existing control slot.
- Add or update audio lifecycle coverage so overview does not stop BGM or create duplicate marker SFX from camera-only movement.
- Run:
  - `dart format lib/screens/timer_screen.dart lib/l10n/*/timer.dart lib/l10n/text_sets.dart test/widget_test.dart test/timer_audio_lifecycle_test.dart`
  - `dart analyze`
  - `flutter test test/widget_test.dart test/timer_audio_lifecycle_test.dart`

## Manual Checks

- Portrait timer screen with 15/25/35 minute courses.
- Standard landscape timer screen.
- Compact landscape timer screen.
- Pause and meal completion while course overview is active.
- Starting course overview near arrival.
- Sound-enabled BGM and marker SFX behavior.
