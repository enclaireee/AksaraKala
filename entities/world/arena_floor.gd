extends Sprite2D
## Arena floor (boss revamp v9, combat.md): one painted image over a boss arena rect, from tools/gen_arena_floors.py.
## Placed by a legend char at the rect's top-left doc cell, props {art:"res://assets/art/arena/<arena>.png"}.
## When that cell is wall or cover, put the char on a floor cell (dx, dy) cells further in and add {dx:.., dy:..}.
## The image is transparent on wall and cover cells, so the tile walls still show. Gimmick fills are drawn by code.

## ponytail: Entities is y-sorted; lifting the node far up and shifting the offset back sorts it under everything.
const LIFT := 4096.0

@export var art := ""
@export var dx := 0   # cells from the rect's top-left to this node's cell
@export var dy := 0


func _ready() -> void:
	if art == "" or not ResourceLoader.exists(art):
		queue_free()
		return
	texture = load(art)
	centered = false
	var z := get_parent().get_parent() as Zone
	var tile := (z.area_scale() if z != null else Zone.SCALE) * 16.0
	offset = Vector2(-tile * (0.5 + dx), -tile * (0.5 + dy) + LIFT)
	position.y -= LIFT
