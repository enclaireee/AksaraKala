#!/usr/bin/env python3
"""Make data/text/{dialogue,quests,codex}.csv and data/dialogue/beats.tres match .docs/script.md. Rerunnable.
NPC and camp-talk .tres files are NOT written here. Run from anywhere."""
import csv, io, json, re, subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = (ROOT / ".docs/script.md").read_text(encoding="utf-8")
CSVS = {n: ROOT / f"data/text/{n}.csv" for n in ("dialogue", "quests", "codex")}
BEATS = ROOT / "data/dialogue/beats.tres"
KEY = re.compile(r"^[A-Z][A-Z0-9_]*$")
report = {"unreadable": [], "skipped": [], "conflict": []}


def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def codes(s):
    return re.findall(r"`([^`]+)`", s)


# ---- parse script.md: sections -> (title, [(header, row-dict)]) ----
sections = []   # (heading, [rows]) ; row = dict by lower-cased header, plus "_n" line number
head, hdr = None, None
for n, line in enumerate(SCRIPT.splitlines(), 1):
    if line.startswith("#"):
        head, hdr = line, None
        sections.append((head, []))
    elif line.startswith("|") and head:
        c = cells(line)
        if c[0] in ("Key", "Id") or c[0].startswith("Entry"):
            hdr = [x.lower() for x in c]
        elif hdr and not set(c[0]) <= set("-: "):
            if len(c) != len(hdr):
                report["unreadable"].append(f"line {n}: {line[:60]}")
                continue
            r = dict(zip(hdr, c)); r["_n"] = n
            sections[-1][1].append(r)

# ---- harvest keys: key -> (id, en) ----
texts = {}
def put(k, i, e, n):
    if k in texts and texts[k] != (i, e):
        report["conflict"].append(f"{k} (line {n})")
    texts[k] = (i, e)

VERIFY = re.compile(r"\s*\(\*\*VERIFY\*\*\)|\*\*VERIFY\*\*: ?|\*\*VERIFY\*\*")
for heading, rows in sections:
    if heading.startswith("## 13"):
        for idx, r in enumerate(rows):
            cid = r["id"].upper()
            te, ti = [x.strip() for x in r["title en / id"].split(" / ", 1)]
            clean = lambda s: VERIFY.sub(lambda m: "(" if m.group().endswith(": ") else "", s) if "**VERIFY**: " in s else VERIFY.sub("", s)
            put(f"CODEX_{cid}_TITLE", ti, te, r["_n"])
            put(f"CODEX_{cid}_BODY", clean(r["body id"]), clean(r["body en"]), r["_n"])
            if r["weak en / id"] not in ("—", ""):
                we, wi = [x.strip() for x in r["weak en / id"].split(" / ", 1)]
                put(f"CODEX_{cid}_WEAK", wi, we, r["_n"])
            tres = ROOT / f"data/codex/{r['id']}.tres"
            if not tres.exists():
                cat = "enemy" if idx < 6 else "legend"
                tres.write_text(
                    '[gd_resource type="Resource" script_class="CodexEntry" load_steps=2 format=3]\n\n'
                    '[ext_resource type="Script" path="res://data/codex_entry.gd" id="1"]\n\n'
                    f'[resource]\nscript = ExtResource("1")\nid = "{r["id"]}"\ncategory = "{cat}"\nsource = "{r["src"]}"\n',
                    encoding="utf-8",
                )
        continue
    for r in rows:
        raw_k = r.get("key", "")
        if "(keep)" in raw_k:
            continue
        k = re.sub(r"\s*\(.*\)$", "", raw_k)
        if not KEY.match(k) or "id" not in r or "en" not in r:
            continue
        i, e = r["id"], r["en"]
        if not i or not e or i == "(same as above)":
            if k not in texts and i != "(same as above)":
                report["unreadable"].append(f"line {r['_n']}: {k} has no text")
            continue
        if k == "EPILOGUE_7":
            report["skipped"].append("EPILOGUE_7 (prose, not literal text)")
            continue
        if k.startswith(("BOSS_",)):
            continue
        if k == "Q_MQ4_TITLE":
            e = re.sub(r"\s*\(steps [^)]*\)$", "", e)
        put(k, i, e, r["_n"])
# boss-name keys live in prose and ui.csv: not ours.

# ---- dropped keys (section 14) ----
dropped = set()
sec14 = SCRIPT.split("## 14. Lines dropped")[1]
for m in re.finditer(r"^- `([A-Z_]+)`: (.+)$", sec14, re.M):
    for s in m.group(2).split(","):
        dropped.add(f"{m.group(1)}_{s.strip()}")
dropped |= {f"PROLOGUE_{n}" for n in range(6, 14)}
dropped |= {f"NPC_KIDUL_ALTAR_{s}" for s in ("1", "2", "3", "H1")}
dropped |= {f"DLG_SUNDA_WEAVER_{n}" for n in (5, 6, 7, 11)}
dropped_prefix = ("NPC_KIDUL_JURUKUNCI_",)

# ---- CSV upsert (raw lines kept for unchanged rows) ----
def parse_csv(path):
    recs = []   # [key, raw_line, id, en]
    lines = path.read_text(encoding="utf-8").split("\n")
    assert lines[-1] == ""
    for l in lines[1:-1]:
        row = next(csv.reader([l]))
        assert len(row) == 3, (path, l[:60])
        recs.append([row[0], l, row[1], row[2]])
    return lines[0], recs

