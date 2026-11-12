#!/usr/bin/env python3
"""Builds assets/audio/ from recorded source files listed in tools/audio/sources/*.json (design: .docs/audio.md).

Run:  /usr/bin/python3 tools/build_audio.py [--only sfx/hit] [--check] [--audition]
Needs numpy + ffmpeg + libsndfile (Ogg encoding). Raw downloads are cached in tools/audio/raw/ (git-ignored); "packs" in a manifest are fetched
when missing. Region music is rendered separately by tools/gen_music.py.

Manifest:  {"packs": {"<dir>": "<url of a zip>"}, "urls": {"<file path under raw/>": "<url of one file>"},
            "sounds": {"sfx/hit_light": {"peak": -3, "vars": [[layer, ...], [layer, ...]]},
                       "amb/sea": {"lufs": -27, "loop": 3.0, "layers": [layer]}}}
Layer:     {"src": "<path under raw/>", "start": 0, "dur": 0.4, "gain": 0 (dB), "pitch": 1.0, "delay": 0,
            "hp": 0, "lp": 0 (Hz), "rev": false, "fadein": 0, "fadeout": 0.03}
Output:    sfx -> 44.1 kHz mono WAV (id.wav, id__2.wav ... one per variation), jingle/music/amb -> stereo Ogg q6.
"""
import argparse
import ctypes
import glob
import json
import os
import subprocess
import sys
import urllib.request
import zipfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "audio", "raw")
SRC = os.path.join(HERE, "audio", "sources")
OUT = os.path.join(os.path.dirname(HERE), "assets", "audio")
SR = 44100
DEFAULT_PEAK = {"sfx": -3.0, "jingle": -3.0}
DEFAULT_LUFS = {"music": -18.0, "amb": -27.0}


def fetch(name, url):
    dest = os.path.join(RAW, name)
    if os.path.exists(dest):
        return
    os.makedirs(dest, exist_ok=True)
    tmp = os.path.join(dest, os.path.basename(url.split("?")[0]) or "file")
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as r, open(tmp, "wb") as f:
        f.write(r.read())
    if zipfile.is_zipfile(tmp):
        with zipfile.ZipFile(tmp) as z:
            z.extractall(dest)
        os.remove(tmp)


def fetch_file(name, url):
    dest = os.path.join(RAW, name)
    if os.path.exists(dest):
        return
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as r, open(dest, "wb") as f:
        f.write(r.read())


def decode(layer, ch):
    """One layer as float32 [n, ch] at SR, trimmed / pitched / filtered by ffmpeg."""
    path = os.path.join(RAW, layer["src"])
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    af = []
    pitch = float(layer.get("pitch", 1.0))
    if pitch != 1.0:
        af += ["aresample=%d" % SR, "asetrate=%d" % round(SR * pitch)]
    af.append("aresample=%d" % SR)
    if layer.get("hp"):
        af.append("highpass=f=%g" % layer["hp"])
    if layer.get("lp"):
        af.append("lowpass=f=%g" % layer["lp"])
    cmd = ["ffmpeg", "-v", "error"]
    if layer.get("start"):
        cmd += ["-ss", str(layer["start"])]
    if layer.get("dur"):
        cmd += ["-t", str(layer["dur"])]
    cmd += ["-i", path, "-af", ",".join(af), "-ac", str(ch), "-f", "f32le", "-"]
    x = np.frombuffer(subprocess.run(cmd, check=True, capture_output=True).stdout, dtype=np.float32)
    x = x.reshape(-1, ch).astype(np.float64)
    if layer.get("rev"):
        x = x[::-1]
    fade(x, float(layer.get("fadein", 0.0)), float(layer.get("fadeout", 0.03)))
    return x * 10 ** (float(layer.get("gain", 0.0)) / 20.0)


def fade(x, t_in, t_out):
    a, b = min(len(x), int(t_in * SR)), min(len(x), int(t_out * SR))
    if a:
        x[:a] *= np.linspace(0, 1, a)[:, None]
    if b:
        x[-b:] *= np.linspace(1, 0, b)[:, None]


