#!/usr/bin/env python3
"""Editor's checks on a rendered trailer.

    python3 video/edit/check.py [video.mp4]      (default: video/AksaraKala_Showcase.mp4, else the preview)

Writes video/out/preview/final_contact*.png (one frame every 3 s with timecodes, ~1920 px wide, split into sheets),
video/out/preview/cuts/cuts_*.png (the frame before and after every cut, with the cut time), and prints: ffprobe
facts, loudness, true peak, per-second RMS with any near-silent seconds, clipping count, black/flash frames at cuts.
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
VIDEO = os.path.dirname(HERE)
OUT = os.path.join(VIDEO, "out")
PREV = os.path.join(OUT, "preview")
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def sh(cmd):
    return subprocess.run(cmd, capture_output=True, check=True).stdout


def frames_at(path, times, w=480):
    """Grab frames at given times (fast seek, accurate)."""
    h = w * 9 // 16
    out = []
    for t in times:
        b = sh(["ffmpeg", "-v", "error", "-ss", f"{max(t, 0):.4f}", "-i", path, "-frames:v", "1", "-vf",
                f"scale={w}:{h}:flags=neighbor", "-f", "rawvideo", "-pix_fmt", "rgb24", "-"])
        if len(b) < w * h * 3:
            out.append(np.zeros((h, w, 3), np.uint8))
        else:
            out.append(np.frombuffer(b[: w * h * 3], np.uint8).reshape(h, w, 3))
    return out


def cut_pair(path, t, w=320):
    """The exact last frame before and first frame after the cut at t: seek near, then select by absolute pts."""
    h = w * 9 // 16
    k = int(round(t * 60))
    b = sh(["ffmpeg", "-v", "error", "-copyts", "-ss", f"{max((k - 30) / 60, 0):.5f}", "-i", path, "-vf",
            f"select='gte(t\\,{(k - 1.5) / 60:.5f})',scale={w}:{h}:flags=neighbor", "-frames:v", "2",
            "-f", "rawvideo", "-pix_fmt", "rgb24", "-"])
    fr = np.frombuffer(b, np.uint8).reshape(-1, h, w, 3)
    return fr[0], fr[1]


def label(im, txt):
    d = ImageDraw.Draw(im)
    f = ImageFont.truetype(FONT, 14)
    d.rectangle([0, 0, 8 * len(txt) + 8, 18], fill=(0, 0, 0))
    d.text((3, 1), txt, fill=(255, 230, 80), font=f)


def fmt(t):
    return f"{int(t // 60)}:{t % 60:05.2f}"


def contact(path, dur):
    times = np.arange(1.5, dur, 3.0)
    ims = frames_at(path, times, 384)
    cols, per = 5, 30
    sheets = []
    for k in range(0, len(ims), per):
        chunk = ims[k:k + per]
        rows = (len(chunk) + cols - 1) // cols
        sheet = Image.new("RGB", (cols * 384, rows * 216), (0, 0, 0))
        for i, a in enumerate(chunk):
            im = Image.fromarray(a)
            label(im, fmt(times[k + i]))
            sheet.paste(im, ((i % cols) * 384, (i // cols) * 216))
        p = os.path.join(PREV, f"final_contact_{k // per + 1}.png")
        sheet.save(p)
        sheets.append(p)
    return sheets


def cut_check(path, rows):
    cuts = sorted({r["t0"] for r in rows if r["t0"] > 0})
    d = os.path.join(PREV, "cuts")
    os.makedirs(d, exist_ok=True)
    pairs = []
    issues = []
    for t in cuts:
        a, b = cut_pair(path, t)
        pairs.append((t, a, b))
        for name, f in (("before", a), ("after", b)):
            m = f.mean()
            if m < 4:
                issues.append(f"{fmt(t)} {name}: near-black frame (mean {m:.1f})")
            if m > 185:
                issues.append(f"{fmt(t)} {name}: near-white flash frame (mean {m:.1f})")
    per = 16
    for k in range(0, len(pairs), per):
        ch = pairs[k:k + per]
        sheet = Image.new("RGB", (4 * 320, ((len(ch) + 1) // 2) * 180), (0, 0, 0))
        for i, (t, a, b) in enumerate(ch):
            x0 = (i % 2) * 640
            y0 = (i // 2) * 180
            ia, ib = Image.fromarray(a), Image.fromarray(b)
            label(ia, "cut " + fmt(t) + " <")
            label(ib, "> " + fmt(t))
            sheet.paste(ia, (x0, y0))
            sheet.paste(ib, (x0 + 320, y0))
        sheet.save(os.path.join(d, f"cuts_{k // per + 1}.png"))
    return cuts, issues


def audio_check(path):
    import pyloudnorm as pyln
    b = sh(["ffmpeg", "-v", "error", "-i", path, "-vn", "-f", "f32le", "-ac", "2", "-ar", "48000", "-"])
    x = np.frombuffer(b, np.float32).reshape(-1, 2).astype(np.float64)
    L = pyln.Meter(48000).integrated_loudness(x)
    from scipy.signal import resample_poly
    tp = max(np.abs(resample_poly(x[:, c], 4, 1)).max() for c in range(2))
    sec = 48000
    rms = [20 * np.log10(np.sqrt(np.mean(x[i:i + sec] ** 2)) + 1e-9) for i in range(0, len(x), sec)]
    clip = int((np.abs(x) >= 0.999).sum())
    print(f"audio: {L:.2f} LUFS integrated, true peak {20 * np.log10(tp):.2f} dBTP, samples at full scale: {clip}")
    print("per-second RMS dBFS:")
    for k in range(0, len(rms), 20):
        print(f"  {fmt(k):>8s} " + " ".join(f"{v:4.0f}" for v in rms[k:k + 20]))
    quiet = [i for i, v in enumerate(rms[:-2]) if v < -45]
    print("near-silent seconds (< -45 dBFS, excluding the final ring-out):", quiet or "none")
    # 50 ms windows: any audio gap (< -60 dBFS) before the last 2 s
    w = 2400
    r50 = np.array([np.sqrt(np.mean(x[i:i + w] ** 2)) for i in range(0, len(x) - 2 * sec, w)])
    gaps = np.where(20 * np.log10(r50 + 1e-9) < -60)[0]
    print("50 ms dropouts below -60 dBFS:", [fmt(g * 0.05) for g in gaps][:20] or "none")


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(VIDEO, "AksaraKala_Showcase.mp4")
    if not os.path.exists(path):
        path = os.path.join(OUT, "AksaraKala_preview.mp4")
    info = json.loads(sh(["ffprobe", "-v", "error", "-show_entries",
                          "stream=codec_name,profile,width,height,r_frame_rate,pix_fmt,sample_rate,channels,bit_rate:format=duration,size,bit_rate",
                          "-of", "json", path]))
    print(json.dumps(info, indent=1))
    dur = float(info["format"]["duration"])
    print(f"duration {fmt(dur)}, size {int(info['format']['size']) / 1e6:.2f} MB")
    rows = json.load(open(os.path.join(OUT, "edit_cache", "timeline.json")))
    print("contact sheets:", contact(path, dur))
    cuts, issues = cut_check(path, rows)
    print(f"{len(cuts)} cuts checked; issues:", issues or "none")
    audio_check(path)


if __name__ == "__main__":
    main()
