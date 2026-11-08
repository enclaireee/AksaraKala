"""Generate zones/kelir/<id>.tscn per "### Memory" section of the zone docs (architecture.md 9b).
Usage: python3 .docs/gen_memories.py .docs/zones/<region>.md [more.md ...] [--out DIR] [--check]
Format (a): fenced ASCII map + legend table. Format (b): no map, a `Layout:` bullet with coordinates.
Gap memories (kind gap) are skipped. zones/kelir/<id>.gd, when it exists, is the root script (extends KelirMemory). Exit 1 if a section lacks a scene path or Kind."""
import re, sys, os, struct, base64
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/"
TILE = 16
TILE_IDX = {"#": 4, "~": 5}   # atlas order of zones/tiles.tres ".,t_#~br"; everything else is lit floor "_" (3)
TILE_ONLY = set("#_.,~")      # legend chars that are terrain, not spots
ORDER_WORDS = {"first": 1, "second": 2, "third": 3, "fourth": 4, "fifth": 5, "sixth": 6,
               "1st": 1, "2nd": 2, "3rd": 3, "4th": 4, "5th": 5, "6th": 6}


def role_of(what, notes="", kind=""):
    """Keyword table (ponytail: first match wins; What decides, Notes only for goal / patrol script hints)."""
    w, n = re.sub(r"\([^)]*\)", "", what.lower().replace("`", "")), notes.lower()
    if re.match(r"\W*stand", w) or "stand-in" in w:
        return "stand"
    if "checkpoint" in w or "safe patch" in w:
        return "checkpoint"
    if re.search(r"\bgoal\b|ends here", n):
        return "goal"
    if re.search(r"\bhide\b|hiding", what.lower() + " " + n):
        return "hide"
    if "`interact`" in n:
        return "interact"   # Notes naming the action win over a "lamp"/"fire" in What (K0 lamp stands)
    if re.search(r"decor|walkable|\bfollows\b|\bnpc\b|does not move|do not react|\bclosed\b|\bnarrator\b", w + " " + n):
        return "prop"   # shown, not counted: a plain marker the art pass dresses
    if "faceless_patrol" in n or re.search(r"patrol|faceless|guard", w):
        r = "patrol"
    elif re.search(r"shadow|lamp|fire", w):
        r = "threat"
    elif re.search(r"narrat|voice|trigger|stops|when you pass|lit by", w):
        return "narrate"
    elif re.search(r"goal|exit|door|gate", w):
        return "goal"
    else:
        r = "interact"
    return "prop" if kind == "walk" else r   # walk memories have no fail state: a threat there is only shown


def order_of(what, ch):
    w = re.sub(r"\([^)]*\)", "", what.lower())
    for k, v in ORDER_WORDS.items():
        if re.search(r"\b%s\b" % k, w):
            return v
    if ch.isdigit():
        return int(ch)
    w_clean = re.sub(r"\b\d+\s*(?:tiles?|px|s|m|sec|seconds?|steps?)\b", "", w)
    m = re.search(r"\b\d\b", w_clean)
    if m:
        return int(m.group())
    return -1


def cells(txt):
    return [(int(a), int(b)) for a, b in re.findall(r"\((\d+),\s*(\d+)\)", txt)]


def legend_tokens(col):
    """Chars named in the first legend column: `S`, `1 2 3`, `1-6`, `1`-`3`, `s` (3,14), `t1`."""
    col = col.strip()
    m = re.match(r"^`(\w)`-`(\w)`$|^`(\w)-(\w)`$", col)
    if m:
        a, b = [x for x in m.groups() if x]
        return [chr(c) for c in range(ord(a), ord(b) + 1)]
    out = []
    for t in re.findall(r"`([^`]+)`", col):
        out += t.split() if re.fullmatch(r"\w( \w)+", t) else [t]
    return out


def parse(path):
    txt = open(path).read()
    region = os.path.basename(path)[:-3]
    for m in re.finditer(r"^(?:### Memory|## Kelir memory K\d).*?(?=^#{2,3} \S|\Z)", txt, re.S | re.M):
        sec = m.group(0)
        head = sec.split("\n")[0]
        sc = re.search(r"zones/kelir/(\w+)\.tscn", sec)
        kd = re.search(r"[Kk]ind `(\w+)", sec)
        yield {"region": region, "head": head, "id": sc and sc.group(1), "kind": kd and kd.group(1), "sec": sec}


