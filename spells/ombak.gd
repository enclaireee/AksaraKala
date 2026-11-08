class_name Ombak extends Arrow
## Jawa Ka: a wave in the aim direction that pierces, pushes enemies back and eats enemy shots (spells.md 3).

var caster: Node2D
var data: SpellData
var power := 1.0
const EAT := 14.0   # px: an enemy shot this close to the wave is destroyed (TUNE)


func _ready() -> void:
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	speed = 200.0       # TUNE
	max_range = 160.0   # TUNE
	pierce = true
	knockback = 64.0    # px of push: enemy_base flinches at knockback / enemy_flinch for enemy_flinch s (spells.md 3)
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult * SpellUtil.poise_mult(data)
	super()


func _physics_process(delta: float) -> void:
	super(delta)
	# ponytail: enemy shots aren't monitorable, so scan siblings; fine for a handful of shots on screen.
	for a in get_parent().get_children():
		if a is Arrow and a != self and a.source != caster and not a is Ombak \
				and a.global_position.distance_to(global_position) < EAT:
			a.queue_free()
