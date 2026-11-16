#!/usr/bin/env python3
"""python3 s3_sheet.py out.png file1.mp4 [file2.mp4 ...]  -> rows of 3 frames (15%, 50%, 85%), labelled, 1920 wide."""
import subprocess, sys, os, json
from PIL import Image, ImageDraw
out = sys.argv[1]; files = sys.argv[2:]
rows = []
for f in files:
    info = json.loads(subprocess.check_output(["ffprobe","-v","error","-select_streams","v:0","-count_packets","-show_entries","stream=nb_read_packets","-of","json",f]))["streams"][0]
    n = int(info["nb_read_packets"]); ims = []
    for q in (0.12, 0.5, 0.88):
        p = "/tmp/_s3f.png"
        subprocess.check_call(["ffmpeg","-v","error","-y","-i",f,"-vf","select=eq(n\\,%d)"%int(q*n),"-frames:v","1",p])
        ims.append(Image.open(p).convert("RGB").resize((640,360), Image.NEAREST))
    row = Image.new("RGB",(1920,360))
    for i,im in enumerate(ims): row.paste(im,(i*640,0))
    ImageDraw.Draw(row).rectangle((0,0,260,12),fill=(0,0,0))
    ImageDraw.Draw(row).text((3,0),os.path.basename(f),fill=(255,255,0))
    rows.append(row)
sheet = Image.new("RGB",(1920,360*len(rows)))
for i,r in enumerate(rows): sheet.paste(r,(0,360*i))
sheet.save(out); print(out)
