# F-Droid submission

This repository is prepared for submission to the main F-Droid repository.
App id: `dk.elspot.app`. **Note:** submissions go to
**gitlab.com/fdroid/fdroiddata** — the GitHub repo `f-droid/fdroiddata` is a
read-only mirror that maintainers never see.

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
- **Store listing (read by F-Droid from this repo)**: `fastlane/metadata/android/en-US/`
  with title.txt, short_description.txt, full_description.txt, changelogs/1.txt
  and a 512x512 `images/icon.png`. Per fdroiddata policy these are NOT copied
  into fdroiddata — only the yml below is.
- **fdroiddata recipe**: `fdroid/metadata/dk.elspot.app.yml` — the single file to
  add to a fork of fdroiddata as `metadata/dk.elspot.app.yml`. It is in
  `fdroid rewritemeta` canonical form and passes fdroiddata CI:
  `check-jsonschema --schemafile schemas/metadata.json` (required fields incl.
  `CurrentVersion`/`CurrentVersionCode`, `AutoUpdateMode: Version`), `fdroid lint`,
  `fdroid rewritemeta` (no diff) and `fdroid checkupdates` (finds tag `v0.1.0`).
  A `.fdroid.yml` with `commit: HEAD` is also at the root for own-CI
  `fdroid build` runs against a mirror of this repo.
- **Updates**: release tags `v*` (e.g. `v0.1.0`) drive F-Droid auto-updates via
  `AutoUpdateMode: Version` + `UpdateCheckMode: Tags`.

## How to submit (manual — needs a GitLab account)

1. Register on https://gitlab.com and fork https://gitlab.com/fdroid/fdroiddata
   (optionally open an RFP issue at https://gitlab.com/fdroid/rfp first).
2. In your fork, create a branch named `dk.elspot.app` (not the protected
   `master`) and add exactly one file: `metadata/dk.elspot.app.yml`, copied from
   `fdroid/metadata/dk.elspot.app.yml` in this repo.
3. Open a merge request against `fdroid/fdroiddata` with title `New app: elspot`.
   A filled-in MR description following their template is ready to paste in
   [fdroid/MR_DESCRIPTION.md](fdroid/MR_DESCRIPTION.md).
4. Watch the MR pipeline (it runs a real build of the recipe) and answer any
   maintainer questions. After merge, F-Droid's build server signs and publishes
   the APK; pushing new `v*` tags here afterwards is picked up automatically.

## Build recipe summary (fdroiddata)

- `subdir: android`, `gradle: [yes]` (no flavors → `assembleRelease`) →
  `android/app/build/outputs/apk/release/app-release-unsigned.apk`
- `commit` is the full hash of tag `v0.1.0`:
  `6796e2d91ee97f73f1b640e0a1878046443cd420`
- `prebuild` locates `sdkmanager` under `$$SDK$$` (`cmdline-tools/*/bin` or the
  legacy `tools/bin` layout used by the buildserver image) and installs
  `platforms;android-36` + `build-tools;36.0.0` (the image preinstalls only up
  to android-33 / build-tools 33.0.0)
- `sudo` installs `openjdk-21-jdk-headless` + selects it via
  `update-java-alternatives`, and `gradleprops` pins
  `org.gradle.java.home=/usr/lib/jvm/java-21-openjdk-amd64` (Capacitor 8 /
  AGP 8.13 compile with Java 21).
- `versionCode 1` / `versionName 0.1.0` are set in `android/app/build.gradle`;
  dependency metadata is excluded from the APK (`dependenciesInfo`) for
  reproducible builds.

## Build verification (2026-11-26)

The exact F-Droid path was exercised locally: clean clone of tag `v0.1.0`
(no `node_modules`, vendored Capacitor used), Temurin JDK 21, SDK 36,
`./gradlew --no-daemon assembleRelease` in `android/` → **BUILD SUCCESSFUL**.

Resulting `app-release-unsigned.apk` (26 MB):

- `aapt dump badging`: `dk.elspot.app`, `versionCode=1`, `versionName=0.1.0`
  (matches the recipe), label `elspot`, launchable `dk.elspot.app.MainActivity`,
  minSdk 24 / targetSdk 36, only `INTERNET` permission, not debuggable, unsigned
  (`apksigner verify` → "DOES NOT VERIFY", no META-INF signatures — F-Droid signs it)
- contains the full web bundle: `assets/public/index.html` (with the injected
  `vendor/ort/ort.min.js` loader), the ORT WASM runtime, the bundled
  `assets/timestral-5m.onnx` (22 MB) and the price snapshots; launcher icons at
  all densities (the 192px icon is pixel-identical to the pixel-bolt source)
- reproducible: two clean builds produce the identical SHA-256
  (`def95bb63fe26c558987d67b23a6acc32f0d27ab02146b00c094ee7b9b8b6e86`)
- app logic: `npm test` passes 128/128 (ONNX WASM vs PyTorch reference 5M/28M
  + web suite)

## Local / CI release build

`tools/build-android-release.sh [versionName] [versionCode]` performs the full
build (npm ci → sync-www → cap sync → launcher icon → `gradlew assembleRelease`)
and is used by `.github/workflows/release-apk.yml` on `v*` tags.
`npm test` runs the ONNX-vs-PyTorch WASM tests (5M/28M) plus the web suite.
