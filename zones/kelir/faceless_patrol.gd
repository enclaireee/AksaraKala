class_name FacelessPatrol extends MemoryThreat
## A Faceless in a Laras chapter (architecture.md 9b): walks its path, sees Laras inside its cone unless she is by
## a `hide` prop, and then fails the chapter. freeze() (Laras saying its true name) stops it for a while.
## ponytail: no wall line of sight; add a ray cast when a chapter map needs walls between Laras and a cone.

const SIGHT := 72.0       # TUNE: px
const CONE := 90.0        # TUNE: degrees
const HIDE_RANGE := 10.0  # TUNE: px from a node in group "hide"

var facing := Vector2.DOWN
var _frozen := 0.0


func _ready() -> void:
	super()
	add_to_group("faceless")


func freeze(seconds := 3.0) -> void:
	_frozen = maxf(_frozen, seconds)


func frozen() -> bool:
	return _frozen > 0.0


func active() -> bool:
	return not frozen()


func _physics_process(delta: float) -> void:
	_frozen = maxf(0.0, _frozen - delta)
	var was := global_position
	super(delta)
	if global_position.distance_squared_to(was) > 0.0001:
		facing = (global_position - was).normalized()
	if active() and sees():
		touch()


func sees() -> bool:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p == null:
		return false
	var v := p.global_position - global_position
	if v.length() > SIGHT or (v.length() > 0.5 and absf(rad_to_deg(facing.angle_to(v))) > CONE / 2.0):
		return false
	for h in get_tree().get_nodes_in_group("hide"):
		if h is Node2D and h.global_position.distance_to(p.global_position) <= HIDE_RANGE:
			return false
	return true
