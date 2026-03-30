# Changelog

All notable changes to **Balloon Tap** are listed here.

Rollback tag before this release: **`rollback/pre-hold-parallax-2026-03-27`** (v0.1.0+4 behavior).

## 2.0.1+201 — 2026-03-30

- **Concept art in app**: `assets/concept/` PNGs (frames 1–5); **Mass Ascension Dawn** drives onboarding backdrop and shell loading screen (`ConceptAssets`).
- **Docs**: `V2_CONCEPT_FRAMES.md` palette + five frames only; removed civic-branded “frame 6” from the concept set; `THIRD_PARTY_ASSETS.md` lists concept PNGs.
- **PowerPoint**: `tool/generate_pptx.py` regenerated deck without CABQ splash slide.
- **Tests**: `concept_assets_test.dart` asserts all concept paths load from the bundle.

## 2.0.0+200 — 2026-03-30 (Balloon Tap 2.0)

- **Immersive shell**: full-screen play; About moved to a top-right FAB-style control; safe-area aware HUD.
- **Onboarding**: first-run card with Lottie accent and hold/release/coast copy (`OnboardingStore` + prefs key `balloon_tap_onboarding_v2_done`).
- **Motion**: `lottie` + `rive` dependencies; placeholder assets (`assets/lottie/nm_sparkle.json`, `assets/rive/hud_accent.riv`); HUD Rive accent uses **Flutter renderer** for stable `flutter test`; Lottie on new personal best at game over.
- **Visual polish**: three-stop sky gradients per skin, frosted-glass score chips, subtle balloon scale on burner strength, bottom inset helper for future v3 banner (`AdBannerReserve`).
- **Fix**: “new best” celebration compares to best-at-round-start, not live-updated `_best`.
- **Tooling**: `dart run rive_native:setup` in CI before tests; docs `docs/BUILD.md`, `docs/V2_PROGRESS.md`, `docs/GIT_AND_FIXES.md`, `docs/THIRD_PARTY_ASSETS.md`.

## 1.1.0-beta.1+101 — 2026-03-28 (TestFlight / beta)

- **Store & security prep**: URL hardening (HTTPS, host allowlist, port 443, no credentials); bounded local prefs (score + appearance JSON); `PrivacyInfo.xcprivacy` (User Defaults, reason CA92.1); `ITSAppUsesNonExemptEncryption` = false; iOS **15** minimum; Android `networkSecurityConfig` disables cleartext; Podfile no longer disables pod code signing (required for Archive).
- **Docs**: `docs/SECURITY_REVIEW.md`, `docs/APP_STORE_RELEASE.md`.
- **Simulation tests**: long-run physics stability + About sheet smoke test.

## 0.2.0+1 — 2026-03-27

- **Hold to burn**: sustained flame at the burner while finger is down; **release** → ~**0.5 s coast** (lift decays) then **gravity** drift down. No auto intro from the ground — player lifts from **`groundStartYNorm`**.
- **Slower climb**: burner eases toward `burnerTargetVy` (gentler than old tap bursts).
- **Parallax**: layered **sine ridge** mountains + sky scroll **left** at `parallaxScrollPerSec` (horizontal flight illusion); sun drifts slightly.
- **CollectibleWorld.scrollXNnorm** follows scroll for future pickups.
- Removed discrete tap impulse / intro ascent physics from the main loop.

## 0.1.0+4 — 2026-03-27

- **Burner placement**: flame draws at the fixed **basket–envelope** neck (matches rig layout), not at the tap point. Tap anywhere still fires the burner and applies lift.
- **`BalloonLayout`**: shared constants for balloon size, anchor offset, and burner position in screen space.

## 0.1.0+3 — 2026-03-27

- **Burner flame** rework: very short puff (~140 ms), narrow vertical jet, bright white/yellow core, orange sheath, subtle blue nozzle hint — inspired by brief balloon-burner shots (e.g. [YouTube](https://www.youtube.com/watch?v=yCnlvFN5kGM) ~3:42). Not frame-accurate.

## 0.1.0+2 — 2026-03-27

- Balloon **colors, pattern** (solid / stripes / patchwork), and **basket** color; saved on device (`AppearanceStore`).
- **Burner flame** at each tap; **lift** from flame while in play (after intro).
- **Intro ascent**: balloon starts near the **ground** and rises to the **sweet spot**, then scoring begins.
- **Collectibles framework** stub: `CollectibleKind`, `CollectibleWorld`, `CollectibleInstance` for future scroll + pickups (v0.2+).
- Horizontal position field **`_balloonXNorm`** reserved for landscape flight (v0.2+).

## Earlier releases

- Pre-0.1.0 work was tagged as `1.0.0+1` in `pubspec` briefly; **0.1.0** is the first listed semantic version for this app.
