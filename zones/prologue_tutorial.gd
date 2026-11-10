extends Node2D
## Prologue Combat & Gameplay Tutorial Scene (Sanggar Ki Semar).
## Teaches core verbs in the prologue story:
## 1. Movement & Dodging (stamina awareness)
## 2. Basic attacks & 3-hit combo on straw training dummy
## 3. Jamu healing flask (vitality restoration)
## 4. Exit to Desa Purwa to meet Laras for the Ruwatan festival.

enum Stage {
	INTRO,
	DODGE,
	ATTACK,
	JAMU,
	COMPLETE,
}

var _stage: Stage = Stage.INTRO
var _hits := 0
var _busy := false
var _waiting_dialogue := ""
var _game: Node
var _ev: Node

var _prompt_card: PanelContainer
var _prompt_label: Label
var _gate_glow: Node2D


func _ready() -> void:
	if has_node("/root/Game"):
		_game = get_node("/root/Game")
	if has_node("/root/Events"):
		_ev = get_node("/root/Events")
	
	_paint_tiles()
	_setup_gate()
	_setup_prompt_ui()
	_connect_events()
	
	var player := _get_player()
	if player:
		var cam := player.get_node_or_null("Camera")
		if cam and cam.has_method("set_bounds"):
			cam.set_bounds(Rect2(0, 0, 480, 272))
	
	# Start opening intro after scene settles
	if get_tree():
		get_tree().create_timer(0.4).timeout.connect(_start_intro)


func _paint_tiles() -> void:
	var tiles: TileMapLayer = $Tiles
	tiles.clear()
	# 30x17 layout: 480x272 px
	for y in 17:
		for x in 30:
			var is_wall := (x <= 1 or x >= 28 or y <= 1 or y >= 15)
			# Exit opening at rows 7, 8, 9 on the east wall
			if x >= 28 and (y >= 7 and y <= 9):
				is_wall = false
			
			if is_wall:
				tiles.set_cell(Vector2i(x, y), 0, Vector2i(4, 0)) # solid wall with collision
			elif x >= 8 and x <= 22 and y >= 4 and y <= 12:
				tiles.set_cell(Vector2i(x, y), 0, Vector2i(3, 0)) # wooden sparring dojo floor
			elif (x >= 23 and (y >= 7 and y <= 9)) or (x >= 3 and x <= 7 and (y >= 7 and y <= 9)):
				tiles.set_cell(Vector2i(x, y), 0, Vector2i(0, 0)) # stone path
			else:
				tiles.set_cell(Vector2i(x, y), 0, Vector2i(1, 0)) # courtyard grass


func _setup_gate() -> void:
	var exit: Area2D = $ExitGate
	if not exit.body_entered.is_connected(_on_gate_entered):
		exit.body_entered.connect(_on_gate_entered)
	
	# Golden glow marker for the exit
	_gate_glow = Node2D.new()
	_gate_glow.position = exit.position
	_gate_glow.visible = false
	add_child(_gate_glow)
	
	var spr := Sprite2D.new()
	spr.texture = preload("res://assets/art/ui/bullet_now.png")
	spr.scale = Vector2(2.5, 2.5)
	spr.modulate = UIFx.GOLD
	_gate_glow.add_child(spr)


func _setup_prompt_ui() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 8
	add_child(hud)
	
	_prompt_card = PanelContainer.new()
	_prompt_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt_card.custom_minimum_size = Vector2(280, 20)
	
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(UIFx.INK_BG, 0.88)
	sb.border_color = UIFx.GOLD
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	_prompt_card.add_theme_stylebox_override("panel", sb)
	
	_prompt_label = Label.new()
	_prompt_label.add_theme_font_override("font", UIFx.body_font())
	_prompt_label.add_theme_font_size_override("font_size", UIFx.BODY)
	_prompt_label.add_theme_color_override("font_color", UIFx.CREAM)
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt_card.add_child(_prompt_label)
	
	_prompt_card.position = Vector2(round((480.0 - 280.0) * 0.5), 236)
	_prompt_card.visible = false
	hud.add_child(_prompt_card)


