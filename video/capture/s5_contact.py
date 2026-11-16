#!/usr/bin/env python3
"""Segment 5 contact sheet: 3 labelled frames per final shot -> video/out/preview/s5_contact.png.
Usage: python3 video/capture/s5_contact.py  (reads video/out/raw/shots_s5.json for the shot list and key moments)."""
import json, subprocess, os
from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "out"))
shots = json.load(open(os.path.join(ROOT, "raw", "shots_s5.json")))
TW, TH = 480, 270
rows = []
for s in shots:
    src = os.path.join(ROOT, "raw", s["file"])
    km = [m["t"] for m in s.get("key_moments", [])]
    ts = [km[0] + 1.2, km[len(km) // 2] + 0.5, km[-1] + 0.6] if len(km) >= 3 else []
    while len(ts) < 3:
        ts.append(s["seconds"] * (len(ts) + 1) / 4)
    ims = []
    for t in ts:
        t = min(max(t, 0.0), s["seconds"] - 0.05)
        out = subprocess.run(["ffmpeg", "-loglevel", "error", "-ss", "%.3f" % t, "-i", src, "-frames:v", "1",
                              "-vf", "scale=%d:%d:flags=area" % (TW, TH), "-f", "image2pipe", "-vcodec", "png", "-"],
                             capture_output=True, check=True).stdout
        from io import BytesIO
        ims.append(Image.open(BytesIO(out)).convert("RGB"))
    rows.append((s, ts, ims))
LAB = 18
sheet = Image.new("RGB", (TW * 3, (TH + LAB) * len(rows)), (16, 12, 28))
d = ImageDraw.Draw(sheet)
for r, (s, ts, ims) in enumerate(rows):
    y = r * (TH + LAB)
    d.text((4, y + 3), "%s  (%.1fs, rating %s)" % (s["file"], s["seconds"], s["rating"]), fill=(240, 230, 210))
    for i, im in enumerate(ims):
        sheet.paste(im, (i * TW, y + LAB))
        d.text((i * TW + 4, y + LAB + 4), "t=%.1f" % ts[i], fill=(255, 255, 0))
sheet.save(os.path.join(ROOT, "preview", "s5_contact.png"))
print(os.path.join(ROOT, "preview", "s5_contact.png"), sheet.size)
