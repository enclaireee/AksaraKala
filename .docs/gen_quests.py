#!/usr/bin/env python3
"""Make data/quests/*.tres match the Story v5 step tables in .docs/zones/*.md.

Each zone doc has one table per region that maps a step number to its marker, area and
"completes on" event string. This reads those tables (plus data/text/quests.csv for the
objective and recap keys) and writes one QuestStep per row. Rerunnable.

Run: python3 .docs/gen_quests.py
"""
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CSV = ROOT / "data/text/quests.csv"
OUT = ROOT / "data/quests"

SIGNALS = [
    "talked_to", "area_cleared", "area_entered", "zone_entered", "petilasan_activated",
    "glyph_learned", "boss_defeated", "enemy_killed", "item_picked", "clue_examined",
    "memory_done", "puzzle_solved", "trial_completed", "name_written", "spell_cast",
    "class_chosen",
]
EV = re.compile(r"\b(" + "|".join(SIGNALS) + r"):([A-Za-z0-9_]+)")
FLAG = re.compile(r"`([a-z][A-Za-z0-9_]*)`")

# Hand fixes where the doc cell is prose, a choice flag, or names a scene instead of a map node.
# key: (quest, step) -> dict(on=..., all=..., alt=..., marker=(zone,id), set_flag=...)
# The three choice steps carry no signal of their own; their talk/item is the trigger.
OVERRIDES = {
    ("mq3", 20): {"on": "", "alt": {"item_picked:keris_gandring": "reforge", "item_picked:batu_kali": "sink"},
                  "marker": ("tt_candi", "beat_keris")},
    ("mq4", 19): {"on": "talked_to:cliff_altar", "set_flag": "mq4_offering",
                  "marker": ("sk_tebing", "cliff_altar")},
    ("mq5", 2): {"on": "talked_to:memorial_stone", "set_flag": "mq5_choice6",
                 "marker": ("gk_pelataran", "memorial_stone")},
    ("mq2", 20): {"marker": ("kg_pamali", "from_mt_gapura")},
    ("mq5", 13): {"marker": ("gk_ruang_kala", "batara_kala")},
    ("mq5", 14): {"marker": ("gk_ruang_kala", "batara_kala")},
}

