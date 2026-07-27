# Timer Audio Implementation Plan

## Commit 1: Audio Asset Catalog and License Metadata

- Validate direct playable files:
  - BGM: `assets/audio/timer_bgm/timer_bgm_01.mp3`
  - Marker: `assets/audio/marker/marker_01.mp3`
- Add `lib/catalogs/timer_audio_asset_catalog.dart` with exact asset paths and default volumes.
- Register only the exact playable files in `pubspec.yaml`.
- Add `assets/audio/README.md`.
- Add per-asset `_licenses/<stem>/README.md` and `metadata.yaml`.
- Preserve existing evidence files and use `TODO_USER` for facts that cannot be verified from local files.

## Commit 2: Dedicated Timer Audio Service

- Add `lib/services/timer_audio_service.dart`.
- Define an injectable interface for looping BGM, BGM pause/stop, marker SFX, stop-all, and dispose.
- Implement production `audioplayers` service with separate BGM and marker players.
- Keep playback failures non-fatal and log with `debugPrint`.
- Keep BGM transitions idempotent and race-resistant.

## Commit 3: TimerScreen BGM Lifecycle Integration

- Add optional `TimerAudioService` injection to `TimerScreen`.
- Own and dispose only a production service created by `TimerScreen`.
- Start BGM only after preview and actual timer start.
- Start restored running sessions when sound is enabled.
- Pause/resume/stop BGM for timer state, app lifecycle, sound setting, arrival, completion, finish drive, confirmed exit, session finalization, and dispose.
- Preserve motivation media and motivation voice behavior.

## Commit 4: Course Marker SFX Integration

- Add `ValueChanged<int>? onCourseMarkerPassed` to `RoadView`.
- Detect crossings with the same progress values used by visible ingredient markers.
- Suppress callbacks on initial mount, restore, rebuild, remount, and orientation changes.
- Emit only the highest newly crossed marker when progress jumps across several markers.
- Add parent-side duplicate protection in `TimerScreen`.
- Play marker SFX only when sound is enabled, the timer is running, the screen is mounted, preview is inactive, and finish drive is inactive.

## Commit 5: Sound Setting Localization

- Update `soundEnabled` label/subtitle in all supported locales: Korean, English, Japanese, Spanish, and Brazilian Portuguese.
- Keep a single sound setting and make the copy cover timer music, marker effects, and future motivation voice.

## Commit 6: Tests and Documentation

- Add fake `TimerAudioService` widget tests for BGM lifecycle.
- Add `RoadView` marker crossing tests.
- Add asset metadata validation tests.
- Update main README with timer audio behavior, sound setting behavior, asset layout, license evidence storage, and motivation media separation.
- Run `flutter pub get`, `dart format .`, `flutter analyze`, and `flutter test`.

## Suggested Final Commit Split

1. `Add timer audio asset catalog and license metadata`
2. `Add dedicated timer audio service`
3. `Wire timer BGM lifecycle`
4. `Play marker SFX on visible course marker crossings`
5. `Update sound setting copy for timer audio`
6. `Add timer audio tests and documentation`

