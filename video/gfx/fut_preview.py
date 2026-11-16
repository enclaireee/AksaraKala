#!/usr/bin/env python3
"""python3 video/gfx/fut_preview.py fut_skins 0.9 2.5 4.5 7  -> video/out/preview/fut_<name>_N.png (1920x1080).
No args after the name: 4 default times. `--contact` builds fut_contact.png from the 4 default frames of each scene."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pxkit as K
import render_all as R
from PIL import Image

TIMES = {"fut_skins": [1.2, 3.1, 5.6, 7.0], "fut_coop": [1.2, 3.0, 5.6, 7.4],
         "fut_mobile": [2.6, 3.9, 5.6, 7.6], "fut_map": [1.5, 3.6, 5.2, 7.6]}

def frames(name, times=None):
    fn, d, a = R.build(name)
    return [fn(t) for t in (times or TIMES[name])]

if __name__ == "__main__":
    if sys.argv[1] == "--contact":
        names = list(TIMES)
        sheet = Image.new("RGB", (4 * 480, 4 * 284), (20, 16, 32))
        sh = sheet.convert("RGBA")
        for r, n in enumerate(names):
            for i, im in enumerate(frames(n)):
                sh.paste(im, (i * 480, r * 284 + 14))
            K.text(sh, f"{n}  t=" + " / ".join(str(t) for t in TIMES[n]), 4, r * 284 + 3, K.CAP, K.CREAM)
        sh = sh.convert("RGB").resize((1920, 1136), Image.NEAREST)
        sh.save(os.path.join(K.PREVIEW, "fut_contact.png"))
    else:
        name = sys.argv[1]
        ts = [float(x) for x in sys.argv[2:]] or TIMES[name]
        for i, im in enumerate(frames(name, ts)):
            K.scaled(im.convert("RGB"), 4).save(os.path.join(K.PREVIEW, f"fut_{name[4:]}_{i + 1}.png"))