# Quest level metadata, kept by hand (quests.md 4 headers and 5 cards).
META = {
    "mq0": dict(kind="main", type="main", zone="desa_purwa", size="S", giver="semar", requires=[], rewards='{"codex": ["hanacaraka"]}'),
    "mq1": dict(kind="main", type="main", zone="tatar_sunda", size="L", giver="semar", requires=[], rewards='{"lakon": "sangkuriang", "codex": ["naganingrum", "sangkuriang", "dayang_sumbi"]}'),
    "mqg": dict(kind="main", type="main", zone="keraton_galuh", size="L", giver="", requires=["mq1_10"], rewards="{}"),
    "mq2": dict(kind="main", type="main", zone="mataram", size="L", giver="", requires=["mqg_7"], rewards='{"items": ["baju_batik"], "lakon": "roro_jonggrang", "codex": ["roro_jonggrang", "candi_seribu"]}'),
    "mq3": dict(kind="main", type="main", zone="tanah_timur", size="L", giver="", requires=["mq2_9"], rewards='{"lakon": "timun_mas", "codex": ["timun_mas"]}'),
    "mq4": dict(kind="main", type="main", zone="segara_kidul", size="L", giver="beats", requires=["mq3_8"], rewards='{"items": ["kain_hijau"], "codex": ["nyi_roro_kidul"]}'),
    "mq5": dict(kind="main", type="main", zone="gua_kala", size="L", giver="", requires=["mq4_9"], rewards='{"codex": ["batara_kala", "ruwatan"]}'),
    "sq_s1": dict(kind="side", type="retelling", zone="tatar_sunda", size="M", giver="ki_darsa", requires=["mq1_3"], rewards='{"items": ["iket_sunda"], "lakon": "lutung_kasarung", "codex": ["lutung_kasarung"]}'),
    "sq_s2": dict(kind="side", type="bounty", zone="tatar_sunda", size="L", giver="kepala_desa", requires=["mq1_3"], rewards='{"items": ["golok"], "herb_pouch": 1, "codex": ["kuntilanak_rumpun"]}'),
    "sq_s3": dict(kind="side", type="errand", zone="tatar_sunda", size="M", giver="angklung_leader", requires=[], rewards='{"flask_shard": 1, "codex": ["angklung"]}'),
    "sq_s4": dict(kind="side", type="errand", zone="tatar_sunda", size="S", giver="cepot", requires=["mq1_1"], rewards='{"items": ["silver_bangle"], "codex": ["cepot"]}'),
    "sq_g1": dict(kind="side", type="retelling", zone="keraton_galuh", size="M", giver="kabayan", requires=[], rewards='{"items": ["ikat_kepala"], "lakon": "kabayan", "codex": ["kabayan"]}'),
    "sq_g2": dict(kind="side", type="bounty", zone="keraton_galuh", size="L", giver="g2_maid", requires=[], rewards='{"items": ["sisir_emas"], "codex": ["ririwa"]}'),
    "sq_c1": dict(kind="side", type="errand", zone="keraton_galuh", size="M", giver="ciung_wanara", requires=[], rewards='{"items": ["bulu_jago"], "codex": ["ayam_jago"]}'),
    "sq_c2": dict(kind="side", type="errand", zone="mataram", size="M", giver="galuh_queen", requires=[], rewards='{"items": ["surat_ibu"], "codex": ["pamali"]}'),
    "sq_c3": dict(kind="side", type="retelling", zone="segara_kidul", size="L", giver="faceless_deserter", requires=[], rewards='{"items": ["topeng_pembelot"], "lakon": "ranga", "codex": ["deserter"]}'),
    "sq_c4": dict(kind="side", type="errand", zone="tatar_sunda", size="S", giver="cepot", requires=[], rewards='{"items": ["wayang_cepot"], "codex": ["cepot"]}'),
    "sq_m1": dict(kind="side", type="retelling", zone="mataram", size="M", giver="nawang_wulan", requires=["mq2_1"], rewards='{"items": ["feather_charm"], "herb_pouch": 1, "lakon": "jaka_tarub", "codex": ["jaka_tarub"]}'),
    "sq_m2": dict(kind="side", type="bounty", zone="mataram", size="L", giver="wewe_neighbor", requires=["mq2_2"], rewards='{"items": ["jimat"]}'),
    "sq_m3": dict(kind="side", type="bounty", zone="mataram", size="M", giver="pande_besi", requires=["mq2_1"], rewards='{"items": ["spear"], "codex": ["tuyul"]}'),
    "sq_m4": dict(kind="side", type="errand", zone="mataram", size="M", giver="mataram_dalang", requires=["mq2_2"], rewards='{"items": ["blangkon"], "codex": ["gamelan"]}'),
    "sq_t1": dict(kind="side", type="retelling", zone="tanah_timur", size="M", giver="klething_kuning", requires=["mq3_1"], rewards='{"items": ["stone_ring"], "lakon": "ande_ande_lumut", "codex": ["ande_ande_lumut"]}'),
    "sq_t2": dict(kind="side", type="bounty", zone="tanah_timur", size="L", giver="timur_herder", requires=["mq3_1"], rewards='{"herb_pouch": 1}'),
    "sq_t3": dict(kind="side", type="errand", zone="tanah_timur", size="M", giver="timur_empu", requires=["mq3_2"], rewards='{"items": ["keris_luk_7"]}'),
    "sq_t4": dict(kind="side", type="errand", zone="tanah_timur", size="S", giver="kepang_leader", requires=["mq3_1"], rewards='{"flask_shard": 1, "codex": ["kuda_kepang"]}'),
    "sq_k1": dict(kind="side", type="errand", zone="segara_kidul", size="S", giver="kidul_nelayan_anak", requires=["mq4_2"], rewards='{"herb_pouch": 1}'),
    "sq_k2": dict(kind="side", type="errand", zone="segara_kidul", size="L", giver="k2_fisher", requires=["mq4_4"], rewards='{"items": ["cakra"]}'),
}


def read_csv():
    """(quest, n) -> (objective key, recap key) from the v5 quest text."""
    keys = {}
    for line in CSV.read_text(encoding="utf-8").splitlines()[1:]:
        key = line.split(",", 1)[0]
        m = re.fullmatch(r"Q_(MQ[0-9G]|SQ_[A-Z][0-9])_S(\d+)_(OBJ|DONE)", key)
        if m:
            q = m.group(1).lower()
            keys.setdefault((q, int(m.group(2))), {})[m.group(3)] = key
    return keys


