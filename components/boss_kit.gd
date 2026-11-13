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
	var motif: Texture2D   # 16x16 fill tile, white/grey so `color` tints it (BossKit.motif_for)
	var t := 0.0

	func _ready() -> void:
		z_index = -1
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED   # the motif tiles 1:1

	func _process(delta: float) -> void:
		t += delta
		if t >= life:
			queue_free()
			return
		if follow != null and is_instance_valid(follow):
			global_position = follow.global_position
		queue_redraw()

	## Pixel art (combat.md 5.3 "Telegraph look"): the shape is cut on the pixel grid, filled with the boss motif and
	## edged with a 3 px stepped band. The fill grows to the strike; its closing edge is a pale 3 px band.
	func _draw() -> void:
		var f := clampf(t / life, 0.0, 1.0)
		var flash := 0.5 + 0.5 * sin(t * 40.0) if f > 0.8 else 0.0
		var edge := BossKit.ramp(Color(color, 0.9))
		var back := Color(color, 0.10)
		var fill := Color(color, 0.18 + 0.30 * f + 0.25 * flash)
		var hot := BossKit.ramp(Color(Color(1, 1, 1).lerp(color, 0.25), 0.3 + 0.5 * flash), 0.15)
		match kind:
			"circle":
				var r := roundf(radius)
				var k := roundf(radius * f)
				var full := BossKit.px_disc(r)
				BossKit.px_fill(self, full, back, motif)
				if k >= 1.0:
					BossKit.px_fill(self, BossKit.px_disc(k), fill, motif)
				BossKit.px_edge(self, full, edge)
				if k >= 3.0:
					BossKit.px_edge(self, BossKit.px_disc(k, k - 3.0), hot, 3, false)
				for i in 8:   # chunks turning on the rim, like a seal being drawn
					var p := (Vector2.from_angle(t * 1.6 + TAU * i / 8.0) * maxf(r - 1.5, 1.0)).round()
					draw_rect(Rect2(p - Vector2(1, 1), Vector2(3, 3)), Color(color.lightened(0.6), 0.9))
			"ring":
				var full := BossKit.px_disc(roundf(radius), roundf(inner))
				var mid := (radius + inner) * 0.5
				var hw := (radius - inner) * 0.5 * f
				BossKit.px_fill(self, full, back, motif)
				if hw >= 0.5:
					BossKit.px_fill(self, BossKit.px_disc(roundf(mid + hw), roundf(mid - hw)), fill, motif)
				BossKit.px_edge(self, full, edge)
			"cone":
				var l := roundf(length)
				var k := roundf(length * f)
				var full := BossKit.px_wedge(dir, arc, l)
				full.key = "w%.3f,%.3f,%d" % [dir, arc, l]
				BossKit.px_fill(self, full, back, motif)
				if k >= 1.0:
					BossKit.px_fill(self, BossKit.px_wedge(dir, arc, k), fill, motif)
				BossKit.px_edge(self, full, edge)
				if k >= 4.0:
					BossKit.px_edge(self, BossKit.px_wedge(dir, arc, k, k - 3.0), hot, 3, false)
			"line":
				var l := roundf(length)
				var w := roundf(width)
				var k := roundf(length * f)
				var full := BossKit.px_rect(dir, 0.0, l, w)
				full.key = "l%.3f,%d,%d" % [dir, l, w]
				BossKit.px_fill(self, full, back, motif)
				if k >= 1.0:
					BossKit.px_fill(self, BossKit.px_rect(dir, 0.0, k, w), fill, motif)
				BossKit.px_edge(self, full, edge)
				if k >= 3.0:
					BossKit.px_edge(self, BossKit.px_rect(dir, k - 3.0, k, w), hot, 3, false)
				var sp := PackedInt32Array()   # 2 px chevrons running down the lane
				var step := 12.0
				var cx := fmod(t * 40.0, step)
				var d := Vector2.from_angle(dir)
				var n := d.orthogonal()
				while cx < length - 3.0:
					var tip := d * (cx + 3.0)
					sp.append_array(BossKit.px_seg(d * cx - n * width * 0.3, tip, 2.0).spans())
					sp.append_array(BossKit.px_seg(tip, d * cx + n * width * 0.3, 2.0).spans())
					cx += step
				BossKit.px_spans(self, sp, Color(color, 0.45))


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
	t.motif = motif_for(host)
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
	t.motif = motif_for(host)
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
	t.motif = motif_for(host)
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
	t.motif = motif_for(host)
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
		for i in _trail.size():   # pixel chunks, bigger and brighter toward the shot
			var f := float(i + 1) / (_trail.size() + 1)
			BossKit.chunk(self, to_local(_trail[i]), clampi(3 - int(f * 3.0), 0, 3), Color(color, 0.35 * ceilf(f * 2.0) / 2.0))
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
	var motif: Texture2D
	var _t := 0.0
	var _tick_t := 0.0

	func _ready() -> void:
		z_index = -1
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

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
		var fade := ceilf(clampf((life - _t) / 0.6, 0.0, 1.0) * 3.0) / 3.0   # fades in 3 steps
		var a := (0.35 if armed else 0.15) * fade
		var s := BossKit.px_disc(roundf(radius))
		BossKit.px_fill(self, s, Color(color, a), motif)
		BossKit.px_edge(self, s, BossKit.ramp(Color(color, 0.9 * fade)))
		if armed:
			for i in 6:
				var ang := TAU * i / 6.0 + _t * 0.7
				var r := radius * (0.25 + 0.6 * fmod(_t * 0.8 + i * 0.37, 1.0))
				BossKit.chunk(self, Vector2.from_angle(ang) * r, 1 + i % 2, Color(1, 1, 0.8, 0.8 * fade))


