class_name DemoRoute extends RefCounted
## Demo mode (architecture.md 10b): plays the game from New Game up to a checkpoint the way a thorough player
## would, through the real quest engine. It walks the main quest step by step: travels area to area on
## Zones.ADJ, talks to the NPC at each marker (their real dialogue: the entry's choices and actions), clears the
## encounters, examines the clues, lives the memories, beats the bosses, rests at every petilasan it passes and
## spends Ilmu there, opens the chests and takes the pickups of every area it walks, does the side quests of the
## region it is in, and lets every story beat play. Quest state, flags, items, codex and choices all come out of
## Game exactly as play leaves them. Game.replaying is on while it runs: no saves, no quest_* signals.
## Usage: var r := DemoRoute.new(Game, Zones); if r.build("warrior", cp): r.place(cp). cp is one of checkpoints().

const MAIN := ["mq0", "mq1", "mqg", "mq2", "mq3", "mq4", "mq5"]
const ACTS := {"mq0": "PROLOG", "mq1": "I", "mqg": "II", "mq2": "III", "mq3": "IV", "mq4": "V", "mq5": "VI"}
const CLASSES := ["warrior", "lancer", "archer", "herder", "rogue", "dancer", "mage", "dalang"]
## Region of an area (its id prefix) -> QuestData.zone of the side quests done there.
const REGION := {"ts": "tatar_sunda", "kg": "keraton_galuh", "mt": "mataram", "tt": "tanah_timur",
	"sk": "segara_kidul", "gk": "gua_kala", "desa_purwa": "desa_purwa"}
## Ilmu per enemy killed in an area of that region (balance.md 8: x1.5 per zone; Galuh shares Mataram's tier). TUNE
const KILL_ILMU := {"desa_purwa": 4, "ts": 6, "kg": 9, "mt": 9, "tt": 14, "sk": 20, "gk": 30}
const ROAMING := 4   # loose enemies a player cuts down crossing an area the first time. TUNE
## Boss Ilmu drops (the `ilmu` of each boss scene).
const BOSS_ILMU := {"sandekala": 100, "faceless_captain": 150, "sangkuriang": 150, "barma_wijaya": 220,
	"bandung_bondowoso": 300, "hariang_banga": 320, "buto_ijo": 300, "keris_gandring": 500,
	"nameless_hunter": 480, "batara_kala": 1000}
## Lowest level at a boss door (balance.md 2.2, main-quest-only column, low end). Below it the hero has
## fought a little more on the way, as a player who keeps dying would. TUNE
const LEVEL_FLOOR := {"sandekala": 3, "faceless_captain": 5, "sangkuriang": 6, "barma_wijaya": 9,
	"bandung_bondowoso": 12, "hariang_banga": 13, "buto_ijo": 15, "keris_gandring": 17,
	"nameless_hunter": 19, "batara_kala": 24}
## Stats each class raises at a petilasan, in turn.
const BUILD := {"warrior": ["str", "vit", "end", "str", "vit"], "archer": ["dex", "end", "vit", "dex", "vit"],
	"rogue": ["dex", "str", "end", "dex", "vit"], "mage": ["spi", "vit", "spi", "end"],
	"lancer": ["str", "end", "vit", "str", "vit"], "herder": ["dex", "end", "vit", "dex", "end"],
	"dancer": ["dex", "str", "end", "dex", "vit"], "dalang": ["spi", "vit", "spi", "end"]}
const MAX_STEPS := 2000   # main-loop guard

var g: Node   # Game
var z: Node   # Zones
var here := ""
var entry := {}       # area -> the spawn the hero last came in by
var visited := {}     # area -> true
var notes := PackedStringArray()   # warnings: steps that needed a nudge, the step it stopped at
var _cls: ClassData
var _beats: DialogueData
var _spots := {}      # area -> SPOTS (zone scripts), cached
var _side_ids: Array = []


