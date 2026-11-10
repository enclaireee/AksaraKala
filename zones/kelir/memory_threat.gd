class_name MemoryThreat extends Area2D
## A shadow in a Kelir memory (architecture.md 9b). Walks its child Path2D back and forth (or stands still);
## touching the stand-in calls the memory's fail().

@export var speed := 30.0   # TUNE: px/s along the path

var _curve: Curve2D
var _xf: Transform2D   # the path's global transform at _ready (the path is a child, so it moves with us)
var _t := 0.0
var _home := Vector2.ZERO


func _ready() -> void:
	_home = global_position
	_make_body()
	for c in get_children():
		if c is Path2D and c.curve and c.curve.point_count > 1:
			_curve = c.curve
			_xf = c.global_transform
	if find_children("*", "CollisionShape2D", false, false).is_empty():
		var cs := CollisionShape2D.new()
		cs.shape = CircleShape2D.new()
		cs.shape.radius = 7.0
		add_child(cs)
	body_entered.connect(func(b: Node) -> void:
		if b.is_in_group("player") and active():
			touch())
	reset()


## False while it cannot hurt (FacelessPatrol frozen).
func active() -> bool:
	return true


func _physics_process(delta: float) -> void:
	if _curve == null or not active():
		return
	var m := KelirMemory.of(self)
	if m and not m.acting():   # the curtain-up, a spoken line and a fail fade all hold the world still
		return
	_t += speed * (0.75 if m and m.fail_count() >= 3 else 1.0) * delta
	var length := _curve.get_baked_length()
	var d := fposmod(_t, 2.0 * length)
	global_position = _xf * _curve.sample_baked(2.0 * length - d if d > length else d)


func reset() -> void:
	_t = 0.0
	global_position = _xf * _curve.sample_baked(0.0) if _curve else _home


func touch() -> void:
	var m := KelirMemory.of(self)
	if m:
		m.fail()


## Replaces the scene's block with the animated shadow puppet (assets/art/cutscene/<_body_art()>.png, 4 frames of 18x30).
var _body: Sprite2D


func _body_art() -> String:
	return "shade_walker"


func _make_body() -> void:
	var old := get_node_or_null("Body")
	if old:
		old.queue_free()
	_body = Sprite2D.new()
	_body.texture = load("res://assets/art/cutscene/%s.png" % _body_art())
	_body.centered = false
	_body.region_enabled = true
	_body.offset = Vector2(-9, -30)
	_body.region_rect = Rect2(0, 0, 18, _body.texture.get_height())
	add_child(_body)


func _process(_delta: float) -> void:
	if _body == null:
		return
	var f := int(Time.get_ticks_msec() / 180.0 + _home.x) % 4
	_body.region_rect = Rect2(f * 18, 0, 18, _body.texture.get_height())
	_body.modulate = Color(0.7, 0.8, 1.0, 0.6) if not active() else Color.WHITE
