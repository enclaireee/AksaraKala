class_name Bolt extends Arrow
## Sunda Ka: a straight sky-blue bolt (spells.md 3). Reuses Arrow flight and wall check.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var power := 1.0
var _side := false   # a fan arrow: does not fan again
const FAN := 0.26    # rad, about 15 degrees (ASSUMED)   # damage multiplier (0.7 for a rough cast)


func _ready() -> void:
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	speed = 260.0       # ASSUMED
	max_range = 220.0   # ASSUMED
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	if SpellUtil.class_id(caster) == "archer":   # Eagle Eye: pierces; spells.md class modifiers: 3-arrow fan
		pierce = true
		if not _side:
			for a in [-FAN, FAN]:
				var s: Bolt = data.scene.instantiate()
				s._side = true
				s.caster = caster
				s.data = data
				s.power = power * 0.6   # ASSUMED: side arrows deal 60%
				s.direction = direction.rotated(a)
				s.global_position = global_position
				get_parent().add_child.call_deferred(s)
	super()