def mix(layers, ch):
    parts = [(int(float(l.get("delay", 0)) * SR), decode(l, ch)) for l in layers]
    out = np.zeros((max(d + len(x) for d, x in parts), ch))
    for d, x in parts:
        out[d:d + len(x)] += x
    return out


def trim_lead(x, thresh_db=-45.0):
    idx = np.nonzero(np.abs(x).max(axis=1) > 10 ** (thresh_db / 20.0))[0]
    if len(idx) == 0:
        return x
    x = x[max(0, idx[0] - 64):]
    fade(x, 0.0015, 0.0)
    return x


def seamless(x, xf):
    """Fold the last xf seconds over the first (equal power), so the file loops without a seam."""
    n = int(xf * SR)
    if n <= 0 or len(x) < 3 * n:
        return x
    t = np.linspace(0, np.pi / 2, n)[:, None]
    body = x[:-n].copy()
    body[:n] = body[:n] * np.sin(t) + x[-n:] * np.cos(t)
    return body


def lufs(x):
    p = subprocess.run(["ffmpeg", "-v", "info", "-f", "f64le", "-ar", str(SR), "-ac", str(x.shape[1]), "-i", "-",
                        "-af", "ebur128", "-f", "null", "-"], input=x.tobytes(), capture_output=True)
    for line in reversed(p.stderr.decode(errors="ignore").splitlines()):
        if line.strip().startswith("I:"):
            return float(line.split()[1])
    return -70.0


def peak_db(x):
    return 20 * np.log10(max(np.abs(x).max(), 1e-9))


class _SfInfo(ctypes.Structure):
    _fields_ = [("frames", ctypes.c_int64), ("samplerate", ctypes.c_int), ("channels", ctypes.c_int),
                ("format", ctypes.c_int), ("sections", ctypes.c_int), ("seekable", ctypes.c_int)]


def write_ogg(x, path, quality=0.6):
    """Ogg Vorbis through libsndfile (Homebrew's ffmpeg is built without libvorbis)."""
    sf = ctypes.CDLL(os.environ.get("LIBSNDFILE", "/opt/homebrew/lib/libsndfile.dylib"))
    sf.sf_open.restype = ctypes.c_void_p
    info = _SfInfo(0, SR, x.shape[1], 0x200000 | 0x0060, 0, 0)   # SF_FORMAT_OGG | SF_FORMAT_VORBIS
    h = ctypes.c_void_p(sf.sf_open(path.encode(), 0x20, ctypes.byref(info)))   # SFM_WRITE
    if not h:
        raise OSError("libsndfile cannot open " + path)
    q = ctypes.c_double(quality)
    sf.sf_command(h, 0x1300, ctypes.byref(q), 8)   # SFC_SET_VBR_ENCODING_QUALITY
    sf.sf_writef_double.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int64]
    data = np.ascontiguousarray(x, dtype=np.float64)
    for i in range(0, len(data), 16384):
        chunk = data[i:i + 16384]
        sf.sf_writef_double(h, chunk.ctypes.data, len(chunk))
    sf.sf_close(h)


def write(x, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    x = np.clip(x, -1, 1)
    if path.endswith(".ogg"):
        return write_ogg(x, path)
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "f64le", "-ar", str(SR), "-ac", str(x.shape[1]), "-i", "-",
                    "-c:a", "pcm_s16le", path], input=x.tobytes(), check=True)


def build(sid, spec):
    kind = sid.split("/")[0]
    ch = 1 if kind == "sfx" else 2
    ext = ".wav" if kind == "sfx" else ".ogg"
    variants = spec.get("vars") or [spec["layers"]]
    for i, layers in enumerate(variants):
        x = mix(layers, ch)
        if spec.get("trim", kind in ("sfx", "jingle")):
            x = trim_lead(x)
        if spec.get("loop"):
            x = seamless(x, float(spec["loop"]))
        elif kind in ("sfx", "jingle"):
            fade(x, 0.0, float(spec.get("fade", 0.02)))
        if kind in DEFAULT_LUFS:
            target = float(spec.get("lufs", DEFAULT_LUFS[kind]))
            x *= 10 ** ((target - lufs(x)) / 20.0)
            x *= min(1.0, 10 ** (-1.5 / 20.0) / max(np.abs(x).max(), 1e-9))   # never above -1.5 dBFS
        else:
            x *= 10 ** ((float(spec.get("peak", DEFAULT_PEAK[kind])) - peak_db(x)) / 20.0)
        write(x, os.path.join(OUT, sid + ("" if i == 0 else "__%d" % (i + 1)) + ext))


