#!/usr/bin/env bash
# Preview Balloon Tap on the iOS Simulator (macOS + Xcode required).
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v flutter >/dev/null 2>&1; then
  echo "Install Flutter and add it to PATH: https://docs.flutter.dev/get-started/install"
  exit 1
fi
if [ ! -d ios ]; then
  flutter create . --project-name balloon_tap
fi
flutter pub get
flutter test
open -a Simulator 2>/dev/null || true
flutter run -d ios
