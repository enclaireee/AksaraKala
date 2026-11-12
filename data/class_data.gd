class_name ClassData extends Resource
## One class (classes.md). File: data/classes/<id>.tres. Passive and spell-modifier logic lives in code, keyed by id.

@export var id := ""                     # one of IDS
@export var title := ""
@export_multiline var description := ""
@export var stats := {"vit": 5, "end": 5, "str": 5, "dex": 5, "spi": 5}
@export var start_weapon := ""           # item ids
@export var start_armor := "padded_tunic"
@export var passive := ""                # text key of the passive name
@export_multiline var passive_text := ""

const IDS := ["warrior", "lancer", "archer", "herder", "rogue", "dancer", "mage", "dalang"]
## Spell school (classes.md Schools): the class whose spell set, spell costs and spell damage this class uses.
const SCHOOL := {"lancer": "warrior", "herder": "archer", "dancer": "rogue", "dalang": "mage"}


static func school(class_id: String) -> String:
	return str(SCHOOL.get(class_id, class_id))


static func by_id(class_id: String) -> ClassData:
	var path := "res://data/classes/%s.tres" % class_id
	return load(path) if class_id != "" and ResourceLoader.exists(path) else null
