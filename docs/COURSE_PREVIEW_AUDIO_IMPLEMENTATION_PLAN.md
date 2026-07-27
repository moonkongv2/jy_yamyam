# Course Preview Audio Implementation Plan

## Current Audio Timing

- `assets/audio/course_loading.mp3`: 6.576 seconds.
- `assets/audio/ready_start_beep_02.mp3`: 1.533958 seconds.
- Current startup sequence:
  - Course preview animation for timers longer than 5 minutes: about 4.7 seconds.
  - Ready message: 770 ms after implementation.
  - Go message: 770 ms after implementation.
  - Ready + Go total: 1.54 seconds after implementation.

The current `ready_start_beep_02.mp3` length fits a 770 ms Ready + 770 ms Go sequence, so the startup preview message delays should be updated from 700 ms to 770 ms.

## Commit 1: Register Preview Audio Assets

- Add exact asset paths to `pubspec.yaml`:
  - `assets/audio/course_loading.mp3`
  - `assets/audio/ready_start_beep_02.mp3`
- Add catalog constants in `TimerAudioAssetCatalog`:
  - `courseLoadingAssetPath`
  - `readyStartBeepAssetPath`
  - `courseLoadingVolume`
  - `readyStartBeepVolume`
- Extend `timer_audio_asset_catalog_test.dart` to verify both files exist and both paths are registered in `pubspec.yaml`.
- Verification:
  - `flutter test test/timer_audio_asset_catalog_test.dart`

## Commit 2: Add Preview Audio APIs

- Add preview audio methods to `TimerAudioService`:
  - `playCourseLoading()`
  - `stopCourseLoading()`
  - `playReadyStartBeep()`
  - `stopReadyStartBeep()`
- Implement no-op methods in `NoOpTimerAudioService`.
- Add dedicated players in `AudioplayersTimerAudioService`:
  - `_courseLoadingPlayer`
  - `_readyStartBeepPlayer`
- Play both preview sounds as one-shot audio.
- Stop and dispose both players from `stopAll()` and `dispose()`.
- Guard all preview stop methods with `_disposed` checks before touching native players.

## Commit 3: Wire Startup Preview Playback

- In `TimerScreen._startPreviewSequence()`, play `course_loading.mp3` only during the course preview animation section.
- Stop `course_loading.mp3` immediately after the preview reverse animation completes.
- Play `ready_start_beep_02.mp3` once immediately before showing the Ready message.
- Change the Ready delay and Go delay from 700 ms to 770 ms each.
- Stop both preview sounds before `_controller.start()` so timer BGM does not overlap.
- Do not play either preview sound for restored sessions.
- Do not play either preview sound during manual course overview after the timer has started.

## Commit 4: Handle Sound and Lifecycle Edges

- If sound is disabled before startup preview, do not play preview audio.
- If sound is toggled off during startup preview, stop the active preview audio.
- If sound is toggled on again during the course-loading phase, allow `course_loading.mp3` to resume.
- Do not restart `ready_start_beep_02.mp3` after it has already fired; it is a short cue tied to the Ready transition.
- On app background during startup preview, stop or pause active preview audio.
- On foreground return, resume only the course-loading phase if it is still active.

## Commit 5: Add Focused Tests

- Extend `_FakeTimerAudioService` in `test/timer_audio_lifecycle_test.dart` with preview audio call counters.
- Add tests for:
  - New 5-minute-plus timer plays course loading audio during startup preview.
  - Course loading audio stops before timer BGM starts.
  - Ready/Go beep plays once before timer start.
  - Sound disabled prevents preview audio and BGM.
  - Restored running/paused sessions do not play preview audio.
  - 5-minute-or-shorter timers skip course loading but still play Ready/Go beep.

## Final Verification

- `dart format` changed Dart files.
- `flutter test test/timer_audio_lifecycle_test.dart test/timer_audio_asset_catalog_test.dart`.
- `flutter analyze` when practical.

## Manual Check Areas

- Timer startup preview for durations longer than 5 minutes.
- Timer startup for durations 5 minutes or shorter.
- Ready/Go cue timing.
- Transition from preview audio to timer BGM.
- Sound off and sound toggle behavior.
- App background/foreground during startup preview.
- Restored session entry.
