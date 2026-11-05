extends Node2D
## Sanggar (practice hall, spells.md 5): draw any learned glyph with no sakti gate or cost and see the score.
## A second CastOverlay stays visible just for the ghost guide.

const LAYOUT_W := 30
const LAYOUT_H := 17
const ALL_GLYPHS := ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra"]
const GUIDE_RECT := Rect2(380, 20, 80, 80)   # top-right corner of the 480x270 screen

@onready var player: Player = $Entities/Player
@onready var guide: CastOverlay = $Guide
@onready var label: Label = $Hud/Score

var index := 0
var guide_on := true


func _ready() -> void:
	var tiles: TileMapLayer = $Tiles
	for y in LAYOUT_H:
		for x in LAYOUT_W:
			var wall := x == 0 or y == 0 or x == LAYOUT_W - 1 or y == LAYOUT_H - 1
			tiles.set_cell(Vector2i(x, y), 0, Vector2i(2 if wall else (x + y) % 2, 0))
	player.cast.practice = true
	player.cast.read.connect(_on_read)
	guide.visible = true
	_show()


func _unhandled_input(event: InputEvent) -> void:
	# ponytail: raw keys until the sanggar gets an NPC menu; 1-9 pick a learned glyph, G toggles the guide
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var n: int = event.physical_keycode - KEY_1
	if n >= 0 and n < _glyphs().size():
		index = n
		_show()
	elif event.physical_keycode == KEY_G:
		guide_on = not guide_on
		_show()
	elif event.physical_keycode == KEY_F3:
		# ponytail: debug, not saved. Jawa Ka (Ombak) is P1, so it stays out.
		get_node("/root/Game").glyphs_learned = PackedStringArray(ALL_GLYPHS)
		_show()


func _glyphs() -> Array[GlyphData]:
	return get_node("/root/Game").learned_glyphs()


func _show() -> void:
	var g: GlyphData = _glyphs()[index]
	guide.hide_guide()
	if guide_on:
		guide.show_guide(g.templates[0], GUIDE_RECT)
	var keys := ""
	for i in _glyphs().size():
		keys += "%d %s  " % [i + 1, _glyphs()[i].latin.capitalize()]
	label.text = "Sanggar: draw %s (hold right mouse)\n%s G guide  F3 learn all" % [g.latin.capitalize(), keys]


func _on_read(r: Dictionary) -> void:
	var g: GlyphData = r.glyph
	var score: float = r.score
	var power: float = r.power
	var verdict := "full power" if power >= 1.0 else "smudged, 70%" if power > 0.0 else "fizzle"
	var target: GlyphData = _glyphs()[index]
	var name := g.latin.capitalize() if g else "?"
	label.text = "Read %s %.2f: %s%s\n(target %s; 0.80 full, 0.65 smudged)" % [
		name, score, verdict, "" if g == target or power == 0.0 else "  WRONG GLYPH", target.latin.capitalize()]
