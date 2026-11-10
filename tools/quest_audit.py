#!/usr/bin/env python3
"""Static audit of quest order, indexing and wiring (.docs/revamp_plan.md 5). There is no Godot in the cloud box, so this
reads the data files directly. Exit 1 when it finds a problem.

Checks
  Q1  step sub_resources are s1..sN in order, the `steps` array lists them in that order, no orphan sub_resource
  Q2  every objective / recap / sub-objective key exists in data/text/quests.csv with both an id and an en text
  Q3  every `on` / `alt` / `all[].on` is a known signal with a known argument somewhere in the game data
  Q4  every marker {zone, id} names a zone in Zones.ZONES and an id that zone's script/scene mentions
  Q5  dialogue `step:<quest>=<n>` conditions point at an existing step index (0 .. N-1) of an existing quest
  Q6  every flag that is READ (dialogue `if`, quest `requires`, lessons `when`) is SET somewhere
  Q7  dialogue entries are not shadowed (an earlier entry whose conditions are a subset always wins first)
  Q8  every dialogue line key and `lesson:` id resolves (key in dialogue.csv or a "@"/"#" cue; lesson in lessons.gd)
  Q9  every memory_done:<id> has a scene (zones/kelir/<id>.tscn) or a gap data file
  Q10 every memory scene has TITLE and an id text, and every MEM_*_HINT with {key}-less text is fine
"""
import csv
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
problems = []


def bad(code, msg):
    problems.append("%s %s" % (code, msg))


def read(p):
    return open(os.path.join(ROOT, p), encoding="utf-8").read()


# ------------------------------------------------------------------------------------------------ load
ZONES = set(re.findall(r'"([a-z_]+)": "res://zones/', read("autoload/zones.gd")))
SIGNALS = {"talked_to", "area_cleared", "area_entered", "zone_entered", "petilasan_activated", "glyph_learned",
           "boss_defeated", "enemy_killed", "item_picked", "clue_examined", "memory_done", "puzzle_solved",
           "trial_completed", "name_written", "spell_cast", "class_chosen"}

text = {}
for f in glob.glob(os.path.join(ROOT, "data/text/*.csv")):
    for r in csv.reader(open(f, encoding="utf-8")):
        if len(r) >= 3:
            text[r[0]] = (r[1], r[2])

quests = {}   # id -> {"steps": [step dict], "requires": [...], "file": path}
for f in sorted(glob.glob(os.path.join(ROOT, "data/quests/*.tres"))):
    s = open(f, encoding="utf-8").read()
    qid = os.path.basename(f)[:-5]
    subs = re.findall(r'\[sub_resource type="Resource" id="(\w+)"\]\n(.*?)(?=\n\[)', s, re.S)
    steps = {}
    for sid, body in subs:
        d = {}
        for line in body.split("\n"):
            m = re.match(r"(\w+) = (.*)$", line)
            if not m or m.group(1) == "script":
                continue
            k, v = m.group(1), m.group(2)
            try:
                d[k] = json.loads(v)
            except ValueError:
                d[k] = v.strip('"')
        steps[sid] = d
    m = re.search(r"steps = Array\[ExtResource\(\"2\"\)\]\(\[(.*?)\]\)", s)
    order = re.findall(r'SubResource\("(\w+)"\)', m.group(1)) if m else []
    req = re.search(r"requires = (\[.*?\])", s)
    quests[qid] = {"order": order, "steps": steps, "requires": json.loads(req.group(1).replace("Array[String](", "")) if req and req.group(1).startswith("[") else [], "file": f}

# every quoted token in code and scene data (excluding quests, text and docs): what "exists" in the game
tokens = {}
for pat in ("zones/*.gd", "zones/kelir/*.tscn", "zones/kelir/*.gd", "zones/*.tscn", "entities/**/*.gd", "entities/**/*.tscn",
            "autoload/*.gd", "data/**/*.tres", "data/*.gd", "ui/*.gd", "spells/*.gd", "components/*.gd"):
    for f in glob.glob(os.path.join(ROOT, pat), recursive=True):
        if "/data/quests/" in f:
            continue
        rel = os.path.relpath(f, ROOT)
        z = os.path.basename(f)[:-3] if rel.startswith("zones/") and f.endswith(".gd") else None
        for t in re.findall(r'"([A-Za-z0-9_:\-\.]+)"', open(f, encoding="utf-8").read()):
            tokens.setdefault(t, set()).add(z or rel)
        for t in re.findall(r'(?:npc_id|clue_id|trigger_id|area_id|item_id|memory_id|id|kind|stake_id|chest_id) = "?([A-Za-z0-9_]+)', open(f, encoding="utf-8").read()):
            tokens.setdefault(t, set()).add(z or rel)
