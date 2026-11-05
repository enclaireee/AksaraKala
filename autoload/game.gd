extends Node
## Run state and the single save slot (architecture.md 3, rpg.md 2, 6, 11).
## Everything here is saved. Systems read it and listen to `changed`; the player calls apply_from_game().

signal changed   # ilmu, stats, gear, glyphs or flask changed
signal saved     # HUD shows "Saved" for 1 s

const VERSION := 1
const STATS := ["vit", "end", "str", "dex", "spi"]
const STARTER_GLYPHS := ["sunda_ka", "sunda_ga", "sunda_nga"]   # ASSUMED until quests teach glyphs (spells.md 2)
## Saved fields, in to_dict order. Add a field here and in _reset(); old saves get its default.
const FIELDS := ["class_id", "stats", "ilmu", "points_spent", "glyphs_learned", "inventory", "equipped",
	"flask_charges", "flask_max", "herb_pouches", "last_petilasan", "killed", "flags", "play_time"]

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


func learned_glyphs() -> Array[GlyphData]:
	var out: Array[GlyphData] = []
	for id in glyphs_learned:
		out.append(GlyphData.by_id(id))
	return out


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
	changed.emit()


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
