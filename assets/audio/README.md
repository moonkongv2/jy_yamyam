# Audio Assets

This directory contains runtime audio files and repository-local license evidence for bundled audio.

## Runtime Assets

- `timer_bgm/`: timer background music used during active meal rides.
- `marker/`: course-marker sound effects used when visible meal ingredient markers are passed.
- `motivation/`: deferred motivation voice assets retained for later feature re-enablement.

Only exact playable app audio files should be registered in `pubspec.yaml`. Do not register entire audio directories, because `_licenses`, metadata files, PDF evidence, certificates, screenshots, and original source files must not be bundled into the app.

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

