#!/usr/bin/env python3
"""Generate the Balloon Tap 2.0 concept deck (PowerPoint)."""

from pathlib import Path
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

ROOT = Path(__file__).resolve().parent.parent
CONCEPTS = ROOT / "docs" / "concepts"
OUT = ROOT / "docs" / "Balloon_Tap_2.0_Concepts.pptx"

SLIDES = [
    {
        "title": "Balloon Tap 2.0",
        "subtitle": "Mass Ascension Dawn concept set\nDesign review",
        "image": None,
    },
    {
        "title": "1 — Mass Ascension Dawn",
        "subtitle": "Canonical v2 look: pre-dawn sky, mass ascension, hero flame. In-app loading + onboarding backdrop.",
        "image": CONCEPTS / "v2_mockup_1_mass_ascension_dawn.png",
    },
    {
        "title": "2 — In-Flight Gameplay",
        "subtitle": "Burner flame, glass HUD, desert parallax, hint text.",
        "image": CONCEPTS / "v2_mockup_2_inflight_gameplay.png",
    },
    {
        "title": "3 — Sandia Sunset Skin",
        "subtitle": "Orange/magenta/purple sky, sunset balloon, chile collectible.",
        "image": CONCEPTS / "v2_mockup_3_sandia_sunset.png",
    },
    {
        "title": "4 — Game Over / New Best",
        "subtitle": "Celebration card, confetti, Play again CTA.",
        "image": CONCEPTS / "v2_mockup_4_gameover_newbest.png",
    },
    {
        "title": "5 — Onboarding (reference composite)",
        "subtitle": "Standalone mockup; shipped app uses Frame 1 backdrop + in-app card.",
        "image": CONCEPTS / "v2_mockup_5_onboarding.png",
    },
    {
        "title": "Design Palette",
        "subtitle": (
            "Sky Top #87CEEB  |  Horizon #FFE8CC  |  Sky Bottom #E8B86D\n"
            "Sandia Pink #FF8FA3  |  Sunset Orange #FFB347  |  Magenta #6B2D5C\n"
            "Primary #0A5F73  |  Accent #D94E1F  |  Sand #F4EDE4\n"
            "Chile Red #B71C1C  |  Chile Green #2E7D32  |  Gold #FFD700"
        ),
        "image": None,
    },
    {
        "title": "Next Steps",
        "subtitle": (
            "- Replace placeholder Lottie/Rive with final NM artwork\n"
            "- Store screenshots from concept frames\n"
            "- v3: sponsor banners via AdBannerReserve (non-intrusive)\n"
        ),
        "image": None,
    },
]

ACCENT = RGBColor(0xD9, 0x4E, 0x1F)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
DARK = RGBColor(0x1A, 0x1A, 0x2E)

SLIDE_W = Inches(13.333)
SLIDE_H = Inches(7.5)


def set_slide_bg(slide, color):
    fill = slide.background.fill
    fill.solid()
    fill.fore_color.rgb = color


def add_text(slide, text, left, top, width, height,
             font_size=18, bold=False, color=WHITE, alignment=PP_ALIGN.LEFT):
    tx_box = slide.shapes.add_textbox(left, top, width, height)
    tf = tx_box.text_frame
    tf.word_wrap = True
    lines = text.split("\n")
    for i, line in enumerate(lines):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = line
        p.font.size = Pt(font_size)
        p.font.bold = bold if i == 0 else False
        p.font.color.rgb = color
        p.alignment = alignment


def main():
    prs = Presentation()
    prs.slide_width = SLIDE_W
    prs.slide_height = SLIDE_H
    blank_layout = prs.slide_layouts[6]

    for s in SLIDES:
        slide = prs.slides.add_slide(blank_layout)
        set_slide_bg(slide, DARK)

        add_text(
            slide,
            s["title"],
            Inches(0.6),
            Inches(0.4),
            Inches(12),
            Inches(0.8),
            font_size=36,
            bold=True,
            color=ACCENT,
            alignment=PP_ALIGN.LEFT,
        )

        if s["image"] and s["image"].exists():
            slide.shapes.add_picture(
                str(s["image"]),
                Inches(0.6),
                Inches(1.5),
                height=Inches(5.2),
            )
            add_text(
                slide,
                s["subtitle"],
                Inches(7.5),
                Inches(1.8),
                Inches(5.2),
                Inches(4),
                font_size=20,
                color=WHITE,
                alignment=PP_ALIGN.LEFT,
            )
        else:
            add_text(
                slide,
                s["subtitle"],
                Inches(0.6),
                Inches(1.6),
                Inches(12),
                Inches(5),
                font_size=24,
                color=WHITE,
                alignment=PP_ALIGN.LEFT,
            )

    prs.save(str(OUT))
    print(f"Saved: {OUT}")


if __name__ == "__main__":
    main()
