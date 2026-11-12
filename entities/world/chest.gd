extends Interactable
## Opens once; the "chest:<id>" flag keeps it open across saves.

@export var chest_id := ""
@export var item_id := ""

var _open := false
var _spr: Sprite2D


func _ready() -> void:
	verb = "UI_VERB_OPEN"
	super()
	_open = get_node("/root/Game").has_flag("chest:" + chest_id)
	usable = not _open
	_sync_sprite()


func _sync_sprite() -> void:
	if _spr == null:
		_spr = Sprite2D.new()
		_spr.texture = load("res://assets/art/props/chest.png")   # 2 frames: closed, open
		_spr.hframes = 2
		_spr.position = Vector2(0, -6)
		add_child(_spr)
	_spr.frame = 1 if _open else 0


func interact() -> void:
	if _open:
		return
	_open = true
	usable = false
	Snd.play("chest_open")
	_refresh_prompt()
	var game := get_node("/root/Game")
	var got := item_id   # a second path gets its sibling item (Game.add_item)
	if item_id.begins_with("ilmu:"):   # an Ilmu chest (items.md Consumables and pickups)
		game.add_ilmu(int(item_id.get_slice(":", 1)))
	else:
		got = game.add_item(item_id, false)
	game.set_flag("chest:" + chest_id, false)
	game.save_game()
	get_node("/root/Events").item_picked.emit(got)
	_sync_sprite()
