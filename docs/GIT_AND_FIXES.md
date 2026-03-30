# Git workflow and fix list (v2.0)

## Branching

- `main` remains the integration branch; tag releases from `pubspec.yaml` version.

## Fix list (resolved in 2.0.0+200)

| Issue | Resolution |
| ----- | ---------- |
| New-best celebration never showed | `_best` was updated during play; compare final score to `_roundStartBest` instead of `_score > _best` at game over. |
| Rive in `flutter test` on macOS | `RiveHudAccent` uses `Factory.flutter` so the VM harness does not hit native Rive renderer assertions; CI still runs `rive_native:setup` for parity with device builds. |
| Onboarding blocked existing widget tests | `SharedPreferences` mock with `OnboardingStore.prefsKeyOnboardingV2Done: true`. |
| Splash before HUD in tests | Tap `splash_play_button` before finding score or About controls. |

## Open (monitor)

- **Impeller vs Rive**: if rendering differs on iOS, try `flutter run --no-enable-impeller` per Rive docs, then file issues upstream if needed.
- **Linux desktop**: Rive does not support Linux targets; use iOS/Android/macOS/Windows for Rive previews.
