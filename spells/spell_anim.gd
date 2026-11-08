class_name SpellAnim extends Sprite2D
## A strip animation for spell FX (art: assets/art/fx/spells/, tools/gen_spell_fx.py). Plays once and frees itself,
## or loops until `life` runs out. Visual only; it never touches gameplay state. Fade uses self_modulate so
## `modulate` stays free for the glyph tint.

var fps := 14.0
var loop := false
var life := 0.0                # >0: free after this many seconds (loops or holds the last frame)
var fade := 0.0                # seconds of alpha fade at the end of `life`
var grow := 1.0                # scale multiplier reached by the end
var persist := false           # never free by itself; restart() replays it (the tiger's pounce)
var follow: Node2D             # keep on this node's position (plus follow_offset); frees with it
var follow_offset := Vector2.ZERO
var _t := 0.0
var _s0 := Vector2.ONE
var _has_follow := false


func _ready() -> void:
	_s0 = scale
	_has_follow = follow != null


func restart() -> void:
	_t = 0.0


func _process(delta: float) -> void:
	_t += delta
	var n := maxi(hframes, 1)
	var f := int(_t * fps)
	if not loop and not persist and life <= 0.0 and f >= n:
		queue_free()
		return
	frame = f % n if loop else mini(f, n - 1)
	var total := life if life > 0.0 else float(n) / fps
	if grow != 1.0:
		scale = _s0.lerp(_s0 * grow, clampf(_t / total, 0.0, 1.0))
	if _has_follow:
		if is_instance_valid(follow):
			global_position = follow.global_position + follow_offset
		else:
			queue_free()
			return
	if life > 0.0:
		if _t >= life:
			queue_free()
			return
		if fade > 0.0 and life - _t < fade:
			self_modulate.a = (life - _t) / fade
