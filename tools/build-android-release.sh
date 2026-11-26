#!/usr/bin/env bash
# Reproducible release build of the elspot Android app.
# Used by CI (.github/workflows/release-apk.yml) on v* tags. The F-Droid build
# runs plain `gradle assembleRelease` in android/ on the committed project.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION_NAME="${1:-$(git describe --tags --match 'v*' --abbrev=0 2>/dev/null | sed 's/^v//' || echo 0.1.0)}"
VERSION_CODE="${2:-1}"

npm ci --no-audit --no-fund
./tools/sync-www.sh
npx cap sync android
# cap sync regenerates capacitor.settings.gradle with node_modules paths; restore the
# committed variant, which falls back to vendor/capacitor-android when node_modules
# is absent (that is the path F-Droid takes).
git checkout -- android/capacitor.settings.gradle 2>/dev/null || true
./tools/apply-launcher.sh

sed -i -E "s/versionCode [0-9]+/versionCode ${VERSION_CODE}/; s/versionName \"[^\"]*\"/versionName \"${VERSION_NAME}\"/" android/app/build.gradle

cd android
if [ -x ./gradlew ]; then ./gradlew --no-daemon assembleRelease; else gradle --no-daemon assembleRelease; fi
echo "unsigned APK: android/app/build/outputs/apk/release/app-release-unsigned.apk (F-Droid signs it)"
