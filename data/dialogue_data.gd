class_name DialogueData extends Resource
## One NPC's dialogue (quests.md 7.1). File: data/dialogue/<npc_id>.tres.
## entries: [{"if": [conditions], "lines": [keys], "do": [actions]}]. First match plays; no "if" = fallback.

@export var npc_id := ""
@export var name_key := ""
@export var entries: Array[Dictionary] = []


## The first entry whose conditions all hold under Game.check, or {} if none.
func pick(game: Node) -> Dictionary:
	for e in entries:
		if e.get("if", []).all(func(c: String) -> bool: return game.check(c)):
			return e
	return {}


static func by_id(id: String) -> DialogueData:
	var path := "res://data/dialogue/%s.tres" % id
	return load(path) if id != "" and ResourceLoader.exists(path) else null
