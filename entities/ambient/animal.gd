class_name AmbientAnimal extends Node2D
## Ambient town animal (architecture.md 9, Town life). Sprites face left; they are mirrored to face right.
## Chickens peck, hop and flee the player within 28 px, then resettle. Cats sit and sleep. Ducks waddle near
## water. Goats and kerbau are tethered to a stake and barely move. No collision, no prompt; grid lookups only.
## Sheet columns: idle0 idle1 walk0-3 extra0 extra1 (extra: peck/hop, swim, sleep, lie or graze).

const Defs := preload("res://entities/ambient/ambient_defs.gd")

enum S { IDLE, PECK, WALK, HOP, FLEE, SLEEP, CROW }

## group, walk speed, flee trigger distance (0 = ignores the player), wander radius
const SPEC := {
	"chicken": {"g": "bird", "speed": 22.0, "flee": 28.0, "radius": 30.0},
	"rooster": {"g": "bird", "speed": 22.0, "flee": 28.0, "radius": 30.0},
	"chick": {"g": "bird", "speed": 24.0, "flee": 28.0, "radius": 26.0},
	"duck": {"g": "duck", "speed": 18.0, "flee": 22.0, "radius": 40.0},
	"cat": {"g": "cat", "speed": 30.0, "flee": 18.0, "radius": 26.0},
	"dog": {"g": "dog", "speed": 38.0, "flee": 0.0, "radius": 44.0},
	"goat": {"g": "tether", "speed": 14.0, "flee": 0.0, "radius": 22.0},
	"kerbau": {"g": "tether", "speed": 10.0, "flee": 0.0, "radius": 26.0},
}
const FLEE_SPEED := 70.0

var species := "chicken"
var row := 0
var life: Node2D
var home := Vector2.ZERO
var leader: AmbientAnimal       # a chick follows its hen
var state: int = S.IDLE
var face_right := false
var rng := RandomNumberGenerator.new()

var _sheet: Texture2D
var _cell := Vector2i(12, 12)
var _spec: Dictionary
var _t := 0.0
var _timer := 0.0
var _target := Vector2.ZERO
var _stuck := 0.0
var _moving := false
var _hop_t := 0.0
var _key := -1
var _in_water := false


func setup(sp: String, r: int, l: Node2D, p: Vector2, seed_: int) -> void:
	species = sp
	row = r
	life = l
	position = p
	home = p
	rng.seed = seed_
	_spec = SPEC[sp]
	_cell = Defs.ANIMALS[sp].cell
	_t = rng.randf() * 10.0
	_timer = rng.randf_range(0.2, 2.5)
	face_right = rng.randf() < 0.5
	if _spec.g == "cat":
		state = S.SLEEP if rng.randf() < 0.5 else S.IDLE


func _ready() -> void:
	_sheet = AmbientBatch.tex("animal_%s" % species)
	queue_redraw()


func _process(delta: float) -> void:
	step(delta)


func step(delta: float) -> void:
	delta = minf(delta, 0.1)
	_t += delta
	_moving = false
	var pp: Vector2 = life.player_pos()
	var d := position.distance_to(pp)
	var flee_at: float = _spec.flee
	if flee_at > 0.0 and d < flee_at and state != S.FLEE:
		state = S.FLEE
		_hop_t = 0.0
	match state:
		S.FLEE:
			if d > flee_at + 16.0:
				state = S.PECK if _spec.g == "bird" else S.IDLE
				_timer = rng.randf_range(1.0, 2.5)
			else:
				_flee(position - pp, delta)
		S.WALK:
			_walk(delta)
		S.HOP:
			_hop_t += delta
			if _hop_t > 0.4:
				state = S.IDLE
				_timer = rng.randf_range(0.5, 1.5)
		_:
			_timer -= delta
			if _follow_leader(delta):
				pass
			elif _timer <= 0.0:
				_decide()
	_in_water = _spec.g == "duck" and life.is_water(position)
	_refresh()


func _flee(away: Vector2, delta: float) -> void:
	if away.length() < 0.1:
		away = Vector2.from_angle(rng.randf() * TAU)
	var n := away.normalized()
	for k in [0.0, 0.8, -0.8, 1.6, -1.6, 2.4, -2.4]:
		var v := n.rotated(float(k))
		if _step(v, FLEE_SPEED if _spec.g == "bird" else 55.0, delta):
			return


func _follow_leader(delta: float) -> bool:
	if leader == null or not is_instance_valid(leader):
		return false
	var d := position.distance_to(leader.position)
	if d > 18.0 and state != S.WALK:
		_target = leader.position + Vector2(rng.randf_range(-8, 8), rng.randf_range(-4, 4))
		state = S.WALK
		_stuck = 0.0
		return true
	return false


