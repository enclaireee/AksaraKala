extends SceneTree
## Every `give:` names a real item (or a key token), and every item in data/items has a source:
## a dialogue/beat give, a class start, a quest reward or a zone chest/drop (verification.md 5.3 B1, B2).

const TOKENS := ["boeh_rarang", "distraction"]   # key tokens checked by `item:` conds, not gear

var fails := 0


func _initialize() -> void:
	var text := ""
	for dir in ["res://data/dialogue", "res://data/quests", "res://data/classes", "res://zones", "res://entities"]:
		text += _read_all(dir)
	var gives := RegEx.create_from_string("\"give:([a-z0-9_]+)\"")
	for m in gives.search_all(text):
		var id := m.get_string(1)
		check(id in TOKENS or ResourceLoader.exists("res://data/items/%s.tres" % id), "give:%s names no item" % id)
	for f in DirAccess.get_files_at("res://data/items"):
		if f.ends_with(".tres"):
			var id := f.get_basename()
			check(RegEx.create_from_string("\\b%s\\b" % id).search(text) != null, "item %s has no source" % id)
	quit(1 if fails else 0)


func _read_all(dir: String) -> String:
	var out := ""
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".tres") or f.ends_with(".gd") or f.ends_with(".tscn"):
			out += FileAccess.get_file_as_string(dir + "/" + f) + "\n"
	for d in DirAccess.get_directories_at(dir):
		out += _read_all(dir + "/" + d)
	return out


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		print("FAIL: ", msg)
