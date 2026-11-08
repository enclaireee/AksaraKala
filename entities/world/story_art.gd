class_name StoryArt extends RefCounted
## Sprites for examinable story objects, so no objective sits on empty floor (tools/gen_story_props.py).
## assets/art/story/<id>.png where id is a clue_id, codex_id, item_id or trigger_id; items without story art
## fall back to their inventory icon in assets/art/items/. Returns null when there is no art.

const DIR := "res://assets/art/story/%s.png"
const ITEM := "res://assets/art/items/%s.png"
static var _cache: Dictionary = {}


static func tex(id: String, use_item_icon := false) -> Texture2D:
	if id == "":
		return null
	var key := id + ("#i" if use_item_icon else "")
	if not _cache.has(key):
		var t: Texture2D = null
		if ResourceLoader.exists(DIR % id):
			t = load(DIR % id)
		elif use_item_icon and ResourceLoader.exists(ITEM % id):
			t = load(ITEM % id)
		_cache[key] = t if t != null else false
	var v: Variant = _cache[key]
	return v if v is Texture2D else null


## Draws `t` with its feet (bottom centre) at `foot`.
static func draw_standing(ci: CanvasItem, t: Texture2D, foot := Vector2(0, 7)) -> void:
	ci.draw_texture(t, foot - Vector2(t.get_width() * 0.5, t.get_height()))


## Draws `t` centred on the node (trigger zones).
static func draw_centered(ci: CanvasItem, t: Texture2D) -> void:
	ci.draw_texture(t, -t.get_size() * 0.5)
