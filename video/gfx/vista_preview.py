import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import render_all
from vistalib import save_preview
for n in sys.argv[1:]:
    fn, d, _ = render_all.build(n)
    save_preview(n, fn)
