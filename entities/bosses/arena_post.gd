class_name ArenaPost extends Interactable
## Sangkuriang's east post. Hang the boeh rarang on it; the "post:<id>" flag keeps it hung.

@export var post_id := "east"

var hung := false
var _spr: Sprite2D


func _ready() -> void:
	super()
	hung = get_node("/root/Game").has_flag("post:" + post_id)
	usable = not hung
	_sync_sprite()


func _sync_sprite() -> void:
	if _spr == null:
		_spr = Sprite2D.new()
		_spr.texture = load("res://assets/art/props/arena_post.png")   # 2 frames: bare, boeh rarang hung
		_spr.hframes = 2
		_spr.centered = false
		_spr.offset = Vector2(-1, -25)
		add_child(_spr)
	_spr.frame = 1 if hung else 0


func interact() -> void:
	var game := get_node("/root/Game")
	if hung or "boeh_rarang" not in game.inventory:
		return
	hung = true
	usable = false
	_refresh_prompt()
	game.set_flag("post:" + post_id, false)   # stays hung for the rest of the fight; the cloth is kept
	_sync_sprite()
