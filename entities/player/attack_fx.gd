class_name AttackFX
extends Node2D
## Player attack visuals (combat.md 2.3b): weapon smear, impact spark / ink / ring, afterimages, dodge and footstep
## dust, bow draw glow and muzzle flash, staff bolt glow and sparks. Visual only: it reads the player's state and
## never changes it. Art: assets/art/fx/ (tools/gen_combat_fx.py). Effects are short-lived nodes that free
## themselves when their animation ends; `tick(delta)` is the single driver (called from _process, or by tests).

const FX_DIR := "res://assets/art/fx/%s.png"
const MAX_FX := 48
const R_REF := 20.0            # smear art: arc radius and span (tools/gen_combat_fx.py)
const ARC_REF := 100.0
const THRUST_REF := 28.0       # smear_thrust art length in px
const DIRT := ",_t"            # zone grid chars that kick up dust (path, floor, trail); `.` is grass
const AFTERIMAGE_ALPHA := 0.35
const AFTERIMAGE_LIFE := 0.12
const DODGE_AFTERIMAGES := 3
const DODGE_AFTERIMAGE_GAP := 0.06

## Class tints: [smear, finisher/core accent, glow]
const TINTS := {
	"": [Color(1, 1, 1), Color(1, 1, 1), Color(1, 0.95, 0.8)],
	"warrior": [Color(1.0, 0.9, 0.78), Color(0.95, 0.42, 0.28), Color(1.0, 0.72, 0.42)],      # Hulubalang: warm steel, wax red, brass
	"rogue": [Color(0.95, 0.92, 0.88), Color(0.86, 0.26, 0.2), Color(1.0, 0.5, 0.42)],       # Pendekar: ink-white, sabuk red
	"archer": [Color(0.78, 1.0, 0.88), Color(0.55, 0.9, 0.74), Color(0.5, 0.86, 0.7)],       # Pamanah: verdigris
	"mage": [Color(0.62, 0.96, 0.88), Color(0.96, 0.9, 0.74), Color(0.45, 0.88, 0.82)],      # Wiku: teal ink-light, paper cream
}

## Test or settings override. The Game autoload may also expose `reduce_flashes` (controls.md 6).
var reduce_flashes := false

var player                      # the Player (untyped so this script has no hard cycle with player.gd)
var _tex_cache := {}
var _fx: Array = []             # {node, t, fps, frames, life, fade, vel, grow}
var _last_state := -1
var _dodge_t := 0.0
var _dodge_images := 0
var _dodge_landed := false
var _lunge_pending := -1.0
var _last_walk_col := -1
var _bolts: Array = []          # {arrow, glow, t, spark_t}
var _draw_glow: Sprite2D


func _ready() -> void:
	player = get_parent()


func _process(delta: float) -> void:
	tick(delta)


func _exit_tree() -> void:
	for e: Dictionary in _fx:
		if is_instance_valid(e.node) and e.node.get_parent() != self:
			e.node.queue_free()
	_fx.clear()


# --- helpers ---

func reduced() -> bool:
	if reduce_flashes:
		return true
	var g := get_node_or_null("/root/Game")
	return g != null and g.get("reduce_flashes") == true


func fx_count() -> int:
	return _fx.size()


func _tex(name: String) -> Texture2D:
	if not _tex_cache.has(name):
		var p := FX_DIR % name
		_tex_cache[name] = load(p) if ResourceLoader.exists(p) else null
	return _tex_cache[name]


func _tints() -> Array:
	return TINTS.get(str(player.class_id), TINTS[""])


func _world() -> Node:
	var w: Node = player.get_parent()
	return w if w != null else self


## Spawn an animated sprite from a strip: `frames` frames at `fps`. Returns the node.
func _anim(name: String, frames: int, pos: Vector2, rot := 0.0, fps := 14.0, mod := Color.WHITE,
		scl := Vector2.ONE, parent: Node = null, local := false) -> Sprite2D:
	var tex := _tex(name)
	if tex == null:
		return null
	if _fx.size() >= MAX_FX:
		_retire(_fx[0])
		_fx.remove_at(0)
	var s := Sprite2D.new()
	s.texture = tex
	s.hframes = frames
	s.rotation = rot
	s.modulate = mod
	s.scale = scl
	s.z_index = 10
	(parent if parent != null else _world()).add_child(s)
	if local:
		s.position = pos
	else:
		s.global_position = pos
	_fx.append({"node": s, "t": 0.0, "fps": fps, "frames": frames, "life": frames / fps, "fade": false,
			"vel": Vector2.ZERO, "grow": 0.0})
	return s


func _retire(e: Dictionary) -> void:
	if is_instance_valid(e.node):
		e.node.queue_free()


