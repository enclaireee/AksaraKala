extends Node2D
## Jawa Ha (spells.md 3). Base: 30% max HP now and 20% more over 5 s, and it cleanses Curse, Burn and Slow.
## Each class casts something else: Hulubalang turns it into a big shield (Doa Penjaga), Pamanah a small
## heal with full stamina and a burst of speed (Angin Segar), Pendekar a quick heal while untouchable
## (Napas Bayangan), Wiku a healing spring you stand in (Mata Air Batin).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var _t := 0.0
var _regen_total := 0
var _paid := 0
var _period := 1.0
var _ticks := 5
var _life := 5.0
var _wind := false
var _tint := Color.WHITE
const REGEN_SHARE := 0.20    # TUNE: of max HP, base spell
const GUARD_SHIELD := 0.55   # TUNE: Hulubalang, of max HP
const WIND_HEAL := 0.25      # TUNE: Pamanah
const WIND_SPEED := 1.3
const WIND_TIME := 6.0
const SHADOW_HEAL := 0.35    # TUNE: Pendekar, over 1.5 s while invincible
const SPRING_TICK := 0.07    # TUNE: Wiku, of max HP per second inside the spring


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	for r in get_tree().get_nodes_in_group("regen"):
		if r != self:
			r.end()
			r.queue_free()   # a new heal replaces the old regen or wind
	add_to_group("regen")
	var h: Health = caster.health
	var cls := SpellUtil.class_id(caster)
	var k := power * SpellUtil.spirit(caster)
	_tint = SpellUtil.tint(data.glyph_id, caster)
	if caster.get("status") != null:
		for t in [Status.Type.CURSE, Status.Type.BURN, Status.Type.SLOW]:
			caster.status.clear(t)
	global_position = caster.global_position
	match cls:
		"warrior":
			h.shield += roundi(h.max_hp * GUARD_SHIELD * k)
			_life = 0.0
		"archer":
			h.heal(roundi(h.max_hp * WIND_HEAL * k))
			var st = caster.get("stamina")
			if st != null:
				st.value = st.max_stamina
				st.changed.emit(st.value, st.max_stamina)
			_life = WIND_TIME
			if caster.has_method("apply_from_game"):   # test dummies have no move_mult to boost
				_wind = true
				_boost()
				get_node("/root/Game").changed.connect(_boost)
		"rogue":
			h.set_invincible(1.5)
			_regen_total = roundi(h.max_hp * SHADOW_HEAL * k)
			_period = 0.25
			_ticks = 6
			_life = 1.5
		"mage":
			var z := SpellZone.new()
			z.caster = caster
			z.tint = _tint
			z.global_position = caster.global_position
			z.radius = 52.0
			z.life = 6.0
			z.tick = 1.0
			z.heal_self = SPRING_TICK * k
			z.slow = 0.6
			get_parent().add_child.call_deferred(z)
			h.heal(roundi(h.max_hp * 0.1 * k))
			_life = 0.0
		_:
			h.heal(roundi(h.max_hp * data.power / 100.0 * k))   # data.power is a percent
			_regen_total = roundi(h.max_hp * REGEN_SHARE * k)
	var rise := SpellFX.make("heal_rise", 8, 8.0)
	if rise:
		rise.loop = true
		rise.life = maxf(_life, 1.0)
		rise.fade = 0.6
		rise.modulate = SpellFX.tint_for("heal_rise", _tint)
		rise.position = Vector2(0, -16)
		add_child(rise)
	SpellFX.burst(get_parent(), "shock", 6, global_position, Color(_tint, 0.7), 0.3, 14.0)
	if _life <= 0.0:
		get_tree().create_timer(1.0).timeout.connect(queue_free)   # let the rising leaves play


func _boost() -> void:
	if _wind:
		caster.move_mult *= WIND_SPEED


## Undo by recomputing, never by dividing (see Rally).
func end() -> void:
	if not _wind:
		return
	_wind = false
	var game := get_node("/root/Game")
	if game.changed.is_connected(_boost):
		game.changed.disconnect(_boost)
	if is_instance_valid(caster) and caster.has_method("apply_from_game"):
		caster.apply_from_game()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(caster) or caster.health.is_dead():
		queue_free()
		return
	global_position = caster.global_position
	_t += delta
	if _regen_total > 0:
		var due := mini(_ticks, int(_t / _period))
		var owed := _regen_total * due / _ticks - _paid
		if owed > 0:
			_paid += owed
			caster.health.heal(owed)
	if _life > 0.0 and _t >= _life:
		queue_free()


func _exit_tree() -> void:
	end()
