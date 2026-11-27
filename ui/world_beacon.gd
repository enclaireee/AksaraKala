class_name WorldBeacon extends Node2D
## Animated world-space target ring + bobbing diamond for Pelajaran Desa Purwa (`.docs/tutorial.md`).
## Attaches directly to an NPC, dummy, petilasan or telegraphing enemy; pulses smoothly even in slow-mo.

const META_KEY := &"_world_beacon"
const RING_PATH := "res://assets/art/ui/tut_ring.png"

var _ring: Sprite2D
var _gem: Sprite2D
var _tint := UIFx.WARM
var _gem_y := -34.0
var _ttl := -1.0
var _start_ms := 0


static func attach(target: Node2D, tint := UIFx.WARM, gem_y := -34.0, ttl := -1.0) -> WorldBeacon:
	if target == null or not is_instance_valid(target):
		return null
	clear(target)
	var b := WorldBeacon.new()
	b._tint = tint
	b._gem_y = gem_y
	b._ttl = ttl
	target.set_meta(META_KEY, b)
	target.add_child(b)
	target.move_child(b, 0)   # first child: the ring draws under the sprite but above the ground (z -1 fell under the tiles)
	return b


static func clear(target: Node2D) -> void:
	if target == null or not is_instance_valid(target) or not target.has_meta(META_KEY):
		return
	var prev: Variant = target.get_meta(META_KEY)
	if prev is Node and is_instance_valid(prev):
		(prev as Node).queue_free()
	target.remove_meta(META_KEY)


func _ready() -> void:
	_start_ms = Time.get_ticks_msec()
	_ring = Sprite2D.new()
	if ResourceLoader.exists(RING_PATH):
		_ring.texture = load(RING_PATH)
		_ring.hframes = 4
	_ring.modulate = _tint
	_ring.position = Vector2(0.0, -2.0)
	add_child(_ring)

	if _gem_y != 0.0:
		_gem = Sprite2D.new()
		_gem.texture = UIFx.tex("ink_cursor")
		_gem.z_index = 25
		_gem.modulate = _tint
		_gem.position = Vector2(0.0, _gem_y)
		add_child(_gem)


func _process(_delta: float) -> void:
	var sec := float(Time.get_ticks_msec() - _start_ms) * 0.001
	if _ttl > 0.0 and sec >= _ttl:
		queue_free()
		return
	if _ring and _ring.texture != null:
		_ring.frame = int(sec * 6.0) % 4
		_ring.modulate.a = 0.72 + 0.25 * sin(sec * 5.0)
	if _gem:
		_gem.position.y = roundf(_gem_y + sin(sec * 4.5) * 2.5)
		_gem.modulate.a = 0.75 + 0.25 * sin(sec * 5.0)
