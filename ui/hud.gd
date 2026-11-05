extends Control
## In-play HUD (ui.md 2). Placeholder bars; reads the player's components every frame.
## ponytail: polling instead of signals so a replaced player (scene change) needs no re-bind.

const HP_COL := Color("D55E00")
const ST_COL := Color("F0E442")
const SK_COL := Color("56B4E9")
const FLASK_COL := Color("009E73")
const GOLD := Color("E8D9A0")

var _bars := {}   # name -> [fill ColorRect, width]
var _pips: Array[ColorRect] = []
var _ilmu: Label
var _saved: Label
var _saved_left := 0.0


func _ready() -> void:
	var t := Theme.new()
	t.default_font_size = 8
	theme = t
	_bars.hp = _bar(Vector2(6, 6), 80, 5, HP_COL)
	_bars.st = _bar(Vector2(6, 13), 64, 3, ST_COL)
	_bars.sk = _bar(Vector2(6, 18), 50, 3, SK_COL)
	for i in 6:
		var p := ColorRect.new()
		p.position = Vector2(6 + i * 9, 270 - 6 - 9)
		p.size = Vector2(7, 9)
		add_child(p)
		_pips.append(p)
	_ilmu = Label.new()
	_ilmu.position = Vector2(480 - 6 - 80, 4)
	_ilmu.size = Vector2(80, 12)
	_ilmu.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_ilmu.add_theme_color_override("font_color", GOLD)
	add_child(_ilmu)
	_saved = Label.new()
	_saved.text = "Tersimpan / Saved"
	_saved.position = Vector2(480 - 6 - 90, 270 - 6 - 12)
	_saved.size = Vector2(90, 12)
	_saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_saved.visible = false
	add_child(_saved)
	var g := get_node("/root/Game")
	g.changed.connect(refresh)
	g.saved.connect(func() -> void:
		_saved_left = 1.0
		_saved.visible = true)
	refresh()


func _bar(pos: Vector2, w: int, h: int, col: Color) -> Array:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.position = pos
	bg.size = Vector2(w, h)
	add_child(bg)
	var fill := ColorRect.new()
	fill.color = col
	fill.size = Vector2(w, h)
	bg.add_child(fill)
	return [fill, w]


func _fill(name: String, value: float, max_value: float) -> void:
	var b: Array = _bars[name]
	b[0].size.x = roundf(b[1] * clampf(value / maxf(max_value, 1.0), 0.0, 1.0))


func refresh() -> void:
	var g := get_node("/root/Game")
	_ilmu.text = "Ilmu %d" % g.ilmu
	for i in _pips.size():
		_pips[i].visible = i < g.flask_max
		_pips[i].color = FLASK_COL if i < g.flask_charges else FLASK_COL.darkened(0.7)


func _process(delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		_fill("hp", p.health.hp, p.health.max_hp)
		_fill("st", p.stamina.value, p.stamina.max_stamina)
		_fill("sk", p.sakti.value, p.sakti.max_value)
	if _saved_left > 0.0:
		_saved_left -= delta
		_saved.visible = _saved_left > 0.0
