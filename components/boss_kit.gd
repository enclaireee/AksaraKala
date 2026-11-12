class_name BossKit extends RefCounted
## Shared boss toolkit (combat.md 5.3b): readable ground telegraphs, projectiles, lingering zones, shockwaves,
## slashes, afterimages, sparks, camera shake and sprite move animations. Everything is drawn in code (pixel
## primitives, no antialiasing) and frees itself. All damage goes through the player's Hurtbox, so dodge i-frames
## refuse it (same rule as BataraKala._hurt). Nodes are added to the boss's parent so they outlive state changes.
## Every function is static: `BossKit.telegraph_circle(self, spot, 28.0, 0.8)`.

const RED := Color(1.0, 0.25, 0.2)
const GOLD := Color(1.0, 0.8, 0.3)
const HURT_OFFSET := Vector2(0, -8)   # the player's hurtbox centre sits this far above its feet
const HURT_RADIUS := 6.0


# --- queries -------------------------------------------------------------------------------------------------

static func player_point(host: EnemyBase) -> Vector2:
	if host == null or not is_instance_valid(host) or host.target == null or not is_instance_valid(host.target):
		return Vector2(INF, INF)
	return host.target.global_position + HURT_OFFSET


static func in_circle(p: Vector2, centre: Vector2, radius: float) -> bool:
	return p.distance_to(centre) <= radius + HURT_RADIUS


static func in_cone(p: Vector2, origin: Vector2, dir: float, arc: float, length: float) -> bool:
	var d := p - origin
	var dist := d.length()
	if dist > length + HURT_RADIUS:
		return false
	if dist < 6.0:
		return true
	return absf(angle_difference(dir, d.angle())) <= arc * 0.5


static func in_line(p: Vector2, from: Vector2, to: Vector2, width: float) -> bool:
	var seg := to - from
	var len2 := seg.length_squared()
	if len2 < 0.001:
		return in_circle(p, from, width * 0.5)
	var f := clampf((p - from).dot(seg) / len2, 0.0, 1.0)
	return p.distance_to(from + seg * f) <= width * 0.5 + HURT_RADIUS


## Damage through the player's Hurtbox. False when refused (dodge i-frames), dead or no target.
static func hurt_player(host: EnemyBase, amount: int, heavy := false) -> bool:
	if host == null or not is_instance_valid(host) or host.target == null or not is_instance_valid(host.target):
		return false
	var hb := host.target.get_node_or_null("Hurtbox") as Hurtbox
	if hb == null:
		return false
	host.attack_hitbox.damage = amount
	host.attack_hitbox.heavy = heavy
	return hb.receive(host.attack_hitbox)


## Instant cone hit (sweeps, breath, claws) with a slash visual. Returns true if the player was hurt.
static func strike_cone(host: EnemyBase, origin: Vector2, dir: float, arc: float, length: float, amount: int, heavy := false, color := Color(1, 1, 1)) -> bool:
	slash(host, origin, dir, arc, length, color)
	if in_cone(player_point(host), origin, dir, arc, length):
		return hurt_player(host, amount, heavy)
	return false


static func strike_circle(host: EnemyBase, centre: Vector2, radius: float, amount: int, heavy := false, color := Color(1, 1, 1)) -> bool:
	sparks(host, centre, color, 10, 70.0, 0.35)
	ring_fx(host, centre, radius, 0.25, color)
	if in_circle(player_point(host), centre, radius):
		return hurt_player(host, amount, heavy)
	return false


static func strike_line(host: EnemyBase, from: Vector2, to: Vector2, width: float, amount: int, heavy := false, color := Color(1, 1, 1)) -> bool:
	beam_fx(host, from, to, width, 0.22, color)
	if in_line(player_point(host), from, to, width):
		return hurt_player(host, amount, heavy)
	return false


# --- telegraphs (ground markers that fill up to the strike, then flash) -------------------------------------------

