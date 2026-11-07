extends Node
## Run state and the single save slot (architecture.md 3, rpg.md 2, 6, 11).
## Everything here is saved. Systems read it and listen to `changed`; the player calls apply_from_game().

signal changed   # ilmu, stats, gear, glyphs or flask changed
signal saved     # HUD shows "Saved" for 1 s

const VERSION := 3   # 2: quest records gain `all` (bits of an all step). Older saves load with all = 0.
                     # 3: memory_return (architecture.md 9b). Older saves load with none.
const STATS := ["vit", "end", "str", "dex", "spi"]
const STARTER_GLYPHS: Array[String] = []   # glyphs come from the main quest (quests.md 3.3)
## Quest Ilmu by zone and size S/M/L (quests.md 3.1, TUNE). Desa Purwa uses the Act 1 row for now.
const QUEST_ILMU := {"tatar_sunda": [30, 60, 90], "desa_purwa": [30, 60, 90], "keraton_galuh": [30, 60, 90], "mataram": [55, 110, 165],
	"tanah_timur": [110, 220, 330], "segara_kidul": [190, 380, 570],
	"gua_kala": [190, 380, 570]}
## Quest-trigger signals on Events with one String arg (quests.md 7.2).
const QUEST_SIGNALS := ["talked_to", "item_picked", "boss_defeated", "area_cleared", "area_entered",
	"zone_entered", "petilasan_activated", "glyph_learned", "class_chosen", "weakness_triggered", "name_written",
	"clue_examined", "memory_done", "puzzle_solved", "trial_completed"]
## Cross-time Laras flags set automatically when LC1-LC6 complete (quests.md 7.1).
const LARAS_FLAGS := {
	"lc1": ["mq1_lc", "laras_sabotage:crater_seal", "laras_key:crater_post", "laras_sabotage_crater_seal", "laras_key_crater_post"],
	"lc2": ["mqg_lc", "laras_sabotage:glamour_seal", "laras_key:archive_grate", "laras_sabotage_glamour_seal", "laras_key_archive_grate"],
	"lc3": ["mq2_lc", "laras_key:candi_crypt", "laras_sabotage:bondowoso_pillar", "laras_key_candi_crypt", "laras_sabotage_bondowoso_pillar"],
	"lc4": ["mq3_lc", "laras_key:sand_tunnel", "laras_sabotage:keris_seventh_stake", "laras_key_sand_tunnel", "laras_sabotage_keris_seventh_stake"],
	"lc5": ["mq4_lc", "laras_key:tidal_gate", "laras_key_tidal_gate"],
	"lc6": ["mq5_lc", "laras_sabotage:kala_eclipse", "laras_sabotage_kala_eclipse"],
}
## Saved fields, in to_dict order. Add a field here and in _reset(); old saves get its default.
const FIELDS := ["class_id", "stats", "ilmu", "points_spent", "glyphs_learned", "inventory", "equipped",
	"flask_charges", "flask_max", "herb_pouches", "last_petilasan", "killed", "flags", "play_time", "quests", "codex", "pinned",
	"hero_name", "hero_pronoun", "memory_return"]
const DEFAULT_NAME := "Jaka"   # ASSUMED (ui.md 3)
## he / she / they -> [they, them, their, They] for Game.fmt.
const PRONOUNS := {"he": ["he", "him", "his", "He"], "she": ["she", "her", "her", "She"], "they": ["they", "them", "their", "They"]}

var save_path := "user://save.json"   # tests point this elsewhere

