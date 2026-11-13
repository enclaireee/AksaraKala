class_name AmbientVillager extends Node2D
## Ambient town villager (architecture.md 9, Town life). No collision, no dialogue, no prompt, no physics body:
## it walks by grid lookups through TownLife.can_walk. Feet sit on y 0 over a shadow, like Npc.
## Adults wander short routes near `home`, pause, and some stand in pairs chatting. Children run small loops.
## `step(delta)` is the whole logic, so a test can drive it without a SceneTree frame.

const Defs := preload("res://entities/ambient/ambient_defs.gd")
const WALK := 30.0
const RUN := 55.0
const NEAR := 20.0     # the player this close: pause or step aside

enum S { IDLE, WALK, RUN, GO_POST, WAIT, CHAT, AVOID }

## Emote bubbles: pixel list inside a 7x5 box, colour.
const EMOTES := [
	[[1, 2], [3, 2], [5, 2]],                                   # ...
	[[3, 0], [3, 1], [3, 2], [3, 4]],                           # !
	[[2, 0], [3, 0], [4, 1], [3, 2], [3 , 4]],                  # ?
	[[1, 1], [2, 0], [4, 0], [5, 1], [1, 2], [5, 2], [2, 3], [4, 3], [3, 4]],   # heart outline
	[[4, 0], [4, 1], [4, 2], [3, 3], [2, 3], [3, 2]],           # note
]

var variant := 0
var _emote_tex: Texture2D
var life: Node2D
var home := Vector2.ZERO
var radius := 36.0
var child := false
var partner: AmbientVillager
var leader := false
var post := Vector2.ZERO
var at_post := false
var state: int = S.IDLE
var dir := 0                 # 0 down, 1 up, 2 left, 3 right
var rng := RandomNumberGenerator.new()

var _sheet: Texture2D
var _t := 0.0
var _timer := 0.0
var _cycle := 0.0
var _target := Vector2.ZERO
var _stuck := 0.0
var _moving := false
var _loop: Array[Vector2] = []
var _li := 0
var _key := -1
var _emote := -1


func setup(v: int, l: Node2D, p: Vector2, seed_: int) -> void:
	variant = v
	life = l
	position = p
	home = p
	post = p
	rng.seed = seed_
	child = Defs.VILLAGERS[v].body == "child"
	_t = rng.randf() * 10.0
	dir = rng.randi() % 4
	_timer = rng.randf_range(0.2, 3.0)
	_cycle = rng.randf_range(4.0, 12.0)
	if child:
		radius = 28.0
		_build_loop()
		state = S.RUN


func _ready() -> void:
	_sheet = AmbientBatch.tex("villager_%02d" % variant)
	_key = -1
	queue_redraw()


func _process(delta: float) -> void:
	step(delta)


func step(delta: float) -> void:
	delta = minf(delta, 0.1)
	_t += delta
	_moving = false
	_emote = -1
	var pp: Vector2 = life.player_pos()
	var d := position.distance_to(pp)
	if d < NEAR and state != S.AVOID:
		state = S.AVOID
		_timer = 3.0
		at_post = false
	match state:
		S.IDLE:
			_timer -= delta
			_cycle -= delta
			if partner != null and _cycle <= 0.0:
				state = S.GO_POST
			elif _timer <= 0.0:
				_decide()
		S.WALK:
			_cycle -= delta
			_go(WALK, delta, S.IDLE)
		S.RUN:
			_run(delta)
		S.GO_POST:
			_target = post
			_go(WALK, delta, S.WAIT)
			if state == S.WAIT:
				at_post = true
				_timer = 12.0
		S.WAIT:
			_timer -= delta
			_face(partner.position - position)
			if partner.at_post and (leader or partner.state == S.CHAT):
				state = S.CHAT
				_timer = rng.randf_range(8.0, 18.0)
			elif _timer <= 0.0:
				_end_chat()
		S.CHAT:
			_timer -= delta
			_face(partner.position - position)
			var turn := int(_t / 2.4) % 2 == (0 if leader else 1)
			if turn and fmod(_t, 2.4) < 1.7:
				_emote = (int(_t / 4.8) + variant) % EMOTES.size()
			if not partner.at_post or (leader and _timer <= 0.0) or (not leader and partner.state != S.CHAT):
				_end_chat()
		S.AVOID:
			_avoid(pp, d, delta)
	_refresh()


func _end_chat() -> void:
	at_post = false
	state = S.IDLE
	_timer = rng.randf_range(0.5, 2.0)
	_cycle = rng.randf_range(14.0, 28.0)


func _decide() -> void:
	_timer = rng.randf_range(1.5, 5.0)
	if child:
		state = S.RUN
		return
	if rng.randf() < 0.65 and _pick_target():
		state = S.WALK
	else:
		if rng.randf() < 0.5:
			dir = rng.randi() % 4