class Telegraph extends Node2D:
	var kind := "circle"   # circle | cone | line | ring
	var radius := 24.0
	var inner := 0.0
	var arc := 1.0         # cone full width, radians
	var length := 64.0     # line / cone reach
	var width := 12.0
	var dir := 0.0
	var life := 0.8
	var color := Color(1.0, 0.25, 0.2)
	var follow: Node2D     # optional: keeps the origin on this node (a boss that is still turning)
	var t := 0.0

	func _ready() -> void:
		z_index = -1

	func _process(delta: float) -> void:
		t += delta
		if t >= life:
			queue_free()
			return
		if follow != null and is_instance_valid(follow):
			global_position = follow.global_position
		queue_redraw()

	func _draw() -> void:
		var f := clampf(t / life, 0.0, 1.0)
		var flash := 0.5 + 0.5 * sin(t * 40.0) if f > 0.8 else 0.0
		var edge := Color(color, 0.85)
		var back := Color(color, 0.10)
		var fill := Color(color, 0.18 + 0.30 * f + 0.25 * flash)
		match kind:
			"circle":
				draw_circle(Vector2.ZERO, radius, back)
				draw_circle(Vector2.ZERO, radius * f, fill)
				draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, edge, 1.0)
				draw_arc(Vector2.ZERO, maxf(radius - 3.0, 1.0), 0.0, TAU, 40, Color(color, 0.4), 1.0)
				draw_arc(Vector2.ZERO, radius * f, 0.0, TAU, 40, Color(1, 1, 1, 0.3 + 0.5 * flash), 1.0)   # the closing edge
				for i in 8:   # tick marks turning on the rim, like a seal being drawn
					var a := t * 1.6 + TAU * i / 8.0
					draw_line(Vector2.from_angle(a) * maxf(radius - 3.0, 1.0), Vector2.from_angle(a) * radius, edge, 1.0)
			"ring":
				var mid := (radius + inner) * 0.5
				draw_arc(Vector2.ZERO, mid, 0.0, TAU, 56, back, radius - inner)
				draw_arc(Vector2.ZERO, mid, 0.0, TAU, 56, fill, (radius - inner) * f)
				draw_arc(Vector2.ZERO, radius, 0.0, TAU, 56, edge, 1.0)
				draw_arc(Vector2.ZERO, inner, 0.0, TAU, 40, edge, 1.0)
			"cone":
				var pts := PackedVector2Array([Vector2.ZERO])
				var n := 14
				for i in n + 1:
					pts.append(Vector2.from_angle(dir - arc * 0.5 + arc * i / n) * length)
				draw_colored_polygon(pts, back)
				var pf := PackedVector2Array([Vector2.ZERO])
				for i in n + 1:
					pf.append(Vector2.from_angle(dir - arc * 0.5 + arc * i / n) * length * f)
				draw_colored_polygon(pf, fill)
				draw_polyline(pts, edge, 1.0)
				draw_line(pts[pts.size() - 1], Vector2.ZERO, edge, 1.0)
				draw_arc(Vector2.ZERO, length * f, dir - arc * 0.5, dir + arc * 0.5, 14, Color(1, 1, 1, 0.3 + 0.5 * flash), 1.0)
				draw_arc(Vector2.ZERO, maxf(length - 3.0, 1.0), dir - arc * 0.5, dir + arc * 0.5, 14, Color(color, 0.4), 1.0)
			"line":
				draw_set_transform(Vector2.ZERO, dir)
				draw_rect(Rect2(0.0, -width * 0.5, length, width), back)
				draw_rect(Rect2(0.0, -width * 0.5, length * f, width), fill)
				draw_rect(Rect2(0.0, -width * 0.5, length, width), edge, false, 1.0)
				draw_line(Vector2(length * f, -width * 0.5), Vector2(length * f, width * 0.5), Color(1, 1, 1, 0.3 + 0.5 * flash), 1.0)
				var step := 12.0
				var off := fmod(t * 40.0, step)   # chevrons running down the lane
				var cx := off
				while cx < length - 3.0:
					draw_line(Vector2(cx, -width * 0.3), Vector2(cx + 3.0, 0.0), Color(color, 0.45), 1.0)
					draw_line(Vector2(cx + 3.0, 0.0), Vector2(cx, width * 0.3), Color(color, 0.45), 1.0)
					cx += step


static func _add(host: Node, n: Node2D, pos: Vector2) -> void:
	var p := host.get_parent()
	if p == null:
		n.queue_free()
		return
	p.add_child(n)
	n.global_position = pos


