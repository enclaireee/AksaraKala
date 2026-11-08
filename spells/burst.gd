extends Hitbox
## Sunda Ca base spell: a shockwave around the caster that hits everything in radius once and shoves it back
## (spells.md 3). Class versions are other spells (spells/spell_variants.gd); this script is also the blast
## they use for explosions: `flat` scales by Spirit only, `poise_scale` and `knock` shape the shove.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var flat := false
var poise_scale := 1.0
var knock := 18.0
var _t := 0.0
var _radius := 0.0
const LIFE := 0.3          # ASSUMED: the hit window


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	var dmg_mult := SpellUtil.spirit(caster) if flat else SpellUtil.damage(caster)
	damage = roundi(data.power * power * dmg_mult)
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult * poise_scale
	knockback = knock   # px of push (Hitbox default is 6)
	_radius = data.radius * SpellUtil.radius_mult(data)   # Tell Ciung +10%
	var cs := CircleShape2D.new()   # own shape: the scene's is shared between instances
	cs.radius = _radius
	$Shape.shape = cs
	super()
	activate()
	var tint := SpellUtil.tint(data.glyph_id, caster)
	var wave := SpellFX.make("shock", 6, 6.0 / LIFE)
	if wave:
		wave.modulate = Color(tint, 0.95)
		wave.scale = Vector2.ONE * _radius / 60.0
		add_child(wave)


func _physics_process(delta: float) -> void:
	_t += delta
	if _t >= LIFE:
		queue_free()
