class_name Banaspati extends Chaser
## Zone 3 chaser: its hit and its ground trail apply Burn. Weakness Ga Ward (bestiary.md): a hit that lands while
## Ward is up snuffs it for SNUFF_TIME: no Burn, no trail, x1.5 damage taken.

const SNUFF_TIME := 3.0       # TUNE
const SNUFF_MULT := 1.5       # TUNE
const SNUFF_TINT := Color(0.5, 0.6, 0.9)
const TRAIL_GAP := 0.3        # TUNE: seconds between fire patches
const EMBER := preload("res://assets/art/fx/spells/ember.png")
const TRAIL_RADIUS := 9.0     # TUNE

var trail_life := 3.0         # TUNE: the elite doubles it
var snuffed := 0.0
var patches: Array[Sprite2D] = []
var _gap := 0.0


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	attack_hitbox.hit_landed.connect(func(hb: Hurtbox) -> void: _on_landed(hb.owner))


func _on_landed(victim: Node) -> void:
	if snuffed <= 0.0 and not get_tree().get_nodes_in_group("ward").is_empty():
		snuffed = SNUFF_TIME
		body.modulate = SNUFF_TINT
		get_node("/root/Events").weakness_triggered.emit(kind)
	_burn(victim, attack_hitbox.damage)


func _burn(victim: Node, dmg: int) -> void:
	var st: Variant = victim.get("status") if victim != null else null
	if snuffed <= 0.0 and st is Status:
		(st as Status).apply(Status.Type.BURN, -1.0, dmg)


func _tick(delta: float) -> void:
	if snuffed > 0.0:
		snuffed -= delta
		if snuffed <= 0.0:
			body.modulate = Color.WHITE
	_gap -= delta
	if snuffed <= 0.0 and _gap <= 0.0 and velocity != Vector2.ZERO:
		_gap = TRAIL_GAP
		var p := Sprite2D.new()   # art pass v8: ember strip (4 frames of 8x8) instead of a flat polygon
		p.texture = EMBER
		p.hframes = 4
		p.scale = Vector2(1.5, 1.5)
		p.modulate = Color(1, 0.55, 0.2, 0.85)
		p.set_meta("left", trail_life)
		get_parent().add_child(p)
		p.global_position = global_position
		patches.append(p)
	for p in patches.duplicate():
		var left: float = p.get_meta("left") - delta
		p.set_meta("left", left)
		p.frame = int(left * 8.0) % 4
		if left <= 0.0:
			patches.erase(p)
			p.queue_free()
		elif snuffed <= 0.0 and target != null and p.global_position.distance_to(target.global_position) <= TRAIL_RADIUS:
			var st: Variant = target.get("status")
			if st is Status and not (st as Status).has(Status.Type.BURN):   # re-applying every frame would reset the ticks
				(st as Status).apply(Status.Type.BURN, -1.0, attack_hitbox.damage)
	super(delta)


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if snuffed > 0.0 and not health.is_dead():
		health.take_damage(roundi(hitbox.damage * (SNUFF_MULT - 1.0)), hitbox.source, true)


func _on_died() -> void:
	super()
	for p in patches:
		p.queue_free()
	patches.clear()
