#!/usr/bin/env bash
# Preview Balloon Tap on the iOS Simulator (macOS + Xcode required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Install Flutter and add it to PATH: https://docs.flutter.dev/get-started/install"
  exit 1
fi

# OneDrive/iCloud paths often add xattrs that make codesign fail ("resource fork... not allowed").
# Build/run from /tmp when needed (or set FORCE_IOS_BUILD_TMP=1).
if [[ "$ROOT" == *OneDrive* ]] || [[ "$ROOT" == *iCloud* ]] || [[ "${FORCE_IOS_BUILD_TMP:-}" == 1 ]]; then
  TMP_ROOT="/tmp/balloon_tap_sim_preview"
  echo "Using $TMP_ROOT for iOS (avoids cloud-sync codesign issues)…"
  rsync -a --delete --exclude=.git --exclude=build "$ROOT/" "$TMP_ROOT/"
  cd "$TMP_ROOT"
fi

if [ ! -d ios ]; then
  flutter create . --project-name balloon_tap
fi
flutter pub get
flutter test
open -a Simulator 2>/dev/null || true
flutter run -d ios
