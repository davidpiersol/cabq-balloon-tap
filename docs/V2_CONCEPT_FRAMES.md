# Balloon Tap 2.0 — Concept Frames and Design Palette

Frame 1 (`v2_mockup_1_mass_ascension_dawn.png`) is the visual north star for the v2 look and feel.

---

## Color palette

| Token | Hex | Usage |
| ----- | --- | ----- |
| **Sky Top (Fiesta)** | `#87CEEB` | Upper sky gradient, Fiesta skin |
| **Sky Horizon (Fiesta)** | `#FFE8CC` | Mid-sky warm haze, Fiesta skin |
| **Sky Bottom (Fiesta)** | `#E8B86D` | Lower sky / horizon, Fiesta skin |
| **Sandia Pink** | `#FF8FA3` | Mid-sky, Sandia Sunset skin |
| **Sunset Orange** | `#FFB347` | Upper sky, Sandia Sunset skin |
| **Sunset Magenta** | `#6B2D5C` | Lower sky, Sandia Sunset skin |
| **Rio Dawn Top** | `#1E3A5F` | Deep pre-dawn, Rio Dawn skin |
| **Rio Dawn Mid** | `#4A7AB8` | Mid-sky, Rio Dawn skin |
| **Rio Dawn Bottom** | `#4A90D9` | Lower sky, Rio Dawn skin |
| **CABQ Primary** | `#0A5F73` | Teal; primary UI, buttons, titles |
| **CABQ Accent** | `#D94E1F` | Warm orange; accent text, icons |
| **Sand** | `#F4EDE4` | Surface / card backgrounds |
| **Chile Red** | `#B71C1C` | Red chile collectible |
| **Chile Green** | `#2E7D32` | Green chile collectible |
| **Gold / Celebration** | `#FFD700` | Confetti, new-best star |
| **Glass White** | `rgba(255,255,255,0.16)` | Frosted HUD chip fill |
| **Glass Border** | `rgba(255,255,255,0.24)` | HUD chip border |

---

## Concept frames (5 screens)

All mockup PNGs are in [`docs/concepts/`](concepts/).

### 1. Mass Ascension Dawn (Splash / Title)
**File:** `v2_mockup_1_mass_ascension_dawn.png`

Pre-dawn NM sky gradient (indigo to Sandia pink to peach). Mass ascension balloons at various depths. Hero balloon foreground with active flame. Title "Balloon Tap 2.0" top center. Play CTA lower third.

### 2. In-Flight Gameplay (Hero Shot)
**File:** `v2_mockup_2_inflight_gameplay.png`

Active play: colorful striped balloon with burner flame, frosted-glass HUD chips (Score 128 / Best 412), info and palette controls top-right. Desert parallax with mesas and cacti. Hint text at bottom.

### 3. Sandia Sunset Skin
**File:** `v2_mockup_3_sandia_sunset.png`

Dramatic orange/coral/magenta/purple sky bands. Ornate sunset-themed balloon envelope. Red chile collectible floating nearby. Sandia ridge silhouette. Demonstrates skin system.

### 4. Game Over / New Personal Best
**File:** `v2_mockup_4_gameover_newbest.png`

Darkened overlay, centered celebration card with gold confetti/star burst. "New personal best!" headline, Score 512 / Best 512, teal "Play again" CTA. Represents Lottie celebration moment.

### 5. First-Run Onboarding
**File:** `v2_mockup_5_onboarding.png`

Semi-transparent overlay over Balloon Fiesta backdrop. Rounded card with balloon illustration, "Balloon Tap" title, "New Mexico skies, Balloon Fiesta energy" subtitle, three sun-icon instruction bullets, "Let's fly" CTA.

## Asset replacement notes

The Lottie (`assets/lottie/nm_sparkle.json`) and Rive (`assets/rive/hud_accent.riv`) files are **placeholders**. Replace with original artwork that matches the palette and frames above. See [`THIRD_PARTY_ASSETS.md`](THIRD_PARTY_ASSETS.md).

---

## v3 banner ad placement

No ads appear in any v2 frame. Future v3 banners will use reserved space below the gameplay area (see `AdBannerReserve`). Banners must **never** overlay the active tap zone during play.