def norm(h):
    return re.sub(r"\s+", " ", h.strip().strip("`").lower())


def table_rows(path):
    """Yield dicts with the columns step, marker, area, event from every step table in a zone doc."""
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    cols, quest_col = None, None
    for line in lines:
        if not line.startswith("|"):
            cols = None
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        hs = [norm(c) for c in cells]
        if any(h.startswith("step") for h in hs) and any("marker" in h for h in hs):
            cols = {}
            for i, h in enumerate(hs):
                if h.startswith("step"):
                    cols["step"] = i
                elif "marker" in h:
                    cols["marker"] = i
                elif h.startswith("area"):
                    cols["area"] = i
                elif "event" in h or "completes" in h:
                    cols["event"] = i
                elif h == "quest":
                    quest_col = i
            continue
        if cols is None:
            continue
        def cell(name):
            i = cols.get(name)
            return cells[i] if i is not None and i < len(cells) else ""
        yield {k: cell(k) for k in ("step", "marker", "area", "event")} | {"quest": cells[quest_col] if quest_col is not None and quest_col < len(cells) else ""}


def quest_of(step, quest_cell):
    m = re.match(r"\s*(SQ-[A-Z]\d+)", quest_cell or "")
    if m:
        return m.group(1).lower().replace("-", "_"), None
    m = re.match(r"\s*(MQ[0-9G])\s*\|?\s*(\d+\.\d+)", quest_cell or "")
    if m:
        return m.group(1).lower(), int(m.group(2).split(".")[1])
    m = re.match(r"\s*(?:MQ\d+\s+)?(\d+|g)\.(\d+)", step)
    if not m:
        return None, None
    a, b = m.group(1), int(m.group(2))
    if a == "g":
        return "mqg", b
    q = {"0": "mq0", "1": "mq1", "2": "mq2", "3": "mq3", "4": "mq4", "5": "mq5"}.get(a)
    return q, b


SETS = re.compile(r"\bsets?\b([^;|]*)", re.I)


def sets_groups(cell):
    """[(pos, [flag, ...])] for every "sets `a`, `b`" phrase in the event cell."""
    out = []
    for m in SETS.finditer(cell):
        flags = [f for f in FLAG.findall(m.group(1)) if not re.match("|".join(SIGNALS) + ":", f)]
        out.append((m.start(), flags[:1]))   # the flag right after "sets"; later backticks are beats/scenes
    return out


def parse_event(cell):
    """Return (on, all, alt, set_flag, count) from a doc event cell."""
    events = [(m.start(), m.group(0)) for m in EV.finditer(cell)]
    if not events:
        return "", [], {}, "", 1
    is_all = bool(re.search(r"`all`|\ball\s*:", cell[:events[0][0]]))
    groups = sets_groups(cell)
    rows = []
    for i, (pos, ev) in enumerate(events):
        end = events[i + 1][0] if i + 1 < len(events) else len(cell)
        flags = [f for gpos, fs in groups if pos <= gpos < end for f in fs]
        rows.append({"on": ev, "set_flag": (flags or [""])[-1]})
    step_flag = rows[-1]["set_flag"] if rows else ""
    # A count on a single trigger ("`area_entered:x` x2"); the engine counts one slot per step.
    count = 1
    if len(rows) == 1:
        m = re.match(r"[`\s]*[x×]\s*(\d+)", cell[events[0][0] + len(events[0][1]):])
        if m:
            count = int(m.group(1))
    if is_all or len(rows) > 1:
        # A "then" chain is a sequence of separate triggers; the engine has one slot per step,
        # so require all of them in any order.
        return "", rows, {}, step_flag, 1
    return rows[0]["on"], [], {}, step_flag, count


def first_id(txt):
    for t in FLAG.findall(txt or ""):
        if t == "none" or "/" in t or t.endswith(".tscn") or re.match(r"^(MQ|SQ)", t):
            continue
        return t
    return ""


