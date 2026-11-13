#!/usr/bin/env python3
"""Boss move sheets -> assets/art/enemies/<boss>_moves.png  (run after tools/gen_bosses.py).

Reads each boss's 4x4 sheet and composes a second 4x4 sheet of the same cell size with the big-move poses
that EnemyArt.play() runs (components/enemy_art.gd, BossKit.anim):
    row 0 cast   raise and gather: glow grows around the silhouette, body lifts
    row 1 slam   rise, hang (glowing), crash (stretch and squash), recover
    row 2 dash   crouch, then a leaning rush with a motion streak behind (art faces right)
    row 3 roar   chest out, pulsing aura, shout
Each boss gets its own aura colour, lift and a flag for hovering bosses (no crouch or squash on the ground).
Poses are composed from the base idle / windup / strike frames, so they always match the boss art.
"""
import os
import sys

from PIL import Image, ImageChops, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixlib as P  # noqa: E402

DIR = os.path.join(P.ART, "enemies")

# name: (aura colour, hover)
BOSSES = {
    "faceless_captain": ((210, 60, 60), False),
    "sandekala": ((120, 90, 200), True),
    "sangkuriang": ((255, 160, 60), False),
    "hariang_banga": ((120, 200, 240), False),
    "barma_wijaya": ((220, 180, 70), False),
    "bandung_bondowoso": ((200, 120, 60), False),
    "nameless_hunter": ((160, 220, 130), False),
    "keris_gandring": ((120, 255, 200), True),
    "buto_ijo": ((120, 230, 80), False),
    # batara_kala: tools/gen_boss_kala.py writes its moves sheet
}


def cell(sheet, col, row):
    cw, ch = sheet.width // 4, sheet.height // 4
    return sheet.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))


def bbox_h(img):
    b = img.getchannel("A").getbbox()
    return (b[3] - b[1]) if b else img.height


def top_room(img):
    b = img.getchannel("A").getbbox()
    return b[1] if b else 0


def sq(img, sy, sx=1.0, lift=0):
    """Stretch about the feet, clamped so the head never leaves the cell, then lift."""
    room = top_room(img) + 1 - 0   # empty rows above the head
    h = bbox_h(img)
    max_sy = (h + max(0, room - lift - 1)) / max(1, h)
    out = P.squash(img, min(sy, max_sy), sx)
    return P.shift(out, 0, -lift) if lift else out


def aura(img, color, strength=1.0, grow=1):
    """Glow behind the silhouette: dilated alpha in `color`, fading with strength; core stays crisp."""
    a = img.getchannel("A")
    big = a
    for _ in range(max(1, grow)):
        big = big.filter(ImageFilter.MaxFilter(3))
    ring = ImageChops.subtract(big, a)
    glow = Image.new("RGBA", img.size, color + (0,))
    glow.putalpha(ring.point(lambda v: int(v * min(1.0, 0.85 * strength))))
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.alpha_composite(glow)
    out.alpha_composite(img)
    return out


def fade(img, k):
    out = img.copy()
    out.putalpha(img.getchannel("A").point(lambda v: int(v * k)))
    return out


def streak(img, n, step, color):
    """Motion streak: fading copies trailing behind (to the left, the art faces right)."""
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    for i in range(n, 0, -1):
        ghost = P.tint(P.shift(img, -step * i, 0), color + (255,), 0.65)
        al = ghost.getchannel("A").point(lambda v, i=i: int(v * (0.5 - 0.12 * i)))
        ghost.putalpha(al)
        out.alpha_composite(ghost)
    out.alpha_composite(img)
    return out