var class_id := ""
var stats := {}
var ilmu := 0
var points_spent := 0
var glyphs_learned := PackedStringArray()
var inventory := PackedStringArray()   # item ids, weapons included
var equipped := {}                     # weapon, armor, accessory -> item id or ""
var flask_charges := 3
var flask_max := 3                     # +1 per Flask Shard, max 6
var herb_pouches := 0                  # +5% flask heal each, max 4
var last_petilasan := {}               # zone (scene path) and id
var killed := PackedStringArray()      # bosses, minibosses, other unique ids that stay dead
var flags := {}
var play_time := 0.0
var quests := {}                       # id -> {state: active|done, step, count, resolution, all} (quests.md 7.3)
var codex := PackedStringArray()       # unlocked CodexEntry ids
var pinned := ""                       # pinned side quest id, "" follows the main quest
var hero_name := DEFAULT_NAME          # set on the name screen; new_game keeps it
var hero_pronoun := "they"             # he, she or they
var memory_return := {}                # inside a Kelir memory: {zone: scene path, pos: [x, y]} to go back to (Zones.enter_memory)


func _init() -> void:
	_reset()


func _reset() -> void:
	class_id = ""
	stats = {"vit": 5, "end": 5, "str": 5, "dex": 5, "spi": 5}
	ilmu = 0
	points_spent = 0
	glyphs_learned = PackedStringArray(STARTER_GLYPHS)
	inventory = PackedStringArray()
	equipped = {"weapon": "", "armor": "", "accessory": ""}
	flask_charges = 3
	flask_max = 3
	herb_pouches = 0
	last_petilasan = {"zone": "", "id": ""}
	killed = PackedStringArray()
	flags = {}
	play_time = 0.0
	quests = {}
	codex = PackedStringArray()
	pinned = ""
	hero_name = DEFAULT_NAME
	hero_pronoun = "they"
	memory_return = {}


func _ready() -> void:
	_connect_events.call_deferred()   # Events is the next autoload


func _connect_events() -> void:
	var ev := get_node_or_null("/root/Events")
	if ev == null:
		return
	for s in QUEST_SIGNALS:
		ev.connect(s, func(arg: String) -> void: on_event(s, arg))
	ev.spell_cast.connect(func(glyph: String, _score: float) -> void: on_event("spell_cast", glyph))
	ev.enemy_killed.connect(func(e: Node2D, _ilmu: int) -> void:
		var kind := str(e.get("kind")) if is_instance_valid(e) and e.get("kind") != null else ""
		if kind != "":
			on_event("enemy_killed", kind))
	ev.weakness_triggered.connect(func(kind: String) -> void: set_flag("weak:" + kind))
	ev.memory_done.connect(func(mid: String) -> void:
		for fl: String in LARAS_FLAGS.get(mid, []):
			set_flag(fl, false))


func _process(delta: float) -> void:
	if class_id != "":
		play_time += delta   # ponytail: slowed by cast slow-mo; fine for a play clock


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and class_id != "":
		save_game()   # quit is a save trigger (rpg.md 11)


# --- hero name and text (ui.md 3) ---

## Keeps letters (any script), digits, space, ' and -, at most 12. `final` also trims and falls back to the
## default, so a name can never hold [ ] { } or BBCode.
static func clean_name(s: String, final := true) -> String:
	var re := RegEx.create_from_string("[^\\p{L}0-9 '\\-]")
	s = re.sub(s, "", true).left(12)
	if not final:
		return s
	s = s.strip_edges()
	return s if s != "" else DEFAULT_NAME


## Fills {name}, {they}, {them}, {their}, {They}. Call it on the result of tr(). Plain replaces on purpose:
## never String.format with player input.
func fmt(s: String) -> String:
	if not "{" in s:
		return s
	var p: Array = PRONOUNS.get(hero_pronoun, PRONOUNS.they)
	return s.replace("{name}", hero_name).replace("{they}", p[0]).replace("{them}", p[1]) \
			.replace("{their}", p[2]).replace("{They}", p[3])


# --- new game, leveling, inventory ---

## Class choice creates the save (rpg.md 11). The old save is replaced only here.
func new_game(cls: ClassData) -> void:
	var keep_name := hero_name   # chosen on the name screen, before class select
	var keep_pronoun := hero_pronoun
	_reset()
	hero_name = keep_name
	hero_pronoun = keep_pronoun
	class_id = cls.id
	stats = cls.stats.duplicate()
	for id in [cls.start_weapon, cls.start_armor]:
		if id != "":
			add_item(id, false)
			equipped[ItemData.by_id(id).slot] = id
	if start_quest("mq0"):
		quests.mq0.step = 2   # 0.1-0.2 (prologue, class) are struck before the save; 0.3 Ibu is next (quests.md MQ0)
	save_game()
	changed.emit()


