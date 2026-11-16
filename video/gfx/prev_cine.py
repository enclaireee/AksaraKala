import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
import pxkit as K
from scenes import SCENES
import scenes_cine
fn=SCENES["cine_taken"][0](9.0)
ts=[float(x) for x in sys.argv[1:]] or [0.5,1.8,3.0,3.9,4.52,5.4,6.0,7.0,7.8,8.9]
os.makedirs(K.PREVIEW,exist_ok=True)
for t in ts:
    K.scaled(fn(t).convert("RGB"),2).save(f"{K.PREVIEW}/_ct_{t:.2f}.png")
