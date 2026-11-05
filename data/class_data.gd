class_name ClassData extends Resource
## One class (classes.md). File: data/classes/<id>.tres. Passive and spell-modifier logic lives in code, keyed by id.

@export var id := ""                     # warrior, archer, rogue, mage
@export var title := ""
@export_multiline var description := ""
@export var stats := {"vit": 5, "end": 5, "str": 5, "dex": 5, "spi": 5}
@export var start_weapon := ""           # item ids
@export var start_armor := "padded_tunic"
@export var passive := ""                # Iron Skin, Eagle Eye, Light Step, Keen Mind
@export_multiline var passive_text := ""

const IDS := ["warrior", "archer", "rogue", "mage"]


static func by_id(class_id: String) -> ClassData:
	var path := "res://data/classes/%s.tres" % class_id
	return load(path) if class_id != "" and ResourceLoader.exists(path) else null
