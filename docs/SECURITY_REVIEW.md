# Security review — Balloon Tap (store prep)

**Role:** Pre–App Store / TestFlight hardening pass  
**Scope:** In-scope code under `lib/`, iOS/Android packaging, local persistence, outbound links.  
**Out of scope:** Apple Developer account configuration, backend services (none), penetration testing by a third party.

## Threat model (summary)

| Area | Risk | Mitigation |
|------|------|------------|
| Outbound URLs | Open arbitrary / phishing links | `safe_links.dart`: **HTTPS only**, host allowlist (`cabq.gov`, `www.cabq.gov`), **port 443 only**, **no userinfo** (blocks `https://user:pass@…`). Opens in **external** browser only. |
| Local storage | Tampered prefs / DoS via huge blobs | **Score**: clamped to `0…ScoreStore.maxReasonableScore`. **Appearance**: JSON capped at `AppearanceStore.maxJsonChars`; `fromJson` clamps ARGB to 32-bit. |
| Tracking / analytics | Unwanted data collection | No analytics SDKs; privacy manifest declares **no tracking**; on-device prefs only for game state. |
| Network | Cleartext interception (Android) | `network_security_config.xml`: cleartext disabled for app traffic (links open in system browser over user-controlled stack). |
| Encryption export (iOS) | ITAR/EAR paperwork | `ITSAppUsesNonExemptEncryption` = **false** (standard TLS only via system when user opens links). |

## Residual risks / follow-ups

1. **Bundle identifier** is still `com.example.balloonTap` until you assign an organization-owned ID in Xcode and App Store Connect.
2. **Privacy Policy URL** — host a policy that matches App Store Connect answers (local-only score + appearance; optional outbound cabq.gov links).
3. **Dependency updates** — run `flutter pub outdated` / Dependabot periodically; review plugin release notes for new manifest requirements.
4. **Jailbreak / rooted device tampering** — not addressed; scores are best-effort local only.

## Sign-off checklist (engineering)

- [x] URL allowlist hardened (scheme, host, port, credentials).
- [x] Prefs inputs bounded and sanitized.
- [x] iOS privacy manifest + encryption flag.
- [x] iOS deployment target aligned with Podfile (15+).
- [x] Android cleartext disabled in app config.
- [x] Pod code signing re-enabled (required for Archive / TestFlight).
