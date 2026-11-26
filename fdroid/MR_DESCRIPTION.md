# Merge request description for gitlab.com/fdroid/fdroiddata

MR title: `New app: elspot`

Branch in your fdroiddata fork: `dk.elspot.app` (do not commit to your `master`).
Only file added in the MR: `metadata/dk.elspot.app.yml`
(copy of [fdroid/metadata/dk.elspot.app.yml](../metadata/dk.elspot.app.yml) from
https://github.com/elpollodiablo2nd/el-forecast — listing texts/icon/changelog
are NOT added here, they live in the upstream repo at
`fastlane/metadata/android/en-US/`, which F-Droid reads from source).

Paste the following as the MR description:

---

## Abstract for new app inclusion

### Please introduce the functions and usage of your app in summary, and also attach some screenshots.

**elspot** (`dk.elspot.app`) forecasts Danish electricity spot prices (elspot) for
the DK1/DK2 price areas, 24/48/72 hours ahead, with a full uncertainty curve
(21 quantiles per hour) instead of a single point estimate. The forecast runs
**fully on-device**: Mistral's open Timestral time-series model is exported to
ONNX and executed in the app with onnxruntime-web (WASM) — no API key, no server
round-trip for the model. The 5M model (~22 MB) is bundled in the APK; the more
accurate 28M model is downloaded once and cached. Prices/fees come from Energi
Data Service (Energinet, keyless), weather from Open-Meteo; a bundled price
snapshot is the last-resort source when the APIs rate-limit, so cached prices
work offline. No accounts, no ads, no tracking; the only permission is INTERNET.

Source: https://github.com/elpollodiablo2nd/el-forecast (tag `v0.1.0`).
Screenshots are not attached yet; the 512px icon is in the upstream
`fastlane/metadata/android/en-US/images/icon.png`.

### Please elaborate why you wrote this app. Please highlight the unique functions it provides over other similar apps in F-Droid.

Existing elspot/price apps either just show current prices or call a commercial
forecast API. elspot is the first F-Droid app that runs the forecast model itself
on the phone (open Timestral ONNX, verified against the PyTorch reference to
<0.006 DKK/MWh max abs diff), so it works without any API key and without
sending price history anywhere. Published backtests (DK2, full year, 28M):
h24 MAE 4.0% of mean price, h48 8.7%, h72 12.2% — vs ~19–25% for published
competitors.

## Checklist

### Policy

* [x] The app complies with the [inclusion policy](https://f-droid.org/docs/Inclusion_Policy). FOSS (ISC), all source public, no ads/tracking/non-free deps (Capacitor MIT vendored, onnxruntime-web Apache-2.0 vendored, Timestral weights Apache-2.0 bundled).
* [x] The submitter is the original app author (elpollodiablo2nd).
* [x] The upstream repo contains the app metadata in a Fastlane folder structure: `fastlane/metadata/android/en-US/` (title.txt, short_description.txt, full_description.txt, changelogs/1.txt, images/icon.png). en-US included.

### Docs

* [x] Read CONTRIBUTING.md, the metadata templates, the Build Metadata Reference and the Quick Start Guide.

### Merge Request Setup

* [x] MR title follows "New app: elspot".
* [x] Fork is public, branch `dk.elspot.app` is not protected.
* [x] One app in this MR.

### Metadata

* [x] Metadata is only `metadata/dk.elspot.app.yml` (valid YAML, LF endings). No texts/images/changelogs added in this MR — they are provided upstream.
* [x] Release tagged (`v0.1.0`) and auto-update enabled (`AutoUpdateMode: Version`, `UpdateCheckMode: Tags`; `CurrentVersion: 0.1.0` / `CurrentVersionCode: 1` set). The file is in `fdroid rewritemeta` canonical form and passes fdroiddata CI: schema validation (`schemas/metadata.json`), `fdroid lint`, `fdroid rewritemeta` (no diff), `fdroid checkupdates`.
* [x] IssueTracker and AuthorName are set.
* [x] Reproducible builds: dependency metadata is excluded from the APK (`dependenciesInfo` disabled in `android/app/build.gradle`); build is deterministic from the committed `android/` Gradle project.
* [x] `commit` is the full hash: `6796e2d91ee97f73f1b640e0a1878046443cd420` (tag `v0.1.0`).
* [x] No disabled versions; only the latest version is in the metadata.

### Pipeline

* [ ] Pipelines pass (run on the fdroiddata fork's GitLab CI; the recipe builds with `subdir: android` + `gradle: [yes]`, installs android-36 platform/build-tools in prebuild and openjdk-21 via sudo).

Build notes for reviewers:

* The `android/` project is committed (Capacitor), including synced web assets
  under `android/app/src/main/assets/public`; the Capacitor Android library is
  vendored in `vendor/capacitor-android/` so no npm is needed at build time.
* `scanignore` covers the bundled ONNX model (`www/assets/timestral-5m.onnx`),
  the vendored WASM runtime, the 28M model parts served via GitHub Pages
  (`models/`), and the Gradle wrapper jar.
* `npm test` in the source repo passes 128/128 (ONNX WASM vs PyTorch reference
  for 5M and 28M, plus the web test suite).