func level() -> int:
	return 1 + points_spent


func level_cost() -> int:
	return roundi(40.0 * pow(1.12, points_spent))


## Raise one stat at a petilasan. Saves on success.
func level_up(stat: String) -> bool:
	if stat not in STATS or ilmu < level_cost():
		return false
	ilmu -= level_cost()
	stats[stat] += 1
	points_spent += 1
	changed.emit()
	save_game()
	return true


func add_ilmu(amount: int) -> void:
	ilmu += amount
	changed.emit()


func add_item(id: String, save := true) -> void:
	if id not in inventory:
		inventory.append(id)
		changed.emit()
		if save:
			save_game()


func equip(id: String) -> bool:
	var item := ItemData.by_id(id)
	if item == null or id not in inventory:
		return false
	equipped[item.slot] = id
	changed.emit()
	save_game()
	return true


func equipped_item(slot: String) -> ItemData:
	return ItemData.by_id(equipped.get(slot, ""))


## A stat with gear bonuses on top.
func stat(key: String) -> int:
	return stats.get(key, 0) + int(bonus(key))


## Sum of one bonus key over armor and accessory (items.md, ItemData.bonus).
func bonus(key: String) -> float:
	var total := 0.0
	for slot in ["armor", "accessory"]:
		var item := equipped_item(slot)
		if item:
			total += float(item.bonus.get(key, 0.0))
	return total


func learn_glyph(id: String) -> void:
	if id not in glyphs_learned:
		glyphs_learned.append(id)
		changed.emit()
		save_game()
		var ev := get_node_or_null("/root/Events")
		if ev:
			ev.glyph_learned.emit(id)


func learned_glyphs() -> Array[GlyphData]:
	var out: Array[GlyphData] = []
	for id in glyphs_learned:
		out.append(GlyphData.by_id(id))
	return out


# --- flags, quests, codex (quests.md 7) ---

func has_flag(f: String) -> bool:
	var v: Variant = flags.get(f, false)
	if v is bool and v:
		return true
	if f.begins_with("laras_"):
		var alt := f.replace(":", "_") if ":" in f else f.replace("laras_key_", "laras_key:").replace("laras_sabotage_", "laras_sabotage:")
		var va: Variant = flags.get(alt, false)
		return va is bool and va
	match f:
		"lakon_4": return flags.keys().filter(func(k: String) -> bool: return k.begins_with("lakon:") and bool(flags.get(k, false))).size() >= 4
		"lakon_9": return flags.keys().filter(func(k: String) -> bool: return k.begins_with("lakon:") and bool(flags.get(k, false))).size() >= 9
		"codex_25": return codex_percent() >= 25.0
		"codex_50": return codex_percent() >= 50.0
		"codex_75": return codex_percent() >= 75.0
		"codex_100": return codex_percent() >= 100.0
	return false


func set_flag(f: String, save := true) -> void:
	if f == "" or has_flag(f):
		return
	flags[f] = true
	changed.emit()
	if save:
		save_game()


## locked, available, active or done.
func quest_state(id: String) -> String:
	if quests.has(id):
		return quests[id].state
	var q := QuestData.by_id(id)
	if q and q.requires.all(has_flag):
		return "available"
	return "locked"


func current_step(id: String) -> QuestStep:
	var q := QuestData.by_id(id)
	if q == null or quest_state(id) != "active" or int(quests[id].step) >= q.steps.size():
		return null
	return q.steps[int(quests[id].step)]


func start_quest(id: String) -> bool:
	if quest_state(id) != "available":
		return false
	quests[id] = {"state": "active", "step": 0, "count": 0, "resolution": "", "all": 0}
	_emit("quest_started", id)
	if QuestData.by_id(id).steps.is_empty():
		_complete(id)
	else:
		_catch_up(id)
	changed.emit()
	save_game()
	return true


