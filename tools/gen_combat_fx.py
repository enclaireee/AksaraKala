#!/usr/bin/env python3
"""Budayago combat FX sheets (Phase 6c, combat.md 2.3b; redrawn in art pass v8, assets.md 1 "FX standard").
Every sheet is a horizontal strip of equal frames in assets/art/fx/. Chunky solid pixel art, no AA, no hairlines
(sparks excepted), lit from the top-left, plum outline on key frames.
Player-attack strips are drawn once in pixlib.KEY tones and written with bake_all: the neutral strip plus
<name>_<class>.png for the 8 classes (attack_fx.gd loads the class one first and skips the tint).
Generic strips (dust, step_dust, ink_*) stay neutral. enemy_smear* and lane_tile are neutral sinister red/ash.
Smear frames face right (+x) with the pivot at the frame centre; the arc sits at R_REF and spans ARC_REF degrees,
and attack_fx.gd scales it to the weapon's reach and arc.
Run: python3 tools/gen_combat_fx.py   Output: assets/art/fx/*.png and tools/fx_preview.png
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import *

S = 48            # smear frame size
R_REF = 20.0      # smear arc radius in px
ARC_REF = 100.0   # smear arc span in degrees
W = KEY["w"]
INKT = [hexc("6A4E92"), hexc("46306C"), hexc("281A40"), hexc("160E24")]      # ink: lit rim .. deep
DUSTT = [hexc("F0E6CC"), hexc("D2C4A2"), hexc("A89878"), hexc("786A54")]
# enemy swings: ash-pink hot edge, blood red, dark red, near black
ENEMY = [hexc("F0C8BC"), hexc("C8403C"), hexc("86283A"), hexc("481A2C")]
ENEMY_W = hexc("FFE6DC")


def img(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def swing(a0, a1, thick, tones, hot=None, gap=0.0, r0=R_REF, minw=2):
    """One 48x48 crescent frame. Thick middle, tips cut at `minw` px so nothing is a hairline. Lit outer rim."""
    f = img(S, S)
    c = S / 2.0
    for y in range(S):
        for x in range(S):
            dx, dy = x + 0.5 - c, y + 0.5 - c
            th = math.degrees(math.atan2(dy, dx))
            if not (a0 <= th <= a1):
                continue
            u = (th - a0) / (a1 - a0)                     # 0 tail .. 1 head
            if gap and ((u * 7.0) % 1.0) > 1 - gap:       # broken into fat chunks
                continue
            env = math.sin(math.pi * min(1.0, 0.1 + 0.9 * u)) ** 0.7
            tw = thick * env
            if tw < minw:
                continue
            d = math.hypot(dx, dy) - (r0 - thick * 0.15 * (1 - env))
            if abs(d) > tw / 2:
                continue
            v = (d + tw / 2) / tw                         # 0 inner .. 1 outer rim
            i = 0 if v > 0.72 else (1 if v > 0.4 else 2)
            if u < 0.3:
                i += 1
            col = tones[min(len(tones) - 1, i)]
            if hot is not None and v > 0.62 and u > 0.45:
                col = hot
            f.putpixel((x, y), col)
    return f


def thrust(length, width, tones, hot, x0=0, gap=0.0):
    """One 48x48 spear streak from the pivot toward +x."""
    f = img(S, S)
    c = S // 2
    for x in range(c + x0, min(S, c + x0 + length)):
        t = (x - c - x0) / float(length)
        half = width / 2.0 * (1 - t) ** 0.8 * (0.5 + 0.5 * min(1, t * 5))
        if half < 1 or (gap and (x // 3) % 3 == 2):
            continue
        for y in range(S):
            d = y + 0.5 - c
            if abs(d) <= half:
                q = abs(d) / half
                col = hot if q < 0.3 else (tones[0] if d < 0 else tones[1]) if q < 0.7 else (tones[1] if d < 0 else tones[2])
                f.putpixel((x, y), col)
    return f


def finish(frames, outline=(1, 2)):
    return strip([plum_outline(f) if i in outline else f for i, f in enumerate(frames)])


def smear_set(tones, hot, k=1.0, core=False):
    t = [round(v * k) for v in (5, 6, 6, 4)]
    a = [(-50, -5), (-50, 28), (-45, 50), (-10, 52)]
    fr = [swing(a[0][0], a[0][1], t[0], tones, None),
          swing(a[1][0], a[1][1], t[1], tones, hot),
          swing(a[2][0], a[2][1], t[2], tones, hot),
          swing(a[3][0], a[3][1], t[3], tones[1:] + tones[-1:], None, gap=0.3)]
    return finish(fr)


def make_smears():
    out = {}
    out["smear_light"] = smear_set(A, W, 1.0)
    out["smear_heavy"] = strip([plum_outline(f) if i in (1, 2) else f for i, f in enumerate([
        swing(-50, -10, 8, A), swing(-50, 30, 11, A, W), swing(-50, 50, 12, A, W),
        swing(-5, 52, 8, A[1:] + A[-1:], None, gap=0.35)])])
    # finisher: accent ramp b on the outer rim, hot core
    fin = [swing(-55, -5, 11, B), swing(-55, 32, 15, B, W), swing(-52, 54, 16, B, W),
           swing(-10, 56, 10, B[1:] + B[-1:], None, gap=0.35)]
    out["smear_finisher"] = finish(fin)
    core = [swing(-55, -5, 6, [W, A[0], A[1]], None), swing(-55, 32, 8, [W, W, A[0]], W),
            swing(-52, 54, 9, [W, W, A[0]], W), swing(-10, 56, 5, [A[0], A[1], A[2]], None, gap=0.4)]
    out["smear_core"] = strip(core)
    out["smear_thrust"] = finish([thrust(22, 5, A, W), thrust(30, 9, A, W), thrust(30, 10, A, W),
                                  thrust(26, 6, A[1:] + A[-1:], A[1], x0=6, gap=1)])
    return out


def make_enemy_smears():
    """Neutral, sinister: blood red with an ash-pink edge. Same layout as the player smears."""
    e = ENEMY
    light = [swing(-50, -5, 5, e), swing(-50, 28, 7, e, ENEMY_W), swing(-45, 50, 7, e, ENEMY_W),
             swing(-10, 52, 4, e[1:] + e[-1:], None, gap=0.3)]
    heavy = [swing(-50, -10, 8, e), swing(-50, 30, 11, e, ENEMY_W), swing(-50, 50, 12, e, ENEMY_W),
             swing(-5, 52, 8, e[1:] + e[-1:], None, gap=0.35)]
    return {"enemy_smear": finish(light), "enemy_smear_heavy": finish(heavy)}


def make_lane_tile():
    """16x8 tile for the charger / wewe_gombel telegraph lane: 2 px edge bands and a stepped diagonal hatch."""
    t = img(16, 8)
    for x in range(16):
        for y in range(8):
            if y in (0, 1):
                col = ENEMY[0] if y == 0 else ENEMY[1]
            elif y in (6, 7):
                col = ENEMY[2] if y == 6 else ENEMY[3]
            else:
                col = ENEMY[1] if ((x + y * 2) % 8) < 4 else ENEMY[2]
            t.putpixel((x, y), col)
    return t


# ---- impacts ------------------------------------------------------------------------------
def make_spark():
    n, w = 4, 24
    c = w // 2
    frames = []
    for i, (ln, th) in enumerate(((5, 2), (10, 4), (11, 4), (8, 2))):
        f = img(w, w)
        if i == 3:     # breaks into four fat chips
            for k, (dx, dy) in enumerate(((-7, -1), (6, -1), (-1, -7), (-1, 6))):
                for yy in range(2):
                    for xx in range(2):
                        dot(f, c + dx + xx, c + dy + yy, A[2] if (xx + yy) % 2 == 0 else A[3])
            frames.append(f)
            continue
        for k in range(1, ln + 1):                         # four arms, thick at the base, 1 px at the tip
            wd = max(1, round(th * (1 - k / float(ln + 1))))
            for j in range(-(wd // 2) - (wd % 2 == 0), wd // 2 + 1):
                dot(f, c + k, c + j, A[0] if j <= 0 else A[1])
                dot(f, c - k - 1, c + j, A[1] if j <= 0 else A[2])
                dot(f, c + j, c + k, A[1] if j <= 0 else A[2])
                dot(f, c + j, c - k - 1, A[0] if j <= 0 else A[1])
        blob(f, c, c, 3.0 if i < 3 else 2, [W, A[0], A[1]])
        if i < 3:     # diagonal accent chips
            for sx, sy in ((1, 1), (-1, 1), (1, -1), (-1, -1)):
                for kk in (3, 4):
                    dot(f, c + sx * kk - (sx < 0), c + sy * kk - (sy < 0), B[0 if kk == 3 else 1])
        frames.append(f)
    return strip([plum_outline(f) if i in (1, 2) else f for i, f in enumerate(frames)])


def make_ring():
    w = 32
    fr = []
    c = w / 2
    for i, (r, th) in enumerate(((7, 5), (11, 4), (13.5, 3))):
        f = img(w, w)
        if i < 2:
            band(f, c, c, r, th, tones=A)
            band(f, c, c, r - th / 2.0 - 1, 2, tones=B[:3])
            fr.append(plum_outline(f))
        else:   # broken into chunks, stepped down the ramp
            for k in range(5):
                a = k * 72 + 10
                band(f, c, c, r, th, a, a + 34, tones=A[2:])
            fr.append(f)
    return strip(fr)


def make_ink_splash():
    n, w = 4, 24
    fr = []
    drops = [(0.2, 0.0, 3.4), (0.55, -0.7, 2.2), (0.6, 0.7, 2.2), (0.9, -0.2, 1.6), (0.85, 0.4, 1.6), (0.4, -1.0, 1.6)]
    for i in range(n):
        f = img(w, w)
        grow = (0.5, 0.85, 1.0, 1.05)[i]
        for k, (dxr, dyr, rad) in enumerate(drops):
            if i == 3 and k % 2:
                continue
            blob(f, 4 + dxr * 16 * grow, w / 2 + dyr * 8 * grow, max(1.6, rad * (1.0 - i * 0.12)), INKT, wobble=0.15, seed=k)
        fr.append(f)
    return strip(fr)


def make_ink_puff():
    n, w = 5, 32
    fr = []
    lobes = [(0.3, 0.8, 4.2), (1.5, 0.9, 3.6), (2.6, 0.7, 3.8), (3.7, 1.0, 3.4), (4.8, 0.8, 3.8), (0.0, 0.0, 4.6)]
    for i in range(n):
        f = img(w, w)
        spread = (3, 7, 10, 12, 13)[i]
        for k, (ang, dist, size) in enumerate(lobes):
            if i == 4 and k % 2:
                continue
            blob(f, 16 + math.cos(ang) * spread * dist, 16 + math.sin(ang) * spread * dist - i * 0.6,
                 max(2.0, size * (1.0 - i * 0.13)), INKT, wobble=0.12, seed=k)
        fr.append(f)
    return strip(fr)


# ---- dust, muzzle, trail, glow --------------------------------------------------------------
def puffs(n, w, base_r, grow, seed, count=5):
    import random
    rnd = random.Random(seed)
    lobes = [(rnd.uniform(0, 6.283), rnd.uniform(0.5, 1.0), rnd.uniform(0.8, 1.2)) for _ in range(count)]
    fr = []
    for i in range(n):
        f = img(w, w)
        c = w / 2.0
        for k, (ang, dist, size) in enumerate(lobes):
            lx = c + math.cos(ang) * (base_r + grow * i) * dist
            ly = c + math.sin(ang) * (base_r + grow * i) * dist * 0.6 - i * 0.5
            rad = max(1.5, size * (base_r * 0.55 + grow * i * 0.25))
            blob(f, lx, ly, rad, DUSTT[i // 2:] if i // 2 < 3 else DUSTT[2:], wobble=0.1, seed=k)
        fr.append(plum_outline(f) if i == 0 and w >= 16 else f)
    return strip(fr)


def make_muzzle():
    n, w, h = 3, 24, 24
    c = h // 2
    fr = []
    for i, (ln, th) in enumerate(((9, 6), (14, 8), (18, 6))):
        f = img(w, h)
        x0 = 3
        if i < 2:
            f.alpha_composite(thrust_flash(w, h, x0, ln, th, [A[1], A[2], A[3]], A[0], W), (0, 0))
        else:     # chunks flying off
            for k in range(3):
                bx = x0 + 5 + k * 5
                for yy in range(2):
                    for xx in range(2 if k < 2 else 3):
                        dot(f, bx + xx, c - 3 + k * 3 + yy, A[2] if k != 1 else A[1])
        fr.append(plum_outline(f) if i < 2 else f)
    return strip(fr)


def thrust_flash(w, h, x0, ln, th, tones, lit_c, hot):
    f = img(w, h)
    c = h / 2.0
    for x in range(x0, w):
        t = (x - x0) / float(ln)
        if t > 1:
            continue
        half = th / 2.0 * (1 - t) ** 0.8 * (0.5 + 0.5 * min(1, t * 5))
        if half < 1:
            continue
        for y in range(h):
            d = y + 0.5 - c
            if abs(d) <= half:
                q = abs(d) / half
                f.putpixel((x, y), hot if q < 0.35 else (lit_c if d < 0 else tones[0]) if q < 0.75 else tones[1])
    for k in (-1, 1):   # 2 px side flares
        for t in range(4):
            for j in range(2):
                dot(f, x0 + 2 + t, int(c + k * (3 + t) - (k < 0) + j * -k), B[0] if t < 2 else B[1])
    return f


def make_arrow_trail():
    n, w, h = 2, 16, 8
    fr = []
    for i, ln in enumerate((12, 15)):
        f = img(w, h)
        for x in range(w):
            t = (w - 1 - x) / float(ln)              # 0 at the arrow end (right) .. 1 tail (left)
            if t > 1:
                continue
            if t > 0.5 and (x // 2) % 2:             # tail breaks into 2 px chunks
                continue
            rows = 4 if t < 0.3 else 2
            col = A[0] if t < 0.3 else (A[1] if t < 0.6 else A[2])
            for y in range(h // 2 - rows // 2, h // 2 + rows // 2):
                f.putpixel((x, y), col if y >= h // 2 - 1 or rows == 2 else A[0])
        fr.append(f)
    return strip(fr)


def make_bolt():
    n, w = 3, 16
    glow = []
    for i, rad in enumerate((5.0, 6.5, 5.5)):
        f = img(w, w)
        c = w / 2.0
        for rr, tone, alpha in ((rad, A[2], 110), (rad - 1.5, A[1], 190), (rad - 3.0, A[0], 255)):
            if rr >= 1:
                for y in range(w):
                    for x in range(w):
                        if math.hypot(x + 0.5 - c, y + 0.5 - c) <= rr:
                            f.putpixel((x, y), tone[:3] + (alpha,))
        blob(f, c, c, 2.0, [W, A[0]])
        glow.append(f)
    sp = []
    import random
    rnd = random.Random(5)
    for i in range(n):
        f = img(8, 8)
        for k in range(3 - i):                     # 2x2 chips
            x, y = rnd.randint(1, 5), rnd.randint(1, 5)
            for yy in range(2):
                for xx in range(2):
                    dot(f, x + xx, y + yy, (W, A[0], A[1])[i] if (xx + yy) % 2 == 0 else (A[0], A[1], A[2])[i])
        sp.append(f)
    return strip(glow), strip(sp)


def main():
    rows = []
    sm = make_smears()
    for k in ("smear_light", "smear_heavy", "smear_thrust", "smear_finisher", "smear_core"):
        bake_all(sm[k], "fx/%s.png" % k)
        rows.append((k, sm[k]))
    for k, make in (("spark", make_spark), ("ring", make_ring), ("muzzle", make_muzzle), ("arrow_trail", make_arrow_trail)):
        im = make()
        bake_all(im, "fx/%s.png" % k)
        rows.append((k, im))
    g, s = make_bolt()
    bake_all(g, "fx/bolt_glow.png")
    bake_all(s, "fx/bolt_spark.png")
    rows += [("bolt_glow", g), ("bolt_spark", s)]
    for k, im in make_enemy_smears().items():
        save(im, "fx/%s.png" % k)
        rows.append((k, im))
    lane = make_lane_tile()
    save(lane, "fx/lane_tile.png")
    for k, im in (("ink_splash", make_ink_splash()), ("ink_puff", make_ink_puff()),
                  ("dust", puffs(4, 16, 4.0, 1.4, 31)), ("step_dust", puffs(3, 8, 1.6, 0.8, 41, count=3))):
        save(im, "fx/%s.png" % k)
        rows.append((k, im))
    # contact sheet: neutral strips, then a few class rows
    pv = [(k, im) for k, im in rows] + [("lane", tiled(lane, 96, 8))]
    for cls in ("warrior", "mage", "dancer"):
        for k in ("smear_light", "smear_finisher", "spark", "ring"):
            pv.append((cls + k, bake(dict(rows)[k], cls)))
    preview(pv, os.path.join(os.path.dirname(os.path.abspath(__file__)), "fx_preview.png"), scale=3, bg=(60, 80, 64, 255))
    for k, im in rows:
        print("wrote", k, im.size)


if __name__ == "__main__":
    main()
