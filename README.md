# Balloon Tap

A lightweight **keep-the-balloon-aloft** game with **City of Albuquerque** / Balloon Fiesta theming, optional skins (Fiesta, Sandia Sunset, Rio Dawn), and **Learn more** links to **cabq.gov** (HTTPS + host allowlist).

> **Not an official City product** until reviewed and approved by CABQ Communications.

## Platforms

One **Flutter** codebase for **iOS** and **Android**.

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. From this directory:

   ```bash
   flutter create . --project-name balloon_tap
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```

## Unit tests

Always run tests before pushing:

```bash
flutter test
```

Coverage includes **physics** ([`lib/game/balloon_physics.dart`](lib/game/balloon_physics.dart)), **safe links**, **score store**, and a **widget smoke** test.

## iOS Simulator preview

```bash
chmod +x tool/preview_ios.sh
./tool/preview_ios.sh
```

Or manually: `flutter run -d ios` after opening Simulator.

## Coordination

See [`COORDINATION.md`](COORDINATION.md): this repo stays **Balloon Tap only**; Burque Bingo is a separate repo/tab.

## Security

- [`lib/security/safe_links.dart`](lib/security/safe_links.dart) restricts outbound links to `https://cabq.gov` and `https://www.cabq.gov`.

## GitHub

```bash
git init
git add .
git commit -m "Describe your change"
git branch -M main
gh repo create cabq-balloon-tap --public --source=. --remote=origin --push
# later pushes:
git push origin main
```

CI runs `flutter analyze` and `flutter test` on push (see `.github/workflows/flutter_ci.yml`).

## Distribution

- **App Store / Play Console**: standard Flutter release builds; disclose **local best score** in privacy labels (`shared_preferences` on device only, no accounts).