func _init(game: Node, zones: Node) -> void:
	g = game
	z = zones
	_beats = DialogueData.by_id("beats")
	for f: String in DirAccess.get_files_at(QuestData.dir):
		var id := f.trim_suffix(".remap").trim_suffix(".tres")
		if id.begins_with("sq_"):
			_side_ids.append(id)
	_side_ids.sort()


# ---------------------------------------------------------------- checkpoints

## Every demo point, in story order: the start of each act, the first arrival in each area of the main
## route, and the door of each boss. {kind: act|area|boss, quest, step, zone, boss}.
static func checkpoints() -> Array:
	var out := []
	var seen := {}
	for q: String in MAIN:
		var data := QuestData.by_id(q)
		if data == null or data.steps.is_empty():
			continue
		var first := 2 if q == "mq0" else 0   # 0.1-0.2 are struck by Game.new_game
		var z0 := _step_zone(data.steps[first])
		out.append({"kind": "act", "quest": q, "step": first, "zone": z0, "boss": ""})
		seen[z0] = true
		for i in range(first, data.steps.size()):
			var st: QuestStep = data.steps[i]
			var boss := ""
			var boss_zone := _step_zone(st)
			for s: Array in _all_subs(st):
				if String(s[0]).begins_with("boss_defeated:"):
					boss = String(s[0]).substr(14)
					if s[1] != "":
						boss_zone = s[1]
			for s: Array in _all_subs(st):
				var zz: String = s[1] if s[1] != "" else _step_zone(st)
				if zz == "" or seen.has(zz):
					continue
				seen[zz] = true
				if boss == "" or zz != boss_zone:
					out.append({"kind": "area", "quest": q, "step": i, "zone": zz, "boss": ""})
			if boss != "":
				seen[boss_zone] = true
				out.append({"kind": "boss", "quest": q, "step": i, "zone": boss_zone, "boss": boss})
	return out


static func _step_zone(st: QuestStep) -> String:
	return str(st.marker.get("zone", ""))


## [on, zone, id] for every trigger of a step (an `all` step's sub-triggers, or `on`, or its first `alt`).
static func _all_subs(st: QuestStep) -> Array:
	var out := []
	var mz := str(st.marker.get("zone", ""))
	var mi := str(st.marker.get("id", ""))
	if not st.all.is_empty():
		for a: Dictionary in st.all:
			var m: Dictionary = a.get("marker", {})
			out.append([str(a.get("on", "")), str(m.get("zone", mz)), str(m.get("id", mi))])
	elif st.on != "":
		out.append([st.on, mz, mi])
	elif not st.alt.is_empty():
		out.append([str(st.alt.keys()[0]), mz, mi])
	return out


## "ACT I" / "PROLOG", for the card.
static func act_label(q: String) -> String:
	return String(ACTS.get(q, "")) if q == "mq0" else "ACT " + String(ACTS.get(q, ""))


# ---------------------------------------------------------------- the run

## New game as `cls_id`, then play until checkpoint `cp` is the current point of the story. False if the
## route could not get there (the reason is in `notes`). Game is left in the reached state either way.
func build(cls_id: String, cp: Dictionary) -> bool:
	_cls = load("res://data/classes/%s.tres" % cls_id) as ClassData
	if _cls == null:
		notes.append("no class " + cls_id)
		return false
	g.replaying = true
	g.new_game(_cls)   # keeps the hero's name and pronoun
	_event("class_chosen", cls_id)
	here = "desa_purwa"
	entry = {}
	visited = {}
	if cp.quest == "mq0" and cp.kind == "act":
		g.replaying = false
		return true   # the prologue's first moment is a plain new game
	_arrive("desa_purwa", "")
	var ok := false
	for _i in MAX_STEPS:
		_play_beats()
		var q := _main()
		if q == "":
			notes.append("no main quest active or startable")
			break
		if q == cp.quest and int(g.quests[q].step) >= int(cp.step):
			ok = true
			break
		if not _advance(q):
			var st: QuestStep = g.current_step(q)
			notes.append("stuck at %s step %d (%s)" % [q, int(g.quests[q].step) + 1, st.on if st else "?"])
			break
		_loot(here)
		_side_quests()
		_equip_best()
	if ok:
		var to: String = cp.get("zone", "")
		if to != "":
			_travel(to, false)   # the point itself is left for the player: nothing done in the area yet
		if cp.kind == "boss":
			_level_floor(int(LEVEL_FLOOR.get(cp.boss, 0)))
		_equip_best()
		g.restore()
	g.replaying = false
	return ok