func _pick_target() -> bool:
	for _i in 8:
		var a := rng.randf() * TAU
		var p := home + Vector2.from_angle(a) * rng.randf_range(10.0, radius)
		if life.can_walk(p) and life.can_walk((p + position) * 0.5) and life.can_walk(p * 0.25 + position * 0.75) and life.can_walk(p * 0.75 + position * 0.25):
			_target = p
			_stuck = 0.0
			return true
	return false


func _build_loop() -> void:
	_loop.clear()
	var r := rng.randf_range(14.0, 26.0)
	var a0 := rng.randf() * TAU
	var sgn := 1.0 if rng.randf() < 0.5 else -1.0
	for k in 4:
		var p := home + Vector2.from_angle(a0 + sgn * k * TAU / 4.0) * r
		if life != null and not life.can_walk(p):
			p = home
		_loop.append(p)


func _run(delta: float) -> void:
	if _loop.is_empty():
		_build_loop()
	_target = _loop[_li]
	if position.distance_to(_target) < 2.0 or _stuck > 0.5:
		_li = (_li + 1) % _loop.size()
		_stuck = 0.0
		if _li == 0 and rng.randf() < 0.3:   # a short rest after a lap
			state = S.IDLE
			_timer = rng.randf_range(1.0, 3.0)
		return
	if not _move_to(_target, RUN, delta):
		_stuck += delta


func _go(speed: float, delta: float, done: int) -> void:
	if position.distance_to(_target) < 2.0 or _stuck > 0.6:
		state = done
		_timer = rng.randf_range(1.5, 5.0)
		_stuck = 0.0
		return
	if not _move_to(_target, speed, delta):
		_stuck += delta


func _move_to(p: Vector2, speed: float, delta: float) -> bool:
	var v := (p - position)
	if v.length() < 0.01:
		return true
	return _step_dir(v.normalized(), speed, delta)


func _step_dir(v: Vector2, speed: float, delta: float) -> bool:
	var cand: Array[Vector2] = [v, Vector2(v.x, 0.0), Vector2(0.0, v.y)]
	for c in cand:
		if c.length() < 0.3:
			continue
		var nxt: Vector2 = position + c.normalized() * speed * delta
		if life.can_walk(nxt) and life.can_walk(nxt + Vector2(4, 0)) and life.can_walk(nxt - Vector2(4, 0)):
			position = nxt
			_moving = true
			_face(c)
			return true
	return false


func _avoid(pp: Vector2, d: float, delta: float) -> void:
	_timer -= delta
	var away := position - pp
	if away.length() < 0.1:
		away = Vector2.RIGHT
	if d < 13.0:   # too close: sidestep, away first, then to the sides
		var n := away.normalized()
		var side := n.orthogonal()
		var order: Array[Vector2] = [n, side, -side]
		for v in order:
			if _step_dir(v, 40.0, delta):
				break
	if not _moving:
		_face(-away)
	if d > NEAR + 6.0 or _timer <= 0.0:
		state = S.IDLE
		_timer = rng.randf_range(0.3, 1.2)


func _face(v: Vector2) -> void:
	if absf(v.x) > absf(v.y):
		dir = 3 if v.x > 0.0 else 2
	elif absf(v.y) > 0.0:
		dir = 0 if v.y > 0.0 else 1


func _refresh() -> void:
	var col := 0
	var row := 0
	if _moving:
		col = int(_t * (9.0 if child else 6.0)) % 4
		row = dir
	else:
		col = int(_t * 1.5) % 2
		row = 4 + dir
	var key := (row * 8 + col) * 8 + (_emote + 1)
	if key != _key:
		_key = key
		queue_redraw()


func _draw() -> void:
	var sh := Npc.shadow_tex("s")
	if sh != null:
		draw_texture(sh, Vector2(-5, -2))
	var top := -9 if child else -19
	if _sheet == null:
		draw_rect(Rect2(-5, top, 10, -top), Color(0.55, 0.4, 0.3))
	else:
		var row := dir if _moving else 4 + dir
		var col := int(_t * (9.0 if child else 6.0)) % 4 if _moving else int(_t * 1.5) % 2
		draw_texture_rect_region(_sheet, Rect2(-8, -23, 16, 24), Rect2(col * 16, row * 24, 16, 24))
	if _emote >= 0:
		_draw_emote(Vector2(-4, top - 11), _emote)


func _draw_emote(at: Vector2, kind: int) -> void:
	if _emote_tex == null:
		_emote_tex = load("res://assets/art/ambient/emotes.png")   # 5 bubbles of 11x10: dots, !, ?, heart, note
	draw_texture_rect_region(_emote_tex, Rect2(at + Vector2(-1, 0), Vector2(11, 10)), Rect2(kind * 11, 0, 11, 10))
