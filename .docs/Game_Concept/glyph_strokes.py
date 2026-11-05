"""Single-stroke designs for the 8 MVP glyphs and the P1 final glyph, plus a confusability check.

Strokes were traced by hand over Noto Sans Javanese / Noto Sans Sundanese
renders (macOS system fonts). No source on traditional stroke order was found
(spells.md 10), so the order and direction here are a game design, not a
cultural claim. Coordinates: x right, y down, any scale (normalized below).

Run: python3 glyph_strokes.py
It simulates sloppy player drawings and reports how often each glyph is read
right, smudged, fizzled or misread, using the spells.md 4 scoring rules.
The asserts are the design targets.
"""
import math
import random

STROKES = {
    # Sunda: two "7"s; the pen slides up from the first foot to the second bar.
    "sunda_ka": [(120, 113), (255, 113), (140, 395), (290, 113), (425, 113), (310, 395)],
    # Sunda: "Z" body, then up-right and back left to close the small box.
    "sunda_ga": [(620, 113), (750, 113), (650, 380), (840, 380), (880, 265), (775, 265)],
    # Sunda: same "Z" body, tail goes up-LEFT (no box). Too close to ga, see check.
    "sunda_nga": [(1135, 113), (1265, 113), (1160, 380), (1355, 380), (1315, 250)],
    # Sunda: bar, slant down into a small loop, round bottom, long up-right slant.
    "sunda_ca": [(1640, 113), (1770, 113), (1700, 300), (1660, 345), (1640, 375), (1615, 385),
                 (1595, 370), (1590, 345), (1605, 315), (1630, 302), (1660, 310), (1690, 335),
                 (1730, 375), (1770, 398), (1800, 392), (1825, 360), (1840, 320), (1910, 113)],
    # Jawa: tail, left arch, bottom bowl, then two humps (retrace the middle leg).
    "jawa_ha": [(105, 282), (78, 268), (72, 240), (72, 130), (82, 105), (100, 98), (118, 105),
                (125, 130), (125, 240), (132, 265), (155, 275), (235, 275), (258, 265), (268, 240),
                (268, 140), (280, 110), (310, 98), (340, 110), (352, 140), (352, 285), (352, 140),
                (370, 108), (400, 98), (430, 108), (440, 140), (440, 285)],
    # Jawa: tail, left arch, down and back up its leg, crossbar into the small loop, big right arch.
    "jawa_na": [(648, 285), (612, 268), (605, 240), (605, 130), (620, 100), (650, 88), (685, 100),
                (697, 130), (697, 285), (697, 205), (780, 205), (828, 215), (835, 255), (810, 282),
                (785, 275), (778, 245), (780, 130), (800, 98), (850, 85), (890, 100), (900, 130),
                (900, 285)],
    # Jawa: tail, big left bowl, small loop, diagonal down-right, up the stem, top bar, right leg.
    "jawa_ca": [(1138, 285), (1100, 270), (1085, 240), (1085, 140), (1105, 100), (1160, 85),
                (1200, 100), (1213, 140), (1213, 260), (1195, 283), (1170, 278), (1160, 250),
                (1175, 220), (1215, 208), (1250, 225), (1300, 268), (1330, 283), (1340, 270),
                (1340, 95), (1385, 95), (1405, 112), (1410, 140), (1410, 285)],
    # Jawa: small spur, top bar, hook down-left, diagonal down-right, up into the right arch.
    "jawa_ra": [(1655, 140), (1620, 140), (1592, 92), (1700, 88), (1722, 115), (1718, 170),
                (1690, 215), (1652, 245), (1735, 282), (1752, 268), (1755, 135), (1775, 100),
                (1830, 86), (1885, 100), (1900, 135), (1900, 285)],
    # Jawa Ka (P1 final glyph, Segara Kidul): like Na with one more hump. Own grid (600x500 render).
    "jawa_ka": [(172, 262), (140, 248), (128, 215), (128, 130), (145, 98), (178, 85), (205, 98),
                (215, 130), (215, 262), (215, 185), (290, 185), (335, 195), (340, 235), (318, 262),
                (292, 258), (282, 230), (285, 130), (310, 95), (350, 85), (385, 95), (395, 130),
                (395, 262), (395, 130), (410, 95), (440, 85), (470, 100), (478, 130), (478, 262)],
}

N = 64


def path_len(p):
    return sum(math.dist(p[i - 1], p[i]) for i in range(1, len(p)))


