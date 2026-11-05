extends Interactable
## Shortcut gate (world.md World structure): blocks one tile until opened from open_side, then stays
## open for good through the flag `id` (e.g. "sc:ts_pagar"). Gates sharing an id open together.
## From the wrong side the prompt says it does not open from here.

@export var id := ""
@export var open_side := "w"   # n, s, e or w: the side the player must stand on

const DIRS := {"n": Vector2.UP, "s": Vector2.DOWN, "e": Vector2.RIGHT, "w": Vector2.LEFT}


func _ready() -> void:
	verb = "UI_VERB_OPEN"
	super()
	_prompt.position = Vector2(-60, -30)
	_prompt.size = Vector2(120, 12)
	var game := get_node("/root/Game")
	if game.has_flag(id):
		queue_free()
		return
	game.changed.connect(_on_changed)


func _draw() -> void:
	for i in 4:   # placeholder bamboo bars
		draw_rect(Rect2(-7 + i * 4, -8, 2, 16), Color(0.55, 0.6, 0.25))
	draw_rect(Rect2(-8, -3, 16, 2), Color(0.4, 0.3, 0.15))


## True when `pos` is on the open side of this gate.
func from_open_side(pos: Vector2) -> bool:
	return (pos - global_position).dot(DIRS.get(open_side, Vector2.ZERO)) > 0.0


func _player_pos() -> Vector2:
	var pl := get_tree().get_first_node_in_group("player") as Node2D
	return pl.global_position if pl else global_position


func _refresh_prompt() -> void:
	super()
	if not from_open_side(_player_pos()):
		_prompt.text = tr("UI_SC_LOCKED")


func interact() -> void:
	if from_open_side(_player_pos()):
		get_node("/root/Game").set_flag(id)   # saves; _on_changed frees every gate with this id


func _on_changed() -> void:
	if get_node("/root/Game").has_flag(id):
		queue_free()