def build(name, color, hover):
    sheet = Image.open(os.path.join(DIR, name + ".png")).convert("RGBA")
    base, wind, strike = cell(sheet, 0, 0), cell(sheet, 0, 2), cell(sheet, 2, 2)
    cw, ch = base.size
    out = P.sheet(cw, ch, 4, 7)
    hurt = P.shear_top(base, -2)   # head bowed; the sheet's own hurt cell is a white flash

    def put(col, row, img):
        out.alpha_composite(img, (col * cw, row * ch))

    # row 0: cast
    put(0, 0, wind)
    put(1, 0, aura(P.shift(wind, 0, -1), color, 0.5))
    put(2, 0, aura(sq(wind, 1.05, 0.98, 2), color, 0.8, 1))
    put(3, 0, aura(sq(wind, 1.04, 0.99, 2), color, 1.0, 2))

    # row 1: slam
    if hover:
        put(0, 1, aura(P.shift(base, 0, -2), color, 0.4))
        put(1, 1, aura(sq(wind, 1.06, 0.96, 4), color, 0.9, 2))
        put(2, 1, aura(P.shift(P.shear_top(strike, 2), 0, 1), color, 1.0, 2))
        put(3, 1, aura(P.shift(strike, 0, -1), color, 0.5))
    else:
        put(0, 1, sq(base, 1.04, 0.98, 2))
        put(1, 1, aura(sq(wind, 1.08, 0.94, 4), color, 0.9, 2))
        put(2, 1, aura(P.shear_top(P.squash(strike, 0.84, 1.1), 2), color, 1.0, 1))
        put(3, 1, P.squash(strike, 0.93, 1.04))

    # row 2: dash
    if hover:
        put(0, 2, aura(P.shear_top(wind, -2), color, 0.4))
    else:
        put(0, 2, P.shear_top(P.squash(wind, 0.9, 1.06), -2))
    put(1, 2, streak(P.shear_top(strike, 4), 3, 4, color))
    put(2, 2, streak(P.shear_top(strike, 5), 4, 5, color))
    put(3, 2, streak(P.shear_top(strike, 3), 2, 4, color))

    # row 3: roar
    put(0, 3, aura(P.squash(base, 0.93, 1.03), color, 0.4))
    put(1, 3, aura(sq(base, 1.07, 0.97, 1), color, 0.8, 1))
    put(2, 3, aura(sq(base, 1.1, 0.95, 1), color, 1.0, 2))
    put(3, 3, aura(sq(base, 1.04, 1.0), color, 0.6, 1))

    # row 4: rise (entrance, boss fights v7): from a crouch to full height
    put(0, 4, sq(hurt, 0.62, 1.06))
    put(1, 4, aura(sq(base, 0.8, 1.03), color, 0.5))
    put(2, 4, aura(sq(wind, 1.05, 0.98, 1), color, 0.9, 1))
    put(3, 4, aura(base, color, 1.0, 2))

    # row 5: kneel (0 HP, waiting for the last glyph)
    put(0, 5, sq(hurt, 0.92, 1.02))
    put(1, 5, sq(hurt, 0.8, 1.05))
    put(2, 5, sq(hurt, 0.7, 1.08))
    put(3, 5, aura(sq(hurt, 0.68, 1.08), color, 0.5))

    # row 6: death: sinks and comes apart into light
    put(0, 6, aura(sq(hurt, 0.66, 1.08), color, 0.8, 1))
    put(1, 6, fade(aura(P.tint(sq(hurt, 0.58, 1.1), color + (255,), 0.35), color, 1.0, 2), 0.8))
    put(2, 6, fade(aura(P.tint(P.shift(sq(hurt, 0.5, 1.12), 0, -1), color + (255,), 0.6), color, 1.0, 2), 0.5))
    put(3, 6, fade(aura(P.tint(P.shift(sq(hurt, 0.42, 1.14), 0, -2), color + (255,), 0.85), color, 1.0, 3), 0.22))
    return out


def main():
    previews = []
    for name, (color, hover) in BOSSES.items():
        src = os.path.join(DIR, name + ".png")
        if not os.path.exists(src):
            print("missing", name)
            continue
        img = build(name, color, hover)
        img.save(os.path.join(DIR, name + "_moves.png"))
        previews.append((name, img))
        print("wrote", name + "_moves.png", img.size)
    if previews:
        P.preview(previews, os.path.join(P.ROOT, "tools", "boss_moves_preview.png"), scale=2)


if __name__ == "__main__":
    main()