def resample(p, n=N):
    step = path_len(p) / (n - 1)
    out, acc, pts = [p[0]], 0.0, list(p)
    i = 1
    while i < len(pts):
        d = math.dist(pts[i - 1], pts[i])
        if acc + d >= step and d > 0:
            t = (step - acc) / d
            q = (pts[i - 1][0] + t * (pts[i][0] - pts[i - 1][0]),
                 pts[i - 1][1] + t * (pts[i][1] - pts[i - 1][1]))
            out.append(q)
            pts.insert(i, q)
            acc = 0.0
        else:
            acc += d
        i += 1
    while len(out) < n:
        out.append(pts[-1])
    return out[:n]


def normalize(p):
    """Resample, uniform scale to a unit box, centroid to origin. No rotation (orientation matters)."""
    p = resample(p)
    xs, ys = [x for x, _ in p], [y for _, y in p]
    s = max(max(xs) - min(xs), max(ys) - min(ys)) or 1
    cx, cy = sum(xs) / len(p), sum(ys) / len(p)
    return [((x - cx) / s, (y - cy) / s) for x, y in p]


HALF_DIAG = 0.5 * math.sqrt(2)


def score(a, b):
    """$1-style ordered path distance, mapped to 0..1 (1 = identical). Direction-sensitive."""
    d = sum(math.dist(p, q) for p, q in zip(a, b)) / N
    return max(0.0, 1 - d / HALF_DIAG)


TEMPLATES = {k: normalize(v) for k, v in STROKES.items()}


def classify(stroke, candidates=TEMPLATES):
    s = normalize(stroke)
    ranked = sorted(((score(s, t), k) for k, t in candidates.items()), reverse=True)
    (s1, k1), (s2, _) = ranked[0], ranked[1]
    if s1 < 0.65 or s1 - s2 < 0.05:
        return "fizzle", k1
    return ("full" if s1 >= 0.80 else "smudged"), k1


def sloppy(p, rng, jitter=0.03, skew=0.15, rot=8):
    """A plausible quick mouse drawing: wobble, uneven scale, slant, small tilt."""
    p = resample(p, 48)
    xs, ys = [x for x, _ in p], [y for _, y in p]
    size = max(max(xs) - min(xs), max(ys) - min(ys))
    sx, sy = rng.uniform(0.85, 1.15), rng.uniform(0.85, 1.15)
    sh, a = rng.uniform(-skew, skew), math.radians(rng.uniform(-rot, rot))
    wx = wy = 0.0
    out = []
    for x, y in p:
        wx = 0.6 * wx + rng.gauss(0, jitter * size)  # smoothed wobble, like a hand
        wy = 0.6 * wy + rng.gauss(0, jitter * size)
        x, y = x * sx + sh * y + wx, y * sy + wy
        out.append((x * math.cos(a) - y * math.sin(a), x * math.sin(a) + y * math.cos(a)))
    return out


def pair_table():
    keys = list(TEMPLATES)
    print("Template-vs-template similarity (higher = more alike, >0.80 is a problem):")
    worst = []
    for i, a in enumerate(keys):
        for b in keys[i + 1:]:
            worst.append((score(TEMPLATES[a], TEMPLATES[b]), a, b))
    for s, a, b in sorted(worst, reverse=True)[:6]:
        print(f"  {a:10s} {b:10s} {s:.2f}")
    return {(a, b): s for s, a, b in worst}


def sim(trials=300, seed=1):
    rng = random.Random(seed)
    print(f"\nSloppy-drawing simulation, {trials} per glyph, all {len(STROKES)} learned:")
    print(f"  {'glyph':10s} {'right':>6s} {'full':>6s} {'fizzle':>7s} {'WRONG':>6s}  most confused with")
    res = {}
    for k, stroke in STROKES.items():
        c = {"full": 0, "smudged": 0, "fizzle": 0, "wrong": 0}
        conf = {}
        for _ in range(trials):
            kind, guess = classify(sloppy(stroke, rng))
            if kind == "fizzle":
                c["fizzle"] += 1
                if guess != k:
                    conf[guess] = conf.get(guess, 0) + 1
            elif guess != k:
                c["wrong"] += 1
                conf[guess] = conf.get(guess, 0) + 1
            else:
                c[kind] += 1
        right = (c["full"] + c["smudged"]) / trials
        top = max(conf, key=conf.get) if conf else "-"
        print(f"  {k:10s} {right:6.0%} {c['full'] / trials:6.0%} {c['fizzle'] / trials:7.0%} "
              f"{c['wrong'] / trials:6.0%}  {top}")
        res[k] = (right, c["wrong"] / trials)
    return res


if __name__ == "__main__":
    pairs = pair_table()
    res = sim()
    # Design targets: a misread must be rare (the tie rule should turn doubt into a fizzle),
    # and an honest sloppy drawing should cast most of the time.
    for k, (right, wrong) in res.items():
        assert wrong <= 0.02, f"{k} misread {wrong:.0%}"
    bad = [k for k, (right, _) in res.items() if right < 0.85]
    print("\nBelow 85% cast rate:", bad or "none")