def collect():
    steps = {}
    docs = [".docs/zones/desa_purwa.md", ".docs/zones/tatar_sunda.md", ".docs/zones/keraton_galuh.md",
            ".docs/zones/mataram.md", ".docs/zones/tanah_timur.md", ".docs/zones/segara_kidul.md",
            ".docs/zones/gua_kala.md"]
    for doc in docs:
        for row in table_rows(ROOT / doc):
            q, n = quest_of(row["step"], row["quest"])
            if not q or not n:
                continue
            if not row["event"]:
                continue
            on, all_, alt, flag, count = parse_event(row["event"])
            if not (on or all_ or alt):
                continue
            marker_id = first_id(row["marker"])
            area = first_id(row["area"])
            if not area:
                area = Path(doc).stem
            entry = {"on": on, "all": all_, "alt": alt, "set_flag": flag}
            if count > 1:
                entry["count"] = count
            if marker_id:
                entry["marker"] = (area, marker_id)
            steps.setdefault((q, n), entry)
    return steps


def fmt_step(q, n, st, keys):
    obj = keys.get((q, n), {}).get("OBJ", "Q_%s_S%d_OBJ" % (q.upper(), n))
    done = keys.get((q, n), {}).get("DONE", "Q_%s_S%d_DONE" % (q.upper(), n))
    lines = ["[sub_resource type=\"Resource\" id=\"s%d\"]" % n, "script = ExtResource(\"2\")", 'objective = "%s"' % obj]
    if st.get("on"):
        lines.append('on = "%s"' % st["on"])
    if st.get("count", 1) != 1:
        lines.append("count = %d" % st["count"])
    if st.get("alt"):
        lines.append("alt = %s" % gd(st["alt"]))
    if st.get("all"):
        for i, sub in enumerate(st["all"]):
            if "objective" not in sub or not sub["objective"]:
                sub["objective"] = "Q_%s_S%d_P%d" % (q.upper(), n, i + 1)
        lines.append("all = %s" % gd(st["all"]))
    if st.get("set_flag"):
        lines.append('set_flag = "%s"' % st["set_flag"])
    lines.append('recap = "%s"' % done)
    if st.get("marker"):
        z, i = st["marker"]
        lines.append('marker = {"zone": "%s", "id": "%s"}' % (z, i))
    return "\n".join(lines) + "\n"


def gd(v):
    """Python literal to GDScript literal for the small dict/list shapes QuestStep uses."""
    if isinstance(v, dict):
        return "{" + ", ".join('"%s": %s' % (k, gd(x)) for k, x in v.items()) + "}"
    if isinstance(v, list):
        return "[" + ", ".join(gd(x) for x in v) + "]"
    return '"%s"' % v


def write_quest(q, rows, keys):
    meta = META[q]
    parts = ['[gd_resource type="Resource" script_class="QuestData" load_steps=%d format=3]\n' % (len(rows) + 3),
             '[ext_resource type="Script" path="res://data/quest_data.gd" id="1"]',
             '[ext_resource type="Script" path="res://data/quest_step.gd" id="2"]\n']
    for n, st in rows:
        parts.append(fmt_step(q, n, st, keys))
    refs = ", ".join('SubResource("s%d")' % n for n, _ in rows)
    res = ['[resource]', 'script = ExtResource("1")', 'id = "%s"' % q,
           'kind = "%s"' % meta["kind"], 'type = "%s"' % meta["type"],
           'zone = "%s"' % meta["zone"], 'size = "%s"' % meta["size"]]
    if meta.get("giver"):
        res.append('giver = "%s"' % meta["giver"])
    if meta.get("requires"):
        res.append('requires = Array[String]([%s])' % ", ".join('"%s"' % r for r in meta["requires"]))
    res.append("steps = Array[ExtResource(\"2\")]([%s])" % refs)
    res.append("rewards = %s" % meta["rewards"])
    (OUT / (q + ".tres")).write_text("\n".join(parts) + "\n".join(res) + "\n", encoding="utf-8")


def main():
    keys = read_csv()
    steps = collect()
    for key, fix in OVERRIDES.items():
        steps[key] = {**steps.get(key, {}), **fix}
    by_quest = {}
    for (q, n), st in steps.items():
        by_quest.setdefault(q, []).append((n, st))
    for q in sorted(by_quest):
        rows = sorted(by_quest[q])
        missing = [n for n, _ in rows if n > 1 and n - 1 not in [x for x, _ in rows]]
        if missing:
            print("%s: missing steps %s" % (q, missing))
        write_quest(q, rows, keys)
        print("%s: %d steps" % (q, len(rows)))


if __name__ == "__main__":
    main()