func _decide() -> void:
	var r := rng.randf()
	match _spec.g:
		"bird":
			if r < 0.5:
				state = S.PECK
				_timer = rng.randf_range(1.5, 4.0)
			elif r < 0.82:
				_pick(S.WALK)
			elif r < 0.92 and species != "chick":
				state = S.HOP
				_hop_t = 0.0
			elif species == "rooster" and r < 0.96:
				state = S.CROW
				_timer = 1.4
			else:
				state = S.IDLE
				_timer = rng.randf_range(0.8, 2.0)
		"duck":
			if r < 0.7:
				_pick(S.WALK)
			else:
				state = S.IDLE
				_timer = rng.randf_range(1.0, 3.0)
		"cat":
			if r < 0.4:
				state = S.SLEEP
				_timer = rng.randf_range(8.0, 18.0)
			elif r < 0.65:
				_pick(S.WALK, 30.0)
			else:
				state = S.IDLE
				_timer = rng.randf_range(4.0, 9.0)
		"dog":
			if r < 0.35:
				state = S.SLEEP
				_timer = rng.randf_range(6.0, 14.0)
			elif r < 0.8:
				_pick(S.WALK)
			else:
				state = S.IDLE
				_timer = rng.randf_range(2.0, 5.0)
		_:   # tethered
			if r < 0.5:
				state = S.PECK   # grazing (extra frames)
				_timer = rng.randf_range(4.0, 9.0)
			elif r < 0.8:
				_pick(S.WALK)
			else:
				state = S.IDLE
				_timer = rng.randf_range(2.0, 5.0)


func _pick(next: int, max_dist := 999.0) -> void:
	var water: bool = _spec.g == "duck"
	for _i in 8:
		var p: Vector2 = home + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(6.0, _spec.radius)
		if p.distance_to(position) > max_dist:
			continue
		if life.can_walk(p, water) and life.can_walk((p + position) * 0.5, water):
			_target = p
			state = next
			_stuck = 0.0
			return
	state = S.IDLE
	_timer = rng.randf_range(1.0, 3.0)


func _walk(delta: float) -> void:
	if position.distance_to(_target) < 2.0 or _stuck > 0.6:
		state = S.IDLE
		_timer = rng.randf_range(0.8, 2.5)
		return
	if not _step((_target - position).normalized(), _spec.speed, delta):
		_stuck += delta


func _step(v: Vector2, speed: float, delta: float) -> bool:
	var water: bool = _spec.g == "duck"
	var nxt := position + v * speed * delta
	if life.can_walk(nxt, water):
		position = nxt
		_moving = true
		if absf(v.x) > 0.15:
			face_right = v.x > 0.0
		return true
	return false


func _col() -> int:
	var walking := _moving or state == S.WALK or state == S.FLEE
	if _in_water:
		return 6 + int(_t * 1.5) % 2
	if state == S.HOP:
		return 7
	if state == S.CROW:
		return 7
	if walking:
		return 2 + int(_t * (12.0 if state == S.FLEE else 7.0)) % 4
	var g: String = _spec.g
	match state:
		S.PECK:
			if g == "tether":
				return 6 + int(_t * 0.8) % 2
			return 6 if int(_t * 3.5) % 2 == 0 else 0
		S.SLEEP:
			return 6 + int(_t * 0.8) % 2
	return int(_t * 1.2) % 2


func _refresh() -> void:
	var key := _col() * 4 + (1 if face_right else 0) * 2 + (1 if _hop_t > 0.0 else 0)
	if state == S.HOP or key != _key:
		_key = key
		queue_redraw()


static var _stake: Texture2D


func _stake_tex() -> Texture2D:
	if _stake == null and ResourceLoader.exists("res://assets/art/world_fx/stake.png"):
		_stake = load("res://assets/art/world_fx/stake.png")
	return _stake


func _draw() -> void:
	var cw := _cell.x
	var ch := _cell.y
	var big := species == "kerbau"
	var sh := Npc.shadow_tex("l" if big else ("m" if cw * 0.6 >= 12.0 else "s"))
	if sh != null:
		draw_texture(sh, Vector2(-sh.get_width() * 0.5, -2))
	if _spec.g == "tether":   # the stake and its rope
		var stake := home - position
		draw_line(stake + Vector2(0, -5), Vector2(0, -ch * 0.35), Color(0.3, 0.22, 0.14), 2.0)   # rope, dark under light
		draw_line(stake + Vector2(0, -6), Vector2(0, -ch * 0.35 - 1.0), Color(0.62, 0.5, 0.32), 1.0)
		var st := _stake_tex()
		if st != null:
			draw_texture(st, stake + Vector2(-3, -11))
	if _sheet == null:
		draw_rect(Rect2(-cw * 0.4, -ch * 0.7, cw * 0.8, ch * 0.7), Color(0.6, 0.5, 0.4))
		return
	var lift := -absf(sin(PI * clampf(_hop_t / 0.4, 0.0, 1.0))) * 4.0 if state == S.HOP else 0.0
	if face_right:
		draw_set_transform(Vector2(0, lift), 0.0, Vector2(-1, 1))
	else:
		draw_set_transform(Vector2(0, lift), 0.0, Vector2(1, 1))
	var src := Rect2(_col() * cw, row * ch, cw, ch)
	draw_texture_rect_region(_sheet, Rect2(-cw * 0.5, -(ch - 1), cw, ch), src)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
