extends Node2D
## Sunda Ga: a shield that soaks damage (spells.md 3). The same for every class. Broken by damage, it bursts
## and shoves nearby enemies back; running out of time gives no pulse.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var replaced := false
var _left := 0.0
var _tint := Color.WHITE
var _spr: SpellAnim
const PULSE_POWER := 22.0    # TUNE: damage of the break pulse
const PULSE_RADIUS := 56.0   # TUNE
const BURST := preload("res://spells/burst.tscn")


func _ready() -> void:
	for w in get_tree().get_nodes_in_group("ward"):
		if w != self:
			w.replaced = true
			w.queue_free()
	add_to_group("ward")
	power *= SpellUtil.perfect_mult(perfect)
	caster.health.shield = roundi(data.power * power * SpellUtil.spirit(caster))
	_left = data.duration
	global_position = caster.global_position
	_tint = SpellUtil.tint(data.glyph_id, caster)
	_spr = SpellFX.make("ward_bubble", 6, 9.0)
	if _spr:
		_spr.loop = true
		_spr.modulate = Color(_tint, 0.9)
		_spr.position = Vector2(0, -6)
		add_child(_spr)
	SpellFX.burst(get_parent(), "cast_sigil", 6, global_position, _tint, 0.8, 16.0)


func _physics_process(delta: float) -> void:
	_left -= delta
	if not is_instance_valid(caster):
		queue_free()
		return
	if caster.health.shield <= 0:
		_shatter()
		return
	if _left <= 0.0:
		queue_free()
		return
	global_position = caster.global_position
	if _spr and _left < 1.5:   # blink when about to end
		_spr.visible = int(_left * 8.0) % 2 == 0


## Broken by damage: shards fly and a pulse knocks enemies back.
func _shatter() -> void:
	var par := get_parent()
	var pos := caster.global_position
	SpellFX.burst(par, "ward_break", 5, pos + Vector2(0, -6), _tint, 1.0, 16.0)
	if _left > 0.0 and par != null and par.is_inside_tree():
		var b: Node2D = BURST.instantiate()
		b.caster = caster
		b.data = SpellUtil.sub_data("sunda_ga", PULSE_POWER, PULSE_RADIUS)
		b.flat = true
		b.power = power
		b.global_position = pos
		par.add_child.call_deferred(b)
	queue_free()


func _exit_tree() -> void:
	if is_instance_valid(caster) and not replaced:   # a room reload can free the player first
		caster.health.shield = 0
