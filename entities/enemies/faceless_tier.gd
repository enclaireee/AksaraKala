class_name FacelessTier extends Node
## Scales its parent Faceless by the zone it spawns in (bestiary.md Story v2, balance.md 6.2). Add as the LAST child,
## so Health has already run _ready. Zone found by the `zone_id` of an ancestor (Zones.current_zone is set late).
## ponytail: the archer's arrow keeps its scene damage (shooter.gd owns it); HP and Ilmu still scale.

const HP := [1.0, 1.3, 1.6, 1.6, 2.2]       # tiers 0-4, balance.md 6.2
const DMG := [1.0, 1.15, 1.3, 1.3, 1.6]
const ILMU := [1.0, 1.5, 2.25, 2.25, 5.1]
const PREFIX := {"desa_": 0, "ts_": 0, "kg_": 1, "mt_": 1, "tt_": 2, "sk_": 3, "gk_": 4}

var tier := 0


func _ready() -> void:
	var e := get_parent() as EnemyBase
	var h: Health = e.get_node("Health")   # the parent's @onready vars are not set yet
	var hb: Hitbox = e.get_node("Aim/Hitbox")
	var id := ""
	var n: Node = e.get_parent()
	while n != null and id == "":
		id = str(n.get("zone_id")) if n.get("zone_id") != null else ""
		n = n.get_parent()
	if id == "":
		id = get_node("/root/Zones").current_zone
	for p: String in PREFIX:
		if id.begins_with(p):
			tier = PREFIX[p]
	h.max_hp = roundi(h.max_hp * HP[tier])
	h.hp = h.max_hp
	hb.damage = roundi(hb.damage * DMG[tier])
	e.ilmu = roundi(e.ilmu * ILMU[tier])
