# Build and run (Balloon Tap 2.x)

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
- Xcode (iOS Simulator / device)
- Android SDK (optional, for Android builds)

## One-time: Rive native libraries

The `rive` package uses `rive_native`. After `flutter pub get`, CI and local **macOS** test runs need:

```bash
dart run rive_native:setup --verbose --clean --platform macos
```

For **iOS** device/simulator builds from a clean machine:

```bash
dart run rive_native:setup --verbose --clean --platform ios
```

See also: [rive package README — Testing](https://pub.dev/packages/rive).

**Renderer note:** HUD Rive accents use the **Flutter** renderer (`Factory.flutter`) so `flutter test` and simulators stay stable. You can switch specific widgets to `Factory.rive` later for the dedicated Rive renderer if you standardize on device-only QA for those screens.

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

### iOS Simulator

```bash
./tool/preview_ios.sh
```

(If the project lives on iCloud/OneDrive, use `FORCE_IOS_BUILD_TMP=1` per [README](../README.md).)

## Release builds

Standard Flutter release flow; bump `version:` in `pubspec.yaml` (`MAJOR.MINOR.PATCH+BUILD`). Track releases in [VERSIONS.md](../VERSIONS.md) and [CHANGELOG.md](../CHANGELOG.md).
