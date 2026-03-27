# Changelog

All notable changes to **Balloon Tap** are listed here. Version numbers follow **0.x** until the first store release.

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