static func telegraph_circle(host: EnemyBase, pos: Vector2, radius: float, life: float, color := RED) -> Telegraph:
	Snd.play("boss_telegraph", -3.0)
	var t := Telegraph.new()
	t.kind = "circle"
	t.radius = radius
	t.life = life
	t.color = color
	_add(host, t, pos)
	return t


static func telegraph_ring(host: EnemyBase, pos: Vector2, outer: float, inner: float, life: float, color := RED) -> Telegraph:
	Snd.play("boss_telegraph", -3.0)
	var t := Telegraph.new()
	t.kind = "ring"
	t.radius = outer
	t.inner = inner
	t.life = life
	t.color = color
	_add(host, t, pos)
	return t


static func telegraph_cone(host: EnemyBase, origin: Vector2, dir: float, arc: float, length: float, life: float, color := RED) -> Telegraph:
	Snd.play("boss_telegraph", -3.0)
	var t := Telegraph.new()
	t.kind = "cone"
	t.dir = dir
	t.arc = arc
	t.length = length
	t.life = life
	t.color = color
	_add(host, t, origin)
	return t


static func telegraph_line(host: EnemyBase, from: Vector2, to: Vector2, width: float, life: float, color := RED) -> Telegraph:
	Snd.play("boss_telegraph", -3.0)
	var t := Telegraph.new()
	t.kind = "line"
	t.dir = (to - from).angle()
	t.length = from.distance_to(to)
	t.width = width
	t.life = life
	t.color = color
	_add(host, t, from)
	return t


# --- projectiles ----------------------------------------------------------------------------------------------

class Shot extends Node2D:
	var host: EnemyBase
	var vel := Vector2.ZERO
	var radius := 5.0
	var damage := 14
	var heavy := false
	var life := 3.0
	var color := Color(1.0, 0.5, 0.2)
	var style := "orb"        # orb | blade | log | shard | skull
	var homing := 0.0         # radians per second toward the player
	var pierce := false       # keeps flying after a hit
	var accel := 0.0          # px/s^2 along its heading (negative slows)
	var _tried := false
	var _trail: Array[Vector2] = []
	var _t := 0.0

	func _physics_process(delta: float) -> void:
		_t += delta
		life -= delta
		if life <= 0.0 or host == null or not is_instance_valid(host):
			queue_free()
			return
		if homing > 0.0:
			var p := BossKit.player_point(host)
			if p.x != INF:
				var want := (p - global_position).angle()
				var cur := vel.angle()
				var step := clampf(angle_difference(cur, want), -homing * delta, homing * delta)
				vel = Vector2.from_angle(cur + step) * vel.length()
		if accel != 0.0:
			vel = vel.normalized() * maxf(0.0, vel.length() + accel * delta)
		global_position += vel * delta
		_trail.append(global_position)
		if _trail.size() > 6:
			_trail.pop_front()
		queue_redraw()
		if not _tried and BossKit.in_circle(BossKit.player_point(host), global_position, radius):
			if BossKit.hurt_player(host, damage, heavy):
				BossKit.sparks(host, global_position, color, 6, 50.0, 0.25)
				if not pierce:
					queue_free()
					return
			_tried = true   # a dodge slips through; it cannot hit again

	func _draw() -> void:
		var a := vel.angle()
		for i in _trail.size():
			var f := float(i + 1) / (_trail.size() + 1)
			draw_circle(to_local(_trail[i]), radius * f * 0.8, Color(color, 0.35 * f))
		var k := radius / 5.0   # the sprites are authored for a 5 px shot
		match style:
			"blade", "shard":
				draw_set_transform(Vector2.ZERO, a)
				var tb := _tex("boss_blade")
				draw_texture_rect(tb, Rect2(-tb.get_size() * k * 0.5, tb.get_size() * k), false, color)
			"log":
				draw_set_transform(Vector2.ZERO, _t * 9.0)
				var tl := _tex("boss_log")
				draw_texture_rect(tl, Rect2(-tl.get_size() * k * 0.5, tl.get_size() * k), false)
			"skull":
				var ts := _tex("boss_skull")
				draw_texture_rect(ts, Rect2(-ts.get_size() * k * 0.5, ts.get_size() * k), false, Color(1, 1, 1).lerp(color, 0.25))
			_:
				var to := _tex("boss_orb")
				var fr := int(_t * 12.0) % 3
				var pulse := 1.0 + 0.1 * sin(_t * 24.0)
				draw_texture_rect_region(to, Rect2(-Vector2(8, 8) * k * pulse, Vector2(16, 16) * k * pulse), Rect2(fr * 16, 0, 16, 16), color)

	static var _texes := {}

	static func _tex(n: String) -> Texture2D:   # fx/boss_<n>.png, loaded once
		if not _texes.has(n):
			_texes[n] = load("res://assets/art/fx/%s.png" % n)
		return _texes[n]