def build(mem, warn):
    sec, mid, kind = mem["sec"], mem["id"], mem["kind"]
    own = os.path.exists(ROOT + "zones/kelir/%s.gd" % mid)   # a root script of its own (K0, K7) draws what the legend cannot place
    if own:
        warn = lambda *_: None
    legend, grid = {}, None
    mp = re.search(r"```\n(.*?)\n```", sec, re.S)
    rows = mp.group(1).split("\n") if mp else None
    if rows:
        w, h = len(rows[0]), len(rows)
        if any(len(r) != w for r in rows):
            print("%s:%s map rows differ in width" % (mem["region"], mid))
    else:
        sz = re.search(r"Size (\d+)\s*x\s*(\d+)", sec) or re.search(r"(\d+)\s*x\s*(\d+)", sec)
        w, h = int(sz.group(1)), int(sz.group(2))
        rows = ["#" * w] + ["#" + "_" * (w - 2) + "#" for _ in range(h - 2)] + ["#" * w]
    rows = [list(r) for r in rows]
    items = []   # (role, (x,y), what, notes, ch)

    def put(ch, what, notes, pos):
        items.append((role_of(what, notes, kind), pos, what, notes, ch))

    if mp and "| " in sec:
        for ln in sec.split("\n"):
            if not ln.startswith("| ") or ln.startswith("| ---") or re.match(r"\| (Char|Marker|gap_id)", ln):
                continue
            c = [x.strip() for x in ln.strip().strip("|").split(" | ")]
            if len(c) < 2:
                continue
            what, notes = c[1], c[2] if len(c) > 2 else ""
            toks = legend_tokens(c[0])
            if not toks:
                warn("%s:%s char '%s' what=\"%s\"" % (mem["region"], mid, c[0], what))
                continue
            for t in toks:
                if len(t) == 1 and t in TILE_ONLY:
                    continue
                pos = [(x, y) for y, r in enumerate(rows) for x, ch in enumerate(r) if len(t) == 1 and ch == t]
                if not pos:
                    pos = cells(c[0] + " " + what + " " + notes)
                if not pos:
                    warn("%s:%s char '%s' what=\"%s\"" % (mem["region"], mid, t, what))
                for p in pos:
                    put(t, what, notes, p)
    else:
        lay = re.search(r"Layout: (.*)", sec).group(1)
        for mm in re.finditer(r"`~` across x (\d+)\.\.(\d+)", lay):
            for r in rows[1:-1]:
                for x in range(int(mm.group(1)), int(mm.group(2)) + 1):
                    r[x] = "~"
        prev_end, noun, used = 0, "", set()
        lay = lay.split(", ", 1)[1] if ", " in lay else lay
        for cm in re.finditer(r"\((\d+),\s*(\d+)\)", lay):
            seg = re.sub(r"^[\s,]*(and\b)?[\s,]*", "", lay[prev_end:cm.start()])
            noun = seg.strip().split(", ")[-1] or noun
            prev_end = cm.end()
            ch = re.search(r"`(.)`", noun)
            used.add(ch.group(1) if ch else "")
            put(ch.group(1) if ch else noun[:1], noun, "", (int(cm.group(1)), int(cm.group(2))))
        for ch in set(re.findall(r"`(.)`", lay)) - used:
            if not re.search(r"`~` across x", lay) or ch != "~":
                warn("%s:%s char '%s' what=\"%s\"" % (mem["region"], mid, ch, lay))

    # tiles
    data = bytearray(struct.pack("<H", 0))
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            data += struct.pack("<hhHHHH", x, y, 0, TILE_IDX.get(ch, 3), 0, 0)
    pba = "PackedByteArray(%s)" % ", ".join(map(str, data))

    cid = "".join(p.capitalize() for p in mid.split("_"))
    uid = mid.upper()
    body, n_cp, n_line, used_roles = [], 0, 0, set()
    seen = set()   # a patrol/threat drawn as a path of cells is ONE node per connected run (at its first cell)
    for role, (x, y), what, notes, ch in items:
        if role in ("patrol", "threat"):
            if any((x + dx, y + dy) in seen for dx, dy in ((-1, 0), (0, -1))):
                seen.add((x, y))
                continue
            seen.add((x, y))
        pos = "Vector2(%d, %d)" % (x * TILE + 8, y * TILE + 8)
        cm = "; %s %s | %s | %s" % (role, ch, what, notes)
        if role == "stand":
            body.append('%s\n[node name="Stand" type="Marker2D" parent="."]\nposition = %s\n' % (cm, pos))
        elif role == "checkpoint":
            n_cp += 1
            body.append('%s\n[node name="Checkpoint%d" type="Marker2D" parent="."]\nposition = %s\n' % (cm, n_cp, pos))
        elif role == "hide":
            body.append('%s\n[node name="Hide%d" type="Marker2D" parent="." groups=["hide"]]\nposition = %s\n' % (cm, len(body), pos))
        elif role == "prop":
            body.append('%s\n[node name="Prop%d_%s" type="Marker2D" parent="."]\nposition = %s\n' % (cm, len(body), ch, pos))
        elif role in ("patrol", "threat"):
            n_line += 1
            used_roles.add(role)
            body.append('%s\n[node name="Threat%d" parent="." instance=ExtResource("4")]\nposition = %s\n%s'
                        % (cm, n_line, pos, 'script = ExtResource("5")\n' if role == "patrol" else ""))
        else:
            n_line += 1
            order = order_of(what, ch) if role != "narrate" else -1
            body.append('%s\n[node name="Spot%d" parent="." instance=ExtResource("3")]\nposition = %s\n'
                        'action_kind = "%s"\norder = %d\nline_key = "MEM_%s_%d"\n'
                        % (cm, n_line, pos, role, order, uid, n_line))
    ext = ['[ext_resource type="Script" path="res://zones/kelir/%s.gd" id="1"]' % (mid if own else "memory"),
           '[ext_resource type="TileSet" path="res://zones/tiles.tres" id="2"]',
           '[ext_resource type="PackedScene" path="res://zones/kelir/memory_spot.tscn" id="3"]',
           '[ext_resource type="PackedScene" path="res://zones/kelir/memory_threat.tscn" id="4"]',
           '[ext_resource type="Script" path="res://zones/kelir/faceless_patrol.gd" id="5"]']
    out = ('; Generated by .docs/gen_memories.py from %s.md: change the doc and re-run, not this file.\n'
           '[gd_scene load_steps=6 format=3]\n\n%s\n\n[node name="%s" type="Node2D"]\nscript = ExtResource("1")\n'
           'kind = "%s"\nmemory_id = "%s"\n\n[node name="Tiles" type="TileMapLayer" parent="."]\n'
           'tile_set = ExtResource("2")\ntile_map_data = %s\n\n%s'
           % (mem["region"], "\n".join(ext), cid, kind, mid, pba, "\n".join(body)))
    return out, w, h, len(items)


def main(argv):
    outdir = ROOT + "zones/kelir"
    if "--out" in argv:
        i = argv.index("--out")
        outdir = argv[i + 1]
        del argv[i:i + 2]
    check = "--check" in argv
    files = [a for a in argv if not a.startswith("--")]
    if not files:
        files = sorted(os.path.join(ROOT, ".docs/zones", f) for f in os.listdir(ROOT + ".docs/zones") if f.endswith(".md"))
    bad, made, skipped = 0, 0, 0
    if not check:
        os.makedirs(outdir, exist_ok=True)
    for f in files:
        for mem in parse(f):
            if not mem["id"] or not mem["kind"]:
                print("ERROR %s: %s lacks scene path or Kind" % (mem["region"], mem["head"]))
                bad += 1
                continue
            if mem["kind"] == "gap" or mem["id"].startswith("gap_"):
                skipped += 1
                continue
            text, w, h, n = build(mem, print)
            if not check:
                open(os.path.join(outdir, mem["id"] + ".tscn"), "w").write(text)
            made += 1
            print("%s: %s %dx%d %d nodes" % (mem["region"], mem["id"], w, h, n)) if check else None
    print("%d scenes, %d gaps skipped, %d errors" % (made, skipped, bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
