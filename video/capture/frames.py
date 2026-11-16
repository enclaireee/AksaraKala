#!/usr/bin/env python3
"""Extracts evenly spaced frames from a shot mp4 into video/out/preview/ (and a contact sheet).
   python3 video/capture/frames.py video/out/raw/<shot>.mp4 [count=6]"""
import subprocess, sys, os, json
from PIL import Image
src = sys.argv[1]; n = int(sys.argv[2]) if len(sys.argv) > 2 else 6
name = os.path.splitext(os.path.basename(src))[0]
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "out", "preview")
os.makedirs(out, exist_ok=True)
info = json.loads(subprocess.check_output(["ffprobe", "-v", "error", "-select_streams", "v:0", "-count_packets",
    "-show_entries", "stream=nb_read_packets,width,height", "-of", "json", src]))["streams"][0]
total = int(info["nb_read_packets"])
paths = []
for i in range(n):
    f = int((i + 0.5) * total / n)
    p = os.path.join(out, "%s_%02d_f%04d.png" % (name, i, f))
    subprocess.check_call(["ffmpeg", "-v", "error", "-y", "-i", src, "-vf", "select=eq(n\\,%d)" % f, "-frames:v", "1", p])
    paths.append(p)
ims = [Image.open(p) for p in paths]
w, h = ims[0].size
cols = 2 if n > 3 else n
rows = (n + cols - 1) // cols
sheet = Image.new("RGB", (cols * w // 2, rows * h // 2))
for i, im in enumerate(ims):
    sheet.paste(im.resize((w // 2, h // 2), Image.NEAREST), ((i % cols) * w // 2, (i // cols) * h // 2))
sp = os.path.join(out, "%s_sheet.png" % name)
sheet.save(sp)
print("\n".join(paths + [sp]))
