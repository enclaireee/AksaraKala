class_name WeweGombel extends Chaser
## SQ-M2 elite: slow wide swing (scene tuning) plus a grab that pulls the player in.
## The grab is telegraphed (red line, she stops and cannot turn) and dodgeable: i-frames or leaving the line.
## Stats are the balance.md Wewe Gombel row. Inert until quest sq_m2 is at step 2.

const GRAB_WINDUP := 0.8      # TUNE
const GRAB_MIN := 40.0        # TUNE: closer than this she swings instead
const GRAB_RANGE := 110.0     # TUNE
const GRAB_WIDTH := 14.0      # TUNE: half width of the line
const GRAB_COOLDOWN := 4.0    # TUNE
const LANE_TILE := "res://assets/art/fx/lane_tile.png"
const PULL_STOP := 22.0       # the player lands this far from her

var active := true
var grabbing := false
var grab_time := 0.0
var grab_cd := 2.0
var line: Line2D


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	line = Line2D.new()
	line.width = GRAB_WIDTH * 2.0
	line.default_color = Color(1, 1, 1, 0.45)
	line.antialiased = false
	if ResourceLoader.exists(LANE_TILE):   # art pass v8: stepped hatched lane, tiled along the line
		line.texture = load(LANE_TILE)
		line.texture_mode = Line2D.LINE_TEXTURE_TILE
		line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.points = PackedVector2Array([Vector2.ZERO, Vector2(GRAB_RANGE, 0)])
	line.visible = false
	aim.add_child(line)
	var g := EliteGuard.new()
	g.cond = "step:sq_m2=2"
	add_child(g)


func _tick(delta: float) -> void:
	grab_cd -= delta
	if grabbing:
		grab_time += delta
		velocity = Vector2.ZERO
		if grab_time >= GRAB_WINDUP:
			_grab()
		return
	if state == State.CHASE and grab_cd <= 0.0 and target != null:
		var d := global_position.distance_to(target.global_position)
		if d >= GRAB_MIN and d <= GRAB_RANGE:
			grabbing = true
			grab_time = 0.0
			release_token()
			facing = (target.global_position - global_position).angle()
			aim.rotation = facing
			body.modulate = TELEGRAPH
			line.visible = true
			return
	super(delta)


func _end_grab() -> void:
	if grabbing:
		grabbing = false
		line.visible = false
		body.modulate = Color.WHITE
	grab_cd = GRAB_COOLDOWN


func _grab() -> void:
	_end_grab()
	var rel := target.global_position - global_position
	var along := rel.dot(Vector2.from_angle(facing))
	var across := absf(rel.cross(Vector2.from_angle(facing)))
	var hp: Variant = target.get("health")
	var dodged: bool = hp != null and (hp as Health).is_invincible()
	if along > 0.0 and along <= GRAB_RANGE and across <= GRAB_WIDTH and not dodged:
		var pull := -rel.normalized() * maxf(0.0, rel.length() - PULL_STOP)
		if target is CharacterBody2D:
			(target as CharacterBody2D).move_and_collide(pull)
		else:
			target.global_position += pull
	_enter(State.RECOVER)


func _on_stagger(seconds: float) -> void:
	_end_grab()
	super(seconds)


func _on_died() -> void:
	_end_grab()
	super()
