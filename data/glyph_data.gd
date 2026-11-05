class_name GlyphData extends Resource
## One learnable aksara (spells.md 3, architecture.md 4). Templates are raw strokes, any scale;
## the Recognizer normalizes them. Record more in tools/glyph_recorder.tscn.

@export var id := ""
@export var aksara := "sunda"   # sunda or jawa
@export var latin := ""
@export var templates: Array[PackedVector2Array] = []


static func by_id(glyph_id: String) -> GlyphData:
	return load("res://data/glyphs/%s.tres" % glyph_id)
