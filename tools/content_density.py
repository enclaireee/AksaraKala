#!/usr/bin/env python3
"""Area depth check (world.md "Area depth floor"). Reads zones/*.gd and data/dialogue/*.tres.

    python3 tools/content_density.py            # report all regions, fail on Acts IV-VI (tt, sk, gk)
    python3 tools/content_density.py --all      # fail on every region

Exits 1 and lists the areas below the floor. Prints nothing else unless -v.
"""
import glob, re, sys

ORDER = ["desa", "ts", "kg", "mt", "tt", "sk", "gk"]
ENFORCED = {"tt", "sk", "gk"}
ARENAS = {"gk_ruang_kala"}   # boss-only rooms, exempt
TOWNS = {"desa_purwa", "ts_kampung", "kg_alun", "kg_pasar", "mt_pasar", "sk_nelayan"}   # zones/zone.gd TOWNS: safe hubs, no fight needed
FLOOR = {"people": 2, "lines": 4, "clues": 2, "action": 1, "feature": 10.0}   # TUNE
# ponytail: name heuristic for "this NPC is an object"; add a flag to DialogueData if it misfires.
OBJECT = re.compile(r"stone|beacon|tree|marker|altar|barrier|post|frame|mirror|root|base|arca|lamp|bell|chime|jetty|statue")


def dialogue():
    out = {}
    for f in glob.glob("data/dialogue/*.tres"):
        s = open(f).read()
        nid = re.search(r'npc_id = "(\w+)"', s)
        if not nid:
            continue
        name = re.search(r'name_key = "(\w*)"', s)
        obj = (name is None or name.group(1) == "") or bool(OBJECT.search(nid.group(1)))
        keys = {k for arr in re.findall(r'"lines": \[(.*?)\]', s) for k in re.findall(r'"([A-Z][A-Z0-9_]+)"', arr)}
        out[nid.group(1)] = (obj, len(keys))   # every spoken line key; "@NPC_X" speaker switches don't match
    return out


def area(path, dlg):
    s = open(path).read()
    m = re.search(r"const MAP := \[(.*?)\n\]", s, re.S)
    if not m:
        return None
    rows = re.findall(r'"([^"]*)"', m.group(1))
    spot_keys = set(re.findall(r'^\s*"(.)": \{', s, re.M))
    inner = [r[1:-1] for r in rows[1:-1]]   # the outer ring is the frame, not layout
    cells = sum(len(r) for r in inner)
    feat = sum(1 for r in inner for c in r if c not in ".,_" and c not in spot_keys)
    scenes = re.findall(r'"scene": "res://([^"]+)\.tscn"', s)
    base = [x.split("/")[-1] for x in scenes]
    people = [n for n in re.findall(r'"npc_id": "(\w+)"', s) if not dlg.get(n, (False, 0))[0]]
    return {
        "people": sum(1 for n in set(people) if dlg.get(n, (False, 0))[1] >= FLOOR["lines"]),
        "clues": base.count("clue") + base.count("pickup"),
        "action": base.count("encounter") + base.count("rehearsal") + sum("puzzle" in x for x in re.findall(r'"\w+_id": "(\w+)"', s)),
        "feature": 100.0 * feat / max(cells, 1),
    }


def main():
    enforced = set(ORDER) if "--all" in sys.argv else ENFORCED
    dlg = dialogue()
    fails = []
    for f in sorted(glob.glob("zones/*.gd")):
        z = f[6:-3]
        reg = z.split("_")[0]
        if reg not in ORDER or z.endswith("_base") or z in ARENAS:
            continue
        a = area(f, dlg)
        if a is None:
            continue
        low = [k for k, v in FLOOR.items() if k != "lines" and a[k] < v and not (k == "action" and z in TOWNS)]
        if "-v" in sys.argv:
            print("%-14s people %d  clues %d  action %d  feature %4.1f%%  %s" % (z, a["people"], a["clues"], a["action"], a["feature"], " ".join(low)))
        if low and reg in enforced:
            fails.append("%s: %s" % (z, ", ".join("%s %s < %s" % (k, round(a[k], 1), FLOOR[k]) for k in low)))
    for line in fails:
        print(line)
    return 1 if fails else 0


def _selfcheck():
    assert OBJECT.search("tidal_beacon_1") and OBJECT.search("whisper_tree_2") and not OBJECT.search("kidul_sari")


if __name__ == "__main__":
    _selfcheck()
    sys.exit(main())
