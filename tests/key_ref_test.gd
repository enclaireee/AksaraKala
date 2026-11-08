extends SceneTree
## Every text key the data references resolves to a CSV row: dialogue lines and name_key, quest objective/recap keys,
## and CLUE_<ID>_1 for every Clue placed in a built zone (a memory clue may have none: it pulls you straight in).
## MEM_* keys are not required yet.

const LATER: Array[String] = []

var fails := 0
var keys := {}


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func ref(k: String, where: String) -> void:
	if k != "" and k != "@":
		check(keys.has(k), "%s: dangling key %s" % [where, k])


func _initialize() -> void:
	await process_frame
	for f in ["ui", "dialogue", "quests", "codex", "items"]:
		var fa := FileAccess.open("res://data/text/%s.csv" % f, FileAccess.READ)
		fa.get_csv_line()
		while not fa.eof_reached():
			var r := fa.get_csv_line()
			if r[0] != "":
				keys[r[0]] = true
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if f.ends_with(".tres"):
			var d: DialogueData = load("res://data/dialogue/" + f)
			ref(d.name_key, f)
			for e in d.entries:
				for l: String in e.get("lines", []):
					if l.begins_with("#"):   # scene cue, not a text key
						continue
					ref(l.trim_prefix("@"), f)
	for q in QuestData.all():
		for s in q.steps:
			ref(s.objective, q.id)
			ref(s.recap, q.id)
			for a: Dictionary in s.all:
				ref(a.get("objective", ""), q.id)
	var zones := root.get_node("Zones")
	for id: String in zones.ZONES:
		if id == "hub":
			continue
		var z := (load(zones.ZONES[id]) as PackedScene).instantiate()
		root.add_child(z)
		await process_frame
		for n in z.find_children("*", "Clue", true, false):
			if n.lines.is_empty() and n.memory_id == "" and n.clue_id not in LATER:
				ref("CLUE_%s_1" % n.clue_id.to_upper(), "zone " + id)
			for l in n.lines:
				ref(l, "zone %s clue %s" % [id, n.clue_id])
		z.free()
	quit(1 if fails > 0 else 0)
