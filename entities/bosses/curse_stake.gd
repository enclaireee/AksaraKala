class_name CurseStake extends Node2D
## Curse stake (bestiary.md Keris Gandring). Unlit, then a 1 s red mark, then lit. Any glyph cast within 40 px puts a lit stake out;
## Jawa Ha puts out every lit stake within 80 px. The Keris lights and counts stakes. A practice stake is always lit and relights after 2 s.

enum State { UNLIT, MARK, LIT }

const UNLIT_COLOR := Color(0.35, 0.3, 0.3)
const MARK_COLOR := Color(0.8, 0.45, 0.4)
const LIT_COLOR := Color(1.0, 0.15, 0.1)

@export var stake_id := 1
@export var practice := false
@export var cleanse_range := 40.0   # spec
@export var ha_range := 80.0        # spec
@export var mark_time := 1.0        # spec
@export var relight_time := 2.0     # spec, practice

var state := State.UNLIT
var _left := 0.0
var _body: Polygon2D


func _ready() -> void:
	add_to_group("curse_stake")
	_body = Polygon2D.new()
	_body.polygon = PackedVector2Array([-3, -18, 3, -18, 4, 0, -4, 0])
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


func _on_cast(glyph_id: String, _score: float) -> void:
	if state != State.LIT:
		return
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p == null:
		return
	var d := global_position.distance_to(p.global_position)
	if d <= cleanse_range or (glyph_id == "jawa_ha" and d <= ha_range):
		put_out()


func _paint() -> void:
	_body.color = [UNLIT_COLOR, MARK_COLOR, LIT_COLOR][state]