ITEMS = {os.path.basename(f)[:-5] for f in glob.glob(os.path.join(ROOT, "data/items/*.tres"))}
GLYPHS = {os.path.basename(f)[:-5] for f in glob.glob(os.path.join(ROOT, "data/glyphs/*.tres"))}
ENEMIES = {os.path.basename(f)[:-5] for f in glob.glob(os.path.join(ROOT, "data/enemies/*.tres"))}
NPCS = {os.path.basename(f)[:-5] for f in glob.glob(os.path.join(ROOT, "data/dialogue/*.tres"))}

DOCS = "".join(open(f, encoding="utf-8").read() for f in glob.glob(os.path.join(ROOT, ".docs/zones/*.md")))

# ------------------------------------------------------------------------------------------------ Q1-Q4
for qid, q in quests.items():
    ids = list(q["steps"].keys())
    want = ["s%d" % (i + 1) for i in range(len(ids))]
    if ids != want:
        bad("Q1", "%s: sub_resource ids %s are not s1..s%d in order" % (qid, ids[:4] + ["..."], len(ids)))
    if q["order"] != ids:
        bad("Q1", "%s: the steps array order differs from the sub_resource order" % qid)
    for i, sid in enumerate(q["order"]):
        st = q["steps"].get(sid)
        if st is None:
            bad("Q1", "%s step %d: SubResource %s missing" % (qid, i, sid))
            continue
        keys = [st.get("objective", "")] + [st.get("recap", "")]
        for sub in st.get("all", []) or []:
            keys.append(sub.get("objective", ""))
        for k in keys:
            if k and (k not in text or not text[k][0].strip() or not text[k][1].strip()):
                bad("Q2", "%s step %d: text key %s missing or empty" % (qid, i + 1, k))
        ons = []
        if st.get("on"):
            ons.append(st["on"])
        ons += list((st.get("alt") or {}).keys())
        ons += [sub.get("on", "") for sub in (st.get("all") or [])]
        if not ons:
            bad("Q3", "%s step %d (%s): no trigger at all (on, alt and all are empty)" % (qid, i + 1, sid))
        for o in ons:
            if not o:
                continue
            sig, _, arg = o.partition(":")
            if sig not in SIGNALS:
                bad("Q3", "%s step %d: unknown signal '%s'" % (qid, i + 1, o))
                continue
            if arg == "":
                continue
            if arg.endswith("*"):   # a prefix match (Game.matches): some token starts with it
                known = any(t.startswith(arg[:-1]) for t in tokens)
                if known:
                    continue
            known = arg in tokens or arg in ITEMS or arg in GLYPHS or arg in ENEMIES or arg in NPCS or arg in ZONES
            if sig == "memory_done":
                known = os.path.exists(os.path.join(ROOT, "zones/kelir/%s.tscn" % arg)) or arg in tokens
            if sig == "zone_entered":
                known = arg in ZONES
            if sig == "spell_cast" or sig == "glyph_learned":
                known = arg in GLYPHS
            if not known:
                bad("Q3", "%s step %d: '%s' has no source anywhere in the game data" % (qid, i + 1, o))
        markers = [st.get("marker")] + [sub.get("marker") for sub in (st.get("all") or [])]
        for m in markers:
            if not m:
                continue
            z, mid = m.get("zone", ""), m.get("id", "")
            if z not in ZONES:
                bad("Q4", "%s step %d: marker zone '%s' is not in Zones.ZONES" % (qid, i + 1, z))
                continue
            if mid and z in tokens.get(mid, set()) is False:
                pass
            boss_here = os.path.exists(os.path.join(ROOT, "entities/bosses/%s.tscn" % mid)) and ("bosses/%s.tscn" % mid) in read("zones/%s.gd" % z)
            exit_doc = mid.startswith("exit_") and mid in DOCS
            if mid and not (boss_here or exit_doc or z in tokens.get(mid, set()) or mid in NPCS or mid in ZONES or os.path.exists(os.path.join(ROOT, "zones/kelir/%s.tscn" % mid))):
                bad("Q4", "%s step %d: marker id '%s' is not mentioned by zone %s" % (qid, i + 1, mid, z))

