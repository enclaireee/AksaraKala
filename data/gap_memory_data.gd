class_name GapMemoryData extends Resource
## One gap memory (architecture.md 9b "Gap memory"). File: data/memories/gap_<la|ra|sa>.tres, played in zones/kelir/gap.tscn.

@export var memory_id := ""    # the memory_done:<id> id (quests.md 5.1: la, ra, sa)
@export var scene_spot := ""   # which prologue-day spot the scene copies (desa_purwa.md), for the builder
## [{gap_id, pos: Vector2i (tile), prompt_key: GAP_<ID>_P, options: [GAP_<ID>_1..3] (a key, or {key, icon}), correct: key}]
@export var gaps: Array[Dictionary] = []


## An option's text key: options are plain keys or {key, icon}.
static func option_key(o: Variant) -> String:
	return o if o is String else str(o.get("key", "")) if o is Dictionary else ""
