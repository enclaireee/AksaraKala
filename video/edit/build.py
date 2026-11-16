#!/usr/bin/env python3
"""Build the Aksara Kala showcase trailer from edl.py + music_plan.py.

    python3 video/edit/build.py              # full 1920x1080 render -> video/AksaraKala_Showcase.mp4
    python3 video/edit/build.py --preview    # fast 960x540 draft     -> video/out/AksaraKala_preview.mp4
    python3 video/edit/build.py --audio-only # re-mix the soundtrack only (writes video/out/edit_cache/mix.wav)
    python3 video/edit/build.py --timeline   # print the resolved timeline and exit

Pipeline: (1) resolve the EDL (optional entries by file existence), (2) re-render any retimed graphics through
video/gfx (cached in video/out/edit_gfx/), (3) render each segment to an intermediate file (cached by a hash of its
entries and source files, so changing one segment re-renders only that segment), (4) mix the whole soundtrack in
numpy (clip audio, music cues, ducks, SFX, loudness -14 LUFS, true peak < -1 dBTP), (5) concatenate and encode.

Picture rules kept here: footage is never resampled with a smoothing filter (preview halves with nearest-neighbour),
zooms are integer scales of the native 480x270 grid, fades are stepped 4x4 Bayer dithers on the native grid.
"""
import argparse
import hashlib
import json
import math
import os
import subprocess
import sys
import time
from multiprocessing import Pool

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
VIDEO = os.path.dirname(HERE)
ROOT = os.path.dirname(VIDEO)
OUT = os.path.join(VIDEO, "out")
CACHE = os.path.join(OUT, "edit_cache")
GFXCACHE = os.path.join(OUT, "edit_gfx")
sys.path.insert(0, HERE)

FPS = 60
SR = 48000
NIGHT = (0x0A, 0x08, 0x14)
VERSION = "v4"            # bump to invalidate every cached segment after changing the renderer
FINAL = os.path.join(VIDEO, "AksaraKala_Showcase.mp4")
PREVIEW = os.path.join(OUT, "AksaraKala_preview.mp4")
SIZE_LIMIT = 95e6

# --------------------------------------------------------------------------------------------- helpers


def run(cmd, **kw):
    r = subprocess.run(cmd, capture_output=True, **kw)
    if r.returncode != 0:
        sys.stderr.write(r.stderr.decode(errors="replace")[-3000:])
        raise SystemExit("command failed: " + " ".join(map(str, cmd))[:300])
    return r


def src_path(src):
    if src == "black":
        return None
    kind, name = src.split("/", 1)
    if kind == "raw":
        return os.path.join(OUT, "raw", name + ".mp4")
    if kind == "gfx":
        return os.path.join(OUT, "gfx", name + ".mp4")
    raise ValueError(src)


def ov_path(name):
    return os.path.join(OUT, "gfx", name + ".mov")


def fstat(p):
    try:
        s = os.stat(p)
        return [os.path.basename(p), s.st_size, int(s.st_mtime)]
    except OSError:
        return [os.path.basename(p), None]


def probe_frames(p):
    r = run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", p])
    return int(round(float(r.stdout.decode().strip()) * FPS))


# --------------------------------------------------------------------------------------------- EDL resolve


def load_edl():
    import importlib
    import edl
    import music_plan
    importlib.reload(edl)
    importlib.reload(music_plan)
    return edl, music_plan


def resolve(edl):
    """-> list of segments with entries carrying absolute frame ranges."""
    segs = []
    t = 0.0
    f0 = 0
    for seg in edl.SEGMENTS:
        ents = []
        seg_t0 = t
        for e in seg["entries"]:
            if "need" in e and not os.path.exists(os.path.join(OUT, e["need"])):
                continue
            if "skip_if" in e and os.path.exists(os.path.join(OUT, e["skip_if"])):
                continue
            e = dict(e)
            e["t0"] = t
            e["f0"] = int(round(t * FPS))
            t += e["dur"]
            e["f1"] = int(round(t * FPS))
            e["t1"] = t
            ents.append(e)
        segs.append(dict(name=seg["name"], entries=ents, t0=seg_t0, t1=t,
                         f0=int(round(seg_t0 * FPS)), f1=int(round(t * FPS))))
    return segs