## Fires one projectile from `from` toward angle `dir`.
static func shoot(host: EnemyBase, from: Vector2, dir: float, speed: float, amount: int, color: Color, style := "orb", radius := 5.0, life := 3.0, homing := 0.0, heavy := false) -> Shot:
	var s := Shot.new()
	s.host = host
	s.vel = Vector2.from_angle(dir) * speed
	s.damage = amount
	s.color = color
	s.style = style
	s.radius = radius
	s.life = life
	s.homing = homing
	s.heavy = heavy
	s.z_index = 40
	_add(host, s, from)
	return s


## A fan (or ring when arc is TAU) of `count` projectiles.
static func fan(host: EnemyBase, from: Vector2, dir: float, arc: float, count: int, speed: float, amount: int, color: Color, style := "orb", radius := 4.0, life := 3.0) -> Array[Shot]:
	var out: Array[Shot] = []
	for i in count:
		var a := dir
		if count > 1:
			if is_equal_approx(arc, TAU):
				a = dir + TAU * i / count
			else:
				a = dir - arc * 0.5 + arc * i / (count - 1)
		out.append(shoot(host, from, a, speed, amount, color, style, radius, life))
	return out


# --- lingering ground zones ---------------------------------------------------------------------------------

class HazardZone extends Node2D:
	var host: EnemyBase
	var radius := 24.0
	var damage := 8
	var life := 4.0
	var warm := 0.5          # seconds drawn as a warning before it can hurt
	var tick := 0.5
	var color := Color(1.0, 0.45, 0.1)
	var _t := 0.0
	var _tick_t := 0.0

	func _ready() -> void:
		z_index = -1

	func _physics_process(delta: float) -> void:
		_t += delta
		if host == null or not is_instance_valid(host) or _t >= life:
			queue_free()
			return
		queue_redraw()
		if _t < warm:
			return
		_tick_t -= delta
		if _tick_t <= 0.0:
			_tick_t = tick
			if BossKit.in_circle(BossKit.player_point(host), global_position, radius):
				BossKit.hurt_player(host, damage, false)

	func _draw() -> void:
		var armed := _t >= warm
		var fade := clampf((life - _t) / 0.6, 0.0, 1.0)
		var a := (0.35 if armed else 0.15) * fade
		draw_circle(Vector2.ZERO, radius, Color(color, a))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(color, 0.9 * fade), 1.0)
		if armed:
			for i in 6:
				var ang := TAU * i / 6.0 + _t * 0.7
				var r := radius * (0.25 + 0.6 * fmod(_t * 0.8 + i * 0.37, 1.0))
				draw_rect(Rect2(Vector2.from_angle(ang) * r - Vector2(1, 1), Vector2(2, 2)), Color(1, 1, 0.8, 0.8 * fade))


static func zone(host: EnemyBase, pos: Vector2, radius: float, amount: int, life: float, color := Color(1.0, 0.45, 0.1), warm := 0.5) -> HazardZone:
	var z := HazardZone.new()
	z.host = host
	z.radius = radius
	z.damage = amount
	z.life = life
	z.color = color
	z.warm = warm
	_add(host, z, pos)
	return z


# --- expanding shockwave (jump it with a dodge) -------------------------------------------------------------------

