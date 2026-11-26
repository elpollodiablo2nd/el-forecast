# F-Droid submission

This repository is prepared for submission to the main F-Droid repository
(https://f-droid.org). App id: `dk.elspot.app`.

## What is prepared here

- **Buildable from source without npm**: the Capacitor `android/` Gradle project is
  committed (including the synced web assets in `android/app/src/main/assets/public`),
  and the Capacitor Android library is vendored under `vendor/capacitor-android/`
  (`android/capacitor.settings.gradle` uses `node_modules` when present and falls
  back to the vendored copy). F-Droid therefore only needs
  `gradle assembleRelease` in `android/` — the unsigned APK is signed by F-Droid.
- **Vendored runtime + model are committed**: `www/vendor/ort/` (onnxruntime-web
  WASM) and `www/assets/timestral-5m.onnx` ship in the APK and are listed in
  `scanignore` in the build recipe so the source scanner keeps them.
- **No proprietary components**: Capacitor (MIT, vendored), onnxruntime-web
  (Apache-2.0), Timestral model weights (Apache-2.0). No ads, no tracking, no
  Google Play services (the unused google-services hook was removed from the
  Gradle files). The only permission is `INTERNET`.
- **License**: ISC — see `LICENSE`.
- **Store listing**: `fastlane/metadata/android/en-US/` (title, short/full
  description, changelog, 512x512 icon) — F-Droid reads these from the source repo.
- **fdroiddata recipe**: `fdroid/metadata/dk.elspot.app.yml` plus
  `fdroid/metadata/dk.elspot.app/en-US/` — copy both into a fork of
  https://gitlab.com/fdroid/fdroiddata (`metadata/dk.elspot.app.yml` and
  `metadata/dk.elspot.app/`).
- **Updates**: release tags `v*` (e.g. `v0.1.0`) drive F-Droid auto-updates via
  `AutoUpdateMode: Version v%v` + `UpdateCheckMode: Tags`.

## Build recipe summary (fdroiddata)

- `subdir: android`, `gradle: [release]` →
  `android/app/build/outputs/apk/release/app-release-unsigned.apk`
- `prebuild` installs `platforms;android-36` + `build-tools;36.0.0` into the
  build-server SDK; `sudo` installs `openjdk-21-jdk-headless` (Capacitor 8 /
  AGP 8.13 compile with Java 21).
- `versionCode 1` / `versionName 0.1.0` are set in `android/app/build.gradle`;
  dependency metadata is excluded from the APK (`dependenciesInfo`) for
  reproducible builds.

## How to submit

1. Push a release tag: `git tag v0.1.0 && git push origin v0.1.0`
2. Fork https://gitlab.com/fdroid/fdroiddata, then copy
   `fdroid/metadata/dk.elspot.app.yml` → `metadata/dk.elspot.app.yml` and
   `fdroid/metadata/dk.elspot.app/` → `metadata/dk.elspot.app/`
3. Optionally validate locally with fdroidserver:
   `fdroid readmeta dk.elspot.app && fdroid lint dk.elspot.app`
4. Open a merge request against `fdroid/fdroiddata` (the MR bot runs a real
   build of the recipe). Alternatively open an issue requesting inclusion.
5. After merge, F-Droid's build server builds and signs the APK; pushing new
   `v*` tags afterwards is picked up automatically by `checkupdates`.

## Local / CI release build

`tools/build-android-release.sh [versionName] [versionCode]` performs the full
build (npm ci → sync-www → cap sync → launcher icon → `gradlew assembleRelease`)
and is used by `.github/workflows/release-apk.yml` on `v*` tags.