# --------------------------------------------------------------------------------------------- graphics re-render


def gfx_render_path(e):
    r = e["render"]
    name = e["src"].split("/", 1)[1]
    key = hashlib.sha1(json.dumps([name, round(r.get("dur", 0), 4), r.get("kw")], sort_keys=True).encode()).hexdigest()[:10]
    return os.path.join(GFXCACHE, f"{name}__{key}.mp4")


def _render_gfx_job(args):
    name, dur, kw, out = args
    sys.path.insert(0, os.path.join(VIDEO, "gfx"))
    import pxkit as K
    from render_all import build
    fn, d, alpha = build(name, dur, kw)
    tmpdir = out + ".tmpdir"
    os.makedirs(tmpdir, exist_ok=True)
    K.render(name, fn, d, alpha, outdir=tmpdir)
    os.replace(os.path.join(tmpdir, name + ".mp4"), out)
    os.rmdir(tmpdir)
    return out


def render_gfx(segs):
    jobs = []
    for s in segs:
        for e in s["entries"]:
            if e.get("render"):
                p = gfx_render_path(e)
                e["path"] = p
                if not os.path.exists(p):
                    name = e["src"].split("/", 1)[1]
                    jobs.append((name, e["render"].get("dur"), e["render"].get("kw"), p))
    jobs = list({j[3]: j for j in jobs}.values())
    if jobs:
        os.makedirs(GFXCACHE, exist_ok=True)
        print(f"rendering {len(jobs)} retimed graphics ...", flush=True)
        with Pool(min(3, len(jobs))) as p:
            for r in p.imap_unordered(_render_gfx_job, jobs):
                print("  ", os.path.relpath(r, VIDEO), flush=True)


# --------------------------------------------------------------------------------------------- picture


