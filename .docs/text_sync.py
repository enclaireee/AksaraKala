#!/usr/bin/env python3
"""Pull the shipped text back into `.docs/script.md`. Rerunnable. Run from anywhere.

`script_to_data.py` pushes script.md -> CSVs for **new** keys. When a key already exists in a CSV, the CSV is
what the game ships, so it is the one that wins (script_to_data.py keeps it too). This script does the same
thing in the other direction: for every key the two share, script.md's id/en cells become the CSV's cells.
Nothing else in the table is touched (the `#`, `Entry`, `do` and `(keep)` columns stay as they are), and rows
the CSVs do not have (speaker markers `@NPC_...`, beat directives `#wait:...`, `BOSS_` prose) are left alone.

Run it after any content pass that edited `data/text/*.csv` directly, so the doc and the game say the same thing:

    python3 .docs/text_sync.py          # apply
    python3 .docs/text_sync.py --dry    # report only
"""
import csv, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / ".docs/script.md"
CSVS = {n: ROOT / f"data/text/{n}.csv" for n in ("dialogue", "quests", "codex")}
dry = "--dry" in sys.argv


def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def fmt(cs):
    return "| " + " | ".join(cs) + " |"


# ---- script.md: line -> (header, cells) for every table row with a Key column ----
lines = SCRIPT.read_text(encoding="utf-8").split("\n")
rows = []   # (index, header, cells)
hdr = None
for i, line in enumerate(lines):
    if line.startswith("#"):
        hdr = None
        continue
    if not line.startswith("|"):
        continue
    c = cells(line)
    if c[0] in ("Key", "Id") or c[0].startswith("Entry"):
        hdr = [x.lower() for x in c]
        continue
    if not hdr or len(c) != len(hdr) or set(c[0]) <= set("-: "):
        continue
    rows.append((i, hdr, c))

# ---- the shipped CSVs ----
text = {}   # key -> (id, en)
where = {}
for name, p in CSVS.items():
    for raw in p.read_text(encoding="utf-8").split("\n")[1:]:
        if not raw.strip():
            continue
        k, i, e = next(csv.reader([raw]))
        text[k] = (i, e)
        where[k] = name

# ---- pull ----
changed, seen = [], set()
for idx, hdr, c in rows:
    if "key" not in hdr or "id" not in hdr or "en" not in hdr:
        continue
    r = dict(zip(hdr, c))
    k = re.sub(r"\s*\(.*\)$", "", r["key"])
    if k not in text:
        continue
    seen.add(k)
    i, e = text[k]
    if k == "Q_MQ4_TITLE":
        e = re.sub(r"\s*\(steps [^)]*\)$", "", e)
    if (r["id"], r["en"]) == (i, e):
        continue
    r["id"], r["en"] = i, e
    lines[idx] = fmt([r[h] for h in hdr])
    changed.append(k)

only_csv = [k for k in text if k not in seen]

if not dry:
    SCRIPT.write_text("\n".join(lines), encoding="utf-8")

print(f"script.md rows pulled from csv: {len(changed)}{' (dry)' if dry else ''}")
for k in changed[:40]:
    print("  updated", k, "(", where[k], ")")
if len(changed) > 40:
    print(f"  ... {len(changed) - 40} more")
print(f"keys only in the cs vs (no script.md row): {len(only_csv)}")
for k in only_csv[:20]:
    print("  csv-only", k, "(", where[k], ")")
if len(only_csv) > 20:
    print(f"  ... {len(only_csv) - 20} more")
