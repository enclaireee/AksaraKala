class_name WorldBark extends Node2D
## Floating diegetic speech chip above an NPC in world space (`.docs/tutorial.md`).
## Non-blocking, ignores Engine.time_scale, auto-replaces any prior bark on the same speaker.

const META_KEY := &"_world_bark"
const MAX_W := 152.0
const PAD_X := 6.0
const PAD_Y := 3.0
const OFFSET_Y := -32.0

var _panel: NinePatchRect
var _lbl: Label
var _tail: ColorRect
var _tw: Tween


static func say(target: Node2D, text: String, duration := 3.2, col := UIFx.TEXT) -> WorldBark:
	if target == null or not is_instance_valid(target) or text.strip_edges() == "":
		return null
	clear(target)
	var b := WorldBark.new()
	b.z_index = 45
	b.position = Vector2(0.0, OFFSET_Y)
	target.set_meta(META_KEY, b)
	target.add_child(b)
	b._setup(text, duration, col)
	return b


static func clear(target: Node2D) -> void:
	if target == null or not is_instance_valid(target) or not target.has_meta(META_KEY):
		return
	var prev: Variant = target.get_meta(META_KEY)
	if prev is Node and is_instance_valid(prev):
		(prev as Node).queue_free()
	target.remove_meta(META_KEY)


func _setup(text: String, duration: float, col: Color) -> void:
	_panel = NinePatchRect.new()
	_panel.texture = UIFx.tex("ink_panel")
	for side in ["left", "top", "right", "bottom"]:
		_panel.set("patch_margin_" + side, 4)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	_lbl = UIFx.text(text, "body", col)
	_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl.add_theme_constant_override("line_spacing", 1)
	_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var f := UIFx.body_font()
	var single_w := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
	var inner_w := clampf(ceilf(single_w) + 2.0, 40.0, MAX_W - PAD_X * 2.0)
	_panel.add_child(_lbl)   # in the tree first: out of it the label never shapes and reports 1 line
	_lbl.size = Vector2(inner_w, UIFx.LINE - 1)
	var lines := maxi(1, _lbl.get_line_count())
	var h := PAD_Y * 2.0 + lines * UIFx.LINE - 2.0   # caps sit 4 px under the top edge, baseline 5 px over the bottom
	var w := inner_w + PAD_X * 2.0
	_panel.size = Vector2(w, h)
	_panel.position = Vector2(roundf(-w * 0.5), roundf(-h))
	_lbl.position = Vector2(PAD_X, PAD_Y)
	_lbl.size = Vector2(inner_w, lines * UIFx.LINE - 1.0)

	# Tiny 3x2 pointer pixel at bottom center
	_tail = ColorRect.new()
	_tail.color = UIFx.NIGHT
	_tail.size = Vector2(4, 2)
	_tail.position = Vector2(-2, -1)
	_tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tail)

	modulate.a = 0.0
	position.y = OFFSET_Y + 4.0
	_tw = create_tween().set_ignore_time_scale(true)
	_tw.set_parallel(true)
	_tw.tween_property(self, "modulate:a", 1.0, 0.14)
	_tw.tween_property(self, "position:y", OFFSET_Y, 0.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tw.set_parallel(false)   # chain() only links the next tweener; the hold and fade must run in order
	_tw.tween_interval(maxf(0.4, duration))
	_tw.tween_property(self, "modulate:a", 0.0, 0.28)
	_tw.tween_callback(queue_free)
