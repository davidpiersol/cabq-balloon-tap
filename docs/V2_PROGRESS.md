# Balloon Tap 2.0 — implementation progress

| Step | Description | Tests |
| ---- | ----------- | ----- |
| 1 | Documentation (`BUILD.md`, `GIT_AND_FIXES.md`, versioning) + `AdBannerReserve` for v3 | `ad_banner_reserve_test.dart` |
| 2 | Dependencies: `rive`, `lottie`; assets `nm_sparkle.json`, `hud_accent.riv` | `lottie_asset_smoke_test.dart`, `rive_hud_accent_smoke_test.dart` |
| 3 | `RiveNative.init()` in `main.dart`; CI runs `rive_native:setup` | full `flutter test` |
| 4 | Immersive `GameShell` (no app bar), About FAB, onboarding | `game_shell_e2e_test.dart`, `onboarding_store_test.dart`, `onboarding_overlay_test.dart` |
| 5 | Parallax 3-stop sky, glass HUD, balloon burn scale, Rive accent, Lottie new-best, safe-area insets | `widget_test.dart`, existing physics/widget suite |

## Next (optional)

- Replace placeholder Rive/Lottie with designer-authored NM / Balloon Fiesta assets.
- Settings: burn sensitivity; optional `AdBannerReserve.playfieldBottomInset(..., includeV3BannerSlot: true)` when ads ship (v3).