def bayer_grid(W, H):
    b = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]], float)
    b = (b + 0.5) / 16.0
    nat = np.tile(b, (270 // 4 + 1, 480 // 4))[:270, :480]
    s = W // 480
    return np.repeat(np.repeat(nat, s, 0), s, 1)


def frame_reader(path, inp, n, W, H, rgba=False, full=False):
    """Yield exactly n frames from path starting at the frame nearest inp (held on its last frame if short)."""
    fi = int(round(inp * FPS))
    ss = max(0.0, (fi - 0.5) / FPS)
    w, h = (1920, 1080) if full else (W, H)
    vf = [] if (w == 1920) else ["-vf", f"scale={w}:{h}:flags=neighbor"]
    ch = 4 if rgba else 3
    cmd = ["ffmpeg", "-v", "error", "-ss", f"{ss:.6f}", "-i", path, "-frames:v", str(n), *vf,
           "-f", "rawvideo", "-pix_fmt", "rgba" if rgba else "rgb24", "-"]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    size = w * h * ch
    last = None
    got = 0
    for _ in range(n):
        buf = p.stdout.read(size)
        if len(buf) < size:
            break
        last = np.frombuffer(buf, np.uint8).reshape(h, w, ch)
        got += 1
        yield last
    p.stdout.close()
    p.wait()
    if last is None:
        raise SystemExit(f"no frames from {path} at {inp}")
    for _ in range(n - got):
        yield last


def zoom_frame(fr, k, cx, cy, W, H):
    """fr: 1920x1080 frame of 4x nearest-scaled native 480x270 art -> show native at k x centred on (cx, cy)."""
    nat = fr[2::4, 2::4]
    ww, hh = 1920 // k, 1080 // k
    x0 = int(min(max(cx - ww // 2, 0), 480 - ww))
    y0 = int(min(max(cy - hh // 2, 0), 270 - hh))
    crop = nat[y0:y0 + hh, x0:x0 + ww]
    out = np.repeat(np.repeat(crop, k, 0), k, 1)
    if W != 1920:
        out = out[::1920 // W, ::1920 // W]
    return out


def render_segment(args):
    seg, mode, out = args
    W, H = (1920, 1080) if mode == "full" else (960, 540)
    bay = bayer_grid(W, H)
    night = np.array(NIGHT, np.uint8)
    enc = ["ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}", "-r", str(FPS),
           "-i", "-", "-c:v", "libx264", "-pix_fmt", "yuv420p"]
    enc += ["-preset", "veryfast", "-crf", "8"] if mode == "full" else ["-preset", "ultrafast", "-crf", "20"]
    tmp = out + ".part"
    proc = subprocess.Popen(enc + ["-f", "h264", tmp], stdin=subprocess.PIPE)
    # overlays on the segment's frame timeline
    ovs = []
    for e in seg["entries"]:
        for o in e.get("ov", []):
            p = ov_path(o["src"])
            n = probe_frames(p) if o.get("dur") is None else int(round(o["dur"] * FPS))
            start = e["f0"] + int(round(o["at"] * FPS))
            ovs.append(dict(path=p, f0=start, f1=start + n, inp=o.get("inp", 0.0), it=None))
    for e in seg["entries"]:
        n = e["f1"] - e["f0"]
        if e["src"] == "black":
            frames = (np.broadcast_to(night, (H, W, 3)) for _ in range(n))
        else:
            path = e.get("path") or src_path(e["src"])
            frames = frame_reader(path, e["inp"], n, W, H, full=bool(e.get("zoom")))
        fin = int(round(e.get("fin", 0) * FPS))
        fout = int(round(e.get("fout", 0) * FPS))
        for i, fr in enumerate(frames):
            gf = e["f0"] + i
            if e.get("zoom"):
                t = i / FPS
                step = [z for z in e["zoom"] if z[0] <= t + 1e-6][-1]
                fr = zoom_frame(fr, step[1], step[2], step[3], W, H)
            fr = np.array(fr)
            for o in ovs:
                if o["f0"] <= gf < o["f1"]:
                    if o["it"] is None:
                        o["it"] = frame_reader(o["path"], o["inp"] + (gf - o["f0"]) / FPS, o["f1"] - gf, W, H, rgba=True)
                    ofr = next(o["it"])
                    m = ofr[..., 3] > 127
                    fr[m] = ofr[..., :3][m]
            vis = None
            if fin and i < fin:
                ns = max(1, math.ceil(fin / 3))
                vis = (i // 3 + 1) / (ns + 1)
            if fout and i >= n - fout:
                j = n - 1 - i
                ns = max(1, math.ceil(fout / 3))
                v2 = (j // 3 + 1) / (ns + 1)
                vis = v2 if vis is None else min(vis, v2)
            if vis is not None:
                fr[bay >= vis] = night
            proc.stdin.write(np.ascontiguousarray(fr, np.uint8).tobytes())
    proc.stdin.close()
    if proc.wait() != 0:
        raise SystemExit("encode failed for " + seg["name"])
    os.replace(tmp, out)
    return out


def seg_key(seg, mode):
    items = []
    for e in seg["entries"]:
        d = {k: v for k, v in e.items() if k not in ("t0", "t1", "f0", "f1", "id")}
        d["n"] = e["f1"] - e["f0"]
        d["file"] = fstat(e.get("path") or src_path(e["src"])) if e["src"] != "black" else None
        d["ovf"] = [fstat(ov_path(o["src"])) for o in e.get("ov", [])]
        items.append(d)
    blob = json.dumps([VERSION, mode, items], sort_keys=True, default=str)
    return hashlib.sha1(blob.encode()).hexdigest()[:12]


def render_video(segs, mode, jobs=2):
    d = os.path.join(CACHE, mode)
    os.makedirs(d, exist_ok=True)
    todo, outs = [], []
    for i, s in enumerate(segs):
        out = os.path.join(d, f"{i + 1:02d}_{s['name']}_{seg_key(s, mode)}.264")
        outs.append(out)
        if not os.path.exists(out):
            todo.append((s, mode, out))
    print(f"segments: {len(segs) - len(todo)} cached, {len(todo)} to render", flush=True)
    t = time.time()
    if todo:
        with Pool(min(jobs, len(todo))) as p:
            for r in p.imap_unordered(render_segment, todo):
                print(f"  rendered {os.path.basename(r)}  ({time.time() - t:.0f}s)", flush=True)
    # drop stale cache files of the same segment names
    keep = set(outs)
    for f in os.listdir(d):
        fp = os.path.join(d, f)
        if fp not in keep and (f.endswith(".mp4") or f.endswith(".264")):
            os.remove(fp)
    return outs


# --------------------------------------------------------------------------------------------- sound

_AUDIO = {}


def load_audio(path):
    """Any audio file -> float32 stereo at 48 kHz (cached)."""
    if path in _AUDIO:
        return _AUDIO[path]
    r = run(["ffmpeg", "-v", "error", "-i", path, "-f", "f32le", "-ac", "2", "-ar", str(SR), "-"])
    a = np.frombuffer(r.stdout, np.float32).reshape(-1, 2).astype(np.float64)
    _AUDIO[path] = a
    return a


def clip_audio(path, inp, dur):
    r = run(["ffmpeg", "-v", "error", "-ss", f"{inp:.6f}", "-i", path, "-t", f"{dur:.6f}", "-vn", "-f", "f32le",
             "-ac", "2", "-ar", str(SR), "-"])
    return np.frombuffer(r.stdout, np.float32).reshape(-1, 2).astype(np.float64)


def db(x):
    return 10 ** (x / 20.0)


def ramp(n, kind):
    t = np.linspace(0, 1, max(n, 1))
    return np.sin(t * np.pi / 2) if kind == "in" else np.cos(t * np.pi / 2)


def add_at(buf, sig, t):
    a = int(round(t * SR))
    if a < 0:
        sig = sig[-a:]
        a = 0
    m = min(len(sig), len(buf) - a)
    if m > 0:
        buf[a:a + m] += sig[:m]


class Anchors:
    def __init__(self, segs):
        self.e, self.s = {}, {}
        for s in segs:
            self.s[s["name"]] = (s["t0"], s["t1"])
            for e in s["entries"]:
                if e.get("id"):
                    self.e[e["id"]] = (e["t0"], e["t1"])

    def __call__(self, a):
        """'@id+x' (from entry start), '@id$x' (from entry end), '#seg+x', float. None if the anchor is absent."""
        if isinstance(a, (int, float)):
            return float(a)
        tab = self.e if a[0] == "@" else self.s
        body = a[1:]
        for i, c in enumerate(body):
            if c in "+-$" and i > 0:
                name, rest = body[:i], body[i:]
                break
        else:
            name, rest = body, "+0"
        if name not in tab:
            return None
        t0, t1 = tab[name]
        if rest[0] == "$":
            return t1 + float(rest[1:] or 0)
        return t0 + float(rest)


def reverb_tail(x, secs, seed=7, level=0.5):
    """Stereo exponential-noise reverb of x (no dry), length len(x)+secs."""
    rng = np.random.default_rng(seed)
    n = int(secs * SR)
    env = np.exp(-6.9 * np.arange(n) / n)
    out = np.zeros((len(x) + n, 2))
    from scipy.signal import fftconvolve
    for ch in range(2):
        ir = rng.standard_normal(n) * env
        ir[: int(0.01 * SR)] *= np.linspace(0, 1, int(0.01 * SR))
        w = fftconvolve(x[:, ch], ir)[: len(out)]
        out[: len(w), ch] = w
    rms_x = np.sqrt(np.mean(x ** 2)) + 1e-12
    rms_w = np.sqrt(np.mean(out[: len(x)] ** 2)) + 1e-12
    return out * (rms_x / rms_w) * level


def synth(kind, dur=None, f=None):
    """Sounds from the game's own instrument code (tools/audio/inst.py, 44.1 kHz mono) -> 48 kHz stereo."""
    sys.path.insert(0, os.path.join(ROOT, "tools", "audio"))
    import inst as I
    from scipy.signal import resample_poly
    if kind == "lampout":
        # a sub boom from the instrument code + the gong stroke that opens the game's 'death' stinger (cut before
        # its rebab line enters at 0.8 s)
        y = np.zeros(int(44100 * 4.0))
        b = np.asarray(I.sub_boom(38.0, 3.0, 1.0), float)
        y[:len(b)] += b / (np.abs(b).max() + 1e-9)
        y = resample_poly(y, 160, 147)
        st = load_audio(os.path.join(ROOT, "assets/audio/jingle/death.ogg"))[: int(0.78 * SR)].mean(1)
        st = st * np.cos(np.linspace(0, np.pi / 2, len(st))) ** 0.5
        st = st / (np.abs(st).max() + 1e-9)
        y[:len(st)] += st * 0.8
        y = np.stack([y, y], 1)
        w = reverb_tail(y[: int(0.8 * SR)], 3.0)
        m = min(len(w), len(y))
        y[:m] += w[:m]
        return y / (np.abs(y).max() + 1e-9) * 0.9
    else:
        raise ValueError(kind)


def mix(segs, edl, mp, verbose=True):
    T = segs[-1]["t1"]
    n = int(math.ceil(T * SR))
    A = Anchors(segs)
    clip = np.zeros((n, 2))
    music = np.zeros((n, 2))
    fx = np.zeros((n, 2))
    xf = int(0.012 * SR)
    # --- clip audio (game SFX / ambience)
    for s in segs:
        for e in s["entries"]:
            if not e["src"].startswith("raw/") or e.get("audio", True) is False:
                continue
            tail = e.get("atail", 0.0)
            a = clip_audio(src_path(e["src"]), e["inp"], e["dur"] + tail + 0.012)
            a = a * db(e.get("gain", edl.CLIP_GAIN))
            a[:xf] *= ramp(xf, "in")[:, None]
            k = min(len(a), int((e["dur"] + 0.012) * SR))
            a = a[:k + int(tail * SR)]
            if tail:
                tn = int(tail * SR)
                a[-tn:] *= ramp(tn, "out")[:, None]
            else:
                a[-xf:] *= ramp(xf, "out")[:, None]
            add_at(clip, a, e["t0"])
    # --- music cues
    placed = {}
    for c in mp.CUES:
        at, until = A(c["at"]), A(c["until"])
        if at is None or until is None:
            continue
        src = c["src"]
        if isinstance(src, str) and src.startswith("sync:"):
            ref = placed[src[5:]]
            src = ref["src"] + (at - ref["at"])
        if c.get("id"):
            placed[c["id"]] = dict(at=at, src=src)
        tr = load_audio(os.path.join(ROOT, c["file"]))
        L = int(round((until - at) * SR))
        s0 = int(round(src * SR))
        if c.get("loop"):
            ln = int(round(c["loop"] * SR))
            tr = tr[:ln]
            idx = (s0 + np.arange(L)) % ln
            seg_a = tr[idx]
        else:
            seg_a = tr[max(s0, 0): s0 + L]
            if s0 < 0:
                seg_a = np.concatenate([np.zeros((-s0, 2)), seg_a])
            if len(seg_a) < L:
                seg_a = np.concatenate([seg_a, np.zeros((L - len(seg_a), 2))])
        seg_a = seg_a.copy() * db(c.get("gain", 0))
        fi, fo = int(c.get("fin", 0.02) * SR), int(c.get("fout", 0.02) * SR)
        seg_a[:fi] *= ramp(fi, "in")[:, None]
        if c.get("ring"):
            last = seg_a[-int(1.6 * SR):].copy()
            wet = reverb_tail(last, c["ring"], level=db(c.get("ring_gain", -6)))
            # the tail takes over as the dry track releases: silent until 0.4 s before the end, then ramps in
            k0, k1 = int(1.2 * SR), int(1.6 * SR)
            wet[:k0] = 0
            wet[k0:k1] *= np.linspace(0, 1, k1 - k0)[:, None]
            add_at(music, wet, until - 1.6)
        if fo:
            seg_a[-fo:] *= ramp(fo, "out")[:, None]
        add_at(music, seg_a, at)
    # --- ducks on the music bus
    env = np.ones(n)
    rn = int(0.15 * SR)
    for a0, a1, d in mp.DUCKS:
        t0, t1 = A(a0), A(a1)
        if t0 is None or t1 is None:
            continue
        g = np.ones(n)
        i0, i1 = int(t0 * SR), int(t1 * SR)
        g[i0:i1] = db(d)
        g[max(i0 - rn, 0):i0] = np.linspace(1, db(d), i0 - max(i0 - rn, 0))
        e1 = min(i1 + rn, n)
        g[i1:e1] = np.linspace(db(d), 1, e1 - i1)
        env = np.minimum(env, g)
    music *= env[:, None]
    # --- sfx: listed, overlay ticks, synthesised hits, final gong
    sfx = list(mp.SFX)
    for s in segs:
        for e in s["entries"]:
            for o in e.get("ov", []):
                for pre, (f, off, g) in mp.OVERLAY_SFX.items():
                    if o["src"].startswith(pre):
                        sfx.append((f, e["t0"] + o["at"] + off, g))
    for f, at, g in sfx:
        t = A(at)
        if t is None:
            continue
        add_at(fx, load_audio(os.path.join(ROOT, f)) * db(g), t)
    for kind, at, g in getattr(mp, "HITS", []):
        t = A(at)
        if t is not None:
            add_at(fx, synth(kind) * db(g), t)
    if getattr(mp, "GONG", None):
        t = A(mp.GONG["at"])
        if t is not None:
            add_at(music, synth("gong", mp.GONG["dur"], mp.GONG["f"]) * db(mp.GONG["gain"]), t)
    out = clip + music + fx
    if os.environ.get("STEMS"):
        np.save(os.path.join(CACHE, "stems.npy"), np.stack([clip.mean(1), music.mean(1), fx.mean(1)]).astype(np.float32))
    # the end: everything rings out into silence over the last 1.5 s
    k = int(1.2 * SR)
    out[-k:] *= np.linspace(1, 0, k)[:, None] ** 2
    return master(out, verbose)


def true_peak(x):
    from scipy.signal import resample_poly
    return max(np.abs(resample_poly(x[:, ch], 4, 1)).max() for ch in range(2))


def limiter(x, ceiling_db=-1.5, look=0.003, rel=0.03):
    """Peak limiter on a 4x-oversampled peak estimate: the gain curve is the minimum over a window around each
    peak, averaged over `rel` s, so it is never above the needed gain at a peak and moves smoothly."""
    from scipy.signal import resample_poly
    from scipy.ndimage import maximum_filter1d, minimum_filter1d, uniform_filter1d
    c = db(ceiling_db)
    pk = np.zeros(len(x))
    for ch in range(2):
        up = np.abs(resample_poly(x[:, ch], 4, 1))
        up = np.pad(up, (0, max(0, 4 * len(x) - len(up))))[: 4 * len(x)]
        pk = np.maximum(pk, up.reshape(-1, 4).max(1))
    g = np.minimum(1.0, c / (pk + 1e-12))
    if g.min() >= 1.0:
        return x
    L, R = int(look * SR), int(rel * SR)
    g = minimum_filter1d(g, 2 * L + R + 1)
    g = uniform_filter1d(g, R)
    return x * g[:, None]


def master(x, verbose=True):
    import pyloudnorm as pyln
    meter = pyln.Meter(SR)
    for _ in range(3):
        L = meter.integrated_loudness(x)
        x = x * db(-14.0 - L)
        x = limiter(x, -1.5)
    L = meter.integrated_loudness(x)
    tp = 20 * np.log10(true_peak(x) + 1e-12)
    if verbose:
        print(f"mix: {L:.2f} LUFS integrated, true peak {tp:.2f} dBTP", flush=True)
    return x, L, tp


def write_wav(path, x):
    import soundfile as sf
    sf.write(path, np.clip(x, -1, 1).astype(np.float32), SR, subtype="FLOAT")


# --------------------------------------------------------------------------------------------- output


def timeline_json(segs):
    rows = []
    for s in segs:
        for e in s["entries"]:
            rows.append(dict(seg=s["name"], src=e["src"], inp=round(e["inp"], 3), dur=round(e["dur"], 3),
                             t0=round(e["t0"], 3), t1=round(e["t1"], 3), id=e.get("id"),
                             ov=[o["src"] for o in e.get("ov", [])]))
    return rows


def fmt(t):
    return f"{int(t // 60)}:{t % 60:05.2f}"


def encode_final(outs, wav, target, preview):
    """Segments are raw H.264 (Annex B) streams with identical settings: joined byte-for-byte, then timestamped by
    frame count, so no frame can be lost or duplicated at a segment boundary."""
    allv = os.path.join(CACHE, ("preview" if preview else "full") + "_all.264")
    with open(allv, "wb") as w:
        for o in outs:
            with open(o, "rb") as r:
                while True:
                    b = r.read(1 << 24)
                    if not b:
                        break
                    w.write(b)
    vin = ["-framerate", str(FPS), "-f", "h264", "-i", allv]
    nfr = sum(probe_count(o) for o in outs)
    if preview:
        run(["ffmpeg", "-v", "error", "-y", *vin, "-i", wav, "-map", "0:v", "-map", "1:a", "-c:v", "copy",
             "-c:a", "aac", "-b:a", "192k", "-ar", str(SR), "-movflags", "+faststart", target])
        return
    dur = nfr / FPS
    abr = 320e3
    vbr = int((SIZE_LIMIT * 0.965 * 8) / dur - abr - 20e3)
    vbr = min(vbr, 12_000_000)
    print(f"final encode: {nfr} frames, {dur:.2f}s, 2-pass x264 at {vbr / 1e6:.2f} Mb/s video + 320k AAC", flush=True)
    log = os.path.join(CACHE, "x264_2pass")
    common = ["-c:v", "libx264", "-profile:v", "high", "-preset", "slow", "-tune", "animation", "-b:v", str(vbr),
              "-maxrate", str(int(vbr * 2.2)), "-bufsize", str(int(vbr * 4)), "-pix_fmt", "yuv420p", "-r", "60",
              "-g", "120", "-passlogfile", log]
    run(["ffmpeg", "-v", "error", "-y", *vin, *common, "-pass", "1", "-an", "-f", "mp4", "/dev/null"])
    tmp = target + ".part.mp4"
    run(["ffmpeg", "-v", "error", "-y", *vin, "-i", wav, "-map", "0:v", "-map", "1:a", *common, "-pass", "2",
         "-c:a", "aac", "-b:a", "320k", "-ar", str(SR), "-ac", "2", "-movflags", "+faststart", tmp])
    os.replace(tmp, target)
    sz = os.path.getsize(target)
    print(f"wrote {target}: {sz / 1e6:.2f} MB", flush=True)
    if sz >= SIZE_LIMIT:
        print("WARNING: over the 95 MB limit", flush=True)


def probe_count(p):
    r = run(["ffprobe", "-v", "error", "-count_packets", "-select_streams", "v", "-show_entries",
             "stream=nb_read_packets", "-of", "csv=p=0", p])
    return int(r.stdout.decode().strip())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--preview", action="store_true")
    ap.add_argument("--audio-only", action="store_true")
    ap.add_argument("--timeline", action="store_true")
    ap.add_argument("-j", type=int, default=2, help="segments rendered in parallel")
    a = ap.parse_args()
    os.chdir(ROOT)
    edl, mp = load_edl()
    segs = resolve(edl)
    os.makedirs(CACHE, exist_ok=True)
    with open(os.path.join(CACHE, "timeline.json"), "w") as f:
        json.dump(timeline_json(segs), f, indent=1)
    if a.timeline:
        for s in segs:
            print(f"== {s['name']}  {fmt(s['t0'])} - {fmt(s['t1'])}  ({s['t1'] - s['t0']:.2f}s)")
            for e in s["entries"]:
                print(f"   {fmt(e['t0'])}  {e['dur']:5.2f}  {e['src']:34s} in {e['inp']:.2f}  {e.get('id') or ''}")
        print("total", fmt(segs[-1]["t1"]))
        return
    mode = "preview" if a.preview else "full"
    render_gfx(segs)
    x, L, tp = mix(segs, edl, mp)
    wav = os.path.join(CACHE, "mix.wav")
    write_wav(wav, x)
    if a.audio_only:
        return
    outs = render_video(segs, mode, a.j)
    encode_final(outs, wav, PREVIEW if a.preview else FINAL, a.preview)
    print("done:", PREVIEW if a.preview else FINAL, fmt(segs[-1]["t1"]))


if __name__ == "__main__":
    main()
