class_name QuestData extends Resource
## One quest (quests.md 7.1). File: data/quests/<id>.tres. Title key Q_<ID>_TITLE.

static var dir := "res://data/quests"   # tests point this at user:// fixtures

@export var id := ""
@export_enum("main", "side") var kind := "side"
@export_enum("main", "retelling", "bounty", "errand", "meta") var type := "errand"
@export var zone := ""
@export_enum("S", "M", "L") var size := "S"
@export var giver := ""             # npc_id
@export var requires: Array[String] = []   # flags that must all be set before it is available
@export var steps: Array[QuestStep] = []
## {items: [...], flask_shard: n, herb_pouch: n, lakon: "", flags: [...], codex: [...]}
@export var rewards := {}


static func by_id(quest_id: String) -> QuestData:
	var path := dir + "/%s.tres" % quest_id
	return load(path) if quest_id != "" and ResourceLoader.exists(path) else null


static func all() -> Array[QuestData]:
	var out: Array[QuestData] = []
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".tres") or f.ends_with(".tres.remap"):
			out.append(load(dir + "/" + f.trim_suffix(".remap")))
	return out
