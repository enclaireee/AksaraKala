#!/usr/bin/env python3
"""Set or add rows in data/text/*.csv and the matching rows in .docs/script.md (a hand tool: script_to_data.py is
destructive for keys that only live in the CSV, so text edits go through here instead).
Usage from Python: patch("dialogue", {"KEY": ("ID text", "EN text")}) """
import csv, io, re, os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _read(p):
    return list(csv.reader(open(p, encoding="utf-8", newline="")))


def _write(p, rows):
    buf = io.StringIO(newline="")
    w = csv.writer(buf, lineterminator="\n")
    w.writerows(rows)
    open(p, "w", encoding="utf-8", newline="").write(buf.getvalue())


def patch(name, kv, after=None):
    """Update existing keys in place; new keys go after `after` (a key) or at the end."""
    p = os.path.join(ROOT, "data/text", name + ".csv")
    rows = _read(p)
    idx = {r[0]: i for i, r in enumerate(rows)}
    pos = idx.get(after, len(rows) - 1) if after else len(rows) - 1
    for k, (i, e) in kv.items():
        if k in idx:
            rows[idx[k]] = [k, i, e]
        else:
            pos += 1
            rows.insert(pos, [k, i, e])
            idx = {r[0]: j for j, r in enumerate(rows)}
    _write(p, rows)


def _find(lines, key):
    pat = re.compile(r"^\|( [^|]*\|)? %s \|" % re.escape(key))
    for n, l in enumerate(lines):
        if pat.match(l):
            return n
    return None


def script(kv, after=None):
    """Same for the markdown table rows `| [n |] KEY | ID | EN |` in .docs/script.md (new keys after `after`'s row,
    copying its leading column)."""
    p = os.path.join(ROOT, ".docs/script.md")
    lines = open(p, encoding="utf-8").read().split("\n")
    for k, (i, e) in kv.items():
        n = _find(lines, k)
        if n is not None:
            cells = [c.strip() for c in lines[n].strip().strip("|").split("|")]
            pre = cells[:-3]
            lines[n] = "| " + " | ".join(pre + [k, i, e]) + " |"
        elif after:
            a = _find(lines, after)
            if a is not None:
                cells = [c.strip() for c in lines[a].strip().strip("|").split("|")]
                pre = cells[:-3]
                lines.insert(a + 1, "| " + " | ".join(pre + [k, i, e]) + " |")
                after = k
    open(p, "w", encoding="utf-8").write("\n".join(lines))
