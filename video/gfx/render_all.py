#!/usr/bin/env python3
"""Render the trailer's pixel graphics.

    python3 video/gfx/render_all.py                 # every scene -> video/out/gfx/<name>.mp4 / .mov
    python3 video/gfx/render_all.py card_free end_card
    python3 video/gfx/render_all.py aksara_montage --dur 9 --kw '{"beats":[0.5,...20 numbers...]}'
    python3 video/gfx/render_all.py --list
    python3 video/gfx/render_all.py --preview [names]   # only write 3 frames per scene + gfx_contact.png
Options --dur and --kw apply to the (single) named scene(s)."""
import argparse
import json
import os
import sys
from multiprocessing import Pool

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pxkit as K  # noqa: E402
from scenes import SCENES  # noqa: E402
import scenes_future  # noqa: E402,F401  (segment 7 scenes register into SCENES)
import scenes_vista  # noqa: E402,F401  (region vistas)
import scenes_cine  # noqa: E402,F401  (story cinematics)


def build(name, dur=None, kw=None):
    factory, d0, alpha = SCENES[name]
    d = dur or d0
    return factory(d, **(kw or {})), d, alpha


def job(a):
    name, dur, kw, prev = a
    fn, d, alpha = build(name, dur, kw)
    if prev:
        K.preview_frames(name, fn, d, alpha)
        return name + " (preview)"
    return K.render(name, fn, d, alpha)


def contact(names):
    from PIL import Image
    cols, tw = 4, 480
    th = 270
    rows = (len(names) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * tw, rows * (th + 14)), (20, 16, 32))
    for i, n in enumerate(names):
        fn, d, alpha = build(n)
        t = d * 0.5
        if n == "aksara_montage":
            t = 7.0
        if n == "end_card":
            t = 9.5
        im = fn(t)
        if alpha:
            bg = K.dusk_bg(t).convert("RGBA")
            bg.alpha_composite(K.hard(im))
            im = bg
        sheet.paste(im.convert("RGB"), ((i % cols) * tw, (i // cols) * (th + 14) + 14))
        K.text(sheet.convert("RGBA"), n, 0, 0, K.CAP) if False else None
    sheet = sheet.convert("RGBA")
    for i, n in enumerate(names):
        K.text(sheet, n, (i % cols) * tw + 4, (i // cols) * (th + 14) + 3, K.CAP, K.CREAM)
    sheet = sheet.convert("RGB")
    sheet = sheet.resize((cols * tw * 1920 // (cols * tw) if False else 1920, int(sheet.height * 1920 / sheet.width)), K.Image.NEAREST)
    os.makedirs(K.PREVIEW, exist_ok=True)
    sheet.save(os.path.join(K.PREVIEW, "gfx_contact.png"))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("names", nargs="*")
    ap.add_argument("--dur", type=float)
    ap.add_argument("--kw", type=json.loads)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--preview", action="store_true")
    ap.add_argument("-j", type=int, default=2)
    a = ap.parse_args()
    if a.list:
        for n, (f, d, al) in SCENES.items():
            print(f"{n:28s} {d:5.1f}s {'alpha' if al else 'opaque'}")
        sys.exit()
    names = a.names or list(SCENES)
    jobs = [(n, a.dur, a.kw, a.preview) for n in names]
    if len(jobs) == 1:
        print(job(jobs[0]))
    else:
        with Pool(a.j) as p:
            for r in p.imap_unordered(job, jobs):
                print(r, flush=True)
    if a.preview and not a.names:
        contact(names)
