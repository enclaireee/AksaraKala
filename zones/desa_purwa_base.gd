extends Zone
## Hand-written part of Desa Purwa: the sanggar practice mode and draw guide. zones/desa_purwa.gd (generated) extends this.

const GUIDE_RECT := Rect2(380, 20, 80, 80)
var guide: CastOverlay
var _in_sanggar := false


func _ready() -> void:
	super()
	var stage_decor := RuwatanStageDecor.new()
	add_child(stage_decor)
	guide = preload("res://ui/cast_overlay.tscn").instantiate()
	guide.layer = 4
	add_child(guide)
	for t in find_children("*", "Area2D", true, false):
		if t.get("trigger_id") == "sanggar_enter":
			t.body_entered.connect(_sanggar.bind(true))
			t.body_exited.connect(_sanggar.bind(false))
	get_node("/root/Events").glyph_learned.connect(_show_guide.unbind(1))


func _sanggar(body: Node, inside: bool) -> void:
	if body.is_in_group("player"):
		_in_sanggar = inside
		body.cast.practice = inside   # no sakti gate in the sanggar: a new player starts with 0
		_show_guide()


func _show_guide() -> void:
	var g: Array[GlyphData] = get_node("/root/Game").learned_glyphs()
	guide.hide_guide()
	guide.visible = _in_sanggar and not g.is_empty()
	if guide.visible:
		guide.show_guide(g[-1].templates[0], GUIDE_RECT)