## Advances the current step of every active quest that waits on this event. Cheap: one step each.
func on_event(sig: String, arg: String) -> void:
	if CodexEntry.by_id(arg) != null:
		unlock_codex(arg, false)   # an entry's id is the event arg that unlocks it
	var hit := false
	for id in quests.keys():
		var st := current_step(id)
		if st != null and not st.all.is_empty():
			for i in st.all.size():
				if not _all_bit(id, i) and _matches(str(st.all[i].get("on", "")), sig, arg):
					hit = true
					if _all_hit(id, i):
						break
		elif st != null and (_matches(st.on, sig, arg) or st.alt.has(sig + ":" + arg)):
			hit = true
			if st.alt.has(sig + ":" + arg):
				quests[id].resolution = st.alt[sig + ":" + arg]
			_bump(id)
	if hit:
		changed.emit()
		save_game()


## "sig:arg" exact, bare "sig" for any arg, or a trailing * as a prefix ("item_picked:angklung_*").
func _matches(on: String, sig: String, arg: String) -> bool:
	var ev := sig + ":" + arg
	if on == ev or on == sig or (on.ends_with("*") and ev.begins_with(on.trim_suffix("*"))):
		return true
	if on.begins_with("puzzle_solved:") and sig in ["area_entered", "puzzle_solved"]:
		var pid := on.substr(14)
		return arg == pid or arg == "puzzle_" + pid or "puzzle_" + arg == pid
	if on.begins_with("area_entered:") and sig in ["area_entered", "puzzle_solved"]:
		var tid := on.substr(13)
		return arg == tid or arg == "puzzle_" + tid or "puzzle_" + arg == tid
	if on.begins_with("trial_completed:") and sig in ["area_cleared", "area_entered", "trial_completed"]:
		var trid := on.substr(16)
		return arg == trid or arg == "puzzle_" + trid
	return false


func _bump(id: String) -> void:
	var st := current_step(id)
	quests[id].count = int(quests[id].count) + 1
	if quests[id].count < st.count:
		_emit("quest_updated", id)
		return
	set_flag(st.set_flag, false)
	quests[id].step = int(quests[id].step) + 1
	quests[id].count = 0
	quests[id].all = 0
	if int(quests[id].step) >= QuestData.by_id(id).steps.size():
		_complete(id)
	else:
		_emit("quest_updated", id)
		_catch_up(id)


func _all_bit(id: String, i: int) -> bool:
	return (int(quests[id].get("all", 0)) >> i) & 1 == 1


## Marks trigger i of the current all step done and sets its flag. True when that finished the step.
func _all_hit(id: String, i: int) -> bool:
	var st := current_step(id)
	quests[id].all = int(quests[id].get("all", 0)) | (1 << i)
	set_flag(str(st.all[i].get("set_flag", "")), false)
	for j in st.all.size():
		if not _all_bit(id, j):
			_emit("quest_updated", id)
			return false
	quests[id].count = st.count - 1
	_bump(id)
	return true


## How much of `on` already happened in a way that cannot fire again, capped at `need`: held items and known
## glyphs count each match, a unique kill (boss, elite) already in `killed` meets it (it never respawns).
func _already(on: String, need: int) -> int:
	var kv := on.split(":", true, 1)
	if kv.size() < 2:
		return 0
	var pool := PackedStringArray()
	match kv[0]:
		"boss_defeated", "enemy_killed":
			return need if kv[1] in killed else 0
		"item_picked":
			pool = inventory
		"glyph_learned":
			pool = glyphs_learned
	return mini(need, Array(pool).filter(func(x: String) -> bool: return _matches(on, kv[0], x)).size())


