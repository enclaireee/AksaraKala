extends Control
## Class choice: 4 cards, a confirm step, Back (ui.md 3, classes.md). The old save is replaced only on confirm.

var cards: Array[Control] = []
var _confirm: VBoxContainer
var _confirm_lbl: Label
var _chosen: ClassData
var _row: HBoxContainer
var _back: Button


func _ready() -> void:
	var t := Theme.new()
	t.default_font_size = 8
	theme = t
	var bg := ColorRect.new()
	bg.color = Color("14110f")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	_row = HBoxContainer.new()
	_row.position = Vector2(6, 10)
	_row.size = Vector2(468, 220)
	_row.add_theme_constant_override("separation", 4)
	add_child(_row)
	for id in ClassData.IDS:
		var c := ClassData.by_id(id)
		if c:
			_card(c)
	_back = Button.new()
	_back.text = "Kembali / Back"
	_back.position = Vector2(6, 240)
	_back.size = Vector2(90, 20)
	_back.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://ui/title.tscn"))
	add_child(_back)
	_confirm = VBoxContainer.new()
	_confirm.position = Vector2(150, 100)
	_confirm.size = Vector2(180, 60)
	_confirm.visible = false
	add_child(_confirm)
	_confirm_lbl = Label.new()
	_confirm_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm.add_child(_confirm_lbl)
	var yes := Button.new()
	yes.text = "Ya / Yes"
	yes.pressed.connect(_go)
	_confirm.add_child(yes)
	var no := Button.new()
	no.text = "Batal / Cancel"
	no.pressed.connect(_show_cards)
	_confirm.add_child(no)
	_show_cards()


func _card(c: ClassData) -> void:
	var p := PanelContainer.new()
	p.custom_minimum_size.x = 111
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	p.add_child(v)
	var w := ItemData.by_id(c.start_weapon)
	var st := " ".join(STATS.map(func(s: String) -> String: return "%s %d" % [s.to_upper(), c.stats.get(s, 0)]))
	for text in [c.title, c.description, st, "Senjata / Weapon: " + (w.title if w else c.start_weapon),
			"%s: %s" % [c.passive, c.passive_text]]:
		var l := Label.new()
		l.text = text
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 100
		v.add_child(l)
	var b := Button.new()
	b.text = "Pilih / Choose"
	b.pressed.connect(_ask.bind(c))
	v.add_child(b)
	_row.add_child(p)
	cards.append(p)


const STATS := ["vit", "end", "str", "dex", "spi"]


func _show_cards() -> void:
	_confirm.visible = false
	_row.visible = true
	_back.visible = true
	if cards.size() > 0:
		cards[0].get_child(0).get_child(-1).grab_focus()


func _ask(c: ClassData) -> void:
	_chosen = c
	_confirm_lbl.text = "Pilih %s? / Choose %s?" % [c.title, c.title]
	_row.visible = false
	_back.visible = false
	_confirm.visible = true
	_confirm.get_child(1).grab_focus()


func _go() -> void:
	get_node("/root/Game").new_game(_chosen)
	get_node("/root/Zones").start_new_game()