func _afterimage(alpha := AFTERIMAGE_ALPHA, life := AFTERIMAGE_LIFE) -> void:
	var src: Sprite2D = player.sprite
	if src == null or src.texture == null:
		return
	if _fx.size() >= MAX_FX:
		_retire(_fx[0])
		_fx.remove_at(0)
	var s := Sprite2D.new()
	s.texture = src.texture
	s.hframes = src.hframes
	s.vframes = src.vframes
	s.frame = src.frame
	s.flip_h = src.flip_h
	s.modulate = Color(_tints()[0], alpha)
	s.z_index = -1
	_world().add_child(s)
	s.global_position = src.global_position
	_fx.append({"node": s, "t": 0.0, "fps": 0.0, "frames": 0, "life": life, "fade": true, "vel": Vector2.ZERO,
			"grow": 0.0, "alpha": alpha})


# --- hooks from the player ---

## The melee swing's active phase starts (player._swing(true)).
func on_swing() -> void:
	var item = player.item
	var hit: int = player.hit
	var finisher := hit == 2
	var reach: float = item.reach * (player.tuning.melee_finisher_reach_mult if finisher else 1.0)
	var spear: bool = str(item.id).contains("spear")
	var heavy: bool = item.archetype == "heavy"
	var active: float = player._phase_len(Player.Phase.ACTIVE)
	var rec: float = player._phase_len(Player.Phase.RECOVERY)
	var dur := maxf(0.12, active + rec * 0.4)
	var fps := 4.0 / dur
	var t := _tints()
	var tint: Color = t[1] if (finisher and heavy) else t[0]
	var pos: Vector2 = player.aim.position
	var rot: float = (player.aim_dir as Vector2).angle()
	var s: Sprite2D = null
	if spear or (finisher and not heavy):
		var sx := reach / THRUST_REF
		s = _anim("smear_thrust", 4, pos, rot, fps, tint, Vector2(sx, 1.0 if finisher else 0.7), self, true)
	else:
		var sy := (reach * sin(deg_to_rad(item.arc / 2.0))) / (R_REF * sin(deg_to_rad(ARC_REF / 2.0)))
		var flip := -1.0 if hit == 1 else 1.0        # the backhand sweeps the other way
		var sheet := "smear_finisher" if (finisher and heavy) else ("smear_heavy" if heavy else "smear_light")
		s = _anim(sheet, 4, pos, rot, fps, tint, Vector2(reach / R_REF, sy * flip), self, true)
		if finisher and heavy and not reduced():     # the white core: a flash, so Reduce flashes drops it
			_anim("smear_core", 4, pos, rot, fps, Color.WHITE, Vector2(reach / R_REF, sy * flip), self, true)
	if s != null and reduced():
		s.modulate.a = 0.6
	if finisher and heavy:                            # slam: dust where the blade lands
		var tip: Vector2 = player.aim.global_position + (player.aim_dir as Vector2) * reach * 0.9
		_anim("dust", 4, tip, 0.0, 10.0, Color(1, 1, 1, 0.9), Vector2(1.5, 1.5))
	if item.lunge > 0.0:                              # lunge: 1-2 afterimages
		_afterimage()
		_lunge_pending = 0.035


## The ranged shot leaves the bow or staff (player._shoot).
func on_shoot(arrow: Node2D) -> void:
	var t := _tints()
	var dir: Vector2 = player.aim_dir
	var muzzle_alpha := 0.5 if reduced() else 1.0
	_anim("muzzle", 3, player.aim.global_position + dir * 7.0 - Vector2.ZERO, dir.angle(), 24.0,
			Color(t[2], muzzle_alpha), Vector2.ONE)
	if player.item.archetype == "staff" and is_instance_valid(arrow):
		var glow := Sprite2D.new()
		glow.texture = _tex("bolt_glow")
		glow.hframes = 3
		glow.modulate = Color(t[2], 0.9)
		glow.z_index = 1
		arrow.add_child(glow)
		_bolts.append({"arrow": arrow, "glow": glow, "t": 0.0, "spark_t": 0.0})


## A hit landed (player._on_hit_landed). `kill` is true when the target died from it.
func on_hit(hb: Node2D, heavy: bool, kill: bool) -> void:
	if not is_instance_valid(hb):
		return
	var origin: Vector2 = player.aim.global_position
	var to: Vector2 = hb.global_position - origin
	var dir := to.normalized() if to.length() > 0.1 else (player.aim_dir as Vector2)
	var contact := origin + to * 0.85
	var t := _tints()
	_anim("spark", 4, contact, randf_range(-0.3, 0.3), 16.0, Color(1, 1, 1) if t[0] == Color.WHITE else (t[0] as Color).lerp(Color.WHITE, 0.6),
			Vector2(1.4, 1.4) if heavy else Vector2.ONE)
	_anim("ink_splash", 4, contact, dir.angle(), 12.0, Color.WHITE, Vector2(1.3, 1.3) if heavy else Vector2.ONE)
	if heavy and not reduced():
		_anim("ring", 3, contact, 0.0, 14.0, Color(1, 1, 1, 0.9))
		var owner_node: Node = hb.owner
		if owner_node != null:
			var hf := owner_node.get_node_or_null("HitFlash")
			if hf != null and hf.has_method("flash"):
				hf.flash(2.0 / 30.0)                  # 2 frames of white on the target
	if kill:
		_anim("ink_puff", 5, hb.global_position, 0.0, 10.0, Color.WHITE)