# ------------------------------------------------------------------------------------------------ dialogue
sets = set()
reads = {}
for qid, q in quests.items():
    for st in q["steps"].values():
        if st.get("set_flag"):
            sets.add(st["set_flag"])
        for sub in st.get("all", []) or []:
            if sub.get("set_flag"):
                sets.add(sub["set_flag"])
        for v in (st.get("alt") or {}).values():
            sets.add(v)
    for r in q["requires"]:
        reads.setdefault(r, []).append("%s requires" % qid)
code_sets = set()
for pat in ("**/*.gd", "data/**/*.tres", "zones/**/*.tscn", ".docs/*.py"):
    for f in glob.glob(os.path.join(ROOT, pat), recursive=True):
        s = open(f, encoding="utf-8").read()
        for m in re.findall(r'set_flag\("([^"]+)"', s) + re.findall(r'"flag:([A-Za-z0-9_:]+)"', s) + re.findall(r'"set_flag": "([^"]+)"', s):
            code_sets.add(m)
        for m in re.findall(r'set_flag\("([^"]+)" ?\+', s):
            code_sets.add(m + "*")
        for m in re.findall(r'(?:flag|do_flag|set_flag)\s*=\s*"([^"]+)"', s):
            code_sets.add(m)
        for m in re.findall(r'flag = "([^"]+)"', s):
            code_sets.add(m)
sets |= code_sets

dialogs = {}
for f in sorted(glob.glob(os.path.join(ROOT, "data/dialogue/*.tres"))):
    name = os.path.basename(f)[:-5]
    entries = []
    for n, line in enumerate(open(f, encoding="utf-8").read().split("\n")):
        t = line.strip().rstrip(",")
        if t.startswith("{") and '"lines"' in t:
            try:
                entries.append((n + 1, json.loads(t)))
            except ValueError:
                bad("Q8", "%s line %d: cannot parse the entry" % (name, n + 1))
    dialogs[name] = entries

lessons = set(re.findall(r'^\t"(\w+)": \{', read("data/lessons.gd"), re.M))
for name, entries in dialogs.items():
    seen_if = []
    for ln, e in entries:
        conds = e.get("if", [])
        for c in conds:
            neg = c.startswith("!")
            c2 = c[1:] if neg else c
            kind, _, arg = c2.partition(":")
            if kind == "flag":
                reads.setdefault(arg, []).append("%s.tres:%d" % (name, ln))
            elif kind == "step":
                qn, _, idx = arg.partition("=")
                if qn not in quests:
                    bad("Q5", "%s.tres:%d: step condition names unknown quest '%s'" % (name, ln, qn))
                elif not idx.isdigit() or int(idx) >= len(quests[qn]["order"]):
                    bad("Q5", "%s.tres:%d: %s has %d steps, condition wants index %s" % (name, ln, qn, len(quests[qn]["order"]), idx))
            elif kind == "glyph" and arg not in GLYPHS:
                bad("Q5", "%s.tres:%d: unknown glyph '%s'" % (name, ln, arg))
            elif kind not in ("flag", "step", "glyph", "item", "quest", "zone"):
                bad("Q5", "%s.tres:%d: unknown condition '%s'" % (name, ln, c))
        # Q7: shadowing (topic entries are reached from hubs only)
        if "topic" not in e:
            for pln, pc in seen_if:
                if set(pc).issubset(set(conds)) and not any(c.startswith("!") and c[1:] in pc for c in conds):
                    bad("Q7", "%s.tres:%d is shadowed by the entry at line %d (its conditions %s are a subset)" % (name, ln, pln, pc))
                    break
            seen_if.append((ln, conds))
        for k in e.get("lines", []):
            if k.startswith("@") or k.startswith("#"):
                if k.startswith("@") and len(k) > 1 and k[1:] not in text:
                    bad("Q8", "%s.tres:%d: speaker key %s missing" % (name, ln, k))
                continue
            if k not in text:
                bad("Q8", "%s.tres:%d: line key %s missing from dialogue.csv" % (name, ln, k))
        for d in e.get("do", []):
            kind, _, arg = d.partition(":")
            if kind == "lesson" and arg not in lessons:
                bad("Q8", "%s.tres:%d: unknown lesson '%s'" % (name, ln, arg))
            if kind == "flag":
                sets.add(arg)
            if kind == "learn" and arg not in GLYPHS:
                bad("Q8", "%s.tres:%d: learn:%s is not a glyph" % (name, ln, arg))
        for ch in e.get("choices", []):
            for d in ch.get("do", []):
                if d.startswith("flag:"):
                    sets.add(d[5:])