## A step (or all-trigger) that becomes current counts what already happened (_already), so early pickups,
## early glyphs and bosses beaten before the quest started can't soft-lock it.
func _catch_up(id: String) -> void:
	var st := current_step(id)
	if st == null:
		return
	if not st.all.is_empty():
		for i in st.all.size():
			if _already(str(st.all[i].get("on", "")), 1) > 0 and _all_hit(id, i):
				return
		return
	var n := _already(st.on, st.count)
	if n >= st.count:
		quests[id].count = st.count - 1
		_bump(id)
	else:
		quests[id].count = n


func _complete(id: String) -> void:
	var q := QuestData.by_id(id)
	quests[id].state = "done"
	if pinned == id:
		pinned = ""
	var row: Array = QUEST_ILMU.get(q.zone, QUEST_ILMU.tatar_sunda)
	var base: int = row[["S", "M", "L"].find(q.size)] if q.size in ["S", "M", "L"] else 0
	ilmu += base * 3 / 2 if quests[id].get("resolution", "") == "fight" else base   # quests.md 3: fight +50%
	var r := q.rewards
	for item in r.get("items", []):
		add_item(item, false)
	flask_max = mini(6, flask_max + int(r.get("flask_shard", 0)))
	flask_charges = mini(flask_max, flask_charges + int(r.get("flask_shard", 0)))
	herb_pouches = mini(4, herb_pouches + int(r.get("herb_pouch", 0)))
	if r.get("lakon", "") != "":
		set_flag("lakon:" + r.lakon, false)
	for f in r.get("flags", []):
		set_flag(f, false)
	for c in r.get("codex", []):
		unlock_codex(c, false)
	_emit("quest_completed", id)


## The objective to point the arrow at: the pinned side quest, else the first active main quest.
func objective_marker() -> Dictionary:
	for id in _tracked():
		var st := current_step(id)
		if st and not st.marker.is_empty():
			return st.marker
	return {}


## Quests the HUD follows, in order: the pinned side quest, then active main quests.
func _tracked() -> Array:
	var ids: Array = [pinned] if quest_state(pinned) == "active" else []
	for id in quests.keys():
		var q := QuestData.by_id(id)
		if q and q.kind == "main" and quest_state(id) == "active":
			ids.append(id)
	return ids


## The HUD objective line (ui.md 2): the first tracked step's objective, plus "n/count" for counted steps.
func objective_text() -> String:
	for id in _tracked():
		var st := current_step(id)
		if st:
			return tr(st.objective) + (" %d/%d" % [quests[id].count, st.count] if st.count > 1 else "")
	return ""


## The first key bound to an input action, for prompts and hints ("E", "Right Mouse").
func key_name(action: String) -> String:
	var evs := InputMap.action_get_events(action)
	if evs.is_empty():
		return "?"
	var e := evs[0]
	if e is InputEventKey:
		var k: Key = e.keycode
		if e.physical_keycode:   # the label on this keyboard layout (headless has no layout: QWERTY)
			k = e.physical_keycode if DisplayServer.get_name() == "headless" \
					else DisplayServer.keyboard_get_keycode_from_physical(e.physical_keycode)
		return OS.get_keycode_string(k)
	if e is InputEventMouseButton:
		return tr("UI_KEY_LMB") if e.button_index == MOUSE_BUTTON_LEFT else tr("UI_KEY_RMB")
	return e.as_text()


## Pins an active side quest, or unpins it if already pinned.
func pin_quest(id: String) -> void:
	pinned = "" if pinned == id or quest_state(id) != "active" else id
	changed.emit()
	save_game()


func unlock_codex(id: String, save := true) -> void:
	if id == "" or id in codex:
		return
	codex.append(id)
	changed.emit()
	if save:
		save_game()


func codex_percent() -> float:
	var total := CodexEntry.count()
	return 0.0 if total == 0 else 100.0 * codex.size() / total