static func zone(host: EnemyBase, pos: Vector2, radius: float, amount: int, life: float, color := Color(1.0, 0.45, 0.1), warm := 0.5) -> HazardZone:
	var z := HazardZone.new()
	z.host = host
	z.radius = radius
	z.damage = amount
	z.life = life
	z.color = color
	z.warm = warm
	z.motif = motif_for(host)
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
	var motif: Texture2D
	var _r := 4.0
	var _done := false

	func _ready() -> void:
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

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

	## The hit band (`band` px each side of the front) as a motif ring with a lit 3 px rim on both sides.
	func _draw() -> void:
		var f := clampf(1.0 - _r / max_r, 0.0, 1.0)
		var r := roundf(_r)
		var b := roundf(band)
		var s := BossKit.px_disc(r + b, maxf(r - b, 0.0))
		BossKit.px_fill(self, s, Color(color, 0.25 + 0.4 * f), motif)
		BossKit.px_edge(self, s, BossKit.ramp(Color(Color(1, 1, 1).lerp(color, 0.4), 0.25 + 0.65 * f)))


static func wave(host: EnemyBase, pos: Vector2, max_r: float, speed: float, amount: int, color := Color(1.0, 0.8, 0.4), heavy := true) -> Wave:
	var w := Wave.new()
	w.host = host
	w.max_r = max_r
	w.speed = speed
	w.damage = amount
	w.color = color
	w.heavy = heavy
	w.motif = motif_for(host)
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

	## Pixel FX (assets.md 1 FX standard): chunky bands with a dark outline on the first half (the key frames), then
	## the tones step down and rings break into chunks. Alpha fades in 3 steps.
	func _draw() -> void:
		var f := clampf(_t / life, 0.0, 1.0)
		var a := ceilf((1.0 - f) * 3.0) / 3.0
		var early := f < 0.5
		var c := color if early else color.darkened(0.25)
		match kind:
			"ring":
				var ro := roundf(radius * (0.3 + 0.7 * f) + 1.5)
				if f < 0.6:
					BossKit.px_edge(self, BossKit.px_disc(ro, maxf(ro - 3.0, 0.0)), BossKit.ramp(Color(c, a)), 3, early)
				else:
					for i in 8:   # the fade breaks the ring into 8 fat chunks
						BossKit.px_edge(self, BossKit.px_wedge(TAU * i / 8.0 + f, TAU / 16.0, ro, maxf(ro - 3.0, 0.0)), BossKit.ramp(Color(c, a)), 3, false)
			"slash":
				var r := roundf(length * (0.6 + 0.4 * f))
				var w := maxf(3.0, roundf(5.0 * (1.0 - f) + 1.0))
				BossKit.px_edge(self, BossKit.px_wedge(dir, arc, r, maxf(r - w, 0.0)), BossKit.ramp(Color(c, a)), int(w), early)
				var r2 := roundf(length * (0.5 + 0.3 * f))
				BossKit.px_edge(self, BossKit.px_wedge(dir, arc * 0.8, r2, maxf(r2 - 2.0, 0.0)), BossKit.ramp(Color(1, 1, 1, 0.7 * a), 0.15), 2, false)
			"beam":
				var tl := (to - global_position).round()
				var w := maxf(2.0, roundf(width * (1.0 - f) + 1.0))
				var s := BossKit.px_rect(tl.angle(), 0.0, roundf(tl.length()), w)
				BossKit.px_fill(self, s, Color(c, 0.6 * a))
				if w >= 4.0:
					BossKit.px_edge(self, s, BossKit.ramp(Color(c, 0.6 * a)), 2, early)
				BossKit.px_fill(self, BossKit.px_rect(tl.angle(), 0.0, roundf(tl.length()), maxf(2.0, roundf(w * 0.3))), Color(1, 1, 1, a))
			"flash":
				var r := roundf(radius * (0.4 + 0.6 * f))
				var s := BossKit.px_disc(r)
				BossKit.px_fill(self, s, Color(c, 0.8 * a))
				BossKit.px_fill(self, BossKit.px_disc(roundf(r * 0.5)), Color(c.lightened(0.5), 0.8 * a))
				if early:
					BossKit.px_edge(self, s, BossKit.ramp(Color(c, 0.8 * a)), 2)


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
			_p.append({"pos": Vector2.ZERO, "vel": Vector2.from_angle(randf() * TAU) * speed * randf_range(0.3, 1.0), "size": randi_range(0, 1)})

	func _process(delta: float) -> void:
		_t += delta
		if _t >= life:
			queue_free()
			return
		for q: Dictionary in _p:
			q["vel"] = (q["vel"] as Vector2) + Vector2(0, gravity * delta)
			q["pos"] = (q["pos"] as Vector2) + (q["vel"] as Vector2) * delta
		queue_redraw()

	## Pixel chunks (telegraph/chunks.png) that shrink a frame per third of their life; alpha steps down with them.
	func _draw() -> void:
		var f := _t / life
		var a := 1.0 if f < 0.6 else 0.6 if f < 0.85 else 0.3
		for q: Dictionary in _p:
			BossKit.chunk(self, q["pos"] as Vector2, mini(3, int(q["size"]) + int(f * 3.0)), Color(color, a))


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
static func anim(host: Node, anim_name: String, fps := 10.0, hold := true) -> bool:
	var art := host.get_node_or_null("Body/Art") as EnemyArt
	return art != null and art.play(anim_name, fps, hold)


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


