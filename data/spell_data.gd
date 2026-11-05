class_name SpellData extends Resource
## One spell, keyed by the glyph that casts it (spells.md 3). File: data/spells/<glyph_id>.tres.
## The scene's root script gets caster, data, direction and power set before it enters the tree.

@export var glyph_id := ""
@export var title := ""            # Bolt, Ward, Bind
@export var cost := 15.0           # sakti
@export var power := 30.0          # damage or absorb (TUNE)
@export var duration := 0.0        # seconds, 0 if instant
@export var radius := 0.0          # px, 0 if not an area
@export var scene: PackedScene


static func for_glyph(glyph_id: String) -> SpellData:
	var path := "res://data/spells/%s.tres" % glyph_id
	return load(path) if ResourceLoader.exists(path) else null
