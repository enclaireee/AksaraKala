class_name Genderuwo extends Chaser
## Mataram tank: big melee plus a thrown rock. Holds the rock overhead for the wind-up (telegraph).
## Weakness Ka Bolt: a Bolt hitting during the wind-up shatters the rock on its head: rock damage plus a 1.5 s stagger.
## ponytail: the throw skips attack tokens (one tank per room).

const ROCK := preload("res://entities/enemies/thrown_rock.tscn")
const ROCK_ART := preload("res://assets/art/fx/thrown_rock.png")
const ROCK_DAMAGE := 12   # TUNE: keep equal to thrown_rock.tscn
const THROW_WINDUP := 0.8   # TUNE
const THROW_MIN := 90.0     # TUNE: closer than this it swings instead
const THROW_MAX := 150.0
const THROW_COOLDOWN := 3.5
const SHATTER_STAGGER := 1.5   # TUNE

var throwing := false
var throw_time := 0.0
var cooldown := 1.5
var rock: Sprite2D


func _ready() -> void:
	super()
	rock = Sprite2D.new()   # art pass v8: the thrown rock's own art (2 frames of 10x10)
	rock.texture = ROCK_ART
	rock.hframes = 2
	rock.position = Vector2(0, -26)
	rock.visible = false
	add_child(rock)


func _tick(delta: float) -> void:
	cooldown -= delta
	if throwing:
		throw_time += delta
		velocity = Vector2.ZERO
		if throw_time >= THROW_WINDUP:
			_throw()
		return
	if state == State.CHASE and cooldown <= 0.0 and target != null:
		var d := global_position.distance_to(target.global_position)
		if d >= THROW_MIN and d <= THROW_MAX and _on_screen():
			throwing = true
			throw_time = 0.0
			release_token()
			facing = (target.global_position - global_position).angle()
			aim.rotation = facing
			body.modulate = TELEGRAPH
			rock.visible = true
			return
	super(delta)


func _end_throw() -> void:
	if throwing:
		throwing = false
		rock.visible = false
		body.modulate = Color.WHITE
	cooldown = THROW_COOLDOWN


func _throw() -> void:
	var shot := ROCK.instantiate() as Arrow
	shot.source = self
	shot.direction = Vector2.from_angle(facing)
	shot.speed = tuning.shot_speed
	shot.max_range = tuning.shot_range
	get_parent().add_child(shot)
	shot.global_position = aim.global_position
	_end_throw()
	_enter(State.RECOVER)


func _on_hurt(hitbox: Hitbox) -> void:
	var weak := throwing and hitbox is Bolt
	super(hitbox)
	if weak and not health.is_dead():
		_end_throw()
		health.take_damage(ROCK_DAMAGE, hitbox.source, true)
		get_node("/root/Events").weakness_triggered.emit(kind)
		if not health.is_dead():
			stagger_time = SHATTER_STAGGER
			_enter(State.STAGGER)


func _on_stagger(seconds: float) -> void:
	_end_throw()
	super(seconds)


func _on_died() -> void:
	_end_throw()
	super()