# --- boss fights v7 (combat.md 5.3): gate, hints, marks, open window, finisher ------------------------------------

## False while the zone has an arena gate whose threshold the player has not crossed. Zones without a gate
## (tests, Buto Ijo's ambush fields) keep engage-by-range and first hit.
static func may_engage(host: Node) -> bool:
	var g := host.get_tree().get_first_node_in_group("arena_gate")
	return g == null or bool(g.get("entered"))


## One line above the boss bar. Call it every frame the gimmick state lasts: it shows on the first call and again
## every `every` seconds. Stop calling when the player has answered the state.
static func hint(host: Node, key: String, every := 12.0) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	var m := "hint_" + key
	if host.has_meta(m) and now - float(host.get_meta(m)) < every:
		return
	host.set_meta(m, now)
	var stage := host.get_tree().get_first_node_in_group("boss_stage")
	if stage != null:
		stage.call("show_hint", host.tr(key))


## Marks the next `seconds` as a free hit window: the boss bar glows and shows "TERBUKA".
static func open(host: Node, seconds: float) -> void:
	if host.is_in_group("boss"):
		host.set_meta("open_until", Time.get_ticks_msec() / 1000.0 + seconds)


static func is_open(host: Node) -> bool:
	return host != null and float(host.get_meta("open_until", 0.0)) > Time.get_ticks_msec() / 1000.0


## A pulsing gold ring with the glyph to draw, over the thing that answers a gimmick. One per target; frees
## itself after `life` seconds or with the target. Call again to keep it up.
static func mark(host: Node, target: Node2D, glyph_id := "", life := 4.0, radius := 12.0) -> void:
	if target == null or not is_instance_valid(target) or target.has_node("BossMark"):
		return
	var m := Mark.new()
	m.name = "BossMark"
	m.glyph = GlyphData.by_id(glyph_id) if glyph_id != "" else null
	m.radius = radius
	m.z_index = 50
	target.add_child(m)
	target.get_tree().create_timer(life).timeout.connect(func() -> void:
		if is_instance_valid(m):
			m.queue_free())


