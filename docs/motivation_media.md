# Motivation Media Deferral

Motivation video and voice are temporarily deferred from the launch build because complete localized voice resources are not ready for every supported language.

This is a build availability gate, not a feature deletion. The implementation, settings schema, persisted preference fields, active-session fields, localization strings, tests, and source media files remain in the repository for later re-enablement.

## Availability Flag

Launch builds default to unavailable:

```sh
ENABLE_MOTIVATION_MEDIA=false
```

The app reads this through:

```dart
AppFeatureFlags.motivationMediaAvailable
```

To run an explicitly enabled test build:

```sh
flutter run --dart-define=ENABLE_MOTIVATION_MEDIA=true
```

To build with media unavailable:

```sh
flutter build appbundle --release \
  --dart-define=ENABLE_MOTIVATION_MEDIA=false
```

## Availability vs Preference

Keep these concepts separate:

- `AppFeatureFlags.motivationMediaAvailable`: whether this build offers motivation media.
- `MealTimerConfig.motivationVideoEnabled`: the user's saved preference.

Do not overwrite `motivationVideoEnabled` just because build availability is false. A user may have `motivationVideoEnabled: true` in preferences or in a restored active meal session, but the launch build must still block motivation media while `motivationMediaAvailable` is false.

## Supported Locale Checklist

Before re-enabling motivation media for prelaunch, confirm complete and reviewed voice resources for:

- Korean
- English
- Japanese
- Spanish
- Portuguese

## Asset Restoration

The launch bundle excludes motivation media by omitting these `pubspec.yaml` asset registrations:

```yaml
assets:
  - assets/videos/motivation/
  - assets/audio/motivation/
```

To restore motivation media:

1. Confirm the source files still exist under `assets/videos/motivation/` and `assets/audio/motivation/`.
2. Restore both asset registrations in `pubspec.yaml`.
3. Run `flutter pub get`.
4. Build with `--dart-define=ENABLE_MOTIVATION_MEDIA=true`.
5. Verify video and voice behavior in timer flows.

Enabling `ENABLE_MOTIVATION_MEDIA=true` without restoring the asset registrations is invalid. The UI and cue flow may become available while the media files are absent from the bundle.

## Testing

Disabled availability:

```sh
flutter test test/motivation_media_availability_test.dart
flutter build appbundle --release \
  --dart-define=ENABLE_MOTIVATION_MEDIA=false
```

Bundle inspection should return no matches:

```sh
unzip -l build/app/outputs/bundle/release/app-release.aab \
  | grep -E 'assets/(videos|audio)/motivation'
```

Enabled availability after restoring assets:

```sh
flutter test --dart-define=ENABLE_MOTIVATION_MEDIA=true
flutter run --dart-define=ENABLE_MOTIVATION_MEDIA=true
```

## Active-Session Restoration

Verify both restored-session states:

- Unavailable build: a restored `ActiveMealTimerSession` with `motivationVideoEnabled: true` and saved motivation fields must not activate cues, video, delayed voice, or audio playback.
- Available build: the restored motivation schedule, shown milestones, and last shown time should continue to behave as before the deferral.

## Re-Enablement Tag

Use this tag when preparing the prelaunch re-enablement checkpoint:

```text
motivation-media-enabled-prelaunch-v1
```