## Dialogue conditions (quests.md 7.1). Unknown conditions are false.
func check(cond: String) -> bool:
	if cond.strip_edges() == "":
		return true
	if "," in cond:   # "flag:a,!flag:b": all of
		return Array(cond.split(",")).all(func(c: String) -> bool: return check(c.strip_edges()))
	if cond.begins_with("!"):
		return not check(cond.substr(1))
	var kv := cond.split(":", true, 1)
	var arg := kv[1] if kv.size() > 1 else ""
	match kv[0]:
		"flag":
			return has_flag(arg)
		"glyph":
			return arg in glyphs_learned
		"item":
			return arg in inventory
		"quest":
			var p := arg.split("=")
			return p.size() == 2 and quest_state(p[0]) == p[1]
		"step":
			var p := arg.split("=")
			return p.size() == 2 and quest_state(p[0]) == "active" and int(quests[p[0]].step) == int(p[1])
		"zone":   # the area the player is in (Zones.current_zone, set by Zone._ready)
			var z := get_node_or_null("/root/Zones")
			return z != null and z.current_zone == arg
	push_warning("dialogue: unknown condition '%s'" % cond)
	return false


## Dialogue actions (quests.md 7.1).
func run(action: String) -> void:
	var kv := action.split(":", true, 1)
	var arg := kv[1] if kv.size() > 1 else ""
	match kv[0]:
		"start":
			start_quest(arg)
		"give":
			add_item(arg)
			var ev := get_node_or_null("/root/Events")
			if ev:
				ev.item_picked.emit(arg)
		"learn":
			learn_glyph(arg)
		"flag":
			set_flag(arg)
		"codex":
			unlock_codex(arg)
		"lakon":   # same flag as a quest's lakon reward
			set_flag("lakon:" + arg)
		"restore":
			restore()
		"credits":
			get_node("/root/Zones").go_to("res://ui/epilogue.tscn", "")
		"goto":   # goto:<area>:<spawn>; the area may be a scene path, so split at the last colon
			var p := arg.rsplit(":", true, 1)
			if p.size() == 2:
				get_node("/root/Zones").go_to(p[0], p[1])   # actions run after the box closed; this fires zone_entered
			else:
				push_warning("dialogue: goto '%s' needs <area>:<spawn>" % arg)
		"clue":   # clue:<id>, what a Clue runs after its lines (architecture.md 9b)
			set_flag("clue_" + arg)
			_emit("clue_examined", arg)
		"puzzle":
			set_flag("puzzle_" + arg)
			_emit("puzzle_solved", arg)
		"memory":
			get_node("/root/Zones").enter_memory(arg)
		"write":   # write:<seq_id>:<glyph_id>,<glyph_id>,... (ui/glyph_lesson)
			var p := arg.split(":", true, 1)
			if p.size() == 2:
				var ids := Array(p[1].split(",")).map(func(g: String) -> String: return g.strip_edges()).filter(func(g: String) -> bool: return GlyphData.by_id(g) != null)
				if ids.is_empty():
					push_warning("dialogue: write '%s' names no known glyph" % arg)
				else:
					get_node("/root/Events").write_requested.emit(p[0], PackedStringArray(ids))
		"topic":   # topic:<key>, a hub choice's action; play() handles it (script.md 2, topic hubs)
			pass
		_:
			push_warning("dialogue: unknown action '%s'" % action)


