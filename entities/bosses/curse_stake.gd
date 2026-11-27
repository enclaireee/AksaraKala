class_name CurseStake extends Node2D
## Curse stake (bestiary.md Keris Gandring, boss revamp v9). Unlit, then a 1 s red mark, then lit. The Keris lights the stakes in
## stake_id order and clears the whole clock itself when Jawa Ha lands (keris_gandring.gd), so a boss stake ignores casts.
## A practice stake is always lit, goes out on any glyph within 40 px (Jawa Ha: 80) and relights after 2 s.

enum State { UNLIT, MARK, LIT }


@export var stake_id := 1
@export var practice := false
@export var cleanse_range := 40.0   # spec
@export var ha_range := 80.0        # spec
@export var mark_time := 1.0        # spec
@export var relight_time := 2.0     # spec, practice

var state := State.UNLIT
var _left := 0.0
var charge := 0.0      # 0..1, set by the Keris on the next stake of the clock: it reddens as its turn nears
var _body: Sprite2D   # props/curse_stake.png: 0 unlit, 1 marked, 2 lit


func _ready() -> void:
	add_to_group("curse_stake")
	_body = Sprite2D.new()
	_body.texture = load("res://assets/art/props/curse_stake.png")
	_body.hframes = 3
	_body.centered = false
	_body.offset = Vector2(-6, -23)
	add_child(_body)
	if practice:
		state = State.LIT
	_paint()
	get_node("/root/Events").spell_cast.connect(_on_cast)


func is_lit() -> bool:
	return state == State.LIT


## The Keris starts the mark; it becomes lit after mark_time.
func start_mark() -> void:
	if state == State.UNLIT:
		state = State.MARK
		_left = mark_time
		_paint()


func put_out() -> void:
	if state != State.LIT:
		return
	state = State.UNLIT
	if practice:
		_left = relight_time
		get_node("/root/Events").area_entered.emit("timur_praktik_mark")
	_paint()


func tick(delta: float) -> void:
	if state == State.LIT or (state == State.UNLIT and not practice):
		return
	_left -= delta
	if _left <= 0.0:
		state = State.LIT
		_paint()


func _physics_process(delta: float) -> void:
	tick(delta)
	_paint()   # the countdown colour follows charge


func _on_cast(glyph_id: String, _score: float) -> void:
	if not practice or state != State.LIT:
		return
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p == null:
		return
	var d := global_position.distance_to(p.global_position)
	if d <= cleanse_range or (glyph_id == "jawa_ha" and d <= ha_range):
		put_out()


func _paint() -> void:
	_body.frame = state
	_body.modulate = Color(1.0, 1.0 - 0.5 * charge, 1.0 - 0.5 * charge)
