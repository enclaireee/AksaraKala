class_name AmbientBatch extends Node2D
## A static list of sprites drawn by one canvas item (fence, garden and stall tiles of one row chunk).
## The node origin is the y-sort point; items are [Texture2D, src Rect2, dst Vector2 relative to the origin].
## Also the texture cache for assets/art/ambient/<name>.png (null while the file is missing).

const DIR := "res://assets/art/ambient/%s.png"
static var _cache := {}

var items: Array = []


static func tex(art_name: String) -> Texture2D:
	if not _cache.has(art_name):
		var p := DIR % art_name
		_cache[art_name] = load(p) if ResourceLoader.exists(p) else null
	return _cache[art_name]


func add(t: Texture2D, src: Rect2, dst: Vector2) -> void:
	items.append([t, src, dst])


func _draw() -> void:
	for it: Array in items:
		var s: Rect2 = it[1]
		draw_texture_rect_region(it[0], Rect2(it[2], s.size), s)
