# Finish Audio Implementation Plan

## Agreed Behavior

- If `finishDriveDuration < 1.5s`, skip the drive SFX and only play the arrival SFX.
- If `1.5s <= finishDriveDuration < 2.5s`, play `assets/audio/final_drive_short.mp3`.
- If `finishDriveDuration >= 2.5s`, play `assets/audio/final_drive_long.mp3`.
- When the finish-drive animation completes, explicitly stop any drive SFX before playing the arrival SFX.
- Play `assets/audio/finish_arrival.mp3`, keep the arrived screen visible for about 1 second, then transition to the result screen.
- Use `assets/audio/crowd_cheering.mp3` only for the success result video, not for the timer finish-drive scene.
- Honor the sound setting for all newly added playback.

## Commit 1: Register And Catalog Audio Assets

- Add exact `pubspec.yaml` entries for:
  - `assets/audio/final_drive_short.mp3`
  - `assets/audio/final_drive_long.mp3`
  - `assets/audio/finish_arrival.mp3`
  - `assets/audio/crowd_cheering.mp3`
- Add timer finish-drive path and volume constants to `TimerAudioAssetCatalog`.
- Add a separate result audio catalog for `crowd_cheering.mp3`.
- Update asset registration tests.

## Commit 2: Extend Timer Audio Service

- Add timer finish-drive APIs:
  - `playFinishDriveShortSfx()`
  - `playFinishDriveLongSfx()`
  - `stopFinishDriveSfx()`
  - `playFinishArrivalSfx()`
- Implement them in `NoOpTimerAudioService` and `AudioplayersTimerAudioService`.
- Use dedicated players for drive and arrival SFX.
- Stop/dispose new players from `stopAll()` and `dispose()`.

## Commit 3: Wire Timer Finish-Drive Playback

- Compute `finishDriveDuration` once in `_startFinishDrive()`.
- Play no drive SFX under 1.5s, short SFX under 2.5s, long SFX otherwise.
- On finish-drive animation completion:
  - stop drive SFX,
  - play arrival SFX,
  - hold the arrived screen for about 1s,
  - then open the result screen.
- Guard async completion with `mounted` and `_isFinishDriving`.

## Commit 4: Add Result Video Cheering

- Inspect `ResultScreen` video intro flow and use the smallest suitable audio ownership pattern.
- Play `crowd_cheering.mp3` at a low volume during success result video playback.
- Stop/dispose it on video end, skip, route change, or widget dispose.
- Honor the sound setting through the smallest existing data path or a minimal new one.

## Commit 5: Tests And Verification

- Update fake timer audio service counters.
- Test finish-drive threshold behavior, arrival hold, sound-off suppression, drive SFX stop, and asset registration.
- Add focused result video cheering tests where practical.
- Run:
  - `dart format`
  - `flutter analyze`
  - `flutter test test/timer_audio_lifecycle_test.dart`
  - `flutter test test/timer_audio_asset_catalog_test.dart`
  - focused widget tests around finish drive and result intro

## Manual Checks

- Timer early completion from near finish, mid-course, and early-course progress.
- Sound disabled during early completion.
- Arrival hold before result screen transition.
- Success result video with crowd cheering.
