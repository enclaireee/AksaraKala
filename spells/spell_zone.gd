class_name SpellZone extends Node2D
## A configurable ground effect that most class spells are built from (spells.md 3): a circle that ticks damage,
## slows, roots, pulls, drains, heals the caster, eats enemy shots, drifts, follows the caster, or works as a
## one-shot trap. Damage goes straight to Health (like a burn tick), so it never refills Sakti.
## Set the exported-style fields, then add it to the world. `delay` is a telegraph before the first tick.

var caster: Node2D
var radius := 48.0
var life := 3.0               # seconds, counted from the start (delay included)
var delay := 0.0
var tick := 0.5
var damage := 0               # per tick
var slow := 0.0               # >0: slow multiplier (0.5 = half speed) applied every tick
var root := 0.0               # seconds Bound on the first tick an enemy is inside (bosses are slowed instead)
var pull := 0.0               # px/s toward the centre while alive (bosses are not pulled)
var drift := Vector2.ZERO     # px/s
var follow := false           # stay on the caster
var eat_shots := false        # destroy enemy projectiles inside
var heal_self := 0.0          # fraction of the caster's max HP per tick while the caster stands inside
var drain := 0.0              # fraction of damage dealt returned to the caster as HP
var trap := false             # waits (hidden after the delay) and fires once when an enemy steps in
var tint := Color.WHITE
var show_ring := true
var on_tick := Callable()     # called with (zone) after every tick
var on_end := Callable()      # called with (zone) when the zone ends
var _t := 0.0
var _next := 0.0
var _spin := 0.0
var _rooted := {}


func _ready() -> void:
	z_index = 4
	if caster != null and caster.is_in_group("player"):
		var g := SpellUtil._game()
		if g:
			radius *= 1.0 + g.bonus("spell_radius")
		life *= SpellUtil.zone_life_mult()
	_next = delay


func _physics_process(delta: float) -> void:
	_t += delta
	_spin += delta
	if follow and is_instance_valid(caster):
		global_position = caster.global_position
	else:
		global_position += drift * delta
	var inside := SpellUtil.enemies_near(get_tree(), global_position, radius)
	if pull > 0.0:
		for e in inside:
			if not e.is_in_group("boss"):
				e.global_position = e.global_position.move_toward(global_position, pull * delta)
	if eat_shots:
		for a in get_parent().get_children():
			if a is Arrow and a.source != caster and a.global_position.distance_to(global_position) < radius:
				a.queue_free()
	if trap:
		if _t >= delay and not inside.is_empty():
			_fire(inside)
			_finish()
			return
	elif _t >= _next:
		_next += tick
		_fire(inside)
	if _t >= life:
		_finish()
		return
	modulate.a = clampf((life - _t) / 0.3, 0.0, 1.0)
	queue_redraw()


func _fire(inside: Array) -> void:
	var dealt := 0
	for e in inside:
		if damage > 0:
			SpellUtil.strike(e, damage)
			dealt += damage
		if slow > 0.0:
			SpellUtil.slow(e, tick + 0.6, slow)
		if root > 0.0 and not _rooted.has(e.get_instance_id()):
			_rooted[e.get_instance_id()] = true
			_root(e)
		SpellFX.burst(get_parent(), "hit_burst", 5, e.global_position + Vector2(0, -6), tint, 0.7, 22.0)
	if is_instance_valid(caster) and caster.get("health") != null:
		if drain > 0.0 and dealt > 0:
			caster.health.heal(maxi(1, roundi(dealt * drain)))
		if heal_self > 0.0 and caster.global_position.distance_to(global_position) <= radius:
			caster.health.heal(maxi(1, roundi(caster.health.max_hp * heal_self)))
	if show_ring and not trap:
		SpellFX.burst(get_parent(), "bind_ring", 5, global_position, tint, radius / 62.0, 16.0)
	if on_tick.is_valid():
		on_tick.call(self)


func _root(e: Node) -> void:
	if e.get("status") == null:
		return
	var tuning: CombatTuning = e.status.tuning
	if e.is_in_group("boss"):
		e.status.apply(Status.Type.SLOW, tuning.bind_slow_time, tuning.bind_slow_mult)   # bosses are never rooted
		return
	e.status.apply(Status.Type.BOUND, root)
	var roots := SpellFX.make("bind_roots", 6, 14.0)
	if roots and e is Node2D:
		roots.modulate = SpellFX.tint_for("bind_roots", tint)
		roots.position = Vector2(0, 4)
		roots.life = maxf(root, 1.0)
		roots.fade = 0.3
		e.add_child(roots)


func _finish() -> void:
	if trap:
		SpellFX.burst(get_parent(), "ward_break", 5, global_position, tint, 0.7, 18.0)
	if on_end.is_valid():
		on_end.call(self)
	queue_free()


## Pixel-art ring: no anti-aliasing, a snapped radius, a 3 px stepped band in 3 tones (light inside, deep outside).
func _band(r: float, col: Color) -> void:
	var rr := roundf(r)
	draw_arc(Vector2.ZERO, rr - 1.0, 0.0, TAU, maxi(24, int(rr * 1.6)), col.lightened(0.5), 1.0, false)
	draw_arc(Vector2.ZERO, rr, 0.0, TAU, maxi(24, int(rr * 1.6)), col, 1.0, false)
	draw_arc(Vector2.ZERO, rr + 1.0, 0.0, TAU, maxi(24, int(rr * 1.6)), col.darkened(0.5), 1.0, false)


func _draw() -> void:
	if not show_ring:
		return
	if _t < delay or (trap and _t < delay + 0.05):
		_band(radius, Color(tint, 0.5 + 0.35 * signf(sin(_t * 16.0))))   # telegraph blinks in whole steps
		return
	if trap:
		_band(radius, Color(tint, 0.3))   # a faint ring: a hidden snare
		return
	var tile := SpellFX.tex("zone_fill", false)
	if tile != null:   # sparse tiled motif, whole 16 px cells inside the ring
		var n := int(radius / 16.0)
		for cy in range(-n, n):
			for cx in range(-n, n):
				var c := Vector2(cx * 16 + 8, cy * 16 + 8)
				if c.length() + 8.0 <= radius - 2.0:
					draw_texture(tile, c - Vector2(8, 8), Color(tint, 0.35))
	_band(radius, Color(tint, 0.9))
	for k in 8:
		var a := _spin * 0.9 + k * TAU / 8.0
		var p := (Vector2.from_angle(a) * (radius + 5.0)).round()
		draw_rect(Rect2(p - Vector2(1, 1), Vector2(3, 3)), Color(tint.lightened(0.4), 0.95))