def check():
    bad = 0
    for path in sorted(glob.glob(os.path.join(OUT, "*", "*.wav")) + glob.glob(os.path.join(OUT, "*", "*.ogg"))):
        rel = os.path.relpath(path, OUT)
        kind = rel.split(os.sep)[0]
        ch = 1 if kind == "sfx" else 2
        raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-ac", str(ch), "-ar", str(SR), "-f", "f64le", "-"],
                             capture_output=True).stdout
        x = np.frombuffer(raw, dtype=np.float64).reshape(-1, ch)
        pk, dur = peak_db(x), len(x) / SR
        lead = np.argmax(np.abs(x).max(axis=1) > 0.01) / SR
        notes = []
        if pk > -0.9:
            notes.append("peak above -1 dBFS")
        if kind == "sfx" and lead > 0.012:
            notes.append("%.0f ms of leading silence" % (lead * 1000))
        if kind in ("music", "amb"):
            seam = np.abs(x[0] - x[-1]).max()
            step = np.percentile(np.abs(np.diff(x[:, 0])), 99.9)
            if seam > max(4 * step, 0.02):
                notes.append("loop seam jump %.3f" % seam)
            loud = lufs(x)
            if abs(loud - DEFAULT_LUFS[kind]) > 4:
                notes.append("%.1f LUFS" % loud)
        if notes:
            bad += 1
            print("%-34s %6.2fs %6.1f dB  %s" % (rel, dur, pk, "; ".join(notes)))
    print("check: %d file(s) flagged" % bad)
    return bad


def audition():
    rows = {}
    for path in sorted(glob.glob(os.path.join(OUT, "*", "*.wav")) + glob.glob(os.path.join(OUT, "*", "*.ogg"))):
        rel = os.path.relpath(path, OUT)
        rows.setdefault(rel.split(os.sep)[0], []).append(rel)
    html = ["<!doctype html><meta charset=utf-8><title>Aksara Kala audio</title>",
            "<style>body{font:14px system-ui;margin:24px;background:#16130f;color:#e8dcc4}h2{margin-top:28px}"
            ".g{display:grid;grid-template-columns:repeat(auto-fill,minmax(330px,1fr));gap:6px 18px}"
            ".g div{display:flex;align-items:center;gap:8px}audio{height:28px;flex:1}code{width:150px}</style>"]
    for kind in ("music", "jingle", "amb", "sfx"):
        html.append("<h2>%s (%d)</h2><div class=g>" % (kind, len(rows.get(kind, []))))
        for rel in rows.get(kind, []):
            name = os.path.splitext(os.path.basename(rel))[0]
            html.append("<div><code>%s</code><audio controls preload=none src='../../assets/audio/%s'></audio></div>"
                        % (name, rel))
        html.append("</div>")
    with open(os.path.join(HERE, "audio", "audition.html"), "w") as f:
        f.write("\n".join(html))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--audition", action="store_true")
    a = ap.parse_args()
    os.makedirs(RAW, exist_ok=True)
    open(os.path.join(RAW, ".gdignore"), "a").close()   # keeps Godot from importing the download cache
    if a.check:
        sys.exit(1 if check() else 0)
    if a.audition:
        return audition()
    failed = 0
    for mf in sorted(glob.glob(os.path.join(SRC, "*.json"))):
        with open(mf) as f:
            man = json.load(f)
        for name, url in man.get("packs", {}).items():
            fetch(name, url)
        for name, url in man.get("urls", {}).items():
            fetch_file(name, url)
        for sid, spec in man.get("sounds", {}).items():
            if not sid.startswith(a.only):
                continue
            try:
                build(sid, spec)
            except Exception as e:   # one bad source must not stop the other 150
                failed += 1
                print("FAILED %s: %s" % (sid, e))
    audition()
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