class Wave extends Node2D:
	var host: EnemyBase
	var max_r := 96.0
	var speed := 90.0
	var band := 5.0
	var damage := 20
	var heavy := true
	var color := Color(1.0, 0.8, 0.4)
	var _r := 4.0
	var _done := false

	func _physics_process(delta: float) -> void:
		_r += speed * delta
		if host == null or not is_instance_valid(host) or _r >= max_r:
			queue_free()
			return
		queue_redraw()
		if not _done:
			var d := BossKit.player_point(host).distance_to(global_position)
			if absf(d - _r) <= band + BossKit.HURT_RADIUS:
				_done = true   # one pass, one hit (a refused hit also uses it up)
				BossKit.hurt_player(host, damage, heavy)

	func _draw() -> void:
		var f := clampf(1.0 - _r / max_r, 0.0, 1.0)
		draw_arc(Vector2.ZERO, _r, 0.0, TAU, 64, Color(color, 0.25 + 0.4 * f), band * 2.0)
		draw_arc(Vector2.ZERO, _r, 0.0, TAU, 64, Color(1, 1, 1, 0.7 * f), 1.0)


static func wave(host: EnemyBase, pos: Vector2, max_r: float, speed: float, amount: int, color := Color(1.0, 0.8, 0.4), heavy := true) -> Wave:
	var w := Wave.new()
	w.host = host
	w.max_r = max_r
	w.speed = speed
	w.damage = amount
	w.color = color
	w.heavy = heavy
	w.z_index = 30
	_add(host, w, pos)
	return w


# --- pure visuals -------------------------------------------------------------------------------------------

class Fx extends Node2D:
	var kind := "ring"      # ring | slash | beam | flash
	var radius := 30.0
	var arc := 1.5
	var dir := 0.0
	var length := 40.0
	var width := 6.0
	var to := Vector2.ZERO
	var life := 0.3
	var color := Color(1, 1, 1)
	var _t := 0.0

	func _process(delta: float) -> void:
		_t += delta
		if _t >= life:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var f := clampf(_t / life, 0.0, 1.0)
		match kind:
			"ring":
				draw_arc(Vector2.ZERO, radius * (0.3 + 0.7 * f), 0.0, TAU, 48, Color(color, 1.0 - f), 3.0 * (1.0 - f) + 1.0)
			"slash":
				draw_arc(Vector2.ZERO, length * (0.6 + 0.4 * f), dir - arc * 0.5, dir + arc * 0.5, 20, Color(color, 1.0 - f), 5.0 * (1.0 - f) + 1.0)
				draw_arc(Vector2.ZERO, length * (0.5 + 0.3 * f), dir - arc * 0.4, dir + arc * 0.4, 16, Color(1, 1, 1, 0.7 * (1.0 - f)), 1.0)
			"beam":
				var tl := to - global_position
				draw_line(Vector2.ZERO, tl, Color(color, 0.6 * (1.0 - f)), width * (1.0 - f) + 1.0)
				draw_line(Vector2.ZERO, tl, Color(1, 1, 1, 1.0 - f), maxf(1.0, width * 0.3 * (1.0 - f)))
			"flash":
				draw_circle(Vector2.ZERO, radius * (0.4 + 0.6 * f), Color(color, 0.8 * (1.0 - f)))


static func ring_fx(host: Node, pos: Vector2, radius: float, life := 0.4, color := Color(1, 1, 1)) -> void:
	var f := Fx.new()
	f.kind = "ring"
	f.radius = radius
	f.life = life
	f.color = color
	f.z_index = 45
	_add(host, f, pos)


static func slash(host: Node, origin: Vector2, dir: float, arc: float, length: float, color := Color(1, 1, 1)) -> void:
	var f := Fx.new()
	f.kind = "slash"
	f.dir = dir
	f.arc = arc
	f.length = length
	f.life = 0.22
	f.color = color
	f.z_index = 45
	_add(host, f, origin)


static func beam_fx(host: Node, from: Vector2, to: Vector2, width: float, life := 0.25, color := Color(1, 1, 1)) -> void:
	var f := Fx.new()
	f.kind = "beam"
	f.to = to
	f.width = width
	f.life = life
	f.color = color
	f.z_index = 45
	_add(host, f, from)


static func flash_fx(host: Node, pos: Vector2, radius: float, life := 0.3, color := Color(1, 1, 1)) -> void:
	var f := Fx.new()
	f.kind = "flash"
	f.radius = radius
	f.life = life
	f.color = color
	f.z_index = 46
	_add(host, f, pos)


