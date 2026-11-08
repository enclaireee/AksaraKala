extends Node2D
## Jawa Ca: for 12 s +35% attack speed, doubled stamina regen, and a class edge (spells.md 3):
## Hulubalang takes 20% less damage, Pamanah is faster and attacks even quicker, Pendekar dodges for half
## the stamina, Wiku gains Sakti 1.5x faster. A little stamina comes back at once.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var _left := 0.0
var _on := false
const ATK := 1.35
const ARCHER_ATK := 1.5
const REGEN := 2.0
const REFUND := 40.0       # TUNE: stamina back at once
const WARRIOR_GUARD := 0.2 # damage taken less
const ARCHER_MOVE := 1.2
const ROGUE_DODGE := 0.5   # dodge stamina cost multiplier
const MAGE_SAKTI := 1.5


func _ready() -> void:
	for r in get_tree().get_nodes_in_group("rally"):
		if r != self:
			r.end()   # undo now, not at queue_free: the buffs multiply
			r.queue_free()
	add_to_group("rally")
	_on = true
	_left = data.duration * SpellUtil.perfect_mult(perfect)   # a Perfect cast lasts longer
	_boost()
	var st = caster.get("stamina")
	if st != null:
		st.value = minf(st.max_stamina, st.value + REFUND)
		st.changed.emit(st.value, st.max_stamina)
	# Every Game.changed (a kill's Ilmu, an equip) recomputes the player's stats, so boost again after it.
	# The player connected first, so its apply_from_game() runs before this.
	if caster.has_method("apply_from_game"):
		get_node("/root/Game").changed.connect(_boost)
	var tint := SpellUtil.tint(data.glyph_id, caster)
	var aura := SpellFX.make("rally_aura", 6, 10.0)
	if aura:
		aura.loop = true
		aura.life = _left
		aura.fade = 1.0
		aura.modulate = tint
		aura.position = Vector2(0, 2)
		aura.z_index = -1
		add_child(aura)
	SpellFX.burst(get_parent(), "shock", 6, caster.global_position, Color(tint, 0.8), 0.45, 14.0)


func _boost() -> void:
	var cls := SpellUtil.class_id(caster)
	caster.atk_speed *= ARCHER_ATK if cls == "archer" else ATK
	caster.stamina.regen *= REGEN
	if not caster.has_method("apply_from_game"):
		return   # test dummies: only the two stats above are undone
	match cls:
		"warrior": caster.health.reduction = 1.0 - (1.0 - caster.health.reduction) * (1.0 - WARRIOR_GUARD)
		"archer": caster.move_mult *= ARCHER_MOVE
		"rogue": caster.dodge_cost *= ROGUE_DODGE
		"mage": caster.sakti.gain_mult *= MAGE_SAKTI


## Undo by recomputing, never by dividing: dividing after a recompute would leave the stats low for good.
func end() -> void:
	if not _on:
		return
	_on = false
	var game := get_node("/root/Game")
	if game.changed.is_connected(_boost):
		game.changed.disconnect(_boost)
	if is_instance_valid(caster):
		if caster.has_method("apply_from_game"):
			caster.apply_from_game()
		else:
			var cls := SpellUtil.class_id(caster)
			caster.atk_speed /= ARCHER_ATK if cls == "archer" else ATK   # test dummies with no recompute
			caster.stamina.regen /= REGEN


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0 or not is_instance_valid(caster):
		queue_free()
		return
	global_position = caster.global_position


func _exit_tree() -> void:
	end()