## Puts the hero in the world at the reached point: saves (the demo slot), then the area's entry spawn,
## or the petilasan when the boss's own area has one, or the prologue's start for the first checkpoint.
func place(cp: Dictionary) -> void:
	g.save_game()
	if cp.quest == "mq0" and cp.kind == "act":
		z.start_new_game()
	elif cp.kind == "boss" and g.last_petilasan.get("zone", "") == z.ZONES.get(here, ""):
		z.continue_game()
	else:
		g.restore()
		z.go_to(here, _spawn_in(here, str(entry.get(here, ""))))


## The earliest main quest still open; one that has not started yet starts (its beat may need what the
## demo does not stage). "" when none can.
func _main() -> String:
	for q: String in MAIN:
		var s: String = g.quest_state(q)
		if s == "active":
			return q
		if s != "done":
			if g.start_quest(q):
				notes.append("started %s by hand" % q)
				return q
			return ""
	return ""


## Does what quest `q`'s current step asks, trigger by trigger, until the step moves. True if it moved.
func _advance(q: String) -> bool:
	var st: QuestStep = g.current_step(q)
	if st == null:
		return false
	var before := _sig(q)
	var subs := []
	if not st.all.is_empty():
		var trig := _all_subs(st)
		for i in trig.size():
			if not g._all_bit(q, i):
				subs.append(trig[i])
	else:
		subs = _all_subs(st)
	for s: Array in subs:
		_do(q, before, s[0], s[1], s[2])
		if _sig(q) != before:
			return true
	return false


func _sig(q: String) -> String:
	var r: Dictionary = g.quests.get(q, {})
	return "%s|%s|%s|%s" % [r.get("state", ""), r.get("step", ""), r.get("count", ""), r.get("all", "")]


## One trigger "<signal>:<arg>" at the marker (zone, id): go there, talk to whoever stands at the marker,
## then do the deed itself.
func _do(q: String, before: String, on: String, zone: String, id: String) -> void:
	if zone != "":
		_travel(zone)
	_play_beats()
	if _sig(q) != before:
		return
	var kv := on.split(":", true, 1)
	var sig := kv[0]
	var arg := kv[1] if kv.size() > 1 else ""
	if id != "" and id != arg and sig != "talked_to" and DialogueData.by_id(id) != null:
		_talk(id)
		_play_beats()
		if _sig(q) != before:
			return
	match sig:
		"talked_to":
			_talk(arg)
		"item_picked":
			_give(arg)
		"glyph_learned":
			_learn(arg)
		"boss_defeated":
			_kill_boss(arg)
		"enemy_killed":
			g.add_ilmu(_rate(here) * 2)
			_event(sig, arg)
		"area_cleared":
			_clear(arg)
		"clue_examined":
			_act("clue:" + arg)
		"puzzle_solved":
			_act("puzzle:" + arg)
		"memory_done":
			_act("memory:" + arg)
		"petilasan_activated":
			_rest(arg)
		"weakness_triggered":
			g.set_flag("weak:" + arg, false)
			_event(sig, arg)
		_:   # area_entered, zone_entered, name_written, spell_cast, trial_completed
			_event(sig, arg)
	_play_beats()
	if _sig(q) == before and q in MAIN:
		notes.append("nudged %s: %s" % [q, on])   # the deed was done, the step did not see it: tell it
		_event(sig, arg)