class Mark extends Node2D:
	var glyph: GlyphData
	var radius := 12.0
	var _t := 0.0
	var _cells := PackedVector2Array()   # the glyph as 2x2 px cells, built once

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	## A gold pixel ring (3 px band, plus a faint outer band) and the glyph stamped in 2 px cells on a book tile.
	func _draw() -> void:
		var r := roundf(radius + 2.0 * sin(_t * 6.0))
		var gold := BossKit.ramp(Color(GOLD, 0.9))
		BossKit.px_edge(self, BossKit.px_disc(r, r - 3.0), gold, 3, true)
		BossKit.px_fill(self, BossKit.px_disc(r + 4.0, r + 2.0), Color(GOLD, 0.35))
		if glyph == null or glyph.templates.is_empty():
			return
		var box := Rect2(Vector2(-10, -radius - 24.0), Vector2(20, 20)).abs()
		box.position = box.position.round()
		var tile := BossKit._art_ui("book_glyph_tile.png")
		if tile != null:
			draw_texture_rect(tile, box, false)
		else:
			draw_rect(box, Color(0.05, 0.04, 0.08, 0.85))
			draw_rect(box.grow(-1.0), Color(GOLD.darkened(0.4), 0.9), false, 2.0)
		if _cells.is_empty():
			_cells = _stamp()
		for c in _cells:
			draw_rect(Rect2(c + Vector2(1, 1), Vector2(2, 2)), Color(0.118, 0.071, 0.133))   # plum shadow
		for c in _cells:
			draw_rect(Rect2(c, Vector2(2, 2)), Color(1.0, 0.92, 0.6))

	## The template path (one template is the whole glyph) scaled to 14 px and walked in 1 px steps onto a 2 px grid.
	func _stamp() -> PackedVector2Array:
		var st: PackedVector2Array = glyph.templates[0]
		var box := Rect2(st[0], Vector2.ZERO)
		for p in st:
			box = box.expand(p)
		var k := 14.0 / maxf(maxf(box.size.x, box.size.y), 0.001)
		var at := Vector2(0, -radius - 14.0) - box.get_center() * k
		var seen := {}
		var out := PackedVector2Array()
		for i in st.size() - 1:
			var p0 := at + st[i] * k
			var p1 := at + st[i + 1] * k
			var n := maxi(1, ceili(p0.distance_to(p1)))
			for j in n + 1:
				var c := (p0.lerp(p1, float(j) / n) - Vector2(1, 1)).round()
				if not seen.has(c):
					seen[c] = true
					out.append(c)
		return out


## The aksara finisher. Called by EnemyBase when health dies; `die` is the boss's own _on_died. With no
## `finish_glyph`, or in a zone without an arena gate, death is immediate as before. Otherwise the boss kneels
## for up to `KNEEL` seconds; casting the glyph ends it with a flourish, else the timer does.
const KNEEL := 4.0   # TUNE