## Plays one dialogue entry {"lines": [...], "choices": [{"text": KEY, "do": [...]}], "do": [...]} and returns
## when it is over (await it). `file` is the entry's whole dialogue file (DialogueData.entries); only a hub uses it.
## A hub entry ("hub": true, with choices) goes to _play_hub instead. Contract for every other entry, used by Npc.interact and ui/story_beat.gd:
##   1. emits Events.dialogue_choices (only with choices), then Events.dialogue_requested(name_key, lines);
##   2. waits for Events.dialogue_finished (the box pauses the tree meanwhile);
##   3. runs the picked choice's `do`, then the entry's `do` (every action through run()).
## A line "@KEY" is not shown: it sets the speaker tag for the lines after it. Cancel never skips a choice.
func play(name_key: String, entry: Dictionary, file: Array = []) -> void:
	if entry.get("hub", false) and not entry.get("choices", []).is_empty():
		await _play_hub(name_key, entry, file)
		return
	var ev := get_node("/root/Events")
	var choices: Array = entry.get("choices", [])
	var pick := [-1]   # a lambda cannot assign a captured int
	var on_pick := func(i: int) -> void: pick[0] = i
	if not choices.is_empty():
		ev.dialogue_picked.connect(on_pick)
		ev.dialogue_choices.emit(PackedStringArray(choices.map(func(c: Dictionary) -> String: return c.get("text", ""))))
	if not choices.is_empty() or not entry.get("lines", []).is_empty():   # a do-only entry shows no box (the box would finish before the await)
		ev.dialogue_requested.emit(name_key, PackedStringArray(entry.get("lines", [])))
		await ev.dialogue_finished
	if ev.dialogue_picked.is_connected(on_pick):
		ev.dialogue_picked.disconnect(on_pick)
	if pick[0] >= 0 and pick[0] < choices.size():
		for a: String in choices[pick[0]].get("do", []):
			run(a)
	for a: String in entry.get("do", []):
		run(a)


## "Ask about..." hub (script.md 2, quests.md 7.1 item 2): the hub's lines, then its choices. A choice whose `do`
## has `topic:<key>` runs its other actions, plays topic_entry(file, key), then shows the choices again (no lines).
## A choice without `topic:` (the leave choice) runs its `do`, then the hub's own `do`, and the talk ends.
## Between rounds the box closes and reopens, so Events.dialogue_finished fires once per round.
func _play_hub(name_key: String, entry: Dictionary, file: Array) -> void:
	var choices: Array = entry.get("choices", [])
	var lines := PackedStringArray(entry.get("lines", []))
	while true:
		var i: int = await _ask(name_key, lines, choices)
		lines = PackedStringArray()
		if i < 0 or i >= choices.size():
			break   # no pick (the box did not choose): leave rather than loop
		var topic := ""
		for a: String in choices[i].get("do", []):
			if a.begins_with("topic:"):
				topic = a.substr(6)
			else:
				run(a)
		if topic == "":
			break
		var t := topic_entry(file, topic)
		if not t.is_empty():
			await play(name_key, t)
	for a: String in entry.get("do", []):
		run(a)


## Shows `lines` then `choices` in the box and returns the picked index (-1 if none).
func _ask(name_key: String, lines: PackedStringArray, choices: Array) -> int:
	var ev := get_node("/root/Events")
	var pick := [-1]
	var on_pick := func(i: int) -> void: pick[0] = i
	ev.dialogue_picked.connect(on_pick)
	ev.dialogue_choices.emit(PackedStringArray(choices.map(func(c: Dictionary) -> String: return c.get("text", ""))))
	ev.dialogue_requested.emit(name_key, lines)
	await ev.dialogue_finished
	if ev.dialogue_picked.is_connected(on_pick):
		ev.dialogue_picked.disconnect(on_pick)
	return pick[0]


## The normal first-match entry search: the first entry without a "topic" key whose `if` all holds, or {}.
func pick_entry(entries: Array) -> Dictionary:
	for e: Dictionary in entries:
		if not e.has("topic") and e.get("if", []).all(func(c: String) -> bool: return check(c)):
			return e
	return {}


## The first entry in `entries` with "topic": key whose `if` all holds, or {}.
func topic_entry(entries: Array, key: String) -> Dictionary:
	for e: Dictionary in entries:
		if str(e.get("topic", "")) == key and e.get("if", []).all(func(c: String) -> bool: return check(c)):
			return e
	return {}


## Refill flask, HP and stamina: resting at a petilasan and the `restore` action. Does not save or reload the zone.
func restore() -> void:
	flask_charges = flask_max
	var p: Node = get_tree().get_first_node_in_group("player") if is_inside_tree() else null
	if p and p.get("health") and p.get("stamina"):
		p.health.heal(p.health.max_hp)   # no-op when dead
		p.stamina.refund(p.stamina.max_stamina)
	changed.emit()


