#!/usr/bin/env python3
"""Segment 1/2/4 deliverables: video/out/preview/s124_contact.png (3 labelled frames per final shot) and
video/out/raw/shots_s124.json. Shot metadata lives in SHOTS below; [mark] frames are read from the shot logs.
   python3 video/capture/s124_sheet.py"""
import json, os, re, subprocess, glob
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RAW = os.path.join(ROOT, "out", "raw")
SCRATCH = os.environ.get("S124_LOGS", "")


def dur(f):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", f]))


def marks(shot):
    """[mark] lines: shoot.sh prints them (recording-relative frames) into its stdout; the .log has @@SHOT mark."""
    out = {}
    for p in [os.path.join(SCRATCH, n) for n in ("G_%s.log" % shot, "F_%s.log" % shot, "f_%s.log" % shot)] if SCRATCH else []:
        if os.path.exists(p):
            for l in open(p, errors="ignore"):
                m = re.match(r"\[mark\] frame (\d+) (\S+)", l)
                if m:
                    out[m.group(2)] = int(m.group(1)) / 60.0
            if out:
                break
    return out


def T(m, k, d=0.0):
    return round(m[k] + d, 2) if k in m else None


SHOTS = json.load(open(os.path.join(os.path.dirname(__file__), "s124_shots.json")))


def main():
    res = []
    for s in SHOTS:
        f = os.path.join(RAW, s["file"])
        if not os.path.exists(f):
            print("missing", f)
            continue
        d = dur(f)
        m = marks(s.get("log", s["file"][:-4]))
        km = []
        for t, what in s.get("key_moments", []):
            if isinstance(t, str):
                k, _, off = t.partition("+")
                t = T(m, k, float(off or 0))
            if t is not None:
                km.append({"t": round(t, 2), "what": what})
        e = {k: v for k, v in s.items() if k not in ("key_moments", "log", "frames")}
        e.update({"file": "video/out/raw/" + s["file"], "seconds": round(d, 2), "key_moments": km})
        for k in ("best_in", "best_out"):
            if isinstance(e.get(k), str):
                kk, _, off = e[k].partition("+")
                e[k] = T(m, kk, float(off or 0))
        if e.get("best_out") is None or e["best_out"] > d:
            e["best_out"] = round(d, 2)
        fr = []
        for t in s.get("frames", []):
            if isinstance(t, str):
                k, _, off = t.partition("+")
                t = T(m, k, float(off or 0))
            if t is not None:
                fr.append(t)
        res.append((e, f, fr or [km[i]["t"] for i in range(min(3, len(km)))] or [d * 0.2, d * 0.5, d * 0.8]))
    json.dump([r[0] for r in res], open(os.path.join(RAW, "shots_s124.json"), "w"), indent=1)
    W, H = 480, 270
    sheet = Image.new("RGB", (3 * W, len(res) * (H + 18)), (16, 12, 28))
    dr = ImageDraw.Draw(sheet)
    font = ImageFont.truetype(os.path.join(ROOT, "..", "assets", "fonts", "Jersey10-Regular.ttf"), 14) if os.path.exists(os.path.join(ROOT, "..", "assets", "fonts", "Jersey10-Regular.ttf")) else ImageFont.load_default()
    tmp = os.path.join(ROOT, "out", "preview", "_s124_tmp.png")
    for r, (e, f, ts) in enumerate(res):
        y = r * (H + 18)
        dr.text((4, y + 1), "%s  (%.1fs, rating %s)  %s" % (os.path.basename(e["file"]), e["seconds"], e["rating"], e["description"][:150]), fill=(240, 230, 210), font=font)
        for c, t in enumerate(ts[:3]):
            t = min(max(0.0, float(t)), e["seconds"] - 0.05)
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", str(t), "-i", f, "-frames:v", "1", "-vf", "scale=%d:%d:flags=area" % (W, H), tmp], check=True)
            sheet.paste(Image.open(tmp).convert("RGB"), (c * W, y + 18))
            dr.text((c * W + 4, y + 20), "t=%.1f" % t, fill=(127, 232, 224), font=font)
    sheet.save(os.path.join(ROOT, "out", "preview", "s124_contact.png"))
    print("wrote", len(res), "shots")


if __name__ == "__main__":
    main()
