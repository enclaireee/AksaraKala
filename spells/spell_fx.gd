class_name SpellFX extends RefCounted
## Spawns spell FX strips (SpellAnim) and holds the glyph element colours. Missing art is skipped, never an error.

const DIR := "res://assets/art/fx/spells/%s.png"
static var _cache := {}


static func tex(name: String) -> Texture2D:
	if not _cache.has(name):
		var p := DIR % name
		_cache[name] = load(p) if ResourceLoader.exists(p) else null
	return _cache[name]


## A strip sprite, not yet in the tree; null when the art is missing.
static func make(name: String, frames: int, fps := 14.0) -> SpellAnim:
	var t := tex(name)
	if t == null:
		return null
	var s := SpellAnim.new()
	s.texture = t
	s.hframes = frames
	s.fps = fps
	s.z_index = 8
	return s


## One-shot at a world position. Returns the sprite (or null) so the caller can rotate or scale it.
static func burst(parent: Node, name: String, frames: int, pos: Vector2, tint := Color.WHITE, size := 1.0, fps := 14.0) -> SpellAnim:
	if parent == null or not parent.is_inside_tree():
		return null
	var s := make(name, frames, fps)
	if s == null:
		return null
	s.modulate = tint
	s.scale = Vector2.ONE * size
	parent.add_child(s)
	s.global_position = pos
	return s