static func finisher(host: EnemyBase, die: Callable) -> void:
	if host.is_in_group("boss") and host.unique_id != "":   # the codex shows its "Cara melawan" line from here on (tab_codex.gd)
		host.get_node("/root/Events").weakness_triggered.emit(host.unique_id)
	if host.finish_glyph == "" or not host.is_in_group("boss") or host.get_tree().get_first_node_in_group("arena_gate") == null:
		die.call()
		return
	host.dead = true   # stops _tick; the boss's own _on_died still runs in full afterwards
	host.set_meta("kneeling", true)   # the arena gate counts a kneeling boss as alive: no leaving before the kill is recorded
	var t0 := Time.get_ticks_msec()
	host.velocity = Vector2.ZERO
	host.attack_hitbox.deactivate()
	host.release_token()
	if host.has_method("_clear_attack"):   # no telegraph outlives the last blow
		host.call("_clear_attack")
	if not anim(host, "kneel", 6.0, true):   # no kneel frames: squash
		host.body.create_tween().tween_property(host.body, "scale:y", 0.8, 0.3)
	mark(host, host, host.finish_glyph, KNEEL, 18.0)
	hint(host, "BOSS_HINT_FINISH", 0.0)
	var done := [false]
	var end := func(by_glyph: bool) -> void:
		if done[0] or not is_instance_valid(host):
			return
		done[0] = true
		host.remove_meta("kneeling")
		host.dead = false
		host.body.scale.y = 1.0
		if by_glyph:
			Snd.play("boss_finish")
			ring_fx(host, host.global_position, 110.0, 0.7, GOLD)
			sparks(host, host.global_position + Vector2(0, -14), GOLD, 40, 120.0, 0.9)
			shake(host, 3.0, 0.5)
		die.call()
	var ev := host.get_node("/root/Events")
	var on_cast := func(id: String, _score: float) -> void:
		if id == host.finish_glyph:
			end.call(true)
	ev.spell_cast.connect(on_cast)
	# A weapon blow ends it too, after a beat so the killing combo's next hit does not skip the kneel. TUNE
	host.hurtbox.hurt.connect(func(_hb: Hitbox) -> void:
		if Time.get_ticks_msec() - t0 > 500:
			end.call(false))
	var timer := host.get_tree().create_timer(KNEEL)
	var on_timeout := func() -> void: end.call(false)
	timer.timeout.connect(on_timeout)
	host.tree_exiting.connect(func() -> void:
		if is_instance_valid(ev) and ev.spell_cast.is_connected(on_cast):
			ev.spell_cast.disconnect(on_cast)
		if is_instance_valid(timer) and timer.timeout.is_connected(on_timeout):
			timer.timeout.disconnect(on_timeout))


# --- Pixel rasterizer (combat.md 5.3 "Telegraph look", assets.md 1 FX standard) -----------------------------------
# Shapes are cut into 1 px rows on the world pixel grid and drawn as untextured or motif-textured quads, so a
# telegraph reads as pixel art at any window scale (plain draw_arc / draw_circle render smooth at window resolution).
# Mirror: Px in tools/gen_telegraph_art.py, which draws tools/telegraph_preview.png with the same maths.

const MOTIF := {"batara_kala": "ash", "bandung_bondowoso": "stone", "sangkuriang": "kawung",
		"faceless_captain": "parang", "sandekala": "mega", "keris_gandring": "cinder"}   # ASSUMED
const REGION_MOTIF := {"ts": "kawung", "kg": "parang", "mt": "stone", "tt": "cinder", "sk": "ombak", "gk": "ash"}   # ASSUMED
const ART := "res://assets/art/telegraph/"

static var _cache := {}   # shape key + draw kind -> geometry; cleared when it grows past 2000 shapes


