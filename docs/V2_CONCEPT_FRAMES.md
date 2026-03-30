# Balloon Tap 2.0 — Concept Frames and Design Palette

Concept art follows **Frame 1 (Mass Ascension Dawn)**: pre-dawn New Mexico sky, mass ascension balloons, and in-game polish **without** a dedicated “City of Albuquerque” splash or crest in the concept set. Civic links remain in the in-app **About** sheet only.

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
| **Primary** | `#0A5F73` | Teal; primary UI, buttons, titles |
| **Accent** | `#D94E1F` | Warm orange; accent text, icons |
| **Sand** | `#F4EDE4` | Surface / card backgrounds |
| **Chile Red** | `#B71C1C` | Red chile collectible |
| **Chile Green** | `#2E7D32` | Green chile collectible |
| **Gold / Celebration** | `#FFD700` | Confetti, new-best star |
| **Glass White** | `rgba(255,255,255,0.16)` | Frosted HUD chip fill |
| **Glass Border** | `rgba(255,255,255,0.24)` | HUD chip border |

---

## Concept frames (5 screens)

Runtime bundle: [`assets/concept/`](../assets/concept/). Same files are mirrored under [`docs/concepts/`](concepts/) for reviews and PowerPoint.

### 1. Mass Ascension Dawn (canonical look)
**File:** `v2_mockup_1_mass_ascension_dawn.png`

Pre-dawn NM sky gradient, mass ascension balloons, hero balloon with flame. **Used in-app** as the onboarding backdrop and loading-screen art (`ConceptAssets.dawnMassAscension`).

### 2. In-Flight Gameplay
**File:** `v2_mockup_2_inflight_gameplay.png`

Reference for HUD layout, burner, desert parallax, and hint copy.

### 3. Sandia Sunset Skin
**File:** `v2_mockup_3_sandia_sunset.png`

Sunset palette and collectible styling reference.

### 4. Game Over / New Personal Best
**File:** `v2_mockup_4_gameover_newbest.png`

Celebration card and Lottie moment reference.

### 5. First-Run Onboarding (composite reference)
**File:** `v2_mockup_5_onboarding.png`

Standalone mockup; shipped onboarding uses Frame 1 as full-screen backdrop plus the Lottie + card from the app.

---

## Bundled motion placeholders

`assets/lottie/nm_sparkle.json` and `assets/rive/hud_accent.riv` remain **placeholders**. See [`THIRD_PARTY_ASSETS.md`](THIRD_PARTY_ASSETS.md).

---

## v3 banner ad placement

No ads in v2 frames. Reserve space via `AdBannerReserve` when adding sponsors; never cover the active tap region during play.

---

## PowerPoint

Regenerate the deck after asset changes:

```bash
pip3 install python-pptx
python3 tool/generate_pptx.py
```

Output: [`Balloon_Tap_2.0_Concepts.pptx`](Balloon_Tap_2.0_Concepts.pptx).