func _connect_events() -> void:
	if _ev:
		if not _ev.player_dodged.is_connected(_on_player_dodged):
			_ev.player_dodged.connect(_on_player_dodged)
		if not _ev.player_struck.is_connected(_on_player_struck):
			_ev.player_struck.connect(_on_player_struck)
		if not _ev.player_drank.is_connected(_on_player_drank):
			_ev.player_drank.connect(_on_player_drank)
		if not _ev.dialogue_finished.is_connected(_on_dialogue_finished):
			_ev.dialogue_finished.connect(_on_dialogue_finished)
		if not _ev.dialogue_picked.is_connected(_on_dialogue_picked):
			_ev.dialogue_picked.connect(_on_dialogue_picked)
	
	var semar := $Entities/Semar
	if semar and semar.has_signal("talked") and not semar.talked.is_connected(_on_semar_talk):
		semar.talked.connect(_on_semar_talk)


func _process(_delta: float) -> void:
	if _prompt_card == null:
		return
	var box := get_node_or_null("GameUI/DialogueBox")
	var in_dialogue: bool = box != null and box.is_open()
	_prompt_card.visible = (_stage != Stage.INTRO) and not in_dialogue


func _set_prompt(text: String) -> void:
	if _prompt_label == null:
		_setup_prompt_ui()
	if _prompt_label == null:
		return
	_prompt_label.text = text
	var text_w := UIFx.body_font().get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, UIFx.BODY).x
	var w := clampf(text_w + 24.0, 200.0, 420.0)
	_prompt_card.size = Vector2(w, 20)
	_prompt_card.position = Vector2(round((480.0 - w) * 0.5), 236)
	_prompt_card.visible = true


func _start_intro() -> void:
	_busy = true
	_waiting_dialogue = "intro"
	if _ev:
		_ev.dialogue_choices.emit(PackedStringArray(["TUT_CHOICE_PRACTICE", "TUT_CHOICE_SKIP"]))
		_ev.dialogue_requested.emit("@NPC_SEMAR_NAME", PackedStringArray([
			"TUT_SEMAR_INTRO_1",
			"TUT_SEMAR_INTRO_2",
		]))


func _on_dialogue_picked(idx: int) -> void:
	if _waiting_dialogue == "intro" or _waiting_dialogue == "semar_talk":
		if idx == 1:
			_advance_to_complete(true)
		else:
			if _stage == Stage.INTRO:
				_advance_to_dodge()
	_waiting_dialogue = ""


func _on_dialogue_finished() -> void:
	_busy = false


func _key_name(action: String) -> String:
	if _game == null:
		_game = get_node_or_null("/root/Game")
	if _game and _game.has_method("key_name"):
		return _game.key_name(action)
	match action:
		"dodge": return "Space"
		"attack": return "J"
		"heal_jamu": return "Q"
		"move_up": return "W"
		"move_left": return "A"
		"move_down": return "S"
		"move_right": return "D"
	return action.to_upper()


func _advance_to_dodge() -> void:
	_stage = Stage.DODGE
	var keys := {
		"move": "[%s%s%s%s]" % [_key_name("move_up"), _key_name("move_left"), _key_name("move_down"), _key_name("move_right")],
		"dodge": "[%s]" % _key_name("dodge")
	}
	_set_prompt(tr("UI_TUT_PROMPT_DODGE").format(keys))
	if _ev:
		_ev.dialogue_requested.emit("@NPC_SEMAR_NAME", PackedStringArray(["TUT_SEMAR_DODGE_1"]))


func _on_player_dodged() -> void:
	if _stage != Stage.DODGE:
		return
	Snd.play("ui_page", 0.0, 1.0, 0.04)
	_advance_to_attack()


