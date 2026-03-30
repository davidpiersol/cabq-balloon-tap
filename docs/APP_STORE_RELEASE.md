# App Store & TestFlight release checklist — Balloon Tap

Use with the current **`pubspec.yaml` `version:`** (see [`VERSIONS.md`](../VERSIONS.md); **2.0.0+200** is the v2 store cut). Bump the **+build** number for each upload.

**v2 data on device:** same `shared_preferences` surface as v1, plus optional **`balloon_tap_onboarding_v2_done`** (boolean) for first-run onboarding — disclose with other on-device gameplay prefs in App Privacy.

## Before the first upload

1. **Apple Developer Program** — Enroll; create app record in App Store Connect.
2. **Bundle ID** — Replace `com.example.balloonTap` in Xcode (`Runner` target) with your final ID; match it exactly in App Store Connect.
3. **Signing** — Xcode: automatic signing with your team; archive **Release** build.
4. **Export compliance** — `ITSAppUsesNonExemptEncryption` is set to **NO** in `Info.plist` (standard HTTPS in Safari only). Confirm in App Store Connect questionnaire.
5. **App Privacy** — Declare **no tracking**. Data types: on-device **gameplay content** (high score, cosmetic choices) not linked to identity — align wording with Apple’s definitions (often “not collected” if nothing leaves device).
6. **Privacy policy URL** — Publish and link in App Store Connect (required for many jurisdictions).
7. **Screenshots & metadata** — Add per device class; age rating questionnaire; support URL.

## Build commands (reference)

```bash
flutter pub get
flutter test
flutter build ipa   # iOS archive (requires signing)
flutter build appbundle  # Google Play
```

## TestFlight (beta)

1. Archive in Xcode → **Distribute App** → App Store Connect → Upload.
2. In TestFlight, set **What to Test** (e.g. “1.1.0 beta 1 — balloon physics, collectibles, cabq.gov links”).
3. Add internal then external testers as needed.

## Versioning convention

- `pubspec.yaml`: `version: 1.1.0-beta.1+101` — prerelease tag + build number.
- For a **production** store cut without prerelease suffix, switch to `1.1.0+102` (or next integer) and tag accordingly.

## Android (optional same milestone)

- Play Console internal testing track; signing key configured; same privacy posture.