for flag, where in sorted(reads.items()):
    base = flag
    if flag in sets or any(s.endswith("*") and flag.startswith(s[:-1]) for s in sets):
        continue
    if flag.startswith(("tut_", "memory_", "clue_", "chest:", "post:", "gap_", "beat_", "seen_name_", "shortcut:", "sc:", "boss_", "kabut_")):
        continue
    bad("Q6", "flag '%s' is read (%s) but nothing sets it" % (base, ", ".join(where[:2])))

# Q9/Q10: memories
for f in sorted(glob.glob(os.path.join(ROOT, "zones/kelir/*.tscn"))):
    mid = os.path.basename(f)[:-5]
    if mid in ("gap", "memory_spot", "memory_threat"):
        continue
    tid = mid.upper()
    if mid.startswith("lc"):   # the Laras chapters are LC_<n>_TITLE and LC<n>_1.. (KelirMemory.resolve / _spread_chapter_lines)
        n = mid[2:]
        if "LC_%s_TITLE" % n not in text or "LC%s_1" % n not in text or "LC%s_4" % n not in text:
            bad("Q10", "chapter %s lacks LC_%s_TITLE or enough LC%s_<i> lines" % (mid, n, n))
        continue
    if "MEM_%s_TITLE" % tid not in text:
        bad("Q10", "memory %s has no MEM_%s_TITLE" % (mid, tid))
    if "MEM_%s_IN" % tid not in text:
        bad("Q10", "memory %s has no opening line MEM_%s_IN" % (mid, tid))
    if "MEM_%s_OUT" % tid not in text:
        bad("Q10", "memory %s has no closing line MEM_%s_OUT" % (mid, tid))
# Q11: every spot line_key in a memory scene resolves to text (directly, or without its MEM_ prefix for the LC chapters)
for f in sorted(glob.glob(os.path.join(ROOT, "zones/kelir/*.tscn"))):
    for k in re.findall(r'line_key = "([A-Z0-9_]+)"', open(f, encoding="utf-8").read()):
        if k not in text and k.replace("MEM_", "", 1) not in text:
            bad("Q11", "%s: spot line_key %s has no text" % (os.path.basename(f), k))
for qid, q in quests.items():
    for st in q["steps"].values():
        for o in [st.get("on", "")] + [s.get("on", "") for s in st.get("all", []) or []]:
            if o.startswith("memory_done:"):
                mid = o.split(":", 1)[1]
                if not os.path.exists(os.path.join(ROOT, "zones/kelir/%s.tscn" % mid)) and not glob.glob(os.path.join(ROOT, "data/memories/*%s*" % mid.replace("gap_", ""))):
                    bad("Q9", "%s: memory_done:%s has no scene" % (qid, mid))

# Q12: the player can walk from each step's zone to the next step's zone (Zones.ADJ is the same graph the objective arrow uses)
adj = {}
blk = re.search(r"const ADJ := \{(.*?)\n\}", read("autoload/zones.gd"), re.S)
for m in re.finditer(r'"(\w+)": \[([^\]]*)\]', blk.group(1)):
    adj[m.group(1)] = re.findall(r'"(\w+)"', m.group(2))


def reach(a, b):
    seen, todo = {a}, [a]
    while todo:
        z = todo.pop()
        if z == b:
            return True
        for n in adj.get(z, []):
            if n not in seen:
                seen.add(n)
                todo.append(n)
    return False


for qid, q in quests.items():
    prev = None
    for i, sid in enumerate(q["order"]):
        st = q["steps"][sid]
        zs = [(st.get("marker") or {}).get("zone")] + [((x.get("marker") or {}).get("zone")) for x in (st.get("all") or [])]
        zs = [z for z in zs if z in ZONES]
        if not zs:
            continue
        for z in zs:
            if prev and prev != z and z in adj and prev in adj and not reach(prev, z):
                bad("Q12", "%s step %d: no walkable route from the previous step's zone %s to %s" % (qid, i + 1, prev, z))
        prev = zs[-1]

for p in problems:
    print(p)
print("%d problem(s); %d quests, %d dialogue files, %d text keys" % (len(problems), len(quests), len(dialogs), len(text)))
sys.exit(1 if problems else 0)
