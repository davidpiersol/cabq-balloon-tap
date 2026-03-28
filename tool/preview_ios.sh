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
# A shallow copy under $HOME avoids that and keeps CocoaPods relative paths to ~/.pub-cache valid
# (deep /tmp paths can resolve past / and break as /.pub-cache).
if [[ "$ROOT" == *OneDrive* ]] || [[ "$ROOT" == *iCloud* ]] || [[ "${FORCE_IOS_BUILD_TMP:-}" == 1 ]]; then
  TMP_ROOT="${HOME}/bt_sim"
  echo "Using $TMP_ROOT for iOS (avoids cloud codesign + bad pod paths)…"
  rsync -a --delete --exclude=.git --exclude=build "$ROOT/" "$TMP_ROOT/"
  cd "$TMP_ROOT"
  rm -rf ios/Pods ios/Podfile.lock 2>/dev/null || true
fi

if [ ! -d ios ]; then
  flutter create . --project-name balloon_tap
fi
flutter pub get
flutter test
open -a Simulator 2>/dev/null || true
BOOTED_SIM="$(xcrun simctl list devices booted 2>/dev/null | sed -En 's/.*\(([A-F0-9-]{36})\) \(Booted\).*/\1/p' | head -1)"
if [[ -n "${BOOTED_SIM}" ]]; then
  flutter run -d "${BOOTED_SIM}"
else
  flutter run -d ios
fi
