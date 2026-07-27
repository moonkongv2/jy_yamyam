# Finish Audio Implementation Plan

This plan documents both completed work and remaining follow-up work for the
finish/result reward audio flow.

## Agreed Behavior

- If `finishDriveDuration < 1.5s`, skip the drive SFX and only play the arrival SFX.
- If `1.5s <= finishDriveDuration < 2.5s`, play `assets/audio/final_drive_short.mp3`.
- If `finishDriveDuration >= 2.5s`, play `assets/audio/final_drive_long.mp3`.
- When the finish-drive animation completes, explicitly stop any drive SFX before playing the arrival SFX.
- Play `assets/audio/finish_arrival.mp3`, keep the arrived screen visible for about 1 second, then transition to the result screen.
- Use `assets/audio/crowd_cheering.mp3` only for the success result video, not for the timer finish-drive scene.
- Use `assets/audio/sticker_collect.mp3` only when the awarded sticker lands in the sticker album button.
- Do not add a sticker reveal sound; keep the central sticker reveal silent.
- Honor the sound setting for all newly added playback.

## Commit 1: Register And Catalog Finish/Result Audio Assets

Status: Done in `c7b04ce`.

- Add exact `pubspec.yaml` entries for:
  - `assets/audio/final_drive_short.mp3`
  - `assets/audio/final_drive_long.mp3`
  - `assets/audio/finish_arrival.mp3`
  - `assets/audio/crowd_cheering.mp3`
- Add timer finish-drive path and volume constants to `TimerAudioAssetCatalog`.
- Add a separate result audio catalog for `crowd_cheering.mp3`.
- Update asset registration tests.

## Commit 2: Extend Timer Audio Service

Status: Done in `c7b04ce`.

- Add timer finish-drive APIs:
  - `playFinishDriveShortSfx()`
  - `playFinishDriveLongSfx()`
  - `stopFinishDriveSfx()`
  - `playFinishArrivalSfx()`
- Implement them in `NoOpTimerAudioService` and `AudioplayersTimerAudioService`.
- Use dedicated players for drive and arrival SFX.
- Stop/dispose new players from `stopAll()` and `dispose()`.

## Commit 3: Wire Timer Finish-Drive Playback

Status: Done in `f475ec4`.

- Compute `finishDriveDuration` once in `_startFinishDrive()`.
- Play no drive SFX under 1.5s, short SFX under 2.5s, long SFX otherwise.
- On finish-drive animation completion:
  - stop drive SFX,
  - play arrival SFX,
  - hold the arrived screen for about 1s,
  - then open the result screen.
- Guard async completion with `mounted` and `_isFinishDriving`.

## Commit 4: Add Result Video Cheering

Status: Done in `df3c953`.

- Inspect `ResultScreen` video intro flow and use the smallest suitable audio ownership pattern.
- Play `crowd_cheering.mp3` at a low volume during success result video playback.
- Stop/dispose it on video end, skip, route change, or widget dispose.
- Honor the sound setting through the smallest existing data path or a minimal new one.

## Commit 5: Add Sticker Collect Audio

Status: Done in `182527a`.

- Add exact `pubspec.yaml` entry for:
  - `assets/audio/sticker_collect.mp3`
- Add reward/result audio catalog constant for `sticker_collect.mp3`.
- Keep `sticker_collect.mp3` as the only sticker transfer SFX:
  - no sound when the sticker first appears in the center,
  - play once when the sticker reaches the album button.
- Target timing:
  - `FlyingStickerAnimation` duration is 2.5s,
  - scale/reveal runs from about 0.0s to 0.75s,
  - fly-to-album runs from about 1.5s to 2.5s,
  - play collect SFX at animation completion or just before completion if it feels late on device.
- Current asset check:
  - `sticker_collect.mp3` duration is about 0.69s,
  - no trailing silence detected at `-45dB` for 0.08s,
  - mean volume about `-20.8dB`, max volume about `-12.3dB`.
- Start with a conservative volume around `0.08-0.10`.
- Honor `MealTimerConfig.soundEnabled` for result-screen sticker collect audio.
- Prefer routing playback through the existing result audio service so result-screen audio ownership remains centralized.

## Commit 6: Tests And Verification

Status: Done in this commit.

- Update fake timer audio service counters.
- Test finish-drive threshold behavior, arrival hold, sound-off suppression, drive SFX stop, and asset registration.
- Add focused result video cheering tests where practical.
- Add focused sticker collect tests:
  - collect SFX plays once when an awarded sticker animation completes,
  - no collect SFX when sound is disabled,
  - no collect SFX when no sticker reward is awarded.
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
- Sticker collect sound timing when a sticker lands in the album button.
- Sound disabled for result video and sticker collect audio.