func _emit(sig: String, id: String) -> void:
	var ev := get_node_or_null("/root/Events")
	if ev:
		ev.emit_signal(sig, id)


# --- save (rpg.md 11) ---

func to_dict() -> Dictionary:
	var d := {"version": VERSION}
	for k in FIELDS:
		var v: Variant = get(k)
		d[k] = Array(v) if v is PackedStringArray else (v.duplicate(true) if v is Dictionary else v)
	return d


## Merges a saved dictionary onto a fresh default state. Unknown keys are ignored and a field
## with the wrong type keeps its default, so old or hand-edited saves still load.
func from_dict(d: Dictionary) -> void:
	_reset()
	for k in FIELDS:
		if not d.has(k):
			continue
		var cur: Variant = get(k)
		var v: Variant = d[k]
		match typeof(cur):
			TYPE_INT:
				if v is float or v is int:
					set(k, int(v))
			TYPE_FLOAT:
				if v is float or v is int:
					set(k, float(v))
			TYPE_STRING:
				if v is String:
					set(k, v)
			TYPE_PACKED_STRING_ARRAY:
				if v is Array:
					set(k, PackedStringArray(v.map(func(x: Variant) -> String: return str(x))))
			TYPE_DICTIONARY:
				if v is Dictionary:
					var merged: Dictionary = cur
					merged.merge(v, true)
					set(k, merged)
	hero_name = clean_name(hero_name)
	if hero_pronoun not in PRONOUNS:
		hero_pronoun = "they"
	var mp: Variant = memory_return.get("pos")
	if not (memory_return.get("zone") is String and memory_return.zone != "" and mp is Array and mp.size() == 2 \
			and mp.all(func(x: Variant) -> bool: return x is float or x is int)):
		memory_return = {}
	for s in STATS:   # JSON reads numbers back as floats
		stats[s] = int(stats.get(s, 5))
	for id in quests.keys():   # drop malformed quest records from old or hand-edited saves
		var q: Variant = quests[id]
		if q is Dictionary and str(q.get("state", "")) in ["active", "done"]:
			quests[id] = {"state": str(q.state), "step": maxi(0, _num(q.get("step"))), "count": maxi(0, _num(q.get("count"))), "resolution": str(q.get("resolution", "")), "all": maxi(0, _num(q.get("all")))}
		else:
			quests.erase(id)
	changed.emit()


func _num(v: Variant) -> int:
	return int(v) if v is int or v is float else 0


## True while a Kelir memory is the current scene (architecture.md 9b).
func in_memory() -> bool:
	return is_inside_tree() and get_tree().current_scene is KelirMemory


func has_save() -> bool:
	return FileAccess.file_exists(save_path) or FileAccess.file_exists(_bak())


## Write tmp, copy the current save to .bak, rename tmp over the save. A crash mid-write never
## leaves a broken save.json.
func save_game() -> bool:
	if in_memory():
		return false   # no saves inside a Kelir memory: the one made at the clue (with memory_return) resumes there
	var tmp := save_path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_error("save: cannot write %s (%s)" % [tmp, error_string(FileAccess.get_open_error())])
		return false
	f.store_string(JSON.stringify(to_dict(), "\t", true, true))
	var ok := f.get_error() == OK
	f.close()
	if not ok:
		push_error("save: write failed")
		return false
	if FileAccess.file_exists(save_path) and _read(save_path) != null:
		DirAccess.copy_absolute(save_path, _bak())   # keep the last good save only
	if DirAccess.rename_absolute(tmp, save_path) != OK:
		push_error("save: rename failed")
		return false
	saved.emit()
	return true


## Loads save.json, or save.bak if that does not parse. Never deletes a file that failed to load.
func load_game() -> bool:
	for p in [save_path, _bak()]:
		var d: Variant = _read(p)
		if d != null and str(d.get("class_id", "")) != "":   # valid JSON with no run in it is not a save
			from_dict(d)
			return true
	return false


func _read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Dictionary:
		return null
	return json.data


func _bak() -> String:
	return save_path.get_basename() + ".bak"