## A shape on the pixel grid: inside every half-plane hp (a*x + b*y + c >= 0, (a, b) unit), inside the disc ro,
## outside the disc ri and outside the convex region ex (used by cones wider than PI). Rows y0..y1 are scanned.
class Px extends RefCounted:
	var hp: Array[Vector3] = []
	var ex: Array[Vector3] = []
	var ro := INF
	var ri := 0.0
	var y0 := 0
	var y1 := 0
	var key := ""   # "" = not cached

	## The shape shrunk by d px on every side.
	func inset(d: float) -> Px:
		var s := Px.new()
		for h in hp:
			s.hp.append(Vector3(h.x, h.y, h.z - d))
		for h in ex:
			s.ex.append(Vector3(h.x, h.y, h.z + d))
		s.ro = ro - d
		s.ri = ri + d if ri > 0.0 else 0.0
		s.y0 = y0
		s.y1 = y1
		return s

	static func _hp_iv(planes: Array[Vector3], yc: float) -> Vector2:
		var lo := -1e9
		var hi := 1e9
		for h in planes:
			var k := h.y * yc + h.z
			if absf(h.x) < 1e-6:
				if k < 0.0:
					return Vector2(1.0, -1.0)
			elif h.x > 0.0:
				lo = maxf(lo, -k / h.x)
			else:
				hi = minf(hi, -k / h.x)
		return Vector2(lo, hi)

	static func _cut(ivs: PackedFloat32Array, a: float, b: float) -> PackedFloat32Array:
		var out := PackedFloat32Array()
		for i in range(0, ivs.size(), 2):
			var l := ivs[i]
			var h := ivs[i + 1]
			if b <= l or a >= h:
				out.append_array([l, h])
				continue
			if a > l:
				out.append_array([l, a])
			if b < h:
				out.append_array([b, h])
		return out

	## The covered x intervals (pairs) of the row whose centre is yc.
	func row(yc: float) -> PackedFloat32Array:
		var lo := -1e9
		var hi := 1e9
		if ro < INF:
			var q := ro * ro - yc * yc
			if q < 0.0:
				return PackedFloat32Array()
			hi = sqrt(q)
			lo = -hi
		var iv := _hp_iv(hp, yc)
		lo = maxf(lo, iv.x)
		hi = minf(hi, iv.y)
		if lo > hi:
			return PackedFloat32Array()
		var out := PackedFloat32Array([lo, hi])
		if ri > 0.0:
			var q := ri * ri - yc * yc
			if q > 0.0:
				out = _cut(out, -sqrt(q), sqrt(q))
		if not ex.is_empty():
			var e := _hp_iv(ex, yc)
			if e.x <= e.y:
				out = _cut(out, e.x, e.y)
		return out

	static func _pix(ivs: PackedFloat32Array, y: int, out: PackedInt32Array) -> void:
		for i in range(0, ivs.size(), 2):
			var x0 := ceili(ivs[i] - 0.5)
			var x1 := floori(ivs[i + 1] - 0.5)
			if x1 >= x0:
				out.append_array([x0, y, x1])

	## Pixel spans (x0, y, x1 triples) of the shape, or with d1 >= 0 of the band between insets d0 and d1.
	func spans(d0 := 0.0, d1 := -1.0) -> PackedInt32Array:
		var out := PackedInt32Array()
		var a := self if d0 == 0.0 else inset(d0)
		var b: Px = null if d1 < 0.0 else inset(d1)
		for y in range(y0, y1 + 1):
			var ivs := a.row(y + 0.5)
			if b != null:
				var inner := b.row(y + 0.5)
				for i in range(0, inner.size(), 2):
					ivs = _cut(ivs, inner[i], inner[i + 1])
			_pix(ivs, y, out)
		return out

	## Outward normal of the nearest boundary at p.
	func normal(p: Vector2) -> Vector2:
		var best := 1e9
		var n := Vector2(0, -1)
		var r := maxf(p.length(), 0.001)
		if ro < INF and ro - r < best:
			best = ro - r
			n = p / r
		if ri > 0.0 and r - ri < best:
			best = r - ri
			n = -p / r
		for h in hp:
			var d := h.x * p.x + h.y * p.y + h.z
			if d < best:
				best = d
				n = Vector2(-h.x, -h.y)
		for h in ex:
			var d := -(h.x * p.x + h.y * p.y + h.z)
			if d >= 0.0 and d < best:
				best = d
				n = Vector2(h.x, h.y)
		return n


## 4 tones lit from the top-left: light, base, shade, outline. Alpha is kept.
static func ramp(c: Color, dk := 0.4) -> Array[Color]:
	return [c.lightened(0.45), c, c.darkened(dk), c.darkened(0.7)]


static func px_disc(ro: float, ri := 0.0) -> Px:
	var s := Px.new()
	s.ro = ro
	s.ri = maxf(ri, 0.0)
	s.y0 = -int(ro) - 1
	s.y1 = int(ro) + 1
	s.key = "d%s,%s" % [ro, s.ri]
	return s


## A cone of full width `arc` around `dir`, from ri out to ro.
static func px_wedge(dir: float, arc: float, ro: float, ri := 0.0) -> Px:
	var s := px_disc(ro, ri)
	if arc >= TAU - 0.001:
		return s
	var e0 := Vector2.from_angle(dir - arc * 0.5)
	var e1 := Vector2.from_angle(dir + arc * 0.5)
	if arc <= PI:
		s.hp = [Vector3(-e0.y, e0.x, 0.0), Vector3(e1.y, -e1.x, 0.0)]
	else:
		s.ex = [Vector3(-e1.y, e1.x, 0.0), Vector3(e0.y, -e0.x, 0.0)]
	s.key = "w%.3f,%.3f,%s,%s" % [dir, arc, ro, s.ri]
	return s