## Side quests of the region the hero is in: talk to the giver when one is offered, then a few steps of
## each open one. A step that does not move is left for later, as a player would.
func _side_quests() -> void:
	var region: String = REGION.get(_prefix(here), "")
	for id: String in _side_ids:
		var data := QuestData.by_id(id)
		if data == null or data.zone != region:
			continue
		if g.quest_state(id) == "available":
			if data.giver != "":
				_talk(data.giver)
				_play_beats()
			if g.quest_state(id) == "available":
				g.start_quest(id)
		for _n in 4:
			if g.quest_state(id) != "active" or not _advance(id):
				break


# ---------------------------------------------------------------- moving about

## Walks to `to`, area by area. `deeds` false: the last area is only stepped into (no fights, loot or rest
## there, and no zone_entered: loading it fires that).
func _travel(to: String, deeds := true) -> void:
	for _n in 40:
		if here == to:
			return
		var n: String = z.next_zone(here, to)
		var spawn := "from_" + here
		if n == "":   # no walkable link (a story jump): arrive anyway
			n = to
			spawn = ""
		if n == to and not deeds:
			_step_in(to, spawn)
			return
		_arrive(n, spawn)


## Arrives in an area: first time, it is looked at (area card and map flags), its shortcuts that open from
## this side are opened, the loose enemies on the way are cut down, its encounters cleared and its
## petilasan rested at. Every time: zone_entered, then the pickups and chests in sight.
func _arrive(zone: String, spawn: String) -> void:
	var first := _step_in(zone, spawn)
	if first:
		for sc: String in z.SHORTCUTS:
			if z.SHORTCUTS[sc][0] == zone:
				g.set_flag(sc, false)
		g.add_ilmu(_rate(zone) * ROAMING)
	_event("zone_entered", zone)
	if first:
		for s: Dictionary in _spots_of(zone).values():
			var props: Dictionary = s.get("props", {})
			if String(s.get("scene", "")).ends_with("encounter.tscn") and g.check(str(props.get("cond", ""))):
				_clear(str(props.get("area_id", "")))
	var pet := _pet(zone)
	if pet != "" and g.last_petilasan.get("id", "") != pet:
		_rest(pet)
	_loot(zone)


## Moves the hero into `zone` by `spawn` and marks it seen. True on the first visit.
func _step_in(zone: String, spawn: String) -> bool:
	here = zone
	z.current_zone = zone   # `zone:` dialogue conditions
	entry[zone] = spawn
	var first := not visited.has(zone)
	if first:
		visited[zone] = true
		g.set_flag("seen_area_" + zone, false)
		g.flags["seen_zone:" + zone] = true
	return first


## Chests and pickups of an area whose condition holds: opened and taken.
func _loot(zone: String) -> void:
	for s: Dictionary in _spots_of(zone).values():
		var props: Dictionary = s.get("props", {})
		var scene := String(s.get("scene", ""))
		if scene.ends_with("chest.tscn"):
			var cid := str(props.get("chest_id", ""))
			var item := str(props.get("item_id", ""))
			if cid == "" or g.has_flag("chest:" + cid):
				continue
			g.set_flag("chest:" + cid, false)
			if item.begins_with("ilmu:"):
				g.add_ilmu(int(item.get_slice(":", 1)))
			elif item != "":
				_give(item)
		elif scene.ends_with("pickup.tscn") and not props.get("drop", false):
			var item := str(props.get("item_id", ""))
			var key := item if item != "" else str(props.get("codex_id", ""))
			if key == "" or g.has_flag("pickup:" + key) or not g.check(str(props.get("cond", ""))):
				continue
			g.set_flag("pickup:" + key, false)
			if item != "":
				_give(item)
			else:
				g.unlock_codex(key, false)


func _rest(id: String) -> void:
	var path: String = z.ZONES.get(here, "")
	if _pet(here) == id and path != "":
		g.last_petilasan = {"zone": path, "id": id}
	g.restore()
	_spend()
	_event("petilasan_activated", id)