def fmt(row):
    o = io.StringIO(); csv.writer(o, lineterminator="").writerow(row); return o.getvalue()

files = {n: parse_csv(p) for n, p in CSVS.items()}
where = {r[0]: n for n, (_, recs) in files.items() for r in recs}
other = {}
for p in (ROOT / "data/text").glob("*.csv"):
    if p.stem not in CSVS:
        for l in p.read_text(encoding="utf-8").split("\n")[1:]:
            other[l.split(",", 1)[0]] = p.name
added, updated = [], []
for k, (i, e) in texts.items():
    if k in other:
        report["skipped"].append(f"{k} lives in {other[k]}")
        continue
    n = where.get(k) or ("quests" if k.startswith("Q_") else "codex" if k.startswith("CODEX_") else "dialogue")
    recs = files[n][1]
    for r in recs:
        if r[0] == k:
            if (r[2], r[3]) != (i, e):
                r[1:] = [fmt([k, i, e]), i, e]; updated.append(k)
            break
    else:
        recs.append([k, fmt([k, i, e]), i, e]); added.append(k)
        where[k] = n

def referenced(k):
    out = subprocess.run(["grep", "-rlw", "--include=*.gd", "--include=*.tres", "--include=*.tscn", "--include=*.cfg", "-e", k,
                          *[str(ROOT / d) for d in ("data", "entities", "ui", "zones", "autoload")]],
                         capture_output=True, text=True).stdout.split()
    # a key's own beat/dialogue entries are rewritten by this script: beats.tres is checked after rewrite
    return [Path(f).relative_to(ROOT) for f in out]

deleted, still = [], []
def drop_pass():
    for n, (_, recs) in files.items():
        for r in list(recs):
            k = r[0]
            if k in texts or not (k in dropped or k.startswith(dropped_prefix)):
                continue
            refs = referenced(k)
            if refs:
                still.append(f"{k} ({refs[0]})")
            else:
                recs.remove(r); deleted.append(k)

# ---- beats.tres ----
def build_beats():
    beats = []   # (id, entry)
    for heading, rows in sections:
        m = re.match(r"### Beat `(\w+)` \((.*?)\)", heading)
        if not m:
            continue
        bid, paren = m.groups()
        cond, _, do = paren.partition("; do ")
        cond = re.sub(r"area `(\w+)`", r"`flag:\1`", cond.split(";")[0])
        do = do.split(";")[0]
        ifs = codes(cond)
        dos = codes(do)
        if not any(c.startswith("!flag:beat_") for c in ifs):
            ifs.insert(0, f"!flag:beat_{bid}")
        if not any(c.startswith("flag:beat_") for c in dos):
            dos.insert(0, f"flag:beat_{bid}")
        e = {"if": ifs, "lines": [], "do": dos}
        choices = []
        for r in rows:
            if "do" in r:
                choices.append({"text": r["key"], "do": codes(r["do"])})
            elif r["key"].startswith("@"):
                e["lines"].append(r["key"])
            else:
                e["lines"].append(r["key"])
        if choices:
            e["choices"] = choices
        beats.append((bid, e))
    # `mouth`: same keys as mouth_freed up to the Deserter row
    d = dict(beats)
    if "mouth" in d and not d["mouth"]["lines"]:
        src = d["mouth_freed"]["lines"]
        d["mouth"]["lines"] = src[: src.index("@NPC_FACELESS_DESERTER_NAME")]
    return beats

text = BEATS.read_text(encoding="utf-8")
pre, body = text.split("entries = Array[Dictionary]([\n", 1)
body = body.rsplit("\n])", 1)[0]
old = json.loads("[" + body + "]")
new = build_beats()
ids = {b for b, _ in new} | {"offering"}
new_lines = {tuple(e["lines"]) for _, e in new}
anchor_after, anchor = {}, None
extras = []
for e in old:
    m = re.match(r"flag:beat_(\w+)", (e.get("do") or [""])[0])
    if m and m.group(1) in ids:
        anchor = "offering_song" if m.group(1) == "offering" else m.group(1)
    elif tuple(e.get("lines", [])) not in new_lines:
        anchor_after.setdefault(anchor, []).append(e); extras.append(e)
out = list(anchor_after.get(None, []))
for b, e in new:
    out.append(e)
    out += anchor_after.get(b, [])
dump = lambda e: json.dumps(e, ensure_ascii=False)
BEATS.write_text(pre + "entries = Array[Dictionary]([\n\t" + ",\n\t".join(dump(e) for e in out) + "\n])\n", encoding="utf-8")

drop_pass()
for n, p in CSVS.items():
    h, recs = files[n]
    p.write_text("\n".join([h] + [r[1] for r in recs]) + "\n", encoding="utf-8")

print(f"keys added {len(added)}, updated {len(updated)}, deleted {len(deleted)}, still-referenced {len(still)}; beats written {len(new)}, extras kept {len(extras)}")
for s in sorted(still): print("still referenced:", s)
for k, v in report.items():
    for x in v: print(f"{k}: {x}")