## A lane along `dir` from u0 to u1, `w` wide.
static func px_rect(dir: float, u0: float, u1: float, w: float) -> Px:
	var d := Vector2.from_angle(dir)
	var n := d.orthogonal()
	var s := Px.new()
	s.hp = [Vector3(d.x, d.y, -u0), Vector3(-d.x, -d.y, u1), Vector3(n.x, n.y, w * 0.5), Vector3(-n.x, -n.y, w * 0.5)]
	var lo := INF
	var hi := -INF
	for u in [u0, u1]:
		for v in [-w * 0.5, w * 0.5]:
			lo = minf(lo, d.y * u + n.y * v)
			hi = maxf(hi, d.y * u + n.y * v)
	s.y0 = floori(lo) - 1
	s.y1 = ceili(hi) + 1
	s.key = "r%.3f,%s,%s,%s" % [dir, u0, u1, w]
	return s


## A `w` px stroke from a to b.
static func px_seg(a: Vector2, b: Vector2, w: float) -> Px:
	var s := px_rect((b - a).angle(), 0.0, a.distance_to(b), w)
	for i in s.hp.size():
		var h := s.hp[i]
		s.hp[i] = Vector3(h.x, h.y, h.z - (h.x * a.x + h.y * a.y))
	s.y0 += floori(a.y)
	s.y1 += ceili(a.y)
	s.key = ""
	return s


## Fills the shape, tinting the 16x16 motif tile 1:1 (the node needs texture_repeat enabled), or flat with none.
static func px_fill(ci: CanvasItem, s: Px, color: Color, motif: Texture2D = null) -> void:
	if color.a <= 0.0:
		return
	var k := s.key + "|f" if s.key != "" else ""
	var geo: Array = _cache.get(k, []) if k != "" else []
	if geo.is_empty():
		geo = _geo(s.spans())
		_keep(k, geo)
	_tri(ci, geo, color, motif)


## The stepped edge band, `bw` px: a 1 px outline in the darkest tone (if `outline`), then the lit band whose
## tone follows the outward normal (top-left light, bottom-right shade).
static func px_edge(ci: CanvasItem, s: Px, tones: Array[Color], bw := 3, outline := true) -> void:
	if tones[1].a <= 0.0 or bw <= 0:
		return
	var k := "%s|e%d%s" % [s.key, bw, outline] if s.key != "" else ""
	var geos: Array = _cache.get(k, []) if k != "" else []
	if geos.is_empty():
		var parts: Array[PackedInt32Array] = [PackedInt32Array(), PackedInt32Array(), PackedInt32Array(), PackedInt32Array()]
		if outline:
			parts[3] = s.spans(0.0, 1.0)
		var lit := s.spans(1.0 if outline else 0.0, float(bw))
		for i in range(0, lit.size(), 3):
			var n := s.normal(Vector2((lit[i] + lit[i + 2] + 1) * 0.5, lit[i + 1] + 0.5))
			var d := (-n.x - n.y) * 0.7071
			var t := 0 if d > 0.3 else 2 if d < -0.3 else 1
			parts[t].append_array([lit[i], lit[i + 1], lit[i + 2]])
		for p in parts:
			geos.append(_geo(p))
		_keep(k, geos)
	for t in 4:
		_tri(ci, geos[t], tones[t], null)


## Flat spans (x0, y, x1 triples) in one colour.
static func px_spans(ci: CanvasItem, spans: PackedInt32Array, color: Color) -> void:
	_tri(ci, _geo(spans), color, null)


## One pixel chunk (telegraph/chunks.png: 4 frames of 4x4, big to small) centred on p, tinted.
static func chunk(ci: CanvasItem, p: Vector2, frame: int, color: Color) -> void:
	var tex := _art("chunks.png")
	var at := p.round() - Vector2(2, 2)
	if tex == null:
		var sz := float(maxi(4 - frame, 2))
		ci.draw_rect(Rect2(at, Vector2(sz, sz)), color)
		return
	ci.draw_texture_rect_region(tex, Rect2(at, Vector2(4, 4)), Rect2(clampi(frame, 0, 3) * 4, 0, 4, 4), color)


static func _keep(k: String, v: Array) -> void:
	if k == "":
		return
	# ponytail: drop everything at 256 (a big arena disc is ~50 KB, so this caps memory near 13 MB). Growing
	# fills churn keys every frame and refill it every few seconds; add an LRU or uncached keys if that shows in a profile.
	if _cache.size() > 256:
		_cache.clear()
	_cache[k] = v


