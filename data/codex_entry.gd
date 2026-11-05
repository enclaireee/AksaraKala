class_name CodexEntry extends Resource
## One codex entry (quests.md 7.1). File: data/codex/<id>.tres. Keys CODEX_<ID>_TITLE, _BODY, _WEAK.
## The id equals the event arg that unlocks it: an enemy kind, item id, glyph id, npc id or boss id.

static var dir := "res://data/codex"   # tests point this at user:// fixtures

@export var id := ""
@export_enum("enemy", "legend", "item", "aksara") var category := "legend"
@export var source := ""   # citation line (Phase 7 fills these in)


static func by_id(entry_id: String) -> CodexEntry:
	var path := dir + "/%s.tres" % entry_id
	return load(path) if entry_id != "" and ResourceLoader.exists(path) else null


static func count() -> int:
	return Array(DirAccess.get_files_at(dir)).filter(func(f: String) -> bool: return ".tres" in f).size()
