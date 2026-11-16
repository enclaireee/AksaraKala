#!/usr/bin/env python3
"""1080p-direct vs 480x270 rendered and upscaled 4x nearest. Needs both runs with --keep:
     shoot.sh _compare --keep ; shoot.sh _compare --native --keep --out video/out/raw/_compare_native.mp4
   python3 video/capture/compare.py [shot=_compare]
   Prints per-frame difference and writes side-by-side crops to video/out/preview/compare_*.png"""
import sys, os, re
import numpy as np
from PIL import Image
shot = sys.argv[1] if len(sys.argv) > 1 else "_compare"
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "out")
def start(log):
    return int(re.search(r"@@SHOT rec_start (\d+)", open(log).read()).group(1))
fa, fb = os.path.join(root, "tmp", shot + "_final"), os.path.join(root, "tmp", shot + "_native")
sa, sb = start(os.path.join(root, "raw", shot + ".log")), start(os.path.join(root, "raw", shot + "_native.log"))
def A(i): return np.asarray(Image.open(os.path.join(fa, "f%08d.png" % (sa + i))).convert("RGB")).astype(int)
def B(i):
    im = Image.open(os.path.join(fb, "f%08d.png" % (sb + i))).convert("RGB")
    return np.asarray(im.resize((im.width * 4, im.height * 4), Image.NEAREST)).astype(int)
def block_ok(a):   # fraction of 4x4 blocks that are one flat colour (true pixel-art upscale)
    h, w, _ = a.shape
    b = a[: h // 4 * 4, : w // 4 * 4].reshape(h // 4, 4, w // 4, 4, 3)
    return float((b.max(axis=(1, 3)) == b.min(axis=(1, 3))).all(axis=-1).mean())
out = os.path.join(root, "preview")
n = len([f for f in os.listdir(fa) if f.endswith(".png")]) - sa
for i in list(range(0, n, 15)):
    try:
        a, b = A(i), B(i)
    except FileNotFoundError:
        break
    d = np.abs(a - b).max(axis=-1)
    print("frame %3d  differing px %5.2f%%  mean abs %.2f  flat-4x4 blocks: direct %.3f upscaled %.3f" % (
        i, (d > 8).mean() * 100, np.abs(a - b).mean(), block_ok(a), block_ok(b)))
crops = {"hud": (0, 0, 640, 160), "lesson": (360, 120, 1560, 760), "center": (560, 140, 1360, 760)}
for i, name in [(30, "lesson"), (30, "hud"), (100, "center"), (165, "center")]:
    a, b = Image.fromarray(A(i).astype("uint8")), Image.fromarray(B(i).astype("uint8"))
    box = crops[name]
    ca, cb = a.crop(box), b.crop(box)
    w, h = ca.size
    s = Image.new("RGB", (w * 2 + 8, h), (255, 0, 255))
    s.paste(ca, (0, 0)); s.paste(cb, (w + 8, 0))
    p = os.path.join(out, "compare_%s_f%03d.png" % (name, i))
    s.save(p); print("left: 1080p direct, right: 480x270 x4 ->", p)
