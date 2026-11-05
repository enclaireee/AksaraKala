extends Node
## Run state and the single save slot (architecture.md 3, rpg.md 2, 6, 11).
## Everything here is saved. Systems read it and listen to `changed`; the player calls apply_from_game().

signal changed   # ilmu, stats, gear, glyphs or flask changed
signal saved     # HUD shows "Saved" for 1 s

const VERSION := 1
const STATS := ["vit", "end", "str", "dex", "spi"]
const STARTER_GLYPHS: Array[String] = []   # glyphs come from the main quest (quests.md 3.3)
## Quest Ilmu by zone and size S/M/L (quests.md 3.1, TUNE). Desa Purwa uses the Act 1 row for now.
const QUEST_ILMU := {"tatar_sunda": [30, 60, 90], "desa_purwa": [30, 60, 90], "mataram": [55, 110, 165],
	"tanah_timur": [110, 220, 330], "segara_kidul": [190, 380, 570]}
## Quest-trigger signals on Events with one String arg (quests.md 7.2).
const QUEST_SIGNALS := ["talked_to", "item_picked", "boss_defeated", "area_cleared", "area_entered",
	"zone_entered", "petilasan_activated", "glyph_learned", "class_chosen", "weakness_triggered"]
## Saved fields, in to_dict order. Add a field here and in _reset(); old saves get its default.
const FIELDS := ["class_id", "stats", "ilmu", "points_spent", "glyphs_learned", "inventory", "equipped",
	"flask_charges", "flask_max", "herb_pouches", "last_petilasan", "killed", "flags", "play_time", "quests", "codex", "pinned"]

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
var quests := {}                       # id -> {state: active|done, step, count} (quests.md 7.3)
var codex := PackedStringArray()       # unlocked CodexEntry ids
var pinned := ""                       # pinned side quest id, "" follows the main quest


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


func _process(delta: float) -> void:
	if class_id != "":
		play_time += delta   # ponytail: slowed by cast slow-mo; fine for a play clock


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and class_id != "":
		save_game()   # quit is a save trigger (rpg.md 11)


# --- new game, leveling, inventory ---

## Class choice creates the save (rpg.md 11). The old save is replaced only here.
func new_game(cls: ClassData) -> void:
	_reset()
	class_id = cls.id
	stats = cls.stats.duplicate()
	for id in [cls.start_weapon, cls.start_armor]:
		if id != "":
			add_item(id, false)
			equipped[ItemData.by_id(id).slot] = id
	if start_quest("mq0"):
		quests.mq0.step = 3   # 0.1-0.3 (prologue, Semar, class) came before the save (quests.md MQ0)
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
	return v is bool and v


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
	quests[id] = {"state": "active", "step": 0, "count": 0}
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
		if st != null and _matches(st.on, sig, arg):
			hit = true
			_bump(id)
	if hit:
		changed.emit()
		save_game()


## "sig:arg" exact, bare "sig" for any arg, or a trailing * as a prefix ("item_picked:angklung_*").
func _matches(on: String, sig: String, arg: String) -> bool:
	var ev := sig + ":" + arg
	return on == ev or on == sig or (on.ends_with("*") and ev.begins_with(on.trim_suffix("*")))


func _bump(id: String) -> void:
	var st := current_step(id)
	quests[id].count = int(quests[id].count) + 1
	if quests[id].count < st.count:
		_emit("quest_updated", id)
		return
	set_flag(st.set_flag, false)
	quests[id].step = int(quests[id].step) + 1
	quests[id].count = 0
	if int(quests[id].step) >= QuestData.by_id(id).steps.size():
		_complete(id)
	else:
		_emit("quest_updated", id)
		_catch_up(id)


## A collect step counts items already held, so picking them up early can't soft-lock the quest.
func _catch_up(id: String) -> void:
	var st := current_step(id)
	if st == null or not st.on.begins_with("item_picked:"):
		return
	var n := Array(inventory).filter(func(i: String) -> bool: return _matches(st.on, "item_picked", i)).size()
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
	ilmu += row[["S", "M", "L"].find(q.size)] if q.size in ["S", "M", "L"] else 0
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
	var ids: Array = [pinned] if quest_state(pinned) == "active" else []
	for id in quests.keys():
		var q := QuestData.by_id(id)
		if q and q.kind == "main":
			ids.append(id)
	for id in ids:
		var st := current_step(id)
		if st and not st.marker.is_empty():
			return st.marker
	return {}


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
	if cond.begins_with("!"):
		return not check(cond.substr(1))
	var kv := cond.split(":", true, 1)
	var arg := kv[1] if kv.size() > 1 else ""
	match kv[0]:
		"flag":
			return has_flag(arg)
		"glyph":
			return arg in glyphs_learned
		"quest":
			var p := arg.split("=")
			return p.size() == 2 and quest_state(p[0]) == p[1]
		"step":
			var p := arg.split("=")
			return p.size() == 2 and quest_state(p[0]) == "active" and int(quests[p[0]].step) == int(p[1])
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
		_:
			push_warning("dialogue: unknown action '%s'" % action)


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
	for s in STATS:   # JSON reads numbers back as floats
		stats[s] = int(stats.get(s, 5))
	for id in quests.keys():   # drop malformed quest records from old or hand-edited saves
		var q: Variant = quests[id]
		if q is Dictionary and str(q.get("state", "")) in ["active", "done"]:
			quests[id] = {"state": str(q.state), "step": maxi(0, _num(q.get("step"))), "count": maxi(0, _num(q.get("count")))}
		else:
			quests.erase(id)
	changed.emit()


func _num(v: Variant) -> int:
	return int(v) if v is int or v is float else 0


func has_save() -> bool:
	return FileAccess.file_exists(save_path) or FileAccess.file_exists(_bak())


## Write tmp, copy the current save to .bak, rename tmp over the save. A crash mid-write never
## leaves a broken save.json.
func save_game() -> bool:
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
