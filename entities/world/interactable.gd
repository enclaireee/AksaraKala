class_name Interactable extends Area2D
## Base for NPC, chest, pickup (layer 6). Shows a prompt while the player is in range; only the
## nearest overlapping interactable reacts to `interact`. Subclasses override interact().

var usable := true   # false hides the prompt and ignores input
var verb := "UI_VERB_USE"   # prompt word (ui.md 2: key glyph + 1 word); subclasses set their own
var _near := false
var _prompt: Label   # the verb text; subclasses read and write its text, visible and position
var _prompt_root: Node2D
var _cap: NinePatchRect
var _key_lbl: Label
var _tween: Tween

const KEYCAP := preload("res://assets/art/ui/keycap.png")
const KEY_FONT := preload("res://assets/fonts/AlegreyaSans-Bold.ttf")
const RISE := 3.0


func _ready() -> void:
	add_to_group("interactable")
	# ui.md 3b: an 8x8 keycap with the key in 6 px bold plus the verb in 7 px, outlined; <= 9 px tall, 4 px above the sprite
	_prompt_root = Node2D.new()
	add_child(_prompt_root)
	_cap = NinePatchRect.new()
	_cap.texture = KEYCAP
	_cap.patch_margin_left = 3
	_cap.patch_margin_right = 3
	_cap.patch_margin_top = 3
	_cap.patch_margin_bottom = 3
	_cap.size = Vector2(8, 8)
	_cap.position = Vector2(0, -9)
	_cap.visible = false
	_prompt_root.add_child(_cap)
	_key_lbl = Label.new()
	_key_lbl.add_theme_font_override("font", KEY_FONT)
	_key_lbl.add_theme_font_size_override("font_size", 6)
	_key_lbl.add_theme_color_override("font_color", Color("0E0B0A"))
	_key_lbl.add_theme_constant_override("outline_size", 0)
	_key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_key_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_key_lbl.visible = false
	_prompt_root.add_child(_key_lbl)
	_prompt = Label.new()
	_prompt.add_theme_font_size_override("font_size", 7)
	_prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt.visible = false
	_prompt_root.add_child(_prompt)
	_prompt.visibility_changed.connect(_on_prompt_visibility)
	_prompt.minimum_size_changed.connect(_layout_prompt)
	body_entered.connect(func(b: Node) -> void: _set_near(b, true))
	body_exited.connect(func(b: Node) -> void: _set_near(b, false))


func _set_near(b: Node, on: bool) -> void:
	if b.is_in_group("player"):
		_near = on
		_refresh_prompt()


func _refresh_prompt() -> void:
	_key_lbl.text = get_node("/root/Game").key_name("interact").left(5)
	_prompt.text = tr(verb)
	_prompt.visible = _near and usable
	_layout_prompt()


## Top of the object's sprite in local px (the prompt sits 4 px above it).
func _sprite_top() -> float:
	var top := 0.0
	var found := false
	for c in find_children("*", "Node2D", true, false):
		if c is Sprite2D and c.texture:
			var h: float = c.texture.get_height() / maxf(c.vframes, 1) * absf(c.scale.y)
			var y: float = (c.global_position - global_position).y - (h / 2.0 if c.centered else 0.0) + c.offset.y
			top = minf(top, y) if found else y
			found = true
		elif c is AnimatedSprite2D and c.sprite_frames and c.sprite_frames.has_animation(c.animation):
			var t: Texture2D = c.sprite_frames.get_frame_texture(c.animation, 0)
			if t:
				var y2: float = (c.global_position - global_position).y - (t.get_height() * absf(c.scale.y) / 2.0 if c.centered else 0.0) + c.offset.y
				top = minf(top, y2) if found else y2
				found = true
	return top if found else -16.0


func _layout_prompt() -> void:
	if _prompt == null:
		return
	var kw := maxf(8.0, KEY_FONT.get_string_size(_key_lbl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 6).x + 4.0)
	_cap.size = Vector2(kw, 8)
	_key_lbl.size = Vector2(kw, 7)
	_key_lbl.position = Vector2(0, -9)
	_prompt.reset_size()
	var vs := _prompt.get_minimum_size()
	_prompt.size = vs
	_prompt.position = Vector2(kw + 1.0, -9.0 + (8.0 - vs.y) / 2.0)
	_prompt_root.position = Vector2(-roundf((kw + 1.0 + vs.x) / 2.0), roundf(_sprite_top() - 4.0))


func _on_prompt_visibility() -> void:
	var on := _prompt.visible
	_cap.visible = on
	_key_lbl.visible = on
	if _tween:
		_tween.kill()
	if on:
		_layout_prompt()
		var y := _prompt_root.position.y
		_prompt_root.modulate.a = 0.0
		_prompt_root.position.y = y + RISE
		_tween = create_tween().set_parallel(true)
		_tween.tween_property(_prompt_root, "modulate:a", 1.0, 0.15)
		_tween.tween_property(_prompt_root, "position:y", y, 0.15).set_ease(Tween.EASE_OUT)


func _unhandled_input(event: InputEvent) -> void:
	if _near and usable and event.is_action_pressed("interact") and _is_nearest():
		get_viewport().set_input_as_handled()
		interact()


func _is_nearest() -> bool:
	var pl := get_tree().get_first_node_in_group("player") as Node2D
	if pl == null:
		return false
	for o: Interactable in get_tree().get_nodes_in_group("interactable"):
		if o != self and o._near and o.usable \
				and o.global_position.distance_to(pl.global_position) < global_position.distance_to(pl.global_position):
			return false
	return true


func interact() -> void:
	pass
