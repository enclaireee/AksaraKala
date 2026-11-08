extends Node2D
## Jawa Ha: restore 30% max HP now and another 20% over 5 s, and cleanse Curse, Burn and Slow (spells.md 3).
## Hulubalang turns 12% into a shield, Pamanah refills stamina, Pendekar is untouchable for a moment,
## Wiku heals 1.2x.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var _t := 0.0
var _regen_total := 0
var _paid := 0
const REGEN_SHARE := 0.20   # TUNE: of max HP, over TICKS seconds
const TICKS := 5
const SHIELD_SHARE := 0.12  # TUNE: Hulubalang


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	for r in get_tree().get_nodes_in_group("regen"):
		if r != self:
			r.queue_free()   # a new heal replaces the old regen
	add_to_group("regen")
	var h: Health = caster.health
	var cls := SpellUtil.class_id(caster)
	var k := power * SpellUtil.spirit(caster) * (1.2 if cls == "mage" else 1.0)
	h.heal(roundi(h.max_hp * data.power / 100.0 * k))   # data.power is a percent
	_regen_total = roundi(h.max_hp * REGEN_SHARE * k)
	if caster.get("status") != null:
		for t in [Status.Type.CURSE, Status.Type.BURN, Status.Type.SLOW]:
			caster.status.clear(t)
	match cls:
		"warrior":
			h.shield += roundi(h.max_hp * SHIELD_SHARE * k)
		"archer":
			if caster.get("stamina") != null:
				var st = caster.stamina
				st.value = st.max_stamina
				st.changed.emit(st.value, st.max_stamina)
		"rogue":
			h.set_invincible(1.0)
	global_position = caster.global_position
	var tint := SpellUtil.tint(data.glyph_id, caster)
	var rise := SpellFX.make("heal_rise", 8, 8.0)
	if rise:
		rise.loop = true
		rise.life = float(TICKS)
		rise.fade = 0.6
		rise.modulate = tint
		rise.position = Vector2(0, -16)
		add_child(rise)
	SpellFX.burst(get_parent(), "shock", 6, global_position, Color(tint, 0.7), 0.3, 14.0)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(caster) or caster.health.is_dead():
		queue_free()
		return
	global_position = caster.global_position
	_t += delta
	var due := mini(TICKS, int(_t))
	var owed := _regen_total * due / TICKS - _paid
	if owed > 0:
		_paid += owed
		caster.health.heal(owed)
	if _t >= TICKS:
		queue_free()