# --- per-frame driver ---

func tick(delta: float) -> void:
	if player == null:
		return
	_poll_player(delta)
	_tick_bolts(delta)
	var i := _fx.size() - 1
	while i >= 0:
		var e: Dictionary = _fx[i]
		var n: Node2D = e.node
		if not is_instance_valid(n):
			_fx.remove_at(i)
			i -= 1
			continue
		e.t += delta
		if e.fade:
			n.modulate.a = float(e.alpha) * clampf(1.0 - e.t / e.life, 0.0, 1.0)
		elif e.frames > 0:
			(n as Sprite2D).frame = mini(e.frames - 1, int(e.t * e.fps))
		if e.t >= e.life:
			n.queue_free()
			_fx.remove_at(i)
		i -= 1


func _poll_player(delta: float) -> void:
	var st: int = player.state
	if st != _last_state:
		if st == Player.State.DODGE:
			_dodge_t = 0.0
			_dodge_images = 0
			_dodge_landed = false
			_dust(player.global_position, 1.0)
		_last_state = st
	if _lunge_pending >= 0.0:
		_lunge_pending -= delta
		if _lunge_pending < 0.0:
			_afterimage(AFTERIMAGE_ALPHA * 0.7)
	if st == Player.State.DODGE:
		_dodge_t += delta
		if _dodge_images < DODGE_AFTERIMAGES and _dodge_t >= _dodge_images * DODGE_AFTERIMAGE_GAP:
			_afterimage()
			_dodge_images += 1
		if not _dodge_landed and player.state_time >= player.tuning.dodge_duration:
			_dodge_landed = true
			_dust(player.global_position, 1.2)
	_poll_walk(st)
	_poll_draw_glow(st)


func _poll_walk(st: int) -> void:
	if st != Player.State.FREE or player.move_dir == Vector2.ZERO:
		_last_walk_col = -1
		return
	var col := int(fmod(player.clock * 8.0, 4.0))
	if col != _last_walk_col:
		_last_walk_col = col
		if col == 0 and _on_dirt():                    # every 4th walk frame
			_anim("step_dust", 3, player.global_position + Vector2(0, -1), 0.0, 9.0, Color.WHITE)


## Dust on path or dirt tiles: asks the Zone grid when the player stands in one, else always true.
func _on_dirt() -> bool:
	var n: Node = player.get_parent()
	while n != null and not n is Zone:
		n = n.get_parent()
	if n == null:
		return true
	var z: Zone = n
	if z.grid.is_empty():
		return true
	var c := z.tile_of(z.to_local(player.global_position))
	if c.y < 0 or c.y >= z.grid.size() or c.x < 0 or c.x >= z.grid[c.y].length():
		return false
	return DIRT.contains(z.grid[c.y][c.x])


func _dust(pos: Vector2, k: float) -> void:
	_anim("dust", 4, pos + Vector2(0, -2), 0.0, 10.0, Color(1, 1, 1, 0.9), Vector2(k, k))


## String-draw glow at the bow hand while a ranged wind-up runs.
func _poll_draw_glow(st: int) -> void:
	var on: bool = st == Player.State.ATTACK and not player.item.is_melee() and player.phase == Player.Phase.WINDUP
	if on and _draw_glow == null and _tex("bolt_glow") != null:
		_draw_glow = Sprite2D.new()
		_draw_glow.texture = _tex("bolt_glow")
		_draw_glow.hframes = 3
		_draw_glow.z_index = 11
		add_child(_draw_glow)
	if _draw_glow == null:
		return
	_draw_glow.visible = on
	if on:
		var wlen: float = maxf(player._phase_len(Player.Phase.WINDUP), 0.001)
		var p := clampf(player.state_time / wlen, 0.0, 1.0)
		_draw_glow.position = player.aim.position + (player.aim_dir as Vector2) * 9.0
		_draw_glow.scale = Vector2.ONE * lerpf(0.4, 1.0, p)
		_draw_glow.frame = int(p * 3.0) % 3
		_draw_glow.modulate = Color(_tints()[2], (0.5 if reduced() else 0.85) * p + 0.15)


func _tick_bolts(delta: float) -> void:
	var i := _bolts.size() - 1
	while i >= 0:
		var b: Dictionary = _bolts[i]
		if not is_instance_valid(b.arrow):
			_bolts.remove_at(i)
			i -= 1
			continue
		b.t += delta
		b.spark_t += delta
		if is_instance_valid(b.glow):
			(b.glow as Sprite2D).frame = int(b.t * 12.0) % 3
		if b.spark_t >= 0.05:
			b.spark_t = 0.0
			var a: Node2D = b.arrow
			_anim("bolt_spark", 3, a.global_position + Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.0, 14.0,
					Color(_tints()[2]))
		i -= 1
