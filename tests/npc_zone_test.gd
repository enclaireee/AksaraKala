extends SceneTree
## A dialogue entry gated on `zone:X` can only fire if that NPC stands in zone X (verification.md 5.3 B3).

var fails := 0


func _initialize() -> void:
	var zone_re := RegEx.create_from_string("\"zone:([a-z0-9_]+)\"")
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if not f.ends_with(".tres") or f == "beats.tres":
			continue
		var npc := f.get_basename()
		var seen := {}
		for m in zone_re.search_all(FileAccess.get_file_as_string("res://data/dialogue/" + f)):
			var z := m.get_string(1)
			if seen.has(z):
				continue
			seen[z] = true
			var src := FileAccess.get_file_as_string("res://zones/%s.gd" % z)
			check(src.contains("\"%s\"" % npc), "%s has a zone:%s entry but is not placed there" % [npc, z])
	quit(1 if fails else 0)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		print("FAIL: ", msg)