class Sparks extends Node2D:
	var life := 0.5
	var color := Color(1, 1, 1)
	var gravity := 0.0
	var _p: Array[Dictionary] = []
	var _t := 0.0

	func setup(count: int, speed: float) -> void:
		for i in count:
			_p.append({"pos": Vector2.ZERO, "vel": Vector2.from_angle(randf() * TAU) * speed * randf_range(0.3, 1.0), "size": randi_range(1, 2)})

	func _process(delta: float) -> void:
		_t += delta
		if _t >= life:
			queue_free()
			return
		for q: Dictionary in _p:
			q["vel"] = (q["vel"] as Vector2) + Vector2(0, gravity * delta)
			q["pos"] = (q["pos"] as Vector2) + (q["vel"] as Vector2) * delta
		queue_redraw()

	func _draw() -> void:
		var a := 1.0 - _t / life
		for q: Dictionary in _p:
			var s: int = q["size"]
			draw_rect(Rect2((q["pos"] as Vector2).round(), Vector2(s, s)), Color(color, a))


static func sparks(host: Node, pos: Vector2, color: Color, count := 10, speed := 60.0, life := 0.5, gravity := 0.0) -> void:
	var s := Sparks.new()
	s.color = color
	s.life = life
	s.gravity = gravity
	s.z_index = 47
	s.setup(count, speed)
	_add(host, s, pos)


# --- sprite helpers -------------------------------------------------------------------------------------------

## Play a row of the boss's `<name>_moves.png` sheet (cast, slam, dash, roar). See EnemyArt.play.
static func anim(host: Node, anim_name: String, fps := 10.0, hold := true) -> void:
	var art := host.get_node_or_null("Body/Art") as EnemyArt
	if art != null:
		art.play(anim_name, fps, hold)


static func anim_stop(host: Node) -> void:
	var art := host.get_node_or_null("Body/Art") as EnemyArt
	if art != null:
		art.stop()


## A fading copy of the boss's current frame (dash trails, teleports, time-skips).
static func ghost(host: Node2D, color := Color(0.6, 0.8, 1.0), life := 0.35) -> void:
	var art := host.get_node_or_null("Body/Art") as EnemyArt
	if art == null or art.texture == null or host.get_parent() == null:
		return
	var g := Sprite2D.new()
	g.texture = art.texture
	g.hframes = art.hframes
	g.vframes = art.vframes
	g.frame_coords = art.frame_coords
	g.flip_h = art.flip_h
	g.centered = false
	g.offset = art.offset
	g.modulate = Color(color, 0.55)
	g.z_index = -1
	host.get_parent().add_child(g)
	g.global_position = art.global_position
	g.global_scale = art.global_scale
	var tw := g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, life)
	tw.tween_callback(g.queue_free)


## Squash-and-stretch punch on the boss body (impact, roar). Safe to overlap: it always settles at scale 1.
static func punch(host: EnemyBase, sx: float, sy: float, time := 0.25) -> void:
	if host == null or host.body == null:
		return
	host.body.scale = Vector2(sx, sy)
	var tw := host.body.create_tween()
	tw.tween_property(host.body, "scale", Vector2.ONE, time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func shake(host: Node, px: float, seconds: float) -> void:
	if px >= 3.0:
		Snd.play("boss_slam", -3.0)
	var tree := host.get_tree()
	if tree == null:
		return
	var p := tree.get_first_node_in_group("player")
	if p == null:
		return
	for c in p.get_children():
		if c is PlayerCamera:
			(c as PlayerCamera).shake(px, seconds)
			return


## Phase change / roar: roar pose, expanding ring, sparks, shake. Purely visual, so a boss can call it from any state.
static func roar(host: EnemyBase, color := Color(1.0, 0.8, 0.4), radius := 80.0) -> void:
	Snd.play("boss_roar", -2.0)
	anim(host, "roar", 8.0, false)
	ring_fx(host, host.global_position, radius, 0.6, color)
	ring_fx(host, host.global_position, radius * 0.6, 0.45, Color(1, 1, 1))
	flash_fx(host, host.global_position + Vector2(0, -14), 26.0, 0.4, color)
	sparks(host, host.global_position + Vector2(0, -14), color, 24, 90.0, 0.7)
	punch(host, 1.12, 0.9, 0.4)
	shake(host, 2.5, 0.5)
