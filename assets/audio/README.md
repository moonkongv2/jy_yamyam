# Audio Assets

This directory contains runtime audio files and repository-local license evidence for bundled audio.

## Runtime Assets

- `timer_bgm/`: timer background music used during active meal rides.
- `marker/`: course-marker sound effects used when visible meal ingredient markers are passed.
- `motivation/`: deferred motivation voice assets retained for later feature re-enablement.
- `timer_end.mp3`: the repeating timer-expiration alarm used by the existing completion dialog.

Only exact playable app audio files should be registered in `pubspec.yaml`. Do not register entire audio directories, because `_licenses`, metadata files, PDF evidence, certificates, screenshots, and original source files must not be bundled into the app.

## Timer End Alarm

`timer_end.mp3` is the supplied, unchanged MP3 (approximately 3.408 seconds,
48 kHz stereo, 256 kbps, 109,056 bytes). Its path and initial volume multiplier
of `0.24` are configured in `TimerAudioAssetCatalog`. The audio service preserves
constructor overrides for both values and uses a dedicated looping media player.

With sound enabled, the alarm repeats from expiration until a response to the
completion dialog. It stops on an explicit response, inactivity, mute, or exit;
unconfirmed alarms resume when the same timer becomes active again. Restoring
an already expired session after relaunch does not replay it. Early completion
continues to use the separate one-shot `finish_arrival.mp3`.

Manual completion dialog cancellation and automatic expiry responses have
different result semantics. See the scenario table in
[`../../docs/TIMER_END_ALARM_IMPLEMENTATION_PLAN.md`](../../docs/TIMER_END_ALARM_IMPLEMENTATION_PLAN.md).
There is no background/lock-screen alarm. Perceived volume and loop boundaries
require Android/iOS device checks; automated tests do not evaluate sound quality.

## License Evidence

Each shipped audio file should keep its evidence under:

```text
<runtime-directory>/_licenses/<audio-file-stem>/
```

Store available evidence in that per-asset folder, such as:

- `content_page.pdf`
- `content_page_screenshot.png`
- `license_page.pdf`
- `license_certificate.txt`
- the unmodified downloaded original file, if different from the app asset

Do not invent source URLs, creator names, download dates, license certificates, PDF evidence, or Content ID status. Leave unknown metadata as `TODO_USER` until verified from real source material.

Licensed audio files and evidence are committed to this private repository so the app can be rebuilt and audited. Do not redistribute licensed files independently from the app. If another app ships a copy of the same audio, that app's repository must keep its own evidence and metadata.

