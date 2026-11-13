class_name SpellFX extends RefCounted
## Spawns spell FX strips (SpellAnim) and holds the glyph element colours. Missing art is skipped, never an error.

const DIR := "res://assets/art/fx/spells/%s.png"
static var _cache := {}


## The picked class id ("" before one is picked or when the autoload is missing).
static func _cls() -> String:
	var ml := Engine.get_main_loop() as SceneTree
	var g := ml.root.get_node_or_null("Game") if ml else null
	return str(g.class_id) if g else ""


## The player's class variant (`name_<class>`, colours baked in) when `classed` and one exists, else the neutral strip.
static func tex(name: String, classed := true) -> Texture2D:
	var cls := _cls() if classed else ""
	var key := "%s|%s" % [name, cls]
	if not _cache.has(key):
		var p := DIR % ("%s_%s" % [name, cls] if cls != "" else name)
		if cls == "" or not ResourceLoader.exists(p):
			p = DIR % name
		_cache[key] = load(p) if ResourceLoader.exists(p) else null
	return _cache[key]


## True when tex() would return the baked class variant (so the per-glyph tint must be skipped).
static func is_classed(name: String, classed := true) -> bool:
	var cls := _cls()
	return classed and cls != "" and ResourceLoader.exists(DIR % ("%s_%s" % [name, cls]))


## Modulate for a strip: white (keeping the alpha) when its baked class variant is used, else the glyph tint.
static func tint_for(name: String, tint: Color) -> Color:
	return Color(1, 1, 1, tint.a) if is_classed(name) else tint


## A strip sprite, not yet in the tree; null when the art is missing.
static func make(name: String, frames: int, fps := 14.0, classed := true) -> SpellAnim:
	var t := tex(name, classed)
	if t == null:
		return null
	var s := SpellAnim.new()
	s.texture = t
	s.hframes = frames
	s.fps = fps
	s.z_index = 8
	return s


## One-shot at a world position. Returns the sprite (or null) so the caller can rotate or scale it.
static func burst(parent: Node, name: String, frames: int, pos: Vector2, tint := Color.WHITE, size := 1.0, fps := 14.0, classed := true) -> SpellAnim:
	if parent == null or not parent.is_inside_tree():
		return null
	var s := make(name, frames, fps, classed)
	if s == null:
		return null
	s.modulate = Color(1, 1, 1, tint.a) if is_classed(name, classed) else tint   # baked class colour: keep only the alpha
	s.scale = Vector2.ONE * size
	parent.add_child(s)
	s.global_position = pos
	return s