# ---------------------------------------------------------------- deeds

func _talk(npc: String) -> void:
	var d := DialogueData.by_id(npc)
	if d == null:
		_event("talked_to", npc)
		return
	var e: Dictionary = g.pick_entry(d.entries)
	if e.is_empty():
		_event("talked_to", npc)   # nothing to say yet: walking up to them still counts here
		return
	if d.name_key.begins_with("NPC_") and d.name_key.ends_with("_NAME"):
		g.set_flag("seen_name_" + d.name_key.trim_prefix("NPC_").trim_suffix("_NAME").to_lower(), false)
	g.set_flag("seen_hint_continue", false)
	_play(e, d.entries, 0)
	if not (e.get("quiet", false) or e.get("hub", false) or e.has("topic")):   # as Npc.interact counts a talk
		_event("talked_to", npc)


## Game.play without the box: the first choice, then the entry's actions. A hub asks every topic once.
func _play(e: Dictionary, file: Array, depth: int) -> void:
	var choices: Array = e.get("choices", [])
	if e.get("hub", false) and not choices.is_empty():
		var leave := -1
		for i in choices.size():
			var topic := ""
			for a: String in choices[i].get("do", []):
				if a.begins_with("topic:"):
					topic = a.substr(6)
			if topic == "":
				if leave < 0:
					leave = i
				continue
			for a: String in choices[i].get("do", []):
				if not a.begins_with("topic:"):
					_act(a)
			var t: Dictionary = g.topic_entry(file, topic)
			if not t.is_empty() and depth < 3:
				_play(t, file, depth + 1)
		if leave >= 0:
			for a: String in choices[leave].get("do", []):
				_act(a)
	elif not choices.is_empty():
		for a: String in choices[0].get("do", []):
			_act(a)
	for a: String in e.get("do", []):
		_act(a)


## Story beats (ui/story_beat.gd): every one whose condition now holds plays, each once.
func _play_beats() -> void:
	if _beats == null:
		return
	var last := {}
	for _n in 64:
		var e: Dictionary = _beats.pick(g)
		if e.is_empty() or e == last:
			return
		last = e
		_play(e, [], 0)


## A dialogue action, done the way the scene it stands for would do it.
func _act(action: String) -> void:
	var kv := action.split(":", true, 1)
	var arg := kv[1] if kv.size() > 1 else ""
	match kv[0]:
		"give":
			_give(arg)
		"learn":
			_learn(arg)
		"clue":
			g.set_flag("clue_" + arg, false)
			_event("clue_examined", arg)
		"puzzle":
			g.set_flag("puzzle_" + arg, false)
			_event("puzzle_solved", arg)
		"memory":   # lived through: KelirMemory.finish() sets the flag, then memory_done
			g.set_flag("memory_" + arg, false)
			_event("memory_done", arg)
		"write":   # written: ui/glyph_lesson fires name_written(seq_id)
			_event("name_written", arg.get_slice(":", 0))
		"goto":
			var p := arg.rsplit(":", true, 1)
			if p.size() == 2:
				_arrive(_zone_id(p[0]), p[1])
		"lesson":   # the verb is taught by doing it; the hero has
			g.set_flag(Lessons.flag(arg), false)
		"credits", "topic":
			pass
		_:   # start, flag, codex, lakon, remember, restore
			g.run(action)


func _give(id: String) -> void:
	g.add_item(id, false)
	_event("item_picked", id)


func _learn(id: String) -> void:
	if id not in g.glyphs_learned:
		var gl: PackedStringArray = g.glyphs_learned   # packed arrays copy on write: set it back
		gl.append(id)
		g.glyphs_learned = gl
		_event("glyph_learned", id)


func _kill_boss(id: String) -> void:
	if id not in g.killed:
		var k: PackedStringArray = g.killed
		k.append(id)
		g.killed = k
		g.add_ilmu(int(BOSS_ILMU.get(id, 50)))
	_event("boss_defeated", id)