func _advance_to_attack() -> void:
	_stage = Stage.ATTACK
	_hits = 0
	var keys := {
		"attack": "[%s]" % _key_name("attack"),
		"got": "0"
	}
	_set_prompt(tr("UI_TUT_PROMPT_ATTACK").format(keys))
	if _ev:
		_ev.dialogue_requested.emit("@NPC_SEMAR_NAME", PackedStringArray([
			"TUT_SEMAR_DODGE_2",
			"TUT_SEMAR_DODGE_3",
			"TUT_SEMAR_ATTACK_1",
		]))


func _on_player_struck(_combo: int) -> void:
	if _stage != Stage.ATTACK:
		return
	_hits += 1
	var keys := {
		"attack": "[%s]" % _key_name("attack"),
		"got": str(mini(_hits, 3))
	}
	_set_prompt(tr("UI_TUT_PROMPT_ATTACK").format(keys))
	if _hits >= 3:
		_advance_to_jamu()


func _advance_to_jamu() -> void:
	_stage = Stage.JAMU
	var player := _get_player()
	if player and player.get("health"):
		player.health.hp = maxi(1, player.health.hp - 15)
		player.health.changed.emit(player.health.hp, player.health.max_hp)
	
	var keys := {
		"heal_jamu": "[%s]" % _key_name("heal_jamu")
	}
	_set_prompt(tr("UI_TUT_PROMPT_JAMU").format(keys))
	if _ev:
		_ev.dialogue_requested.emit("@NPC_SEMAR_NAME", PackedStringArray([
			"TUT_SEMAR_ATTACK_2",
			"TUT_SEMAR_JAMU_1",
			"TUT_SEMAR_JAMU_2",
		]))


func _on_player_drank() -> void:
	if _stage != Stage.JAMU:
		return
	_advance_to_complete(false)


func _advance_to_complete(skipped: bool) -> void:
	_stage = Stage.COMPLETE
	
	# Open gate barrier
	var barrier := get_node_or_null("GateBarrier/CollisionShape2D") as CollisionShape2D
	if barrier:
		barrier.disabled = true
	if _gate_glow:
		_gate_glow.visible = true
	
	_set_prompt(tr("UI_TUT_PROMPT_EXIT"))
	
	if _ev:
		if skipped:
			_ev.dialogue_requested.emit("@NPC_SEMAR_NAME", PackedStringArray([
				"TUT_SEMAR_SKIP_CONFIRM",
			]))
		else:
			_ev.dialogue_requested.emit("@NPC_CEPOT_NAME", PackedStringArray([
				"TUT_CEPOT_DONE_1",
			]))
			_ev.dialogue_requested.emit("@NPC_SEMAR_NAME", PackedStringArray([
				"TUT_SEMAR_DONE_1",
				"TUT_SEMAR_DONE_2",
			]))


func _on_semar_talk() -> void:
	if _busy:
		return
	_busy = true
	_waiting_dialogue = "semar_talk"
	var lines := PackedStringArray()
	match _stage:
		Stage.DODGE:
			lines.append("TUT_SEMAR_REMIND_DODGE")
		Stage.ATTACK:
			lines.append("TUT_SEMAR_REMIND_ATTACK")
		Stage.JAMU:
			lines.append("TUT_SEMAR_REMIND_JAMU")
		Stage.COMPLETE:
			lines.append("TUT_SEMAR_REMIND_DONE")
		_:
			lines.append("TUT_SEMAR_INTRO_2")
	
	if _stage != Stage.COMPLETE:
		_ev.dialogue_choices.emit(PackedStringArray(["TUT_CHOICE_PRACTICE", "TUT_CHOICE_SKIP"]))
	_ev.dialogue_requested.emit("@NPC_SEMAR_NAME", lines)


func _on_gate_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_finish_tutorial()


func _finish_tutorial() -> void:
	_game.set_flag("prologue_tutorial_done")
	_game.restore()   # Refills jamu flask & health for the village start
	_game.save_game()
	get_node("/root/Zones").go_to("desa_purwa", "start")


func _get_player() -> Node2D:
	var pl := get_node_or_null("Entities/Player") as Node2D
	if pl != null:
		return pl
	var tree := get_tree()
	if tree != null:
		return tree.get_first_node_in_group("player") as Node2D
	return null