static func _geo(spans: PackedInt32Array) -> Array:
	var pts := PackedVector2Array()
	var idx := PackedInt32Array()
	for i in range(0, spans.size(), 3):
		var v := pts.size()
		var x0 := float(spans[i])
		var y := float(spans[i + 1])
		var x1 := float(spans[i + 2] + 1)
		pts.append_array([Vector2(x0, y), Vector2(x1, y), Vector2(x1, y + 1.0), Vector2(x0, y + 1.0)])
		idx.append_array([v, v + 1, v + 2, v, v + 2, v + 3])
	return [pts, Transform2D.IDENTITY.scaled(Vector2.ONE / 16.0) * pts, idx]


static func _tri(ci: CanvasItem, geo: Array, color: Color, tex: Texture2D) -> void:
	var pts: PackedVector2Array = geo[0]
	if pts.is_empty() or color.a <= 0.0:
		return
	var cols := PackedColorArray()
	cols.resize(pts.size())
	cols.fill(color)
	RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), geo[2], pts, cols,
			geo[1] if tex != null else PackedVector2Array(), PackedInt32Array(), PackedFloat32Array(),
			tex.get_rid() if tex != null else RID())


## A telegraph-art texture, or null when it is missing (callers fall back to flat drawing).
static func _art(file: String) -> Texture2D:
	return _tex_at(ART + file)


static func _art_ui(file: String) -> Texture2D:
	return _tex_at("res://assets/art/ui/" + file)


static var _texs := {}   # path -> Texture2D or null; looked up once, since _draw calls these every frame

static func _tex_at(p: String) -> Texture2D:
	if not _texs.has(p):
		_texs[p] = load(p) as Texture2D if ResourceLoader.exists(p) else null
	return _texs[p]


## The motif tile for a boss (MOTIF by unique_id), else for the region of the current zone, else kawung.
static func motif_for(host: Node) -> Texture2D:
	var id := ""
	if host is EnemyBase:
		id = MOTIF.get((host as EnemyBase).unique_id, "")
	if id == "" and host != null and host.is_inside_tree():
		var zones := host.get_node_or_null("/root/Zones")
		if zones != null:
			id = REGION_MOTIF.get(str(zones.get("current_zone")).get_file().get_slice("_", 0), "")
	return _art("motif_%s.png" % (id if id != "" else "kawung"))


## A standing pixel decal: a motif-filled disc (or lane from a to b) with the stepped edge band. Replaces the
## Polygon2D / Line2D marks the bosses used to build. Setters redraw, so a boss can animate radius or ends.
class PxDecal extends Node2D:
	var kind := "circle"   # circle | line
	var radius := 8.0:
		set(v):
			radius = v
			queue_redraw()
	var inner := 0.0       # circle: a ring when > 0
	var a := Vector2.ZERO:
		set(v):
			a = v
			queue_redraw()
	var b := Vector2.ZERO:
		set(v):
			b = v
			queue_redraw()
	var width := 4.0       # line
	var color := Color(1, 1, 1, 0.3):
		set(v):
			color = v
			queue_redraw()
	var edge_alpha := -1.0   # < 0: max(0.85, color.a)
	var band := 3
	var motif: Texture2D

	func _ready() -> void:
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

	func _draw() -> void:
		var s: BossKit.Px
		if kind == "line":
			if a.distance_to(b) < 1.0:
				return
			s = BossKit.px_seg(a.round(), b.round(), maxf(2.0, roundf(width)))
		else:
			if radius < 1.0:
				return
			s = BossKit.px_disc(roundf(radius), roundf(inner))
		BossKit.px_fill(self, s, color, motif)
		var ea := edge_alpha if edge_alpha >= 0.0 else maxf(0.85, color.a)
		BossKit.px_edge(self, s, BossKit.ramp(Color(color, ea)), band, band >= 3)


static func decal(host: Node, radius: float, color: Color) -> PxDecal:
	var d := PxDecal.new()
	d.radius = radius
	d.color = color
	d.motif = motif_for(host)
	return d


## A sprite prop from res://assets/art/<path>, `hframes` frames; a flat Polygon2D box of `size` when it is missing.
static func prop(path: String, size: Vector2, fallback: Color, hframes := 1) -> Node2D:
	var p := "res://assets/art/" + path
	if ResourceLoader.exists(p):
		var s := Sprite2D.new()
		s.texture = load(p)
		s.hframes = hframes
		return s
	var g := Polygon2D.new()
	var h := size * 0.5
	g.polygon = PackedVector2Array([-h, Vector2(h.x, -h.y), h, Vector2(-h.x, h.y)])
	g.color = fallback
	return g