func _clear(area_id: String) -> void:
	if area_id == "":
		return
	g.add_ilmu(_rate(here) * _enemies(area_id))
	_event("area_cleared", area_id)


## What Events would have told Game (its own connections in Game._connect_events).
func _event(sig: String, arg: String) -> void:
	g.on_event(sig, arg)
	if sig == "memory_done":
		for fl: String in g.LARAS_FLAGS.get(arg, []):
			g.set_flag(fl, false)


# ---------------------------------------------------------------- growth

## Ilmu into levels, in the class's order (a petilasan does this).
func _spend() -> void:
	var order: Array = BUILD.get(_cls.id if _cls else "", ["vit"])
	while g.ilmu >= g.level_cost():
		if not g.level_up(String(order[int(g.points_spent) % order.size()])):
			return


func _level_floor(lv: int) -> void:
	for _n in 100:
		if g.level() >= lv:
			return
		g.add_ilmu(maxi(0, g.level_cost() - g.ilmu))
		_spend()


## The best weapon of the class's kind, the heaviest armor, and an accessory if none is worn.
func _equip_best() -> void:
	if _cls == null:
		return
	var start := ItemData.by_id(_cls.start_weapon)
	var arch := start.archetype if start else ""
	var best := {"weapon": ItemData.by_id(g.equipped.get("weapon", "")), "armor": ItemData.by_id(g.equipped.get("armor", ""))}
	for id: String in g.inventory:
		var it := ItemData.by_id(id)
		if it == null:
			continue
		match it.slot:
			"weapon":
				var cur: ItemData = best.weapon
				if it.archetype == arch and (cur == null or it.damage > cur.damage):
					best.weapon = it
			"armor":
				var cur: ItemData = best.armor
				if cur == null or it.defense > cur.defense:
					best.armor = it
			"accessory":
				if str(g.equipped.get("accessory", "")) == "":
					g.equipped["accessory"] = id
	for slot: String in best:
		if best[slot] != null:
			g.equipped[slot] = (best[slot] as ItemData).id


# ---------------------------------------------------------------- zone data

func _spots_of(zone: String) -> Dictionary:
	if _spots.has(zone):
		return _spots[zone]
	var out := {}
	var path := "res://zones/%s.gd" % zone
	var sc: Script = load(path) if ResourceLoader.exists(path) else null
	while sc != null:
		var m := sc.get_script_constant_map()
		if m.has("SPOTS"):
			out = m.SPOTS
			break
		sc = sc.get_base_script()
	_spots[zone] = out
	return out


func _pet(zone: String) -> String:
	for s: Dictionary in _spots_of(zone).values():
		if String(s.get("scene", "")).ends_with("petilasan.tscn"):
			return str(s.get("props", {}).get("id", ""))
	return ""


## `want` if the area has that spawn, else its first spawn, else "".
func _spawn_in(zone: String, want: String) -> String:
	var first := ""
	for s: Dictionary in _spots_of(zone).values():
		if String(s.get("scene", "")).ends_with("spawn.tscn"):
			var id := str(s.get("props", {}).get("id", ""))
			if id == want:
				return id
			if first == "":
				first = id
	return first


func _enemies(area_id: String) -> int:
	for s: Dictionary in _spots_of(here).values():
		var props: Dictionary = s.get("props", {})
		if str(props.get("area_id", "")) == area_id:
			var n := 0
			for wave: Array in props.get("waves", []):
				n += wave.size()
			return maxi(1, n)
	return 4


func _rate(zone: String) -> int:
	return int(KILL_ILMU.get(_prefix(zone), 6))


static func _prefix(zone: String) -> String:
	return "desa_purwa" if zone == "desa_purwa" or zone == "" else zone.get_slice("_", 0)


func _zone_id(s: String) -> String:
	if z.ZONES.has(s):
		return s
	for k: String in z.ZONES:
		if z.ZONES[k] == s:
			return k
	return s.get_file().get_basename()
