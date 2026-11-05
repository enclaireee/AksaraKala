class_name GameMenu extends Control
## Tab menu: Status (level-up at a petilasan) and Equipment (ui.md 3, rpg.md 2, 6, 7).
## ponytail: Aksara, Journal and Codex tabs wait for their systems; no Q/E tab keys (click or arrows).

const GOLD := Color("E8D9A0")
const NAMES := {"vit": "Vitality", "end": "Endurance", "str": "Strength", "dex": "Dexterity", "spi": "Spirit"}
const HINTS := {
	"vit": "Max HP +10",
	"end": "Max stamina +6, regen +1%",
	"str": "Melee damage +5%",
	"dex": "Ranged damage +5%, attack speed +1%",
	"spi": "Spell damage +5%, sakti gain +2%",
}
const SLOTS := ["weapon", "armor", "accessory"]

var at_petilasan := false
var _pending := ""
var _tabs: TabContainer
var _summary: Label
var _hint: Label
var _raise := {}   # stat -> Button
var _stat_lbl := {}
var _confirm: HBoxContainer
var _confirm_lbl: Label
var _confirm_yes: Button
var _equip: VBoxContainer


func _ready() -> void:
	add_to_group("game_menu")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var t := Theme.new()
	t.default_font_size = 8
	theme = t
	var panel := Panel.new()
	panel.position = Vector2(60, 20)
	panel.size = Vector2(360, 230)
	add_child(panel)
	_tabs = TabContainer.new()
	_tabs.set_anchors_preset(PRESET_FULL_RECT)
	panel.add_child(_tabs)
	_build_status()
	_equip = VBoxContainer.new()
	_equip.name = "Equipment"
	_tabs.add_child(_equip)
	var g := get_node("/root/Game")
	g.changed.connect(refresh)
	get_node("/root/Events").rested.connect(func(_p: Node2D) -> void: open(true))


func _build_status() -> void:
	var v := VBoxContainer.new()
	v.name = "Status"
	_tabs.add_child(v)
	_summary = Label.new()
	v.add_child(_summary)
	for s in NAMES:
		var row := HBoxContainer.new()
		v.add_child(row)
		var l := Label.new()
		l.custom_minimum_size.x = 200
		row.add_child(l)
		_stat_lbl[s] = l
		var b := Button.new()
		b.text = "+"
		b.custom_minimum_size = Vector2(24, 14)
		b.pressed.connect(_ask.bind(s))
		row.add_child(b)
		_raise[s] = b
	_hint = Label.new()
	v.add_child(_hint)
	_confirm = HBoxContainer.new()
	_confirm.visible = false
	v.add_child(_confirm)
	_confirm_lbl = Label.new()
	_confirm.add_child(_confirm_lbl)
	_confirm_yes = Button.new()
	_confirm_yes.text = "Ya / Yes"
	_confirm_yes.pressed.connect(_do_raise)
	_confirm.add_child(_confirm_yes)
	var no := Button.new()
	no.text = "Batal / Cancel"
	no.pressed.connect(_cancel)
	_confirm.add_child(no)


func open(petilasan := false) -> void:
	at_petilasan = petilasan
	visible = true
	var pl := get_tree().get_first_node_in_group("player")
	if pl and pl.get("cast"):
		pl.cast.cancel()   # a paused tree never sees the cast release: slow-mo would stick
	get_tree().paused = true
	_cancel()
	refresh()
	var first: Button = _raise.vit
	for s in _raise:
		if not _raise[s].disabled:
			first = _raise[s]
			break
	first.grab_focus()


func close() -> void:
	visible = false
	at_petilasan = false
	get_tree().paused = false


func _input(e: InputEvent) -> void:
	if e.is_action_pressed("menu"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
	elif visible and e.is_action_pressed("pause"):
		if _pending != "":
			_cancel()
		else:
			close()
		get_viewport().set_input_as_handled()


func _ask(stat: String) -> void:
	_pending = stat
	_confirm_lbl.text = "Naikkan %s? / Raise %s? (%d Ilmu) " % [NAMES[stat], NAMES[stat], get_node("/root/Game").level_cost()]
	_confirm.visible = true
	_confirm_yes.grab_focus()


func _do_raise() -> void:
	if _pending != "":
		get_node("/root/Game").level_up(_pending)
	_cancel()


func _cancel() -> void:
	var s := _pending
	_pending = ""
	_confirm.visible = false
	if s != "" and _raise[s].is_inside_tree() and not _raise[s].disabled:
		_raise[s].grab_focus()


func refresh() -> void:
	var g := get_node("/root/Game")
	var can: bool = at_petilasan and g.ilmu >= g.level_cost()
	_summary.text = "Level %d   Ilmu %d   Next: %d" % [g.level(), g.ilmu, g.level_cost()]
	_hint.text = "" if at_petilasan else "Rest at a petilasan to level up / Istirahat di petilasan untuk naik level"
	for s in NAMES:
		_stat_lbl[s].text = "%s %d  (%s)" % [NAMES[s], g.stat(s), HINTS[s]]
		_raise[s].disabled = not can
	if not can:
		_confirm.visible = false
	_refresh_equipment(g)


func _refresh_equipment(g: Node) -> void:
	for c in _equip.get_children():
		_equip.remove_child(c)
		c.queue_free()
	for slot in SLOTS:
		var h := Label.new()
		h.text = slot.capitalize()
		_equip.add_child(h)
		for id in g.inventory:
			var item := ItemData.by_id(id)
			if item == null or item.slot != slot:
				continue   # ponytail: an item whose data is missing is not listed
			var b := Button.new()
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.text = ("> " if g.equipped.get(slot, "") == id else "  ") + item.title
			b.pressed.connect(g.equip.bind(id))
			if item.mythic:
				b.add_theme_color_override("font_color", GOLD)
			_equip.add_child(b)
			if item.mythic:
				var l := Label.new()
				l.text = "   " + item.lore
				l.add_theme_color_override("font_color", GOLD)
				_equip.add_child(l)
